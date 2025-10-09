import 'package:flutter/material.dart';
import 'package:stoqle/features/view/gallery/allGallery.dart';
import 'package:stoqle/features/view/gallery/imageGallery.dart';
import 'package:stoqle/features/view/gallery/videoGallery.dart';

class GalleryPage extends StatefulWidget {
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with AutomaticKeepAliveClientMixin {
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      initialIndex: 1, // Set the middle tab as the default active tab (index 1)
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 10),
              Expanded(
                child: TabBar(
                  dividerColor: Theme.of(context).appBarTheme.backgroundColor,
                  tabs: [
                    Tab(text: 'Videos'),
                    Tab(text: 'All'),
                    Tab(text: 'Images'),
                  ],
                  labelStyle: TextStyle(fontFamily: "Bold"),
                  indicatorColor: Colors.red,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Theme.of(context).iconTheme.color,
                  unselectedLabelColor: Colors.grey,
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
        body: TabBarView(
          children: [VideoGalleryPage(), AllGalleryPage(), ImageGalleryPage()],
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}
