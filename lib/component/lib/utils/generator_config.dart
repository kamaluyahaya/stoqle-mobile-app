// lib/utils/config_generator.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/background_config.dart';

class ConfigGenerator {
  final Random _rng;

  ConfigGenerator([int? seed]) : _rng = seed == null ? Random() : Random(seed);

  // Generate a single random config
  BackgroundConfig generate() {
    final seed = _rng.nextInt(1 << 30);
    final rng = Random(seed);

    final template =
        TemplateType.values[rng.nextInt(TemplateType.values.length)];

    final lightPalettes = [
      const Color.fromARGB(255, 255, 229, 229),
      const Color(0xFFF5F5F5),
      const Color(0xFFFFF9C4),
      const Color(0xFFE8F5E9),
      const Color(0xFFF0F0F0),
      const Color(0xFFFBE9E7),
      const Color.fromARGB(255, 230, 186, 236),
    ];

    final accents = [
      Colors.green.shade600,
      Colors.yellow.shade700,
      Colors.grey.shade600,
      Colors.green.shade400,
      Colors.purple.shade400,
      Colors.orange.shade600,
    ];

    final base = lightPalettes[rng.nextInt(lightPalettes.length)];
    // slightly change end color for mild gradient
    final end = HSLColor.fromColor(base)
        .withLightness(
          (HSLColor.fromColor(base).lightness *
                  (0.86 + rng.nextDouble() * 0.14))
              .clamp(0.0, 1.0),
        )
        .toColor();

    final emojiSets = [
      ['🔥', '😍', '✨', '💫'],
      ['🌸', '🌿', '💚', '🍃'],
      ['🎉', '🥳', '✨', '🎈'],
      ['☀️', '🌊', '⛱️', '🌴'],
      ['🌙', '⭐', '✨', '🌌'],
      ['🍂', '🍁', '🌻', '🧡'],
      ['🚀', '💡', '🌟', '🎯'],
    ];
    final emojis = emojiSets[rng.nextInt(emojiSets.length)];

    final fontSize = 34.0 + rng.nextInt(10);
    final weight = (rng.nextBool()) ? FontWeight.w700 : FontWeight.w600;

    final motivationalQuotes = [
      'The best way to predict the future is to create it.',
      'Believe you can and you\'re halfway there.',
      'The only way to do great work is to love what you do.',
      'Do what it does. Keep going.',
      'Success is not final, failure is not fatal: courage continues.',
    ];

    final motivationalQuote =
        motivationalQuotes[rng.nextInt(motivationalQuotes.length)];

    return BackgroundConfig(
      seed: seed,
      template: template,
      startColor: base,
      endColor: end,
      emojis: emojis,
      stripeCount: 3 + rng.nextInt(6),
      lineSpacing: 22.0 + rng.nextInt(10),
      rotation: (rng.nextDouble() * 40 - 20),
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: weight,
        color: Colors.black87,
        height: 1.05,
      ),
      motivationalQuote: motivationalQuote,
      outerBorderColor: accents[rng.nextInt(accents.length)],
    );
  }

  // Generate a list of distinct configs
  List<BackgroundConfig> generateList(int count) {
    return List.generate(count, (_) => generate());
  }
}
