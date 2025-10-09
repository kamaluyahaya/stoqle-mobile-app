import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/component/defaultInputRow.dart';
import 'package:stoqle/helper/business-profile-helper.dart';

import 'model/page.dart';

class BusinessAddressEditor extends StatefulWidget {
  final String prefKey;
  final String initialValue;

  const BusinessAddressEditor({
    Key? key,
    required this.prefKey,
    required this.initialValue,
  }) : super(key: key);

  @override
  State<BusinessAddressEditor> createState() => _BusinessAddressEditorState();
}

class _BusinessAddressEditorState extends State<BusinessAddressEditor> {
  late TextEditingController _line1Ctrl;
  late TextEditingController _line2Ctrl;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _line1Ctrl = TextEditingController();
    _line2Ctrl = TextEditingController();
    _loadInitial();
  }

  @override
  void dispose() {
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    try {
      final s = widget.initialValue.isNotEmpty
          ? widget.initialValue
          : await ProfilePrefs.loadField(widget.prefKey) ?? '';

      if (s.isNotEmpty) {
        final decoded = jsonDecode(s);
        if (decoded is Map<String, dynamic>) {
          final info = BusinessAddressInfo.fromJson(decoded);
          _line1Ctrl.text = info.line1;
          _line2Ctrl.text = info.line2;
        }
      }
    } catch (_) {
      // ignore parse errors — keep blank defaults
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final line1 = _line1Ctrl.text.trim();
    final line2 = _line2Ctrl.text.trim();

    if (line1.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address line 1 is required.')),
      );
      return;
    }

    setState(() => _saving = true);

    final info = BusinessAddressInfo(line1: line1, line2: line2);
    final payload = jsonEncode(info.toJson());

    await ProfilePrefs.saveField(widget.prefKey, payload);

    setState(() => _saving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Business address saved')));

    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: AppColors.lightBackground,
        backgroundColor: CupertinoColors.systemGroupedBackground,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text('Business Address'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              _saving ? 'Saving...' : 'Save',
              style: const TextStyle(color: AppColors.kDefault),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            DefaultInputRow(
                              title: "Address line 1",
                              hintText: "Street, building, etc.",
                              controller: _line1Ctrl,
                              isRequired: true,
                              keyboardType: TextInputType.streetAddress,
                              maxLength: 150,
                            ),
                            DefaultInputRow(
                              title: "Address line 2",
                              hintText: "Apartment, suite, landmark (optional)",
                              controller: _line2Ctrl,
                              isRequired: false,
                              keyboardType: TextInputType.text,
                              maxLength: 150,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tip: Provide a clear address to improve delivery accuracy.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
