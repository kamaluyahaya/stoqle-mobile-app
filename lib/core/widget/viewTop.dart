import 'package:flutter/material.dart';

import '../../component/colors/color.dart';

// ignore: must_be_immutable
class ViewTop extends StatelessWidget {
  Color colorStatus;
  ViewTop(this.colorStatus);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        // backgroundColor: colorStatus,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            color: colorStatus,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: TabBar(
                labelColor: AppColors.kDefault,
                unselectedLabelColor: kBlack,
                // padding: EdgeInsetsGeometry.infinity,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.0, color: kWhite),
                  insets: EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
                ),
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Text("Overview"),
                  Text("Reviews"),
                  Text("Descriptions"),
                  Text("Recommendations"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
