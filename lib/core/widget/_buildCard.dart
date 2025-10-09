import 'package:flutter/material.dart';

import '../../component/colors/color.dart';

/// Reusable card used across the app.
/// Matches the original styling but is configurable.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 14.0,
    this.margin = EdgeInsets.zero,
    this.boxShadow,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // backgroundColor:
    final defaultShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ];

    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.accent2 : kWhite,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? defaultShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      // Use InkWell inside Material so taps have material ripple if you want:
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: card,
        ),
      );
    }

    return card;
  }
}
