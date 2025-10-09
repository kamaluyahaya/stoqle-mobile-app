import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/data/country_hierarcy/page.dart';
import 'package:stoqle/helper/business-profile-helper.dart';
import '../../../../component/selectionInputRow.dart';
import 'model/page.dart';

// ---------------- Page ----------------
class CustomerServiceEditor extends StatefulWidget {
  final String prefKey;
  final String initialValue; // optional existing json

  const CustomerServiceEditor({
    Key? key,
    required this.prefKey,
    required this.initialValue,
  }) : super(key: key);

  @override
  State<CustomerServiceEditor> createState() => _CustomerServiceEditorState();
}

class _CustomerServiceEditorState extends State<CustomerServiceEditor> {
  // Controllers
  late TextEditingController _welcomeCtrl;

  // Selection value
  String _replyTime = '';

  // Rating (1.0 - 5.0)
  double _goodReviewRating = 5.0;

  // UI state
  bool _loading = true;
  bool _saving = false;

  // default welcome message if user leaves it blank
  static const String _fallbackWelcomeDm =
      'Hi! 👋 Thanks for contacting us. We will reply shortly.';

  @override
  void initState() {
    super.initState();
    _welcomeCtrl = TextEditingController();
    _loadInitial();
  }

  @override
  void dispose() {
    _welcomeCtrl.dispose();
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
          final info = CustomerServiceInfo.fromJson(decoded);
          setState(() {
            _replyTime = info.replyTime;
            // clamp parsed rating into allowed range
            _goodReviewRating =
                (info.goodReviewSummary >= 1.0 && info.goodReviewSummary <= 5.0)
                ? info.goodReviewSummary
                : 5.0;
            _welcomeCtrl.text = info.welcomeDm;
          });
        }
      }
    } catch (_) {
      // ignore parse errors, we'll use defaults
    } finally {
      // ensure replyTime has a sensible default if empty
      setState(() {
        _replyTime = (_replyTime.isNotEmpty)
            ? _replyTime
            : replyOptions[2]; // default: Within 12 hours
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    // Basic validation
    final welcome = _welcomeCtrl.text.trim();
    if (_replyTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a reply time.')),
      );
      return;
    }

    if (!(_goodReviewRating >= 1.0 && _goodReviewRating <= 5.0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating between 1.0 and 5.0.'),
        ),
      );
      return;
    }

    final welcomeToSave = welcome.isEmpty ? _fallbackWelcomeDm : welcome;

    setState(() => _saving = true);

    final info = CustomerServiceInfo(
      replyTime: _replyTime,
      goodReviewSummary: _goodReviewRating,
      welcomeDm: welcomeToSave,
    );

    final payload = jsonEncode(info.toJson());
    await ProfilePrefs.saveField(widget.prefKey, payload);

    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer service settings saved')),
    );

    Navigator.of(context).pop(payload);
  }

  Widget _buildReplySelector() {
    return SelectionInputRow(
      title: 'Reply time',
      hintText: 'Choose reply time',
      isRequired: true,
      selectedValue: _replyTime,
      options: replyOptions,
      onSelected: (value) => setState(() => _replyTime = value),
    );
  }

  Widget _buildGoodReviewRow() {
    return SelectionInputRow(
      title: 'Good rating',
      hintText: 'Select rating (1.0 - 5.0)',
      isRequired: true,
      selectedValue: _goodReviewRating.toStringAsFixed(1),
      options: ratingOptions,
      onSelected: (value) {
        setState(() {
          _goodReviewRating = double.tryParse(value) ?? 5.0;
        });
      },
    );
  }

  // A multi-line input — if your DefaultInputRow supports isMultiline, switch to that.
  Widget _buildWelcomeRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Welcome DM', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CupertinoTextField(
              controller: _welcomeCtrl,
              maxLines: 5,
              placeholder: 'Default message for new customers (DM)',
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              decoration: null,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This message is sent to new customers who DM you. If left empty, a default message will be used.',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
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
        title: const Text('Customer Service', style: TextStyle()),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.kDefault),
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
                            _buildReplySelector(),
                            Divider(
                              thickness: 1,
                              height: 1,
                              color: Colors.grey[200],
                            ),
                            const SizedBox(height: 10),
                            _buildGoodReviewRow(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                    _buildWelcomeRow(),
                    const SizedBox(height: 24),
                    Text(
                      'Tip: The welcome DM will be sent automatically to new customers who message your shop.',
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
