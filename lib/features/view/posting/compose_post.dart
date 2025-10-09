// file: compose_post_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stoqle/component/default/defaultButton.dart';
import 'package:stoqle/component/loader/custom_loader.dart';
import 'package:video_player/video_player.dart';
import 'package:stoqle/component/colors/color.dart';

import '../gallery/selected_assets_page.dart'; // your colors

class ComposePostPage extends StatefulWidget {
  final List<AssetEntity> assets;
  const ComposePostPage({Key? key, required this.assets}) : super(key: key);

  @override
  _ComposePostPageState createState() => _ComposePostPageState();
}

class _ComposePostPageState extends State<ComposePostPage> {
  late List<AssetEntity> _assets;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _subtitleCtrl = TextEditingController();
  bool _isPublic = true;

  // For full screen viewer (used when tapping a thumbnail)
  void _openFullScreenViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _FullScreenViewer(assets: _assets, initialIndex: initialIndex),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _assets = List.from(widget.assets);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  void _onPreviewPressed() {
    // open your existing SelectedAssetsPage as a preview
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            SelectedAssetsPage(assets: List.from(_assets), initialIndex: 0),
      ),
    );
  }

  void _onPostPressed() {
    final payload = {
      'assets': _assets,
      'title': _titleCtrl.text.trim(),
      'subtitle': _subtitleCtrl.text.trim(),
      'visibility': _isPublic ? 'public' : 'private',
    };

    // return payload to caller (or handle upload here)
    Navigator.of(context).pop(payload);
  }

  Widget _thumbnailBuilder(int idx) {
    final asset = _assets[idx];
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
      builder: (context, snap) {
        final thumb = snap.data;
        return GestureDetector(
          onTap: () => _openFullScreenViewer(idx),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade900,
              image: thumb != null
                  ? DecorationImage(
                      image: MemoryImage(thumb),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: asset.type == AssetType.video
                ? Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        // color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post', style: TextStyle()),
        iconTheme: const IconThemeData(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // top thumbnails
            if (_assets.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  itemCount: _assets.length,
                  itemBuilder: (context, idx) => _thumbnailBuilder(idx),
                ),
              )
            else
              SizedBox(height: 12),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 6,
              ),
              child: TextField(
                controller: _titleCtrl,
                style: const TextStyle(),
                decoration: InputDecoration(
                  hintText: 'Write a title...',
                  hintStyle: TextStyle(),
                  filled: true,
                  // fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Subtitle / Description
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 6,
              ),
              child: TextField(
                controller: _subtitleCtrl,
                maxLines: 3,
                style: const TextStyle(),
                decoration: InputDecoration(
                  hintText: 'Write a description or subtitle...',
                  hintStyle: TextStyle(),
                  filled: true,
                  // fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // visibility toggle (Public / Private)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 8,
              ),
              child: Row(
                children: [
                  const Text('Visibility', style: TextStyle()),
                  const SizedBox(width: 12),
                  ToggleButtons(
                    isSelected: [_isPublic, !_isPublic],
                    onPressed: (i) {
                      setState(() {
                        _isPublic = (i == 0);
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor: AppColors.kDefault.withOpacity(0.9),
                    // color: Colors.white70,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Public'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Private'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Spacer to push the buttons to bottom
            Expanded(child: Container()),

            // Bottom buttons: Preview + Post
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white12),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _onPreviewPressed,
                        child: Text('Preview', style: TextStyle()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kDefault,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _onPostPressed,
                        child: Text('Post', style: TextStyle(color: kWhite)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenViewer extends StatefulWidget {
  final List<AssetEntity> assets;
  final int initialIndex;
  const _FullScreenViewer({
    Key? key,
    required this.assets,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  __FullScreenViewerState createState() => __FullScreenViewerState();
}

class __FullScreenViewerState extends State<_FullScreenViewer> {
  late PageController _pageController;
  late List<AssetEntity> _assets;
  int _currentIndex = 0;
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _assets = List.from(widget.assets);
    _currentIndex = widget.initialIndex.clamp(0, _assets.length - 1);
    _pageController = PageController(initialPage: _currentIndex);

    // initialize only current video
    _ensureVideoInit(_currentIndex);
  }

  Future<void> _ensureVideoInit(int index) async {
    final asset = _assets[index];
    if (asset.type != AssetType.video) return;

    final id = asset.id;
    if (_videoControllers.containsKey(id)) return;

    final file = await asset.file;
    if (file == null) return;

    final ctrl = VideoPlayerController.file(file);
    _videoControllers[id] = ctrl;
    await ctrl.initialize();
    ctrl.setLooping(true);

    // Play only if it’s the current page
    if (_currentIndex == index) {
      ctrl.play();
    }
    setState(() {});
  }

  void _disposeVideoController(String id) {
    if (_videoControllers.containsKey(id)) {
      _videoControllers[id]!.pause();
      _videoControllers[id]!.dispose();
      _videoControllers.remove(id);
    }
  }

  @override
  void dispose() {
    // Safely dispose all controllers
    for (final ctrl in _videoControllers.values) {
      if (ctrl.value.isInitialized) {
        ctrl.pause();
      }
      ctrl.dispose();
    }
    _videoControllers.clear();

    _pageController.dispose();
    super.dispose();
  }

  Widget _buildItem(BuildContext context, int index) {
    final asset = _assets[index];

    if (asset.type == AssetType.video) {
      return FutureBuilder<File?>(
        future: asset.file,
        builder: (context, snap) {
          final file = snap.data;
          if (file == null) {
            return Center(child: CustomCircularProgressIndicator());
          }

          final ctrl = _videoControllers[asset.id];

          // ✅ Guard: don’t try to use a disposed controller
          if (ctrl == null || !ctrl.value.isInitialized || !mounted) {
            return Center(child: CustomCircularProgressIndicator());
          }

          return GestureDetector(
            onTap: () {
              if (!mounted) return;
              if (ctrl.value.isPlaying) {
                ctrl.pause();
              } else {
                ctrl.play();
              }
              setState(() {});
            },
            child: Center(
              child: AspectRatio(
                aspectRatio: ctrl.value.aspectRatio,
                child: VideoPlayer(ctrl),
              ),
            ),
          );
        },
      );
    } else {
      return FutureBuilder<File?>(
        future: asset.file,
        builder: (context, snap) {
          final f = snap.data;
          if (f == null) {
            return Center(child: CustomCircularProgressIndicator());
          }
          return InteractiveViewer(
            child: Center(child: Image.file(f, fit: BoxFit.contain)),
          );
        },
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_currentIndex + 1}/${_assets.length}', // ✅ Page count
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          Container(
            height: 40,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Set as Cover: ${_currentIndex + 1}")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kDefault,
                // foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                ), // Padding inside the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 5),
                  Text(
                    "Set as cover",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _assets.length,
            onPageChanged: (i) async {
              // Pause and dispose previous video
              final prev = _assets[_currentIndex];
              if (prev.type == AssetType.video) {
                _disposeVideoController(prev.id);
              }

              _currentIndex = i;
              setState(() {});

              await _ensureVideoInit(i);
            },
            itemBuilder: _buildItem,
          ),

          // ✅ Delete Button at Bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  if (_assets.isNotEmpty) {
                    setState(() {
                      final removed = _assets.removeAt(_currentIndex);

                      // dispose video controller if it was video
                      if (removed.type == AssetType.video) {
                        _disposeVideoController(removed.id);
                      }

                      // Adjust index if needed
                      if (_currentIndex >= _assets.length) {
                        _currentIndex = _assets.length - 1;
                      }
                    });

                    if (_assets.isEmpty) {
                      Navigator.pop(context); // exit if no assets left
                    }
                  }
                },
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                  "Delete Image",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
