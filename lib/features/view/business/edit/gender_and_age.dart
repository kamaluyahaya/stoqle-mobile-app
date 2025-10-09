import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:stoqle/component/colors/color.dart';

import '../../../../core/widget/_buildCard.dart';
import '../../../../core/widget/_editableRow.dart';

class GenderAndAge extends StatefulWidget {
  const GenderAndAge({super.key});

  @override
  State<GenderAndAge> createState() => _GenderAndAgeState();
}

class _GenderAndAgeState extends State<GenderAndAge> {
  DateTime _selectedDate = DateTime.now(); // ✅ default to current date
  DateTime _currentDate = DateTime.now(); // ✅ default to current date

  String selectedGender = ""; // Holds the selected gender value

  @override
  void initState() {
    super.initState();

    // ✅ Automatically open the date picker after the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBirthDatePicker();
    });
  }

  bool isBirthDateEnabled = true;
  bool _isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  // Shows a bottom sheet with the ScrollDatePicker and a centered indicator
  Future<void> _showBirthDatePicker() async {
    DateTime tempDate = _selectedDate;

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 👈 shrink to fit content
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const Text("Choose Birth Date"),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedDate = tempDate);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 200,
                width: double.infinity, // 👈 ensure full width
                child: ScrollDatePicker(
                  selectedDate: tempDate,
                  minimumDate: DateTime(1980),
                  maximumDate: DateTime.now(),
                  locale: const Locale('en'),
                  options: DatePickerOptions(
                    diameterRatio: 5,
                    backgroundColor: isDark
                        ? AppColors.kDarkMode
                        : AppColors.lightBackground,
                  ),
                  scrollViewOptions: DatePickerScrollViewOptions(
                    year: ScrollViewDetailOptions(
                      margin: const EdgeInsets.only(left: 24, right: 8),
                      // alignment: Alignment.center,
                    ),
                    month: ScrollViewDetailOptions(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                    ),
                    day: ScrollViewDetailOptions(
                      margin: const EdgeInsets.only(left: 8, right: 24),
                      alignment: Alignment.center,
                    ),
                  ),
                  onDateTimeChanged: (DateTime value) {
                    setState(() {
                      tempDate = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 12),
              Text(
                'Use the wheel to pick your birth date then tap Done',
                textAlign: TextAlign.center,
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

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark
            ? AppColors.kDarkMode
            : AppColors.lightBackground,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text('Edit Birth Date', style: TextStyle()),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Ok', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Column(
                      children: [
                        // Show the currently selected date; tapping opens the picker bottom sheet
                        EditableRow(
                          label: 'Birth Date',
                          value: _isSameDate(_selectedDate, _currentDate)
                              ? 'Choose Birth Date'
                              : DateFormat.yMMMMd().format(_selectedDate),
                          onTap: _showBirthDatePicker,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                  const Text(
                    "Publicly Display",
                    style: TextStyle(fontSize: 16, fontFamily: "Medium"),
                  ),
                  const SizedBox(height: 5),
                  AppCard(
                    child: Column(
                      children: [
                        EditableRowToggle(
                          label: 'Show Birth Date',
                          value: isBirthDateEnabled, // <-- a bool in your state
                          onChanged: (newValue) {
                            setState(() {
                              isBirthDateEnabled = newValue;
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Divider(
                            color: isDark ? kWhite40 : kWhiteSmoke,
                            thickness: 0,
                          ),
                        ),
                        EditableRow(
                          label: 'Show age',
                          value: _isSameDate(_selectedDate, _currentDate)
                              ? 'Choose Birth Date'
                              : '${DateTime.now().year - _selectedDate.year} years',
                          onTap: _showBirthDatePicker,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
