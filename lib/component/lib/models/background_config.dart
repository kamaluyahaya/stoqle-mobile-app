// lib/models/background_config.dart
import 'package:flutter/material.dart';

enum TemplateType {
  emoji,
  lined,
  quote,
  dateHeader,
  verticalStripes,
  horizontalLines,
  geometric,
  cartoon,
  white,
  lightGrey,
  motivational,
}

class BackgroundConfig {
  final int seed;
  final TemplateType template;
  final Color startColor;
  final Color endColor;
  final List<String> emojis;
  final int stripeCount;
  final double lineSpacing;
  final double rotation;
  final TextStyle textStyle;
  final String? motivationalQuote;
  final Color outerBorderColor;

  BackgroundConfig({
    required this.seed,
    required this.template,
    required this.startColor,
    required this.endColor,
    required this.emojis,
    required this.stripeCount,
    required this.lineSpacing,
    required this.rotation,
    required this.textStyle,
    this.motivationalQuote,
    required this.outerBorderColor,
  });
}
