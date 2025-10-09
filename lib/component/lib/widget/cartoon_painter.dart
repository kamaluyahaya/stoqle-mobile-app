// lib/widgets/cartoon_painter.dart
// Modern / professional update for the cartoon-style background painter.
// - Softer layered blobs with blur
// - Subtle diagonal accent stripes
// - Small geometric accents (circles/rounded-squares)
// - Thumbnail mode draws fewer, cheaper primitives
// - Deterministic when seed is provided

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CartoonPainter extends CustomPainter {
  final Color startColor;
  final Color endColor;
  final bool isThumbnail;
  final int? seed;
  final double complexity; // 0.0 - 1.0, controls number of accents

  CartoonPainter({
    required this.startColor,
    required this.endColor,
    required this.isThumbnail,
    this.seed,
    this.complexity = 0.85,
  }) : assert(complexity >= 0 && complexity <= 1);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = (seed != null) ? Random(seed) : Random();

    // base gradient background (soft radial + linear mix)
    final rect = Offset.zero & size;
    // final linear = ui.Gradient.linear(rect.topLeft, rect.bottomRight, [
    //   startColor,
    //   endColor,
    // ]);

    // final radial = ui.Gradient.radial(
    //   rect.center,
    //   max(size.width, size.height) * 0.8,
    //   [startColor.withOpacity(0.85), endColor.withOpacity(0.6)],
    // );

    final linear = ui.Gradient.linear(rect.topLeft, rect.bottomRight, [
      startColor,
      endColor,
    ]);
    final radial = ui.Gradient.radial(
      rect.center,
      max(size.width, size.height) * 0.8,
      [startColor.withOpacity(0.85), endColor.withOpacity(0.6)],
    );

    final bgPaint = Paint()
      ..shader = linear
      ..isAntiAlias = true;
    canvas.drawRect(rect, bgPaint);

    final overlayPaint = Paint()
      ..shader = radial
      ..blendMode = BlendMode.softLight
      ..isAntiAlias = true;
    canvas.drawRect(rect, overlayPaint);

    canvas.drawRect(rect, bgPaint);

    // soft layered blobs (gives professional organic feel)
    final int blobCount = isThumbnail ? 1 : (2 + (complexity * 3).round());
    for (int i = 0; i < blobCount; i++) {
      final t = i / max(1, blobCount - 1);
      final cx = size.width * (0.15 + rng.nextDouble() * 0.7);
      final cy = size.height * (0.12 + rng.nextDouble() * 0.76);
      final baseRadius =
          min(size.width, size.height) * (0.22 + rng.nextDouble() * 0.2);

      final blobColor = Color.lerp(
        startColor,
        endColor,
        (0.2 + t * 0.7),
      )!.withOpacity(0.18 + rng.nextDouble() * 0.08);

      _drawSoftBlob(
        canvas,
        Offset(cx, cy),
        baseRadius,
        blobColor,
        rng,
        isThumbnail,
      );
    }

    // diagonal accent stripes — subtle, professional
    if (!isThumbnail && complexity > 0.15) {
      canvas.save();
      final angle =
          -pi / 12 + (rng.nextDouble() - 0.5) * 0.08; // small variation
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(angle);
      canvas.translate(-size.width / 2, -size.height / 2);

      final stripePaint = Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      final stripeCount = 3 + (complexity * 3).round();
      final stripeW = size.width * (0.08 + rng.nextDouble() * 0.03);
      for (int i = 0; i < stripeCount; i++) {
        final left = -size.width * 0.6 + i * (stripeW * 2.2);
        stripePaint.color = Colors.white.withOpacity(0.035 + i * 0.01);
        final rrect = RRect.fromLTRBR(
          left,
          size.height * 0.15,
          left + stripeW,
          size.height * 0.85,
          Radius.circular(16),
        );
        canvas.drawRRect(rrect, stripePaint);
      }
      canvas.restore();
    }

    // minimal geometric accents (dots / small rounded squares)
    final accents = isThumbnail ? 3 : (6 + (complexity * 8).round());
    for (int i = 0; i < accents; i++) {
      if (rng.nextDouble() > complexity)
        continue; // skip some based on complexity
      final px = size.width * (0.08 + rng.nextDouble() * 0.84);
      final py = size.height * (0.08 + rng.nextDouble() * 0.84);
      final s =
          (isThumbnail ? 6.0 : 10.0) +
          rng.nextDouble() * (isThumbnail ? 8.0 : 18.0);
      final accentPaint = Paint()
        ..color = Colors.white.withOpacity(0.06 + rng.nextDouble() * 0.08)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          (isThumbnail ? 2.0 : 6.0),
        );

      if (rng.nextBool()) {
        canvas.drawCircle(Offset(px, py), s, accentPaint);
      } else {
        final rr = RRect.fromLTRBR(
          px - s,
          py - s,
          px + s,
          py + s,
          Radius.circular(s * 0.6),
        );
        canvas.drawRRect(rr, accentPaint);
      }
    }

    // optional subtle grain overlay for texture (cheap, small circles)
    if (!isThumbnail && complexity > 0.3) {
      final grainPaint = Paint()..color = Colors.black.withOpacity(0.02);
      final grains = (size.width * size.height / 25000).round();
      for (int i = 0; i < grains; i++) {
        if (rng.nextDouble() > 0.25) continue;
        final gx = rng.nextDouble() * size.width;
        final gy = rng.nextDouble() * size.height;
        canvas.drawCircle(Offset(gx, gy), rng.nextDouble() * 1.2, grainPaint);
      }
    }
  }

  void _drawSoftBlob(
    Canvas canvas,
    Offset center,
    double r,
    Color color,
    Random rng,
    bool thumbnail,
  ) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        thumbnail ? r * 0.12 : r * 0.18,
      );

    // Create an organic blob by drawing several overlapping ovals
    final pieces = thumbnail ? 3 : 5;
    for (int p = 0; p < pieces; p++) {
      final angle = rng.nextDouble() * pi * 2;
      final offset =
          Offset(cos(angle), sin(angle)) *
          (r * (0.14 + rng.nextDouble() * 0.42));
      final w = r * (0.8 + rng.nextDouble() * 0.6);
      final h = r * (0.6 + rng.nextDouble() * 0.8);
      final rect = Rect.fromCenter(
        center: center + offset,
        width: w,
        height: h,
      );
      canvas.drawOval(rect, paint);
    }

    // inner subtle highlight
    final highlight = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.06), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.9))
      ..blendMode = BlendMode.softLight
      ..isAntiAlias = true;
    canvas.drawCircle(
      center.translate(-r * 0.18, -r * 0.22),
      r * 0.6,
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant CartoonPainter oldDelegate) {
    return oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor ||
        oldDelegate.isThumbnail != isThumbnail ||
        oldDelegate.seed != seed ||
        oldDelegate.complexity != complexity;
  }
}
