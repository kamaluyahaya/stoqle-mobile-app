import 'package:flutter/material.dart';
import 'package:stoqle/helper/business-profile-helper.dart';

class EditFieldPage extends StatefulWidget {
  final String title;
  final String prefKey;
  final String initialValue;

  const EditFieldPage({
    super.key,
    required this.title,
    required this.prefKey,
    required this.initialValue,
  });

  @override
  State<EditFieldPage> createState() => _EditFieldPageState();
}

class _EditFieldPageState extends State<EditFieldPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() async {
    await ProfilePrefs.saveField(widget.prefKey, _controller.text.trim());
    Navigator.pop(context, _controller.text.trim()); // return updated value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${widget.title}"),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text("Save", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.title,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
