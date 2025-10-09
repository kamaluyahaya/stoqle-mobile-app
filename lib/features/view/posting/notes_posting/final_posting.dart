import 'package:flutter/material.dart';
import 'package:stoqle/component/lib/models/background_config.dart';

import '../../../../component/lib/widget/background_preview.dart';

class FinalPreviewPage extends StatelessWidget {
  final BackgroundConfig config;
  final String text;
  final String quoteAuthor;
  final DateTime date;

  const FinalPreviewPage({
    Key? key,
    required this.config,
    required this.text,
    required this.quoteAuthor,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Final Preview")),
      body: Center(
        child: BackgroundPreview(
          config: config,
          text: text,
          showOverlay: true,
          thumbnailMode: false,
          quoteAuthor: quoteAuthor,
          date: date,
        ),
      ),
    );
  }
}
