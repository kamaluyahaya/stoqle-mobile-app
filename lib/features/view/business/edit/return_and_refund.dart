import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/helper/business-profile-helper.dart';

class RefundsEditor extends StatefulWidget {
  final String prefKey;
  final String initialValue;

  const RefundsEditor({
    Key? key,
    required this.prefKey,
    required this.initialValue,
  }) : super(key: key);

  @override
  State<RefundsEditor> createState() => _RefundsEditorState();
}

class _RefundsEditorState extends State<RefundsEditor> {
  bool returnShippingSubsidy = false;
  bool noReasonReturn7Days = false;
  bool rapidRefund = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    try {
      final decoded = jsonDecode(widget.initialValue);
      if (decoded is Map) {
        returnShippingSubsidy = decoded['return_shipping_subsidy'] == true;
        noReasonReturn7Days = decoded['no_reason_return_7days'] == true;
        rapidRefund = decoded['rapid_refund'] == true;
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final payload = jsonEncode({
      'return_shipping_subsidy': returnShippingSubsidy,
      'no_reason_return_7days': noReasonReturn7Days,
      'rapid_refund': rapidRefund,
    });
    await ProfilePrefs.saveField(widget.prefKey, payload);
    setState(() => _saving = false);
    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: kBlack),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text(
          'Returns & Refunds',
          style: TextStyle(fontFamily: "Bold", color: kBlack),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text(
              "Save",
              style: TextStyle(color: AppColors.kDefault),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: returnShippingSubsidy,
                    onChanged: (v) => setState(() => returnShippingSubsidy = v),
                    title: Text(
                      'Return shipping subsidy',
                      style: TextStyle(fontFamily: "Bold", color: kBlack),
                    ),
                    subtitle: Text(
                      'We cover return shipping costs in eligible cases.',
                      style: TextStyle(color: kBlack),
                    ),
                    // toggle colors: thumb + track when ON
                    activeColor: kWhite,
                    activeTrackColor: AppColors.kDefault,
                  ),
                  SizedBox(height: 10),
                  Divider(thickness: 1, height: 1, color: Colors.grey[200]),
                  SizedBox(height: 10),
                  SwitchListTile(
                    value: noReasonReturn7Days,
                    onChanged: (v) => setState(() => noReasonReturn7Days = v),
                    title: Text(
                      '7-day no reason return',
                      style: TextStyle(fontFamily: "Bold", color: kBlack),
                    ),
                    subtitle: Text(
                      'Buyers can return items within 7 days without explanation.',
                      style: TextStyle(color: kBlack),
                    ),
                    activeColor: kWhite,
                    activeTrackColor: AppColors.kDefault,
                  ),
                  SizedBox(height: 10),
                  Divider(thickness: 1, height: 1, color: Colors.grey[200]),
                  SizedBox(height: 10),
                  SwitchListTile(
                    value: rapidRefund,
                    onChanged: (v) => setState(() => rapidRefund = v),
                    title: Text(
                      'Rapid refund',
                      style: TextStyle(fontFamily: "Bold", color: kBlack),
                    ),
                    subtitle: Text(
                      'We the condition are met, customer will recieve an instant refund!',
                      style: TextStyle(color: kBlack),
                    ),
                    activeColor: kWhite,
                    activeTrackColor: AppColors.kDefault,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
