// lib/pages/selected_assets_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/component/lib/db/draft_db.dart';
import 'package:stoqle/component/lib/models/draft_assets.dart';
import 'package:stoqle/component/lib/services/simulated_player.dart';
import 'package:stoqle/component/loader/custom_loader.dart';
import 'package:video_player/video_player.dart';
import '../posting/compose_post.dart';

class SelectedAssetsPage extends StatefulWidget {
  final List<AssetEntity> assets;
  final int initialIndex;
  const SelectedAssetsPage({
    required this.assets,
    this.initialIndex = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<SelectedAssetsPage> createState() => _SelectedAssetsPageState();
}

class _SelectedAssetsPageState extends State<SelectedAssetsPage> {
  late List<AssetEntity> _assets;
  late PageController _pageController;
  bool _containsVideo = false;
  SimulatedPlayerController? _sim;
  List<DraftAsset> _cached = [];
  bool _wasPlayingBeforeSeek = false;

  // ***** <-- NEW: current index tracking for thumbnails & selection highlight
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _assets = List.from(widget.assets);
    _currentIndex = widget.initialIndex.clamp(
      0,
      _assets.length > 0 ? _assets.length - 1 : 0,
    );
    _pageController = PageController(initialPage: _currentIndex);
    _containsVideo = _assets.any((a) => a.type == AssetType.video);
    _prepareCache();
  }

  @override
  void dispose() {
    _sim?.disposeController();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _prepareCache() async {
    // precache images for instant display
    for (final a in _assets) {
      final f = await a.file;
      if (f == null) continue;
      if (a.type == AssetType.image) precacheImage(FileImage(f), context);
    }

    final db = DraftDb();
    await db.clearAll();
    final List<DraftAsset> saved = [];
    int order = 0;
    for (final a in _assets) {
      final f = await a.file;
      if (f == null) continue;
      final type = a.type == AssetType.video
          ? DraftAssetType.video
          : DraftAssetType.image;
      final durMs = a.type == AssetType.video
          ? a.videoDuration.inMilliseconds
          : 3000;
      final savedAsset = await db.cacheAndSaveAsset(
        originalId: a.id,
        sourceFile: f,
        type: type,
        durationMs: durMs,
        order: order++,
      );
      saved.add(savedAsset);
    }
    _cached = saved;

    if (_containsVideo) {
      _sim = SimulatedPlayerController(
        pageController: _pageController,
        assets: _cached,
      );
      _sim!.addListener(() => setState(() {}));

      // auto start after cache is ready
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // if first item is a video, ensure it's initialized before starting playback
        if (_cached.isNotEmpty && _cached.first.type == DraftAssetType.video) {
          await _sim!.ensureVideoCtrl(0); // wait for init
        }
        await _sim?.play(fromStart: true);
      });
    }

    setState(() {});
  }

  Future<void> _removeAssetAt(int index) async {
    if (index < 0 || index >= _assets.length) return;

    // Pause simulator while we mutate lists
    if (_sim != null) {
      try {
        await _sim!.pause();
      } catch (_) {}
    }

    // Remove from UI list
    final removedUi = _assets.removeAt(index);

    // Remove from cached/db list if present (same order)
    DraftAsset? removedCached;
    if (index < _cached.length) {
      removedCached = _cached.removeAt(index);
      // if you saved entries in DB with an id, delete that row
      if (removedCached.id != null) {
        try {
          await DraftDb().deleteAsset(removedCached.id!);
        } catch (_) {}
      }
    }

    // Recompute whether we still have any videos
    _containsVideo = _assets.any((a) => a.type == AssetType.video);

    // If we had a simulator, fully dispose and recreate if needed
    if (_sim != null) {
      try {
        await _sim!.disposeController();
      } catch (_) {}
      _sim = null;

      if (_containsVideo && _cached.isNotEmpty) {
        _sim = SimulatedPlayerController(
          pageController: _pageController,
          assets: _cached,
        );
        _sim!.addListener(() => setState(() {}));
        // restart from nearest index (clamped)
        final newIndex = (_currentIndex >= _assets.length)
            ? (_assets.length - 1)
            : _currentIndex;
        _currentIndex = newIndex.clamp(
          0,
          _assets.isEmpty ? 0 : _assets.length - 1,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients)
            _pageController.jumpToPage(_currentIndex);
          _sim?.play(fromStart: true);
        });
      }
    }

    // fix current index so UI doesn't go out of range
    if (_assets.isEmpty) {
      // nothing left: pop returning empty list
      Navigator.of(context).pop<List<AssetEntity>>(_assets);
      return;
    } else {
      // clamp safely
      if (_currentIndex >= _assets.length) _currentIndex = _assets.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients)
          _pageController.jumpToPage(_currentIndex);
      });
    }

    setState(() {});
  }

  Widget _buildImage(File file, int idx) {
    return GestureDetector(
      onTap: () async {
        if (_sim == null) return;
        if (_sim!.isPlaying) {
          await _sim!.pause();
        } else {
          await _sim!.play();
        }
      },
      child: InteractiveViewer(child: Image.file(file, fit: BoxFit.contain)),
    );
  }

  Widget _buildVideoPreview(File file, VideoPlayerController? ctrl) {
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: () async {
        if (_sim == null) return;
        if (_sim!.isPlaying) {
          await _sim!.pause();
        } else {
          await _sim!.play();
        }
      },
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: ctrl.value.size.width,
            height: ctrl.value.size.height,
            child: VideoPlayer(ctrl),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final choice = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Save or Discard?"),
        content: const Text("Do you want to save this draft or discard it?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('discard'),
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('save'),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (choice == 'discard') {
      try {
        // delete all cached draft assets
        final db = DraftDb();
        final assets = await db.getAllAssets();
        for (final a in assets) {
          final f = File(a.localPath);
          if (await f.exists()) await f.delete();
        }
        await db.clearAll();
      } catch (e) {
        debugPrint("Failed to discard draft: $e");
      }

      // send user home
      Navigator.of(context).pop();
      return false;
    }

    if (choice == 'save') {
      // nothing extra, assets are already cached & saved
      Navigator.of(context).pop();
      return false;
    }

    return false; // cancel pop if dialog dismissed
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Post Preview • ${_assets.length}"),
          centerTitle: true,
        ),
        body: _cached.isEmpty
            ? Center(child: CustomCircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _cached.length,
                      onPageChanged: (i) async {
                        // always keep current index in sync (used for thumbnails highlight)
                        setState(() => _currentIndex = i);

                        if (_containsVideo && _sim != null) {
                          await _sim!.seekToGlobal(
                            Duration(
                              milliseconds: _cached
                                  .take(i)
                                  .fold(0, (s, a) => s + a.durationMs),
                            ),
                          );
                        }
                      },
                      itemBuilder: (context, idx) {
                        final a = _cached[idx];
                        if (a.type == DraftAssetType.image) {
                          return FutureBuilder(
                            future: Future.value(File(a.localPath)),
                            builder: (_, snap) {
                              if (!snap.hasData)
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              return _buildImage(snap.data as File, idx);
                            },
                          );
                        } else {
                          return FutureBuilder<VideoPlayerController?>(
                            future: _sim?.ensureVideoCtrl(idx),
                            builder: (ctx, snap) {
                              final ctrl = snap.data;
                              if (ctrl == null || !ctrl.value.isInitialized)
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              return _buildVideoPreview(
                                File(a.localPath),
                                ctrl,
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),

                  // timeline only when there's at least one video (simulation mode)
                  if (_containsVideo && _sim != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          Slider(
                            min: 0,
                            max: _sim!.totalDuration.inMilliseconds.toDouble(),
                            value: _sim!.currentGlobalPosition.inMilliseconds
                                .toDouble()
                                .clamp(
                                  0,
                                  _sim!.totalDuration.inMilliseconds.toDouble(),
                                ),
                            onChangeStart: (_) async {
                              _wasPlayingBeforeSeek = _sim!.isPlaying;
                              await _sim!.pause();
                            },

                            onChanged: (v) {
                              final pos = Duration(milliseconds: v.toInt());

                              // FIX: Recalculate intra-asset position before bumping
                              final ms = pos.inMilliseconds;
                              int currentMsBefore = _cached
                                  .take(_sim!.currentIndex)
                                  .fold(0, (s, a) => s + a.durationMs);
                              int newIntraElapsed = ms - currentMsBefore;

                              // Call bumpElapsed with the new intra-asset value
                              _sim!.bumpElapsed(newIntraElapsed);
                            },
                            onChangeEnd: (v) async {
                              await _sim!.seekToGlobal(
                                Duration(milliseconds: v.toInt()),
                              );
                              if (_wasPlayingBeforeSeek) await _sim!.play();
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_format(_sim!.currentGlobalPosition)),
                              Text(_format(_sim!.totalDuration)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ***** show thumbnail strip ONLY when there are NO videos *****
                  if (!_containsVideo) ...[
                    Container(
                      height: 80,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _assets.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              itemBuilder: (context, idx) =>
                                  _buildThumbnail(idx),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],

                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kDefault,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () async {
                            if (_sim != null) await _sim!.pause();
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ComposePostPage(assets: _assets),
                              ),
                            );
                            if (result is Map)
                              debugPrint('post payload: $result');
                          },
                          child: const Text(
                            'Next',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildThumbnail(int index) {
    final asset = _assets[index];
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
      builder: (context, snap) {
        final thumb = snap.data;
        final isCurrent = index == _currentIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  _pageController.jumpToPage(index);
                  setState(() => _currentIndex = index);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade900,
                    child: thumb != null
                        ? Image.memory(thumb, fit: BoxFit.cover)
                        : const SizedBox.shrink(),
                  ),
                ),
              ),

              // small play icon for videos (center-left)
              if (asset.type == AssetType.video)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),

              // dark circular remove icon (top-right)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeAssetAt(index),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),

              // selection border
              if (isCurrent)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.kDefault, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final hh = d.inHours.toString().padLeft(2, '0');
      return '$hh:$mm:$ss';
    }
    return '$mm:$ss';
  }
}
