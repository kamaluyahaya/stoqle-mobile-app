// captured_preview_page.dart
import 'dart:io';
import 'package:flutter/material.dart';

class CapturedPreviewPage extends StatelessWidget {
  final String filePath;
  CapturedPreviewPage({required this.filePath});

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
    return Scaffold(
      appBar: AppBar(title: Text('Preview')),
      body: Center(
        child: file.existsSync()
            ? Image.file(file)
            : Text(
                'File not found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: handle upload / use image
          Navigator.of(context).pop();
        },
        label: Text('Use Photo'),
        icon: Icon(Icons.check),
      ),
    );
  }
}
