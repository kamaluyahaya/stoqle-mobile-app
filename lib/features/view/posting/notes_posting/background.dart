// lib/screens/text_background_picker_page.dart
import 'package:flutter/material.dart';
import 'package:stoqle/component/lib/models/background_config.dart';
import 'package:stoqle/component/lib/utils/generator_config.dart';
import 'package:stoqle/component/colors/color.dart';

import '../../../../component/lib/widget/background_preview.dart';
import 'final_posting.dart'; // keep your path

class TextBackgroundPickerPage extends StatefulWidget {
  final String initialText;

  const TextBackgroundPickerPage({
    Key? key,
    this.initialText = 'This is my post 😎',
  }) : super(key: key);

  @override
  _TextBackgroundPickerPageState createState() =>
      _TextBackgroundPickerPageState();
}

class _TextBackgroundPickerPageState extends State<TextBackgroundPickerPage> {
  static const int count = 24;
  late List<BackgroundConfig> configs;
  int selectedIndex = 0;
  late String postText;
  String quoteAuthor = '';
  DateTime selectedDate = DateTime.now();
  late final ConfigGenerator _generator;

  @override
  void initState() {
    super.initState();
    postText = widget.initialText;
    _generator = ConfigGenerator(); // no seed so it is fresh each open
    configs = _generator.generateList(count);
    selectedIndex = 0;
  }

  void _regenerateAll() {
    setState(() {
      configs = _generator.generateList(count);
      // keep selection within range
      selectedIndex = (selectedIndex >= configs.length) ? 0 : selectedIndex;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final config = configs[selectedIndex];

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.lightBackground,
        title: const Text('Preview', style: TextStyle(color: Colors.black87)),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Randomize all',
            icon: const Icon(Icons.shuffle, color: Colors.black87),
            onPressed: _regenerateAll,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),
          // Big preview - always large
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: BackgroundPreview(
                  config: config,
                  text: postText,
                  showOverlay: true,
                  thumbnailMode: false,
                  quoteAuthor: quoteAuthor,
                  date: selectedDate,
                ),
              ),
            ),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),

                if (configs[selectedIndex].template ==
                    TemplateType.dateHeader) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${selectedDate.toLocal().year}-${selectedDate.toLocal().month.toString().padLeft(2, '0')}-${selectedDate.toLocal().day.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _pickDate,
                        child: const Text('Change date'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Thumbnails - small, horizontal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: configs.length,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemBuilder: (context, index) {
                  final cfg = configs[index];
                  final isSelected = index == selectedIndex;

                  // fixed outer size for each thumbnail (prevents overflow)
                  const double thumbWidth = 84.0;
                  const double thumbHeight = 100.0;
                  const double borderWidth = 2.0;

                  return GestureDetector(
                    onTap: () => setState(() => selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: thumbWidth,
                      // outer decoration controls shadow + radius but NOT the border thickness
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      // ClipRRect ensures child can't paint outside rounded corners
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          // draw selected background + inner border *inside* the fixed width
                          color: isSelected
                              ? Colors.black.withOpacity(0.06)
                              : null,
                          child: Container(
                            // inner container that carries the actual border drawn inside the fixed area
                            padding: EdgeInsets.all(
                              isSelected ? borderWidth : 0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.redAccent,
                                      width: borderWidth,
                                    )
                                  : null,
                            ),
                            // Constrain the preview so it never overflows the thumbnail box
                            child: SizedBox(
                              width: double.infinity,
                              height: thumbHeight,
                              child: BackgroundPreview(
                                config: cfg,
                                text: postText,
                                showOverlay: false,
                                thumbnailMode: true,
                                quoteAuthor: quoteAuthor,
                                date: selectedDate,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Pick your favorite label and Next button in same row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'Pick your favorite',
                  style: TextStyle(color: AppColors.kDarkMode),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    // Inside onTap of your Next button
                    final config = configs[selectedIndex];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FinalPreviewPage(
                          config: config,
                          text: postText,
                          quoteAuthor: quoteAuthor,
                          date: selectedDate,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    // width: 40,
                    width: MediaQuery.of(context).size.width / 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.kDefault,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        'Next',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.lightBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
