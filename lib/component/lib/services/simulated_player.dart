// lib/services/simulated_player.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

import '../models/draft_assets.dart';

class SimulatedPlayerController extends ChangeNotifier {
  final PageController pageController;
  final List<DraftAsset> assets;
  final AudioPlayer audioPlayer = AudioPlayer();
  final Duration imageDisplayDuration;
  Timer? _advanceTimer;
  Timer? _progressTimer;
  final Duration _progressTick = const Duration(milliseconds: 100);
  int currentIndex = 0;
  bool isPlaying = false;

  // caches only active/ready VideoPlayerController instances
  final Map<int, VideoPlayerController> _videoCtrls = {};

  SimulatedPlayerController({
    required this.pageController,
    required this.assets,
    this.imageDisplayDuration = const Duration(seconds: 3),
  });

  Duration get totalDuration {
    final ms = assets.fold<int>(0, (s, a) => s + a.durationMs);
    return Duration(milliseconds: ms);
  }

  Duration get currentGlobalPosition {
    final before = assets
        .take(currentIndex)
        .fold<int>(0, (s, a) => s + a.durationMs);
    final activeElapsed = _activeElapsedMs;
    return Duration(milliseconds: before + activeElapsed);
  }

  int _activeElapsedMs = 0; // ms elapsed within current asset

  /// Public video init for UI to call
  Future<VideoPlayerController?> ensureVideoCtrl(int idx) async {
    if (idx < 0 || idx >= assets.length) return null;
    final a = assets[idx];
    if (a.type != DraftAssetType.video) return null;
    if (_videoCtrls.containsKey(idx)) return _videoCtrls[idx];

    final ctrl = VideoPlayerController.file(File(a.localPath));
    _videoCtrls[idx] = ctrl;
    await ctrl.initialize();

    // mute video always (you wanted this)
    try {
      ctrl.setVolume(0.0);
    } catch (_) {}

    // IMPORTANT: forward controller updates to UI listeners so the texture shows immediately
    ctrl.addListener(() {
      // when the video controller updates (position, initialized, etc) notify UI
      notifyListeners();
    });

    return ctrl;
  }

  Future<void> play({bool fromStart = false}) async {
    if (assets.isEmpty) return;

    if (fromStart) {
      currentIndex = 0;
      _activeElapsedMs = 0;
      if (pageController.hasClients) {
        // jump is fine for instant placement
        pageController.jumpToPage(0);
      }
    }

    isPlaying = true;

    final a = assets[currentIndex];
    if (a.type == DraftAssetType.video) {
      final ctrl = await ensureVideoCtrl(currentIndex);
      if (ctrl != null && ctrl.value.isInitialized) {
        final seekTo = Duration(
          milliseconds: _activeElapsedMs.clamp(
            0,
            ctrl.value.duration.inMilliseconds,
          ),
        );
        await ctrl.seekTo(seekTo);
        await ctrl.play();

        if (fromStart && currentIndex == 0 && _activeElapsedMs == 0) {
          // warm-up: play 1 frame then pause, then resume properly
          await ctrl.play();
          await Future.delayed(const Duration(milliseconds: 30));
          await ctrl.pause();
          await ctrl.seekTo(Duration.zero);
          await ctrl.play();
        }

        // tiny delay to let the texture attach & first frame render, then notify
        await Future.delayed(const Duration(milliseconds: 50));
        notifyListeners();
      }
    }

    // preload the next video to avoid init lag when advancing
    if (currentIndex + 1 < assets.length &&
        assets[currentIndex + 1].type == DraftAssetType.video) {
      // don't await — run in background
      ensureVideoCtrl(currentIndex + 1);
    }

    // start UI progress AFTER we started the controller
    _startProgressTicker();
    _scheduleForCurrentRemaining();
    notifyListeners();
  }

  Future<void> pause() async {
    if (!isPlaying) return;
    isPlaying = false;
    _stopProgressTicker();
    _advanceTimer?.cancel();
    // pause current video if playing
    final ctrl = _videoCtrls[currentIndex];
    if (ctrl != null && ctrl.value.isPlaying) {
      await ctrl.pause();
    }
    notifyListeners();
  }

  Future<void> seekToGlobal(Duration pos) async {
    if (assets.isEmpty) return;

    final ms = pos.inMilliseconds.clamp(0, totalDuration.inMilliseconds);

    // 🔍 find index and intra offset
    int idx = 0;
    int accum = 0;
    for (var i = 0; i < assets.length; i++) {
      final a = assets[i];
      if (accum + a.durationMs > ms) {
        idx = i;
        _activeElapsedMs = ms - accum; // exact offset inside this asset
        break;
      } else {
        accum += a.durationMs;
      }
    }

    // 🔄 update index + move pager
    currentIndex = idx;
    if (pageController.hasClients) {
      pageController.jumpToPage(idx);
    }

    // stop videos and seek correctly
    await _stopAllVideoPlayers();
    final a = assets[idx];
    if (a.type == DraftAssetType.video) {
      final ctrl = await ensureVideoCtrl(idx);
      if (ctrl != null && ctrl.value.isInitialized) {
        final posMs = _activeElapsedMs.clamp(
          0,
          ctrl.value.duration.inMilliseconds,
        );
        await ctrl.seekTo(Duration(milliseconds: posMs));
        if (isPlaying) await ctrl.play();
      }
    }

    // ✅ reschedule timers with updated offset
    _advanceTimer?.cancel();
    if (isPlaying) {
      _scheduleForCurrentRemaining();
      _startProgressTicker(); // Ensure ticker is running after seek if playing
    } else {
      // FIX: If we seek while paused, we still need to stop the old ticker
      _stopProgressTicker();
    }

    notifyListeners();
  }

  void _scheduleForCurrentRemaining() {
    _advanceTimer?.cancel();
    final a = assets[currentIndex];

    // compute actual duration for current asset:
    int assetDurationMs = a.durationMs;
    if (a.type == DraftAssetType.video) {
      final ctrl = _videoCtrls[currentIndex];
      if (ctrl != null && ctrl.value.isInitialized) {
        // prefer controller's real duration
        assetDurationMs = ctrl.value.duration.inMilliseconds;
        // safety: don't trust zero
        if (assetDurationMs <= 0) assetDurationMs = a.durationMs;
      }
    }

    final remainingMs = (assetDurationMs - _activeElapsedMs).clamp(
      0,
      assetDurationMs,
    );
    if (remainingMs <= 0) {
      // immediate advance
      _advanceToNext();
      return;
    }
    _advanceTimer = Timer(Duration(milliseconds: remainingMs), _advanceToNext);
  }

  Future<void> _advanceToNext() async {
    final nextIndex = currentIndex + 1;

    if (nextIndex < assets.length) {
      // 👉 Normal forward slide
      currentIndex = nextIndex;
      _activeElapsedMs = 0;

      pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );

      final asset = assets[currentIndex];
      if (asset.type == DraftAssetType.video) {
        final ctrl = await ensureVideoCtrl(currentIndex);
        if (ctrl != null && ctrl.value.isInitialized && isPlaying) {
          await ctrl.seekTo(Duration.zero);
          await ctrl.play();
        }
      }

      if (isPlaying) _scheduleForCurrentRemaining();
      notifyListeners();
    } else {
      // 🔁 Loop back to the start (jump instantly, no reverse animation)
      currentIndex = 0;
      _activeElapsedMs = 0;

      pageController.jumpToPage(0);

      final first = assets[currentIndex];
      if (first.type == DraftAssetType.video) {
        final ctrl = await ensureVideoCtrl(currentIndex);
        if (ctrl != null && ctrl.value.isInitialized && isPlaying) {
          await ctrl.seekTo(Duration.zero);
          await ctrl.play();
        }
      }

      if (isPlaying) _scheduleForCurrentRemaining();
      notifyListeners();
    }
  }

  // light-weight progress ticker to update UI frequently without seeking videos constantly
  void _startProgressTicker() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(_progressTick, (_) async {
      // --- FIX: Logic to read video position directly ---
      final a = assets[currentIndex];

      if (isPlaying) {
        if (a.type == DraftAssetType.video) {
          final ctrl = _videoCtrls[currentIndex];

          // Check if controller is initialized and attached to the player (usually after play() call)
          if (ctrl != null && ctrl.value.isInitialized) {
            try {
              // Primary method: Read video player's actual position
              final pos = ctrl.value.position;
              _activeElapsedMs = pos.inMilliseconds.clamp(0, a.durationMs);

              // If video ends before the schedule timer triggers, force advance
              if (ctrl.value.position >= ctrl.value.duration &&
                  ctrl.value.duration > Duration.zero) {
                // Use a slight delay to ensure UI updates before page flip
                Future.delayed(
                  const Duration(milliseconds: 50),
                  () => _advanceToNext(),
                );
              }
            } catch (_) {
              // Fallback: Increment timer conservatively if position read fails
              _activeElapsedMs += _progressTick.inMilliseconds;
            }
          } else {
            // Controller not ready yet or disposed: increment manually (should be rare)
            _activeElapsedMs += _progressTick.inMilliseconds;
          }
        } else {
          // Image: increment manually
          _activeElapsedMs += _progressTick.inMilliseconds;
        }

        // --- End FIX ---

        final currDur = _getCurrentAssetDurationMs();
        if (_activeElapsedMs >= currDur) {
          // The video should have triggered _advanceToNext, but if an image finishes, do it here.
          _advanceToNext();
          return;
        }
      }
      notifyListeners();
    });
  }

  int _getCurrentAssetDurationMs() {
    final a = assets[currentIndex];
    if (a.type == DraftAssetType.video) {
      final ctrl = _videoCtrls[currentIndex];
      if (ctrl != null && ctrl.value.isInitialized) {
        final ms = ctrl.value.duration.inMilliseconds;
        if (ms > 0) return ms;
      }
    }
    return a.durationMs;
  }

  void _stopProgressTicker() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  /// update elapsed inside current asset while user drags slider etc
  void bumpElapsed(int ms) {
    _activeElapsedMs = ms.clamp(0, assets[currentIndex].durationMs);
    notifyListeners();
  }

  Future<void> _stopAllVideoPlayers() async {
    for (final ctrl in _videoCtrls.values) {
      try {
        if (ctrl.value.isPlaying) await ctrl.pause();
      } catch (_) {}
    }
  }

  Future<void> disposeController() async {
    _advanceTimer?.cancel();
    _stopProgressTicker();
    await _stopAllVideoPlayers();
    for (final ctrl in _videoCtrls.values) {
      try {
        ctrl.dispose();
      } catch (_) {}
    }
    _videoCtrls.clear();
    try {
      await audioPlayer.dispose();
    } catch (_) {}
    super.dispose();
  }
}
