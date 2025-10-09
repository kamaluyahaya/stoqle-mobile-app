// lib/widgets/background_preview.dart
import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/background_config.dart';
import 'cartoon_painter.dart';

class BackgroundPreview extends StatelessWidget {
  final BackgroundConfig config;
  final String text;
  final bool showOverlay;
  final bool thumbnailMode;
  final String quoteAuthor;
  final DateTime date;

  const BackgroundPreview({
    Key? key,
    required this.config,
    required this.text,
    this.showOverlay = true,
    this.thumbnailMode = false,
    this.quoteAuthor = '',
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rng = Random(config.seed);
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget card = Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [config.startColor, config.endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildCoveringTextLayer(rng, constraints),
              if (config.template == TemplateType.emoji)
                _buildEmojiLayer(rng, constraints),
              if (config.template == TemplateType.lined)
                _buildLinedLayer(constraints),
              if (config.template == TemplateType.horizontalLines)
                _buildHorizontalLineLayer(constraints),
              if (config.template == TemplateType.verticalStripes)
                _buildVerticalStripeLayer(constraints),
              if (config.template == TemplateType.geometric)
                _buildGeometricLayer(rng, constraints),
              if (config.template == TemplateType.quote)
                _buildQuoteDecoration(rng, constraints),
              if (config.template == TemplateType.dateHeader)
                _buildDateHeaderDecoration(rng, constraints),
              if (config.template == TemplateType.cartoon)
                _buildCartoonLayer(constraints),
              if (showOverlay)
                Container(
                  color: Colors.black.withOpacity(thumbnailMode ? 0.03 : 0.06),
                ),
              _buildTextBody(constraints),
            ],
          ),
        );

        if (config.template == TemplateType.white ||
            config.template == TemplateType.lightGrey) {
          return Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(6),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: config.outerBorderColor, width: 6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: card,
              ),
            ),
          );
        }
        return card;
      },
    );
  }

  Widget _buildCoveringTextLayer(Random rng, BoxConstraints c) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    final tiles = thumbnailMode ? 6 : 18;
    final tileFont = _calculateFontSize(
      text,
      config.textStyle,
      c.maxWidth * 0.25,
      c.maxHeight * 0.12,
      2,
    );
    return Stack(
      children: [
        for (int i = 0; i < tiles; i++)
          Positioned(
            left: (rng.nextDouble() * (c.maxWidth - 20)).clamp(
              0.0,
              c.maxWidth - 20,
            ),
            top: (rng.nextDouble() * (c.maxHeight - 20)).clamp(
              0.0,
              c.maxHeight - 20,
            ),
            child: Transform.rotate(
              angle: (rng.nextDouble() * 12 - 6) * (math.pi / 180),
              child: Opacity(
                opacity: thumbnailMode ? 0.08 : 0.06,
                child: SizedBox(
                  width: c.maxWidth * 0.4,
                  child: Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: config.textStyle.copyWith(
                      fontSize: tileFont,
                      color: config.textStyle.color!.withOpacity(0.12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmojiLayer(Random rng, BoxConstraints constraints) {
    final emojiCount = thumbnailMode ? 6 : 14;
    return Stack(
      children: [
        for (int i = 0; i < emojiCount; i++)
          _positionedEmoji(
            rng,
            config.emojis[rng.nextInt(config.emojis.length)],
            constraints,
            i,
          ),
      ],
    );
  }

  Positioned _positionedEmoji(
    Random rng,
    String emoji,
    BoxConstraints c,
    int i,
  ) {
    final left = rng.nextDouble() * (c.maxWidth - 10);
    final top = rng.nextDouble() * (c.maxHeight - 10);
    final rot = (rng.nextDouble() * 30 - 15) * (math.pi / 180);
    final base = thumbnailMode ? 12.0 : 30.0;
    final size = base + rng.nextDouble() * (thumbnailMode ? 6 : 20);
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: rot,
        child: Opacity(
          opacity: thumbnailMode ? 0.6 : 0.9,
          child: Text(emoji, style: TextStyle(fontSize: size)),
        ),
      ),
    );
  }

  Widget _buildLinedLayer(BoxConstraints constraints) {
    final spacing = config.lineSpacing;
    final paintLines = <Widget>[];
    final count = (constraints.maxHeight / spacing).ceil();
    for (int i = 0; i < count; i++) {
      paintLines.add(
        Positioned(
          top: i * spacing,
          left: 0,
          right: 0,
          child: Container(height: 1, color: Colors.black.withOpacity(0.03)),
        ),
      );
    }
    paintLines.add(
      Positioned(
        top: 8,
        bottom: 8,
        left: 22,
        child: Container(width: 4, color: Colors.black.withOpacity(0.06)),
      ),
    );
    return Stack(children: paintLines);
  }

  Widget _buildHorizontalLineLayer(BoxConstraints constraints) {
    final spacing = config.lineSpacing * 0.7;
    final count = (constraints.maxHeight / spacing).ceil();
    return Stack(
      children: [
        for (int i = 0; i < count; i++)
          Positioned(
            top: i * spacing,
            left: 12,
            right: 12,
            child: Container(height: 2, color: Colors.black.withOpacity(0.03)),
          ),
      ],
    );
  }

  Widget _buildVerticalStripeLayer(BoxConstraints constraints) {
    final stripes = config.stripeCount;
    final stripeWidth = (constraints.maxWidth / stripes);
    return Stack(
      children: [
        for (int i = 0; i < stripes; i++)
          Positioned(
            left: i * stripeWidth,
            top: 0,
            bottom: 0,
            child: Container(
              width: stripeWidth,
              color: (i % 2 == 0)
                  ? Colors.black.withOpacity(0.02)
                  : Colors.transparent,
            ),
          ),
      ],
    );
  }

  Widget _buildGeometricLayer(Random rng, BoxConstraints constraints) {
    final shapes = <Widget>[];
    final n = thumbnailMode ? 3 : 7;
    for (int i = 0; i < n; i++) {
      final left = rng.nextDouble() * constraints.maxWidth;
      final top = rng.nextDouble() * constraints.maxHeight;
      final w = 40.0 + rng.nextDouble() * 120;
      final h = 14.0 + rng.nextDouble() * 60;
      final rot =
          (config.rotation + rng.nextDouble() * 40 - 20) * (math.pi / 180);
      shapes.add(
        Positioned(
          left: left,
          top: top,
          child: Transform.rotate(
            angle: rot,
            child: Opacity(
              opacity: 0.06,
              child: Container(
                width: w,
                height: h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Stack(children: shapes);
  }

  Widget _buildQuoteDecoration(Random rng, BoxConstraints constraints) {
    return Stack(
      children: [
        Positioned(
          left: 16,
          top: 12,
          child: Opacity(
            opacity: 0.12,
            child: Text(
              '“',
              style: TextStyle(
                fontSize: thumbnailMode ? 44 : 110,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(height: 1, color: Colors.black.withOpacity(0.04)),
        ),
      ],
    );
  }

  Widget _buildDateHeaderDecoration(Random rng, BoxConstraints constraints) {
    final dateText =
        '${date.toLocal().year}-${date.toLocal().month.toString().padLeft(2, '0')}-${date.toLocal().day.toString().padLeft(2, '0')}';
    return Positioned(
      top: 12,
      left: 12,
      child: Opacity(
        opacity: 0.95,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: TextStyle(
              fontSize: thumbnailMode ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartoonLayer(BoxConstraints constraints) {
    return Positioned.fill(
      child: CustomPaint(
        painter: CartoonPainter(
          startColor: config.startColor,
          endColor: config.endColor,
          isThumbnail: thumbnailMode,
          seed: config.seed,
        ),
      ),
    );
  }

  Widget _buildTextBody(BoxConstraints constraints) {
    final padding = EdgeInsets.symmetric(horizontal: 22.0, vertical: 18.0);

    final double maxWidthForText = thumbnailMode
        ? constraints.maxWidth * 0.85
        : constraints.maxWidth * 0.9;
    final double maxHeightForText = thumbnailMode
        ? constraints.maxHeight * 0.5
        : constraints.maxHeight * 0.6;
    final int maxLinesForText = thumbnailMode ? 4 : 12;

    double fitFont = _calculateFontSize(
      text,
      config.textStyle,
      maxWidthForText,
      maxHeightForText,
      maxLinesForText,
    );

    final mainStyle = config.textStyle.copyWith(
      fontSize: fitFont,
      color: config.textStyle.color,
    );

    if (config.template == TemplateType.quote) {
      return Padding(
        padding: padding,
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                textAlign: TextAlign.left,
                style: mainStyle.copyWith(fontStyle: FontStyle.italic),
                maxLines: maxLinesForText,
                overflow: TextOverflow.ellipsis,
              ),
              if (quoteAuthor.isNotEmpty) const SizedBox(height: 8),
              if (quoteAuthor.isNotEmpty)
                Text(
                  '- $quoteAuthor',
                  style: mainStyle.copyWith(
                    fontSize: max(12, fitFont - 6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (config.template == TemplateType.motivational) {
      return Padding(
        padding: padding,
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            config.motivationalQuote ?? '',
            textAlign: TextAlign.left,
            style: mainStyle.copyWith(fontWeight: FontWeight.w800),
            maxLines: maxLinesForText,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    if (config.template == TemplateType.dateHeader) {
      return Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: thumbnailMode ? 8 : 12),
            Text(
              '${date.toLocal().day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}',
              style: mainStyle.copyWith(
                fontSize: thumbnailMode ? 12 : 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  text,
                  textAlign: TextAlign.start,
                  style: mainStyle,
                  maxLines: maxLinesForText,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (quoteAuthor.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '"$quoteAuthor"',
                style: mainStyle.copyWith(
                  fontSize: max(12, fitFont - 8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: maxWidthForText,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                textAlign: TextAlign.left,
                style: mainStyle,
                maxLines: maxLinesForText,
                overflow: TextOverflow.ellipsis,
              ),
              if (quoteAuthor.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  '- $quoteAuthor',
                  style: mainStyle.copyWith(
                    fontSize: max(12, fitFont - 8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[(m - 1).clamp(0, 11)];
  }

  double _calculateFontSize(
    String text,
    TextStyle baseStyle,
    double maxWidth,
    double maxHeight,
    int maxLines,
  ) {
    double low = 8.0;
    double high = 220.0;
    double best = low;
    while (low <= high) {
      double mid = (low + high) / 2;
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: baseStyle.copyWith(fontSize: mid),
        ),
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
      );
      tp.layout(maxWidth: maxWidth);
      final didFit = tp.height <= maxHeight && tp.width <= maxWidth;
      if (didFit) {
        best = mid;
        low = mid + 0.5;
      } else {
        high = mid - 0.5;
      }
    }
    return best.clamp(12.0, baseStyle.fontSize ?? 34.0);
  }
}
