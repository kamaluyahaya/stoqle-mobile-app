import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/helper/business-profile-helper.dart';
import 'model/page.dart';

// -----------------------------
// Editor
// -----------------------------
class ShippingDurationEditor extends StatefulWidget {
  final String prefKey;
  final String initialValue;

  const ShippingDurationEditor({
    Key? key,
    required this.prefKey,
    required this.initialValue,
  }) : super(key: key);

  @override
  State<ShippingDurationEditor> createState() => _ShippingDurationEditorState();
}

class _ShippingDurationEditorState extends State<ShippingDurationEditor> {
  late List<ShippingDurationItem> _items;
  bool _loading = true;
  bool _saving = false;

  static const _units = ['hours', 'days', 'weeks'];

  // Defaults are loaded from ProfilePrefs per-prefKey and updated on save
  late int _defaultAvgHours; // stored as hours
  late int _defaultPromiseHours; // stored as hours

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _loadDefaults();
    _loadItems();
  }

  Future<void> _loadDefaults() async {
    // default fallback if nothing stored
    const fallbackAvg = 16;
    const fallbackPromise = 48;

    final key = '${widget.prefKey}_defaults';
    try {
      final s = await ProfilePrefs.loadField(key);
      if (s != null && s.isNotEmpty) {
        final decoded = jsonDecode(s);
        if (decoded is Map) {
          _defaultAvgHours = (decoded['avg_hours'] is int)
              ? decoded['avg_hours']
              : int.tryParse('${decoded['avg_hours']}') ?? fallbackAvg;
          _defaultPromiseHours = (decoded['promise_hours'] is int)
              ? decoded['promise_hours']
              : int.tryParse('${decoded['promise_hours']}') ?? fallbackPromise;
          return;
        }
      }
    } catch (_) {}
    // fallback
    _defaultAvgHours = fallbackAvg;
    _defaultPromiseHours = fallbackPromise;
  }

  void _loadItems() {
    // Defaults: use stored defaults (hours) converted to hours->value+unit = hours with unit hours.
    final defaults = [
      ShippingDurationItem(type: 'avg', value: _defaultAvgHours, unit: 'hours'),
      ShippingDurationItem(
        type: 'promise',
        value: _defaultPromiseHours,
        unit: 'hours',
      ),
    ];

    final s = widget.initialValue;
    if (s.isEmpty) {
      _items = defaults;
    } else {
      try {
        final decoded = jsonDecode(s);
        if (decoded is List) {
          final loaded = decoded
              .map(
                (e) => ShippingDurationItem.fromJson(e as Map<String, dynamic>),
              )
              .toList();
          if (loaded.length == 2) {
            // ensure we have both types in correct order: avg then promise
            ShippingDurationItem? avgItem = loaded.firstWhere(
              (it) => it.type == 'avg',
              orElse: () => loaded[0],
            );
            ShippingDurationItem? promiseItem = loaded.firstWhere(
              (it) => it.type == 'promise',
              orElse: () => loaded.length > 1 ? loaded[1] : loaded[0].copy(),
            );
            _items = [avgItem.copy(), promiseItem.copy()];
          } else {
            _items = defaults;
          }
        } else {
          _items = defaults;
        }
      } catch (_) {
        _items = defaults;
      }
    }

    setState(() => _loading = false);
  }

  int _unitToHoursMultiplier(String unit) {
    switch (unit) {
      case 'days':
        return 24;
      case 'weeks':
        return 24 * 7;
      case 'hours':
      default:
        return 1;
    }
  }

  int _toHours(ShippingDurationItem it) {
    final mult = _unitToHoursMultiplier(it.unit);
    return it.value * mult;
  }

  int _hoursToUnitValue(int hours, String unit) {
    final mult = _unitToHoursMultiplier(unit);
    return (hours + mult - 1) ~/ mult; // ceil
  }

  Future<void> _saveDefaults(int avgHours, int promiseHours) async {
    final key = '${widget.prefKey}_defaults';
    final payload = jsonEncode({
      'avg_hours': avgHours,
      'promise_hours': promiseHours,
    });
    await ProfilePrefs.saveField(key, payload);
    // update in-memory defaults
    _defaultAvgHours = avgHours;
    _defaultPromiseHours = promiseHours;
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final avg = _items[0];
    final promise = _items[1];

    // if any <= 0 -> replace with persisted defaults
    if (avg.value <= 0) {
      final newVal = _hoursToUnitValue(_defaultAvgHours, avg.unit);
      setState(() => avg.value = newVal);
    }
    if (promise.value <= 0) {
      final newVal = _hoursToUnitValue(_defaultPromiseHours, promise.unit);
      setState(() => promise.value = newVal);
    }

    int avgHours = _toHours(avg);
    int promiseHours = _toHours(promise);

    if (promiseHours <= avgHours) {
      // enforce promise > avg by bumping promise to avg + 1 hour (keep promise unit)
      final desiredHours = avgHours + 1;
      final newPromiseValue = _hoursToUnitValue(desiredHours, promise.unit);
      setState(() => promise.value = newPromiseValue);
      promiseHours = _toHours(promise);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Promise duration adjusted to be greater than average (now ${promise.value} ${promise.unit}).',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }

    // Save the shipping durations payload (includes `type` so titles remain correct)
    final payload = jsonEncode(_items.map((e) => e.toJson()).toList());
    await ProfilePrefs.saveField(widget.prefKey, payload);

    // Persist these saved values as the new defaults (store as hours)
    await _saveDefaults(avgHours, promiseHours);

    setState(() => _saving = false);
    Navigator.of(context).pop(payload);
  }

  void _increment(ShippingDurationItem item) {
    setState(() => item.value = item.value + 1);
  }

  void _decrement(ShippingDurationItem item) {
    // Prevent going to 0. Minimum is 1.
    if (item.value > 1) {
      setState(() => item.value = item.value - 1);
    }
  }

  Future<void> _editNumeric(ShippingDurationItem item) async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) {
        final ctrl = TextEditingController(text: item.value.toString());
        return AlertDialog(
          title: const Text('Enter duration'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Number (must be >=1)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final v = int.tryParse(ctrl.text.trim()) ?? item.value;
                Navigator.of(context).pop(v);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      if (result <= 0) {
        final defHours = (item.type == 'avg')
            ? _defaultAvgHours
            : _defaultPromiseHours;
        final newVal = _hoursToUnitValue(defHours, item.unit);
        setState(() {
          item.value = newVal;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Duration cannot be 0 — applied default (${newVal} ${item.unit}).',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() => item.value = result);
      }
    }
  }

  // builds a dynamic title using the current item value + unit
  String _displayTitleFor(ShippingDurationItem item) {
    final human = '${item.value} ${item.unit}';
    if (item.type == 'avg') {
      return 'Ships within $human on average';
    } else {
      return 'Promise to ship within $human, delay compensation guaranteed';
    }
  }

  Widget _buildDurationControl(ShippingDurationItem item) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: OutlinedButton(
            onPressed: () => _decrement(item),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(Icons.remove, size: 18),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _editNumeric(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.kDefault,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              '${item.value}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          height: 36,
          child: OutlinedButton(
            onPressed: () => _increment(item),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(Icons.add, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _units.map((u) {
              final selected = item.unit == u;
              return InkWell(
                onTap: () => setState(() => item.unit = u),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? Colors.red.shade50 : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    u,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? Colors.red : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(ShippingDurationItem item) {
    final human = '${item.value} ${item.unit}';
    final displayTitle = _displayTitleFor(item);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // dynamic title now
          Text(
            displayTitle,
            style: TextStyle(fontFamily: "Bold", fontSize: 15, color: kBlack),
          ),
          const SizedBox(height: 8),
          Text('Duration: $human', style: TextStyle(color: AppColors.accent1)),
          const SizedBox(height: 12),
          _buildDurationControl(item),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CupertinoColors.systemGroupedBackground,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: kBlack),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text(
          'Shipping Info',
          style: TextStyle(color: kBlack, fontFamily: "Bold"),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: _items.map((i) => _buildCard(i)).toList(),
                      ),
                    ),
                    Text(
                      'Tip: Durations cannot be zero. Promise must be greater than average.',
                      style: TextStyle(color: AppColors.accent4, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
    );
  }
}
