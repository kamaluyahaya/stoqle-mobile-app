import 'package:flutter/material.dart';

import '../colors/color.dart';

class StoqleUserLoginHeader extends StatelessWidget {
  const StoqleUserLoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Stoqle",
                style: TextStyle(
                  fontFamily: "Bold",
                  color: AppColors.lightBackground,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: AppColors.kDefault,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.more_horiz,
              // color: kWhite,
            ),
          ),
        ],
      ),
    );
  }
}
