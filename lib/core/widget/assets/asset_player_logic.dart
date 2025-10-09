import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stoqle/core/widget/assets/assets_cache_manager.dart';
import 'package:stoqle/features/view/gallery/selected_assets_page.dart';
import 'package:video_player/video_player.dart';

// A mixin to hold the complex playback and timing logic for SelectedAssetsPage
mixin AssetPlayerLogic on State<SelectedAssetsPage> {
  // config
  static const Duration imageDisplayDuration = Duration(seconds: 3);
  static const Duration tickInterval = Duration(milliseconds: 200);

  // State properties from SelectedAssetsPage's State
  abstract final PageController pageController;
  abstract final List<AssetEntity> assets;
  abstract int currentIndex;
  abstract bool hasVideoAssets; // New property to determine simulation mode

  // per-asset video controllers cached lazily
  final Map<String, VideoPlayerController> videoControllers = {};

  // timeline durations
  final List<Duration> itemDurations = []; // same length as assets
  final List<Duration> cumulativeDurations = []; // prefix sums
  Duration totalDuration = Duration.zero;

  // simulated playback state
  Duration position = Duration.zero; // global simulated timeline position
  Timer? _ticker;
  bool isPlaying = false;

  // audio (music) sync
  final AudioPlayer audioPlayer = AudioPlayer();
  String?
  musicPath; // set this if you want background music; remain null otherwise

  // --- Core Lifecycle Methods (To be called from the main State) ---

  void initPlayerLogic() {
    hasVideoAssets = assets.any((a) => a.type == AssetType.video);
    if (hasVideoAssets) {
      _prepareDurations(); // only need to prepare durations if simulating video
    }
  }

  Future<void> disposePlayerLogic() async {
    _ticker?.cancel();
    await _disposeAllVideoControllers();
    await audioPlayer.dispose();
  }

  // --- Video Controller Management ---

  Future<void> _disposeAllVideoControllers() async {
    for (final c in videoControllers.values) {
      try {
        await c.pause();
      } catch (_) {}
      try {
        c.dispose();
      } catch (_) {}
    }
    videoControllers.clear();
  }

  Future<void> initVideoControllerIfNeeded(AssetEntity asset) async {
    if (asset.type != AssetType.video || videoControllers.containsKey(asset.id))
      return;

    // Use the AssetCacheManager to get the local file path (cached or fresh)
    final localPath = await AssetCacheManager.instance.getCachedAssetPath(
      asset,
    );
    if (localPath == null) return;

    final controller = VideoPlayerController.file(File(localPath));
    videoControllers[asset.id] = controller;
    await controller.initialize();
    controller.setLooping(false);
    // Notify the UI to rebuild after controller is ready
    if (mounted) setState(() {});
  }

  void _pauseOtherVideoControllers(String? exceptId) {
    for (final entry in videoControllers.entries) {
      if (entry.key != exceptId) {
        if (entry.value.value.isPlaying) entry.value.pause();
      }
    }
  }

  // --- Duration and Position Mapping (Only used if hasVideoAssets is true) ---

  /// Compute durations for each asset.
  Future<void> _prepareDurations() async {
    if (!hasVideoAssets) return; // Skip if no video simulation needed

    itemDurations.clear();
    cumulativeDurations.clear();
    totalDuration = Duration.zero;

    for (final a in assets) {
      if (a.type == AssetType.video) {
        // Use videoDuration, falling back to image duration if zero (e.g., corrupted metadata)
        final d = a.videoDuration;
        final dur = (d != Duration.zero) ? d : imageDisplayDuration;
        itemDurations.add(dur);
      } else {
        itemDurations.add(imageDisplayDuration);
      }
      totalDuration += itemDurations.last;
      cumulativeDurations.add(totalDuration);
    }

    if (position > totalDuration) position = totalDuration;
    if (mounted) setState(() {});
  }

  // map global position -> index + intraOffset
  MapEntry<int, Duration> _positionToIndex(Duration pos) {
    if (assets.isEmpty) return MapEntry(0, Duration.zero);
    if (pos <= Duration.zero) return MapEntry(0, Duration.zero);
    for (int i = 0; i < cumulativeDurations.length; i++) {
      final cum = cumulativeDurations[i];
      if (pos <= cum) {
        final prevCum = i == 0 ? Duration.zero : cumulativeDurations[i - 1];
        final intra = pos - prevCum;
        return MapEntry(i, intra);
      }
    }
    // past end -> last
    final lastIndex = assets.length - 1;
    final lastIntra = itemDurations.isNotEmpty
        ? itemDurations.last
        : Duration.zero;
    return MapEntry(lastIndex, lastIntra);
  }

  // --- Playback/Simulation Controls (Only used if hasVideoAssets is true) ---

  void _startTicker() {
    if (_ticker != null && _ticker!.isActive) return;
    _ticker = Timer.periodic(tickInterval, (_) => _tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<void> _tick() async {
    if (!isPlaying || assets.isEmpty || totalDuration == Duration.zero) return;

    // Advance position
    final newPos = position + tickInterval;
    if (newPos >= totalDuration) {
      // Reached end -> stop at end
      position = totalDuration;
      isPlaying = false;
      await audioPlayer.pause();
      _pauseOtherVideoControllers(null);
      _stopTicker();
      if (mounted) setState(() {});
      return;
    } else {
      position = newPos;
    }

    // Determine current asset
    final entry = _positionToIndex(position);
    final idx = entry.key;
    final intra = entry.value;

    if (idx != currentIndex) {
      // update page and controllers
      currentIndex = idx;
      if (pageController.hasClients) {
        // Use animateToPage for smooth transition on auto-advance
        pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }

    final currentAsset = assets[currentIndex];
    if (currentAsset.type == AssetType.video) {
      // Ensure controller initialized and play from intra offset
      await initVideoControllerIfNeeded(currentAsset);
      final ctrl = videoControllers[currentAsset.id];
      if (ctrl != null && ctrl.value.isInitialized) {
        final videoPos = Duration(
          milliseconds: intra.inMilliseconds.clamp(
            0,
            ctrl.value.duration.inMilliseconds,
          ),
        );
        try {
          // Seek only if necessary
          if ((ctrl.value.position - videoPos).inMilliseconds.abs() > 300) {
            await ctrl.seekTo(videoPos);
          }
          if (isPlaying && !ctrl.value.isPlaying) {
            await ctrl.play();
          } else if (!isPlaying && ctrl.value.isPlaying) {
            await ctrl.pause();
          }
          _pauseOtherVideoControllers(currentAsset.id);
        } catch (_) {}
      }
    } else {
      // current asset is image; ensure videos paused
      _pauseOtherVideoControllers(null);
    }

    // sync audio player if present
    if (musicPath != null) {
      try {
        if (audioPlayer.playing != isPlaying) {
          if (isPlaying)
            await audioPlayer.play();
          else
            await audioPlayer.pause();
        }
        final audioPos = position;
        final diff = (audioPlayer.position - audioPos).inMilliseconds.abs();
        if (diff > 500) {
          await audioPlayer.seek(audioPos);
        }
      } catch (_) {}
    }

    if (mounted) setState(() {});
  }

  Future<void> playSimulation() async {
    if (!hasVideoAssets) return;
    if (assets.isEmpty || totalDuration == Duration.zero) return;
    isPlaying = true;

    // ensure current asset video plays (if video)
    final curr = assets[currentIndex];
    if (curr.type == AssetType.video) {
      await initVideoControllerIfNeeded(curr);
      final ctrl = videoControllers[curr.id];
      if (ctrl != null && ctrl.value.isInitialized) {
        final entry = _positionToIndex(position);
        final intra = entry.value;
        final pos = Duration(
          milliseconds: intra.inMilliseconds.clamp(
            0,
            ctrl.value.duration.inMilliseconds,
          ),
        );
        await ctrl.seekTo(pos);
        await ctrl.play();
        _pauseOtherVideoControllers(curr.id);
      }
    }

    // start audio if present
    if (musicPath != null) {
      try {
        if (audioPlayer.processingState == ProcessingState.idle ||
            audioPlayer.processingState == ProcessingState.ready) {
          await audioPlayer.setFilePath(musicPath!);
        }
        await audioPlayer.seek(position);
        await audioPlayer.play();
      } catch (e) {
        debugPrint('audio play error: $e');
      }
    }

    _startTicker();
    if (mounted) setState(() {});
  }

  Future<void> pauseSimulation() async {
    if (!hasVideoAssets) return;
    isPlaying = false;
    _stopTicker();
    // pause videos
    _pauseOtherVideoControllers(null);
    // pause audio
    try {
      if (audioPlayer.playing) await audioPlayer.pause();
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Duration _clampDuration(Duration value, Duration min, Duration max) {
    if (value.compareTo(min) < 0) return min;
    if (value.compareTo(max) > 0) return max;
    return value;
  }

  Future<void> seekTo(Duration pos) async {
    if (!hasVideoAssets) return;
    if (assets.isEmpty) return;

    // clamp pos
    position = _clampDuration(pos, Duration.zero, totalDuration);

    // identify index + intra
    final entry = _positionToIndex(position);
    final idx = entry.key;
    final intra = entry.value;

    currentIndex = idx;
    if (pageController.hasClients) {
      pageController.jumpToPage(idx);
    }

    final asset = assets[idx];
    if (asset.type == AssetType.video) {
      await initVideoControllerIfNeeded(asset);
      final ctrl = videoControllers[asset.id];
      if (ctrl != null && ctrl.value.isInitialized) {
        final videoTarget = Duration(
          milliseconds: intra.inMilliseconds.clamp(
            0,
            ctrl.value.duration.inMilliseconds,
          ),
        );
        await ctrl.seekTo(videoTarget);
        if (isPlaying)
          await ctrl.play();
        else
          await ctrl.pause();
        _pauseOtherVideoControllers(asset.id);
      }
    } else {
      _pauseOtherVideoControllers(null);
    }

    if (musicPath != null) {
      try {
        await audioPlayer.seek(position);
      } catch (_) {}
    }

    if (mounted) setState(() {});
  }

  // Method to be called when an asset is removed from the list
  Future<void> removeAssetAtLogic(int index) async {
    final removed = assets[index];
    // dispose controller if video
    final id = removed.id;
    if (videoControllers.containsKey(id)) {
      await videoControllers[id]!.pause();
      videoControllers[id]!.dispose();
      videoControllers.remove(id);
    }

    // Recheck for videos
    hasVideoAssets = assets.any((a) => a.type == AssetType.video);

    // recompute durations only if simulation is active
    if (hasVideoAssets) {
      await _prepareDurations();
      // clamp position to new total
      if (position > totalDuration) position = totalDuration;
    } else {
      // If no more videos, stop simulation
      await pauseSimulation();
      totalDuration = Duration.zero;
      position = Duration.zero;
    }
  }
}
