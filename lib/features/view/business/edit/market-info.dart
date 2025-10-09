import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/component/defaultInputRow.dart';
import 'package:stoqle/data/country_hierarcy/page.dart';
import 'package:stoqle/helper/business-profile-helper.dart';
import '../../../../component/selectionInputRow.dart';
import 'model/page.dart';

// ---------------- Page ----------------
class MarketEditor extends StatefulWidget {
  final String prefKey;
  final String initialValue; // optional existing json
  final bool isTrustedPartner; // injected from backend / management

  const MarketEditor({
    Key? key,
    required this.prefKey,
    required this.initialValue,
    this.isTrustedPartner = false,
  }) : super(key: key);

  @override
  State<MarketEditor> createState() => _MarketEditorState();
}

class _MarketEditorState extends State<MarketEditor> {
  // Controllers
  late TextEditingController _noteCtrl;

  // Selection value
  String? _selectedMarket;

  // UI state
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController();
    _loadInitial();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
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
          final info = MarketInfo.fromJson(decoded);
          setState(() {
            _selectedMarket = info.market;
            _noteCtrl.text = info.note ?? '';
          });
        }
      }
    } catch (_) {
      // ignore parse errors
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final info = MarketInfo(
      market: _selectedMarket,
      trustedPartner: widget.isTrustedPartner,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    final payload = jsonEncode(info.toJson());
    await ProfilePrefs.saveField(widget.prefKey, payload);

    setState(() => _saving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Market info saved')));

    Navigator.of(context).pop(payload);
  }

  Widget _buildMarketSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SelectionInputRow(
        title: 'Market:',
        hintText: 'Choose your market if applicable',
        isRequired: false,
        selectedValue: _selectedMarket ?? '',
        options: marketOptions,
        onSelected: (value) => setState(() => _selectedMarket = value),
      ),
    );
  }

  Widget _buildTrustedPartnerRow() {
    return Column(
      children: [
        Divider(thickness: 1, height: 1, color: Colors.grey[200]),
        ListTile(
          title: const Text("Trusted Partner Status:"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isTrustedPartner
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.xmark_circle,
                color: widget.isTrustedPartner ? Colors.green : kBlack,
              ),
              const SizedBox(width: 6),
              Text(
                widget.isTrustedPartner ? "Trusted Partner" : "Not Partner",
                style: TextStyle(
                  color: widget.isTrustedPartner ? Colors.green : kBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DefaultInputRow(
        title: "Notes:",
        hintText: "Optional info (e.g. Online only, Delivery only)",
        controller: _noteCtrl,
        maxLength: 100,
        isRequired: false,
      ),
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
          icon: Icon(CupertinoIcons.back, color: kBlack),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text('Market Affiliation', style: TextStyle(color: kBlack)),
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
                child: Container(
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        _buildMarketSelector(),

                        _buildTrustedPartnerRow(),
                        Divider(
                          thickness: 1,
                          height: 1,
                          color: Colors.grey[200],
                        ),
                        _buildNoteRow(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
