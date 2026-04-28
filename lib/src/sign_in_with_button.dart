import 'package:flutter/material.dart';

import 'colors.dart';

const _kDefaultBorderRadius = BorderRadius.all(Radius.circular(3.0));

class SignInWithButton extends StatefulWidget {
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final String assetName;
  final String text;
  final double? elevation;
  final BorderRadius? borderRadius;

  const SignInWithButton({
    super.key,
    this.onTap,
    this.padding,
    this.color,
    required this.assetName,
    required this.text,
    this.elevation,
    this.borderRadius,
  });

  factory SignInWithButton.apple({
    Color? color,
    String? text,
    VoidCallback? onTap,
    double? elevation,
    BorderRadius? borderRadius,
  }) => SignInWithButton(
    assetName: 'packages/common_flutter/assets/images/appleid_button_white.png',
    text: text ?? 'Sign in with Apple',
    color: color ?? Colors.white,
    onTap: onTap,
    elevation: elevation,
    borderRadius: borderRadius,
  );

  factory SignInWithButton.google({
    Color? color,
    String? text,
    VoidCallback? onTap,
    double? elevation,
    BorderRadius? borderRadius,
  }) => SignInWithButton(
    assetName:
        'packages/common_flutter/assets/images/btn_google_light_normal_ios.png',
    text: text ?? 'Sign in with Google',
    color: color ?? const Color.fromARGB(255, 79, 133, 233),
    onTap: onTap,
    elevation: elevation,
    borderRadius: borderRadius,
  );

  @override
  State<StatefulWidget> createState() => _SignInWithButtonState();
}

class _SignInWithButtonState extends State<SignInWithButton> {
  bool disabled = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: widget.padding ?? EdgeInsets.zero,
    child: Material(
      elevation: widget.onTap == null ? 0 : widget.elevation ?? 3.0,
      color: widget.color,
      borderRadius: widget.borderRadius ?? _kDefaultBorderRadius,
      child: Stack(
        children: [
          Ink.image(
            image: AssetImage(widget.assetName),
            alignment: Alignment.centerLeft,
            width: 250.0,
            height: 48.0,
            child: InkWell(
              onTap: widget.onTap,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(left: 48.0, right: 24.0),
                  child: Text(
                    widget.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: widget.color?.contrast,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.onTap == null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(128),
                  borderRadius: widget.borderRadius ?? _kDefaultBorderRadius,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
