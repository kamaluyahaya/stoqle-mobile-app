import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/component/selectionInputRow.dart';
import 'package:stoqle/helper/business-profile-helper.dart';

class SaleDiscountPage extends StatefulWidget {
  final String prefKey;
  final String initialValue;

  const SaleDiscountPage({
    Key? key,
    required this.prefKey,
    required this.initialValue,
  }) : super(key: key);

  @override
  State<SaleDiscountPage> createState() => _SaleDiscountPageState();
}

class _SaleDiscountPageState extends State<SaleDiscountPage> {
  String _selectedType = '';
  double _discount = 0;

  bool _loading = true;
  bool _saving = false;

  final List<String> discountTypes = [
    "New Buyer",
    "Flash Sale",
    "Black Friday",
    "Clearance",
    "Holiday Special",
  ];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    try {
      final s = widget.initialValue.isNotEmpty
          ? widget.initialValue
          : await ProfilePrefs.loadField(widget.prefKey) ?? '';

      if (s.isNotEmpty) {
        final decoded = jsonDecode(s);
        if (decoded is Map<String, dynamic>) {
          setState(() {
            _selectedType = decoded['type'] ?? '';
            _discount = (decoded['discount'] ?? 0).toDouble();
          });
        }
      }
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_selectedType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select discount type')),
      );
      return;
    }
    if (_discount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a discount greater than 0%')),
      );
      return;
    }

    final payload = jsonEncode({'type': _selectedType, 'discount': _discount});

    setState(() => _saving = true);
    await ProfilePrefs.saveField(widget.prefKey, payload);
    setState(() => _saving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sale Discount saved')));

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
          icon: Icon(CupertinoIcons.back, color: kWhite),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text("Sale Discounts", style: TextStyle(color: kBlack)),
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
      body: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kWhite,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectionInputRow(
                          title: "Discount Type",
                          hintText: "Select discount type",
                          isRequired: true,
                          selectedValue: _selectedType,
                          options: discountTypes,
                          onSelected: (val) =>
                              setState(() => _selectedType = val),
                        ),
                        const SizedBox(height: 5),
                        Divider(
                          thickness: 1,
                          height: 1,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(height: 10),
                        // Slider UI
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Discount: ${_discount.toStringAsFixed(0)}%",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Slider(
                          value: _discount,
                          min: 0,
                          max: 90,
                          divisions: 90,
                          activeColor: AppColors.kDefault,
                          label: "${_discount.toStringAsFixed(0)}%",
                          onChanged: (value) {
                            setState(() {
                              _discount = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
