import 'package:flutter/material.dart';

class SettingsIconWidget extends StatelessWidget {
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final double opacity;

  const SettingsIconWidget({
    Key? key,
    this.iconColor,
    this.backgroundColor,
    required this.onPressed,
    this.size = 36.0,
    this.iconSize = 18.0,
    this.opacity = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // color: backgroundColor ?? Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: size,
          minHeight: size,
        ),
        icon: Icon(
          Icons.settings_outlined,
          size: iconSize,
          color: iconColor ?? Colors.black,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
