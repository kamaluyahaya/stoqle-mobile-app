import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/component/defaultInputRow.dart';
import 'package:stoqle/component/selectionInputRow.dart';
import 'package:stoqle/core/widget/constant.dart';
import 'package:stoqle/data/country_hierarcy/page.dart';
import 'package:stoqle/helper/business-profile-helper.dart';
import 'package:toast/toast.dart';

import 'model/page.dart'; // if not already available

// ---------- PaymentInfoEditor Page ----------
class PaymentInfoEditor extends StatefulWidget {
  final String prefKey;
  final String initialValue; // json string as saved before

  const PaymentInfoEditor({
    Key? key,
    required this.prefKey,
    required this.initialValue,
  }) : super(key: key);

  @override
  State<PaymentInfoEditor> createState() => _PaymentInfoEditorState();
}

class _PaymentInfoEditorState extends State<PaymentInfoEditor> {
  // Controllers
  late TextEditingController _acctNumCtrl;
  late TextEditingController _acctNameCtrl;
  String _selectedBank = '';

  // Toggles
  bool _supportAvailable = true;
  bool _podEnabled = true;
  bool _codEnabled = true;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _acctNumCtrl = TextEditingController();
    _acctNameCtrl = TextEditingController();
    _loadInitial();
  }

  @override
  void dispose() {
    _acctNumCtrl.dispose();
    _acctNameCtrl.dispose();
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
          final info = PaymentInfo.fromJson(decoded);
          _supportAvailable = info.supportAvailable;
          _podEnabled = info.podEnabled;
          _codEnabled = info.codEnabled;
          _acctNumCtrl.text = info.accountNumber;
          _acctNameCtrl.text = info.accountName;
          _selectedBank = info.bankName;
        }
      }
    } catch (_) {
      // ignore parse errors and keep defaults
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    // trim values
    final acctNum = _acctNumCtrl.text.trim();
    final acctName = _acctNameCtrl.text.trim();
    final bank = _selectedBank.trim();

    // required checks
    if (acctNum.isEmpty) {
      toastNotify("Please enter account number");
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(acctNum)) {
      toastNotify("Account number must be numeric");
      return;
    }

    if (acctName.isEmpty) {
      toastNotify("Please enter account name");
      return;
    }

    if (bank.isEmpty) {
      toastNotify("Please choose a bank");
      return;
    }

    // all good — proceed to save
    setState(() => _saving = true);

    final info = PaymentInfo(
      supportAvailable: _supportAvailable,
      podEnabled: _podEnabled,
      codEnabled: _codEnabled,
      accountNumber: acctNum,
      accountName: acctName,
      bankName: _selectedBank,
    );

    final payload = jsonEncode(info.toJson());
    await ProfilePrefs.saveField(widget.prefKey, payload);

    setState(() => _saving = false);

    toastNotify("Payment info saved");

    Navigator.of(context).pop(payload); // return saved payload
  }

  Widget _buildToggleRow({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white, // thumb color when ON
        activeTrackColor: Colors.red, // track color when ON
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        controlAffinity: ListTileControlAffinity.trailing,
        visualDensity: const VisualDensity(
          horizontal: -4, // tighter horizontally
          vertical: -4, // tighter vertically
        ),
      ),
    );
  }

  // String? _selectedBankName;

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        elevation: 0,

        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: kBlack),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text('Edit Payment Info', style: TextStyle()),
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
                    // Toggles
                    _buildToggleRow(
                      label: 'Pay On Delivery (POD)',
                      subtitle:
                          'Allow customers to pay when item is delivered.',
                      value: _podEnabled,
                      onChanged: (v) => setState(() => _podEnabled = v),
                    ),
                    _buildToggleRow(
                      label: 'Cash On Delivery (COD)',
                      subtitle:
                          'Allow cash payments on delivery (if supported in your area).',
                      value: _codEnabled,
                      onChanged: (v) => setState(() => _codEnabled = v),
                    ),

                    const SizedBox(height: 10),

                    // Account fields
                    Container(
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          DefaultInputRow(
                            title: "Account No.",
                            hintText: "Account number",
                            controller: _acctNumCtrl,
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                          ),
                          DefaultInputRow(
                            title: "Account name",
                            hintText: "Account name",
                            controller: _acctNameCtrl,
                            maxLength: 30,
                            keyboardType: TextInputType.text,
                            isRequired: true,
                          ),

                          SelectionInputRow(
                            title: "Bank name",
                            hintText: "Choose Bank",
                            isRequired: true,
                            selectedValue: _selectedBank,
                            options: banks,
                            onSelected: (value) {
                              setState(() => _selectedBank = value);
                            },
                          ),

                          const SizedBox(height: 6),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // small hint
                    Text(
                      'Tip: POD and COD are enabled by default. Fill your bank details if you want direct bank transfers.',
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
