import 'package:flutter/material.dart';

import '../../component/colors/color.dart';

class BottomSheetBar extends StatefulWidget {
  final image, title, code, selected;
  BottomSheetBar({super.key, this.image, this.title, this.code, this.selected});

  @override
  State<BottomSheetBar> createState() => _BottomSheetBarState();
}

class _BottomSheetBarState extends State<BottomSheetBar> {
  // List recipeData = [];
  // Future<List> getUserData() async {
  //   SharedPreferences pred = await SharedPreferences.getInstance();
  //   try {
  //     // transactionData = jsonDecode(res.body);
  //     // pred.setString("course", transactionData[0]['course']);
  //     // pred.setString("semester", transactionData[0]['semester']);
  //     // pred.setString("level", transactionData[0]['level']);
  //     // id = pred.getString("id");
  //     var res = await http.post(Uri.parse(myurl),
  //         body: {"request": "FETCH RECIPES", "id": widget.id.toString()});

  //     setState(() {
  //       recipeData = jsonDecode(res.body);
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  //   return recipeData;
  // }

  void initState() {
    // getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: kBlack,
          ),
          width: MediaQuery.of(context).size.width,
          child: OutlinedButton(
            onPressed: () {
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => EnvelopRefreshIndicator(
              //         child: Customer_nav(),
              //         onRefresh: () async {
              //           // Customer_nav();
              //         })));
              // showFlexibleBottomSheet(
              //   minHeight: 0,
              //   initHeight: 0.5,
              //   maxHeight: 1,
              //   isExpand: true,
              //   context: context,
              //   builder: _buildBottomSheet,
              //   anchors: [0, 0.8, 1],
              //   isSafeArea: false,
              // );
            },
            child: TextButton(
              onPressed: () {
                // BottomSheetBar();
              },
              child: Text("Continue", style: TextStyle(color: kWhite)),
            ),
          ),
        ),

        // recipeData.isEmpty ? Text("Empty") : Text("${recipeData[0]['name']}"),
      ],
    );
  }
}
