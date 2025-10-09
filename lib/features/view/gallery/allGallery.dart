import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

import '../../../component/loader/custom_loader.dart';

class AllGalleryPage extends StatefulWidget {
  @override
  _AllGalleryPageState createState() => _AllGalleryPageState();
}

class _AllGalleryPageState extends State<AllGalleryPage>
    with AutomaticKeepAliveClientMixin {
  List<AssetEntity> mediaFiles = [];

  @override
  void initState() {
    super.initState();
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

                    // Check if the media is a video
                    bool isVideo = mediaFiles[index].type == AssetType.video;

                    return GestureDetector(
                      onTap: () {
                        if (isVideo) {
                          _openVideoView(mediaFiles[index]);
                        } else {
                          _openImageView(mediaFiles[index]);
                        }
                      },
                      child: Stack(
                        children: [
                          Image.memory(
                            bytes,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          if (isVideo)
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

  void _openImageView(AssetEntity mediaFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewPage(mediaFile: mediaFile),
      ),
    );
  }

  void _openVideoView(AssetEntity mediaFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoViewPage(mediaFile: mediaFile),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ImageViewPage extends StatelessWidget {
  final AssetEntity mediaFile;

  ImageViewPage({required this.mediaFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Uint8List?>(
        future: mediaFile.originBytes,
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes == null) {
            return Center(child: CustomCircularProgressIndicator());
          }
          return Center(child: Image.memory(bytes));
        },
      ),
    );
  }
}

class VideoViewPage extends StatelessWidget {
  final AssetEntity mediaFile;

  VideoViewPage({required this.mediaFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          'Video playback not implemented',
        ), // Implement video playback here
      ),
    );
  }
}
