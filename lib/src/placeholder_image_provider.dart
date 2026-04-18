import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A custom image provider that only occupies space without displaying anything
class PlaceholderImageProvider extends ImageProvider<PlaceholderImageProvider> {
  final double width;
  final double height;
  final Color color;

  const PlaceholderImageProvider({
    required this.width,
    required this.height,
    this.color = Colors.transparent,
  });

  @override
  int get hashCode => Object.hash(width, height, color);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaceholderImageProvider &&
        other.width == width &&
        other.height == height &&
        other.color == color;
  }

  @override
  ImageStreamCompleter loadImage(
    PlaceholderImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(codec: _loadAsync(key), scale: 1.0);
  }

  @override
  Future<PlaceholderImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PlaceholderImageProvider>(this);
  }

  Future<Codec> _loadAsync(PlaceholderImageProvider key) async {
    // Create a transparent image with the specified dimensions
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw a transparent rectangle to occupy space
    final paint = Paint()..color = key.color;
    canvas.drawRect(Rect.fromLTWH(0, 0, key.width, key.height), paint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(key.width.toInt(), key.height.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return await instantiateImageCodec(bytes);
  }
}
