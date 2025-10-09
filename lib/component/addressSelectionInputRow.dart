import 'package:flutter/material.dart';

class AddressSelectionInputRow extends StatelessWidget {
  final String title;
  final bool isRequired;
  final String hintText;
  final String? selectedValue;
  final Map<String, Map<String, List<String>>>? hierarchy;
  final ValueChanged<String> onSelected;

  const AddressSelectionInputRow({
    Key? key,
    required this.title,
    this.isRequired = false,
    this.hintText = '',
    this.selectedValue,
    this.hierarchy,
    required this.onSelected,
  }) : assert(hierarchy != null, 'Hierarchy must be provided'),
       super(key: key);

  void _showSelectionSheet(
    BuildContext context,
    Map<String, Map<String, List<String>>> hierarchy,
    ValueChanged<String> onSelected,
    FormFieldState<String> fieldState,
  ) {
    String? selectedCountry;
    String? selectedState;
    String? selectedLga;
    int level = 0; // 0 = country, 1 = state, 2 = lga
    String stateQuery = '';
    String lgaQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // now these vars won’t reset when rebuilding
            final countries = hierarchy.keys.toList()
              ..sort((a, b) {
                if (a == 'Nigeria') return -1; // Nigeria always first
                if (b == 'Nigeria') return 1;
                return a.compareTo(b); // sort others alphabetically
              });
            final states = (selectedCountry != null)
                ? (hierarchy[selectedCountry]!.keys.toList()..sort())
                : <String>[];
            final lgas = (selectedCountry != null && selectedState != null)
                ? (List<String>.from(
                    hierarchy[selectedCountry]![selectedState] ?? [],
                  )..sort())
                : <String>[];

            List<String> filteredStates = states
                .where(
                  (s) => s.toLowerCase().contains(stateQuery.toLowerCase()),
                )
                .toList();
            List<String> filteredLgas = lgas
                .where((l) => l.toLowerCase().contains(lgaQuery.toLowerCase()))
                .toList();

            bool canNext() {
              if (level == 0) return selectedCountry != null;
              if (level == 1) return selectedState != null;
              if (level == 2) return selectedLga != null;
              return false;
            }

            void commitSelectionAndClose() {
              if (selectedCountry != null &&
                  selectedState != null &&
                  selectedLga != null) {
                final full = '$selectedCountry, $selectedState, $selectedLga';
                onSelected(full);
                fieldState.didChange(full);
                Navigator.pop(context);
              }
            }

            Widget buildHeader() {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level == 0
                                ? 'Select Country'
                                : level == 1
                                ? 'Select State'
                                : 'Select LGA',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Container(
                              width: 36,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            }

            Widget buildBreadcrumb() {
              // breadcrumb only visible when user has advanced to level 1 or 2
              if (level == 0) return const SizedBox.shrink();

              TextStyle titleStyle = const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              );
              TextStyle valueStyle = const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          level = 0;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Country', style: titleStyle),
                          const SizedBox(height: 4),
                          Text(
                            selectedCountry ?? 'Please select',
                            style: selectedCountry != null
                                ? valueStyle
                                : titleStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: () {
                        if (selectedCountry != null) {
                          setState(() {
                            level = 1;
                          });
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('State', style: titleStyle),
                          const SizedBox(height: 4),
                          Text(
                            selectedState ?? 'Please select',
                            style: selectedState != null
                                ? valueStyle
                                : titleStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: () {
                        if (selectedState != null) {
                          setState(() {
                            level = 2;
                          });
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LGA', style: titleStyle),
                          const SizedBox(height: 4),
                          Text(
                            selectedLga ?? 'Please select',
                            style: selectedLga != null
                                ? valueStyle
                                : titleStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            Widget buildListForLevel() {
              if (level == 0) {
                // Country list (simple list)
                return ListView.separated(
                  itemCount: countries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 0),
                  itemBuilder: (context, i) {
                    final c = countries[i];
                    final bool isSelected = c == selectedCountry;
                    final bool isNigeria = c == 'Nigeria';

                    return Padding(
                      padding: const EdgeInsets.only(left: 14.0),
                      child: ListTile(
                        dense: true,
                        minVerticalPadding: 0,
                        minTileHeight: 40,
                        title: Text(
                          c,
                          style: TextStyle(
                            color: isNigeria
                                ? (isSelected ? Colors.red : Colors.black87)
                                : Colors.grey, // disable others
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isNigeria
                            ? (isSelected
                                  ? const Icon(Icons.check, color: Colors.red)
                                  : null)
                            : const Text(
                                "Coming Soon",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                        onTap: isNigeria
                            ? () {
                                setState(() {
                                  selectedCountry = c;
                                  selectedState = null;
                                  selectedLga = null;
                                  level = 1;
                                });
                              }
                            : null, // disable others
                      ),
                    );
                  },
                );
              } else if (level == 1) {
                // State view with search + list
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search state...',
                            border: InputBorder.none, // 🔹 removes underline
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() => stateQuery = v),
                        ),
                      ),
                    ),

                    Expanded(
                      child: filteredStates.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  'No states found',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredStates.length,

                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 0),
                              itemBuilder: (context, i) {
                                final s = filteredStates[i];
                                final bool isSelected = s == selectedState;
                                return Padding(
                                  padding: const EdgeInsets.only(left: 14.0),
                                  child: ListTile(
                                    dense: true,
                                    minVerticalPadding: 0,
                                    minTileHeight: 35,

                                    title: Text(
                                      s,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.red
                                            : Colors.black87,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.red,
                                          )
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        selectedState = s;
                                        selectedLga = null;
                                        level = 2; // go to LGA
                                        lgaQuery = '';
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              } else {
                // Level == 2: LGA with search + list
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search LGA...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),

                            isDense: true,
                          ),
                          onChanged: (v) => setState(() => lgaQuery = v),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filteredLgas.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  'No LGAs found',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: filteredLgas.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 0),
                              itemBuilder: (context, i) {
                                final l = filteredLgas[i];
                                final bool isSelected = l == selectedLga;
                                return Padding(
                                  padding: const EdgeInsets.only(left: 14.0),
                                  child: ListTile(
                                    dense: true,
                                    minVerticalPadding: 0,
                                    minTileHeight: 35,
                                    title: Text(
                                      l,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.red
                                            : Colors.black87,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.red,
                                          )
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        selectedLga = l;
                                      });
                                      // commit immediately on LGA tap
                                      final full =
                                          '$selectedCountry, $selectedState, $selectedLga';
                                      onSelected(full);
                                      fieldState.didChange(
                                        full,
                                      ); // ✅ update form state immediately

                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              }
            }

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.76,
              child: Column(
                children: [
                  buildHeader(),
                  buildBreadcrumb(), // only visible when level > 0
                  // main content
                  Expanded(child: buildListForLevel()),
                  // Next button (advances if selection exists)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canNext()
                                ? Colors.red
                                : Colors.grey.shade300,
                            foregroundColor: canNext()
                                ? Colors.white
                                : Colors.grey.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: canNext()
                              ? () {
                                  if (level == 0 && selectedCountry != null) {
                                    setState(() => level = 1);
                                    return;
                                  }
                                  if (level == 1 && selectedState != null) {
                                    setState(() => level = 2);
                                    return;
                                  }
                                  if (level == 2 && selectedLga != null) {
                                    commitSelectionAndClose();
                                    return;
                                  }
                                }
                              : null,
                          child: Text(
                            level < 2 ? 'Next' : 'Select',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: selectedValue,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return "$title is required";
        }
        return null;
      },
      builder: (fieldState) {
        // Sync external selectedValue -> FormField internal value.
        // Use addPostFrameCallback to avoid mutating state during build.
        if (selectedValue != fieldState.value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // double-check mounted context
            try {
              fieldState.didChange(selectedValue);
            } catch (_) {}
          });
        }

        final theme = Theme.of(fieldState.context);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () =>
                    _showSelectionSheet(fieldState.context, hierarchy!, (val) {
                      onSelected(val); // update parent
                      fieldState.didChange(val); // update FormField immediately
                    }, fieldState),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Label
                    Expanded(
                      flex: 3,
                      child: Text.rich(
                        TextSpan(
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    // Selected value or hint
                    Expanded(
                      flex: 7,
                      child: Text(
                        selectedValue ?? hintText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: selectedValue == null
                              ? Colors.grey[600]
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Error under same column as value/hint
              if (fieldState.hasError)
                Row(
                  children: [
                    const Spacer(flex: 3), // align under flex:7 column
                    Expanded(
                      flex: 7,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          fieldState.errorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 10),
              Divider(thickness: 1, height: 1, color: Colors.grey[200]),
            ],
          ),
        );
      },
    );
  }
}
