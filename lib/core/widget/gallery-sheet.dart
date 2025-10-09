// file: media_action_sheet.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:photo_manager/photo_manager.dart'; // for AssetEntity type

Future<dynamic> showMediaSheet(
  BuildContext context, {
  int maxAssets = 20,
  List<AssetEntity>? selectedAssets, // NEW
}) {
  final theme = Theme.of(context);
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<dynamic>(
    context: context,
    backgroundColor: isDark ? Color.fromARGB(255, 17, 17, 19) : kWhite10,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1B1B1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        try {
                          final List<AssetEntity>? result =
                              await AssetPicker.pickAssets(
                                ctx,
                                pickerConfig: AssetPickerConfig(
                                  maxAssets: maxAssets,
                                  requestType: RequestType.common,
                                  pageSize: 80,
                                  selectedAssets:
                                      selectedAssets, // PASS PREVIOUS
                                ),
                              );
                          Navigator.of(ctx).pop(result);
                        } catch (e) {
                          debugPrint('AssetPicker error: $e');
                          Navigator.of(ctx).pop(null);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 18.0,
                          ),
                          child: Center(
                            child: Text(
                              'Choose from Album',
                              style: theme.textTheme.titleMedium?.copyWith(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Divider(
                    color: isDark ? kWhite50 : kWhiteSmoke,
                    thickness: 0.5,
                  ),

                  // Capture / Camera
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        try {
                          // open camera (image). To capture video, use pickVideo()
                          final ImagePicker picker = ImagePicker();
                          final XFile? captured = await picker.pickImage(
                            source: ImageSource.camera,
                            preferredCameraDevice: CameraDevice.rear,
                            maxWidth: 4000,
                            maxHeight: 4000,
                            imageQuality: 90,
                          );

                          Navigator.of(ctx).pop(
                            captured,
                          ); // returns XFile? (null if user cancelled)
                        } catch (e) {
                          debugPrint('Camera error: $e');
                          Navigator.of(ctx).pop(null);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 18.0,
                          ),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Capture / Camera',
                                style: theme.textTheme.titleMedium?.copyWith(),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Capture & Go Live',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    color: isDark ? kWhite50 : kWhiteSmoke,
                    thickness: 0.5,
                  ),

                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        Navigator.of(context).pushNamed("/stoqle_text_posting");
                        // Navigator.of(ctx).pop(result);
                      },
                      child: Container(
                        width: double.infinity,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 18.0,
                            ),
                            child: Text(
                              'Text',
                              style: theme.textTheme.titleMedium?.copyWith(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Cancel button in a separate card (iOS style)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1B1B1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(ctx).pop(null),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: theme.textTheme.titleMedium?.copyWith(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}
