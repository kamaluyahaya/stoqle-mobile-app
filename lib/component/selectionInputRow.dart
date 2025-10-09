import 'package:flutter/material.dart';
import 'package:stoqle/component/colors/color.dart';

/// A reusable input row widget for selecting a value from a bottom sheet.
class SelectionInputRow extends StatelessWidget {
  final String title;
  final bool isRequired;
  final String hintText;
  final String? selectedValue;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const SelectionInputRow({
    Key? key,
    required this.title,
    this.isRequired = false,
    this.hintText = '',
    this.selectedValue,
    required this.options,
    required this.onSelected,
  }) : super(key: key);

  void _showSelectionSheet(
    BuildContext context,
    String? selectedValue,
    List<String> options,
    ValueChanged<String> onSelected,
    FormFieldState<String> fieldState,
  ) {
    showModalBottomSheet(
      backgroundColor: AppColors.lightBackground,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        String? tempSelection = selectedValue;

        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.76,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),

                  // Scrollable list
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: options.map((option) {
                          final isSelected = option == tempSelection;
                          return GestureDetector(
                            onTap: () {
                              setState(() => tempSelection = option);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.red
                                      : Colors.grey.shade400,
                                ),
                                color: isSelected
                                    ? Colors.red.withOpacity(0.1)
                                    : null,
                              ),
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.red
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Next button
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            if (tempSelection != null) {
                              onSelected(tempSelection!);
                              fieldState.didChange(tempSelection);
                            }
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Next",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormField<String>(
      autovalidateMode:
          AutovalidateMode.onUserInteraction, // 🔥 live validation
      validator: (value) {
        if (isRequired && (selectedValue == null || selectedValue!.isEmpty)) {
          return "$title is required";
        }
        return null;
      },
      builder: (fieldState) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showSelectionSheet(
                  context,
                  selectedValue,
                  options,
                  onSelected,
                  fieldState,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Expanded(
                      flex: 3,
                      child: Text.rich(
                        TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          children: [
                            TextSpan(text: title),
                            if (isRequired)
                              const TextSpan(
                                text: ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Selected value or hint
                    Expanded(
                      flex: 7,
                      child: Text(
                        (selectedValue != null && selectedValue!.isNotEmpty)
                            ? selectedValue!
                            : hintText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              (selectedValue == null || selectedValue!.isEmpty)
                              ? Colors.grey[600] // hint style
                              : Colors.black, // selected value style
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // ✅ Error message under value column
              if (fieldState.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: (4 / 11.5) * 300),
                  child: Text(
                    fieldState.errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 10),
              // Divider(thickness: 1, height: 1, color: Colors.grey[200]),
            ],
          ),
        );
      },
    );
  }
}
