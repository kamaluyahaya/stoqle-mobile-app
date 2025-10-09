import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/component/selectionInputRow.dart';
import 'package:stoqle/core/widget/constant.dart';
import 'package:stoqle/data/country_hierarcy/page.dart';
import 'package:stoqle/helper/business-profile-helper.dart';
import 'package:toast/toast.dart';
import 'model/page.dart';

/// Active occasions filter
List<Occasion> getAvailableOccasions() {
  final now = DateTime.now();
  final all = buildOccasionsForYear(now.year);
  return all
      .where((o) => now.isAfter(o.windowStart) && now.isBefore(o.windowEnd))
      .toList();
}

class PromotionsEditor extends StatefulWidget {
  final String prefKey;
  final String initialValue;

  const PromotionsEditor({
    Key? key,
    required this.prefKey,
    required this.initialValue,
  }) : super(key: key);

  @override
  State<PromotionsEditor> createState() => _PromotionsEditorState();
}

class _PromotionsEditorState extends State<PromotionsEditor> {
  String _selectedOccasion = '';
  DateTime? _startDate;
  DateTime? _endDate;
  double _discount = 0;

  bool _loading = true;
  bool _saving = false;

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
          final promo = Promotion.fromJson(decoded);
          setState(() {
            _selectedOccasion = promo.occasion;
            _startDate = promo.start;
            _endDate = promo.end;
            _discount = promo.discount;
          });
        }
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDate(bool isStart) async {
    if (_selectedOccasion.isEmpty) {
      toastNotify("Select an occasion first");
      return;
    }

    final occasion = getAvailableOccasions().firstWhere(
      (o) => o.name == _selectedOccasion,
    );

    DateTime tempDate = DateTime.now();
    final now = DateTime.now();
    final minDate = occasion.windowStart;
    final maxDate = occasion.windowEnd;

    // Disallow past dates
    final effectiveMinDate = now.isAfter(minDate) ? now : minDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.kDarkMode : AppColors.lightBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  Text(isStart ? "Choose Start Date" : "Choose End Date"),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (isStart) {
                          _startDate = tempDate;
                        } else {
                          _endDate = tempDate;
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  minimumDate: effectiveMinDate,
                  maximumDate: maxDate,
                  initialDateTime: effectiveMinDate,
                  onDateTimeChanged: (value) {
                    tempDate = value;
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Selectable only within ±7 days of ${occasion.name}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (_selectedOccasion.isEmpty) {
      toastNotify("Please select an occasion");
      return;
    }
    if (_startDate == null || _endDate == null) {
      toastNotify("Please select both start and end dates");
      return;
    }
    if (_startDate!.isAfter(_endDate!)) {
      toastNotify("Start date cannot be after end date");
      return;
    }
    if (_discount <= 0) {
      toastNotify("Please set a discount greater than 0%");
      return;
    }

    final promo = Promotion(
      occasion: _selectedOccasion,
      start: _startDate!,
      end: _endDate!,
      discount: _discount,
    );

    setState(() => _saving = true);
    final payload = jsonEncode(promo.toJson());
    await ProfilePrefs.saveField(widget.prefKey, payload);
    setState(() => _saving = false);

    toastNotify("Promotion saved");
    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    final availableOccasions = getAvailableOccasions();

    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text("Promotions"),
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
                padding: const EdgeInsets.all(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (availableOccasions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "No active occasion available right now",
                            ),
                          ),
                        if (availableOccasions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SelectionInputRow(
                              title: "Occasion",
                              hintText: "Select occasion",
                              isRequired: true,
                              selectedValue: _selectedOccasion,
                              options: availableOccasions
                                  .map((o) => o.name)
                                  .toList(),
                              onSelected: (val) =>
                                  setState(() => _selectedOccasion = val),
                            ),
                          ),

                        Divider(color: Colors.grey[200]),
                        _datePickerRow(
                          "Start Date",
                          _startDate,
                          () => _pickDate(true),
                        ),
                        Divider(color: Colors.grey[200]),
                        _datePickerRow(
                          "End Date",
                          _endDate,
                          () => _pickDate(false),
                        ),
                        Divider(color: Colors.grey[200]),

                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            "Discount: ${_discount.toStringAsFixed(0)}%",
                            style: const TextStyle(
                              fontSize: 14,
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
                          onChanged: (value) =>
                              setState(() => _discount = value),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _datePickerRow(String title, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            Text(
              date != null
                  ? "${date.day}/${date.month}/${date.year}"
                  : "Select date",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
