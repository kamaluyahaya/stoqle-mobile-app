import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../component/loader/custom_loader.dart';

class ImageGalleryPage extends StatefulWidget {
  @override
  _ImageGalleryPageState createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage>
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
      // Fetch the images from the gallery
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      // Get the first album and fetch media files
      if (albums.isNotEmpty) {
        List<AssetEntity> files = await albums[0].getAssetListRange(
          start: 0,
          end: 100000, // Adjust based on how many images you want to load
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
                      onTap: () => _openImageView(mediaFiles[index]),
                      child: Image.memory(bytes, fit: BoxFit.cover),
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

  bool get wantKeepAlive => true;
}

class ImageViewPage extends StatelessWidget {
  final AssetEntity mediaFile;

  ImageViewPage({required this.mediaFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image View')),
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
