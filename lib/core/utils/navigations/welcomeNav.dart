// user_navigator.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stoqle/core/widget/capturing-live.dart';
import 'package:stoqle/core/widget/gallery-sheet.dart';
import 'package:stoqle/features/view/market/markeplece.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../component/colors/color.dart';
import '../../../features/view/gallery/selected_assets_page.dart';
import '../../../features/view/home/dashboard.dart';
import '../../../features/view/message/message-selection.dart';
import '../../../features/view/profile/me/me.dart';

class Usernavigator extends StatefulWidget {
  @override
  _UsernavigatorState createState() => _UsernavigatorState();
}

class _UsernavigatorState extends State<Usernavigator>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;

  // keep selected assets here so selection persists between openings
  List<AssetEntity> _selectedAssets = [];

  final _pageOptions = [
    Dashboard(),
    MarketPlace(),
    Container(), // placeholder for plus (we open sheet instead)
    MessageDashboard(),
    ProfileMe(),
  ];

  // inside _UsernavigatorState

  void _onItemTapped(int index) async {
    if (index == 2) {
      // open action sheet (existing)
      final result = await showMediaSheet(
        context,
        maxAssets: 5,
        selectedAssets: _selectedAssets, // pass prior selection if any
      );

      if (result == null) return;

      if (result is List<AssetEntity>) {
        // user just picked some assets from the picker opened by the sheet
        _selectedAssets = List.from(result); // update local cache

        // open the preview page
        final previewResult = await Navigator.of(context)
            .push<List<AssetEntity>?>(
              MaterialPageRoute(
                builder: (_) => SelectedAssetsPage(
                  assets: List.from(_selectedAssets),
                  initialIndex: 0,
                ),
              ),
            );

        // CASE A: previewResult == null -> user pressed Back on preview
        if (previewResult == null) {
          // Re-open AssetPicker directly from the main context (not via sheet)
          // pass the currently selected assets so the picker shows them pre-selected
          final List<AssetEntity>? reopened = await AssetPicker.pickAssets(
            context,
            pickerConfig: AssetPickerConfig(
              maxAssets: 5,
              requestType: RequestType.common,
              selectedAssets: _selectedAssets,
              pageSize: 80,
            ),
          );

          // If user made changes in reopened picker, open preview again or update local list:
          if (reopened != null && reopened.isNotEmpty) {
            _selectedAssets = List.from(reopened);
            // open preview again with the new selection (optional)
            final again = await Navigator.of(context).push<List<AssetEntity>?>(
              MaterialPageRoute(
                builder: (_) => SelectedAssetsPage(
                  assets: List.from(_selectedAssets),
                  initialIndex: 0,
                ),
              ),
            );

            if (again != null) {
              // user pressed Next this time -> update and continue
              setState(() {
                _selectedAssets = List.from(again);
              });
            } else {
              // user backed out again -> reopen picker, etc. (up to you)
            }
          }
          return;
        }

        // CASE B: previewResult is a List -> user tapped Next and we got an updated list
        if (previewResult is List<AssetEntity>) {
          setState(() {
            _selectedAssets = List.from(previewResult);
          });
        }

        return;
      }

      if (result is XFile) {
        // handle camera capture (unchanged)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CapturedPreviewPage(filePath: result.path),
          ),
        );
        return;
      }

      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: _pageOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.houseSimple(), size: 20),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.storefront(), size: 20),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 50,
              height: 35,
              decoration: BoxDecoration(
                color: AppColors.kDefault,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(PhosphorIconsBold.plus, color: Colors.white),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.chatCircleDots(), size: 20),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.user(), size: 20),
            label: 'Me',
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
