import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageFetchFailure implements Exception {
  final String id;
  final String url;
  final int? statusCode;

  const ImageFetchFailure(this.id, this.url, {this.statusCode});

  @override
  String toString() {
    final status = statusCode == null ? '' : ' (HTTP $statusCode)';
    return 'Image fetch failed for $id$status';
  }
}

class _FailedImageFetch {
  final String url;
  final DateTime failedAt;
  final int? statusCode;

  const _FailedImageFetch({
    required this.url,
    required this.failedAt,
    this.statusCode,
  });
}

/// A simple disk-backed image cache utility that can be reused across apps.
///
/// Images are cached under the application's documents directory using a
/// deterministic file name derived from the provided `id`.
abstract class ImageCacheService {
  static const String _cacheDirName = 'image_cache';
  static const Duration _failedFetchCooldown = Duration(minutes: 2);
  static Directory? _cacheDir;
  static final Map<String, _FailedImageFetch> _failedFetchesById = {};
  static final Map<String, Future<File?>> _pendingDownloadsById = {};

  /// Returns an [ImageProvider] for the given image.
  ///
  /// - If the image is already cached, it is returned from disk.
  /// - Otherwise, it is downloaded, cached, and then returned.
  /// - If anything fails, falls back to [fallback] when provided, otherwise
  ///   returns a [NetworkImage] for [url].
  static Future<ImageProvider> getOrCacheImage(
    String id,
    String url, {
    ImageProvider? fallback,
  }) async {
    try {
      final cachedProvider = await getCachedImageProvider(id);
      if (cachedProvider != null) {
        _clearFetchFailure(id);
        return cachedProvider;
      }

      final recentFailure = _recentFetchFailure(id, url);
      if (recentFailure != null) {
        if (fallback != null) {
          return fallback;
        }
        throw ImageFetchFailure(id, url, statusCode: recentFailure.statusCode);
      }

      final cachedFile = await cacheImage(id, url);
      if (cachedFile != null) return FileImage(cachedFile);

      final failedFetch = _recentFetchFailure(id, url);
      if (failedFetch != null) {
        if (fallback != null) {
          return fallback;
        }
        throw ImageFetchFailure(id, url, statusCode: failedFetch.statusCode);
      }

      return NetworkImage(url);
    } on ImageFetchFailure {
      rethrow;
    } catch (_) {
      return fallback ?? NetworkImage(url);
    }
  }

  /// Downloads an image from [url] and stores it under a hashed file name
  /// computed from [id]. Returns the cached file on success, otherwise null.
  static Future<File?> cacheImage(String id, String url) async {
    try {
      await _initialize();

      final existing = await getCachedImage(id);
      if (existing != null) {
        _clearFetchFailure(id);
        return existing;
      }

      if (_recentFetchFailure(id, url) != null) {
        return null;
      }

      final pendingDownload = _pendingDownloadsById[id];
      if (pendingDownload != null) {
        return await pendingDownload;
      }

      late final Future<File?> downloadFuture;
      downloadFuture = _downloadAndCacheImage(id, url);
      _pendingDownloadsById[id] = downloadFuture;
      try {
        return await downloadFuture;
      } finally {
        if (identical(_pendingDownloadsById[id], downloadFuture)) {
          _pendingDownloadsById.remove(id);
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<File?> _downloadAndCacheImage(String id, String url) async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(url));
    } catch (_) {
      recordFetchFailure(id, url);
      return null;
    }

    if (response.statusCode != 200) {
      recordFetchFailure(id, url, statusCode: response.statusCode);
      return null;
    }

    try {
      final file = File(_getCacheFilePath(id));
      await file.writeAsBytes(response.bodyBytes);
      _clearFetchFailure(id);
      return file;
    } catch (_) {
      return null;
    }
  }

  /// Returns the cached file for [id] if it exists.
  static Future<File?> getCachedImage(String id) async {
    try {
      await _initialize();
      final file = File(_getCacheFilePath(id));
      if (await file.exists()) return file;
    } catch (_) {}
    return null;
  }

  /// Returns an [ImageProvider] for the cached image, or null if it is not
  /// present on disk.
  static Future<ImageProvider?> getCachedImageProvider(String id) async {
    final file = await getCachedImage(id);
    if (file != null) return FileImage(file);
    return null;
  }

  static void recordFetchFailure(String id, String url, {int? statusCode}) {
    _failedFetchesById[id] = _FailedImageFetch(
      url: url,
      failedAt: DateTime.now(),
      statusCode: statusCode,
    );
  }

  @visibleForTesting
  static bool hasRecentFetchFailure(String id, String url) {
    return _recentFetchFailure(id, url) != null;
  }

  @visibleForTesting
  static void resetForTesting() {
    _cacheDir = null;
    _failedFetchesById.clear();
    _pendingDownloadsById.clear();
  }

  /// Clears the entire image cache directory.
  static Future<void> clearCache() async {
    try {
      await _initialize();
      if (await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create();
      }
    } catch (_) {}
  }

  /// Evicts a single cached image by [id] from disk if present.
  static Future<void> evictCachedImage(String id) async {
    try {
      await _initialize();
      final file = File(_getCacheFilePath(id));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  /// Returns true if an image for [id] is cached on disk.
  static Future<bool> isCached(String id) async {
    try {
      await _initialize();
      final file = File(_getCacheFilePath(id));
      return await file.exists();
    } catch (_) {
      return false;
    }
  }

  /// Returns the aggregate cache size in bytes.
  static Future<int> getCacheSize() async {
    try {
      await _initialize();
      if (!await _cacheDir!.exists()) return 0;

      int totalSize = 0;
      await for (final fileEntity in _cacheDir!.list(recursive: true)) {
        if (fileEntity is File) {
          totalSize += await fileEntity.length();
        }
      }
      return totalSize;
    } catch (_) {
      return 0;
    }
  }

  /// Returns a short, human-readable representation of the cache size.
  static Future<String> getCacheSizeString() async {
    final sizeInBytes = await getCacheSize();
    if (sizeInBytes < 1024) {
      return '${sizeInBytes}B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  static Future<void> _initialize() async {
    if (_cacheDir != null) return;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/$_cacheDirName');
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
    } catch (_) {}
  }

  static String _getCacheFilePath(String id) {
    final hash = sha256.convert(Uint8List.fromList(id.codeUnits)).toString();
    return '${_cacheDir!.path}/$hash';
  }

  static void _clearFetchFailure(String id) {
    _failedFetchesById.remove(id);
  }

  static _FailedImageFetch? _recentFetchFailure(String id, String url) {
    final failure = _failedFetchesById[id];
    if (failure == null) return null;

    if (failure.url != url) {
      _failedFetchesById.remove(id);
      return null;
    }

    if (DateTime.now().difference(failure.failedAt) > _failedFetchCooldown) {
      _failedFetchesById.remove(id);
      return null;
    }

    return failure;
  }
}
