// imports (update pubspec.yaml to include: image_picker, photo_manager, wechat_assets_picker)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DocumentUploadSheet extends StatefulWidget {
  final String title;
  final String placeholderAsset;
  final List<String> guidelines;
  final File? selectedFile;
  final ValueChanged<File?> onFileSelected;

  const DocumentUploadSheet({
    Key? key,
    required this.title,
    required this.placeholderAsset,
    required this.guidelines,
    required this.selectedFile,
    required this.onFileSelected,
  }) : super(key: key);

  @override
  State<DocumentUploadSheet> createState() => _DocumentUploadSheetState();
}

class _DocumentUploadSheetState extends State<DocumentUploadSheet> {
  final ImagePicker _imagePicker = ImagePicker();

  /// Unified pick method:
  /// - fromCamera: uses image_picker (camera)
  /// - fromCamera == false: uses wechat_assets_picker for SINGLE image pick (maxAssets: 1)
  Future<File?> _pickFile({required bool fromCamera}) async {
    try {
      if (fromCamera) {
        // camera via image_picker (returns XFile -> convert to File)
        final XFile? xfile = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (xfile == null) return null;
        return File(xfile.path);
      } else {
        // gallery via wechat_assets_picker with permission handling
        final PermissionState ps = await PhotoManager.requestPermissionExtend();

        // ps.isAuth => full access; ps.hasAccess => has at least limited access
        if (ps.isAuth || ps.hasAccess) {
          final List<AssetEntity>? assets = await AssetPicker.pickAssets(
            context,
            pickerConfig: AssetPickerConfig(
              requestType: RequestType.image,
              maxAssets: 1, // <-- FORCE single selection
            ),
          );
          if (assets == null || assets.isEmpty) return null;
          return await assets.first.file;
        }

        // If permission is limited, let user re-select limited set (native UI)
        if (ps == PermissionState.limited) {
          // This opens the system "Select More Photos..." UI on iOS.
          // The user can add more photos to the app's allowed set.
          await PhotoManager.presentLimited();

          // re-check permission after user finishes the limited-picker
          final PermissionState newPs =
              await PhotoManager.requestPermissionExtend();
          if (newPs.isAuth || newPs.hasAccess) {
            final List<AssetEntity>? assets = await AssetPicker.pickAssets(
              context,
              pickerConfig: AssetPickerConfig(
                requestType: RequestType.image,
                maxAssets: 1,
              ),
            );
            if (assets == null || assets.isEmpty) return null;
            return await assets.first.file;
          } else {
            // user still limited/denied -> open settings as fallback
            PhotoManager.openSetting();
            return null;
          }
        }

        // any other state (denied/restricted) -> open Settings
        PhotoManager.openSetting();
        return null;
      }
    } catch (e, st) {
      // dev: log for debugging
      // print(e); print(st);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.78,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // header
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        widget.placeholderAsset,
                        fit: BoxFit.cover,
                        // height: 180,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            height: 160,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                LucideIcons.image,
                                size: 36,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upload Guidelines',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ...widget.guidelines.map(
                          (g) =>
                              Text('• $g', style: const TextStyle(height: 1.4)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final File? file = await _pickFile(fromCamera: true);
                      widget.onFileSelected(file);
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade600, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Colors.red.shade600,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.camera,
                          size: 16,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Take Photo',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final File? file = await _pickFile(fromCamera: false);
                      widget.onFileSelected(file);
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Upload from Gallery',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
