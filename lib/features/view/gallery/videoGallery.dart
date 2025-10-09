import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

import '../../../component/loader/custom_loader.dart';

class VideoGalleryPage extends StatefulWidget {
  @override
  _VideoGalleryPageState createState() => _VideoGalleryPageState();
}

class _VideoGalleryPageState extends State<VideoGalleryPage>
    with AutomaticKeepAliveClientMixin {
  List<AssetEntity> mediaFiles = [];

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    // Request permission to access media files
    var result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      // Fetch the videos from the gallery
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      // Get the first album and fetch media files
      if (albums.isNotEmpty) {
        List<AssetEntity> files = await albums[0].getAssetListRange(
          start: 0,
          end: 100000, // Adjust based on how many videos you want to load
        );
        setState(() {
          mediaFiles = files;
        });
      }
    } else {
      // Handle the case where permission was denied
      print("Permission denied to access the gallery.");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: mediaFiles.isEmpty
          ? Center(child: CustomCircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: mediaFiles.length,
              itemBuilder: (context, index) {
                return FutureBuilder<Uint8List?>(
                  future: mediaFiles[index].thumbnailData,
                  builder: (context, snapshot) {
                    final bytes = snapshot.data;
                    if (bytes == null) {
                      return Center(child: Container());
                    }
                    return GestureDetector(
                      onTap: () => _openVideoPlayer(mediaFiles[index]),
                      child: Stack(
                        children: [
                          Image.memory(
                            bytes,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _openVideoPlayer(AssetEntity mediaFile) async {
    final videoFile = await mediaFile.file;
    if (videoFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerPage(videoPath: videoFile.path),
        ),
      );
    }
  }

  bool get wantKeepAlive => true;
}

class VideoPlayerPage extends StatefulWidget {
  final String videoPath;

  VideoPlayerPage({required this.videoPath});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.play();
          _isPlaying = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  Widget _buildPlayPauseButton() {
    return IconButton(
      icon: Icon(
        _isPlaying ? Icons.pause : Icons.play_arrow,
        size: 30.0,
        color: Colors.white,
      ),
      onPressed: _togglePlayPause,
    );
  }

  Widget _buildProgressBar() {
    return VideoProgressIndicator(
      _controller,
      allowScrubbing: true,
      colors: VideoProgressColors(
        backgroundColor: Colors.grey,
        playedColor: Colors.red,
        bufferedColor: Colors.lightGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video Player")),
      body: Center(
        child: _isInitialized
            ? Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  _buildProgressBar(),
                  _buildPlayPauseButton(),
                ],
              )
            : CustomCircularProgressIndicator(),
      ),
    );
  }
}
