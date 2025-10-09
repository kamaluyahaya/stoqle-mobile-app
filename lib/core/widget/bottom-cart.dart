import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stoqle/component/colors/color.dart';

class BottomCart extends StatefulWidget {
  final shop_logo;
  const BottomCart(this.shop_logo);

  @override
  State<BottomCart> createState() => _BottomCartState();
}

class _BottomCartState extends State<BottomCart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: kWhite,
        border: Border(top: BorderSide(width: 0.5, color: kWhiteSmoke)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 12.0,
          top: 4.0,
          // bottom: 10.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                        0,
                      ), // space between avatar and border
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kWhiteSmoke,
                          width: 0.5, // border thickness
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: widget.shop_logo.isNotEmpty
                            ? NetworkImage(widget.shop_logo)
                            : null,
                        child: widget.shop_logo.isEmpty
                            ? Icon(
                                PhosphorIcons.cat(),
                                size: 14, // smaller so it fits inside border
                                color: const Color.fromARGB(255, 221, 134, 4),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Shop",
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: "ExtraBold",
                        color: kBlack10,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),

                Column(
                  children: [
                    Icon(LucideIcons.messageCircle, color: kBlack10, size: 20),
                    SizedBox(height: 5),
                    Text(
                      "Service",
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: "ExtraBold",
                        color: kBlack10,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  children: [
                    Icon(LucideIcons.shoppingCart, color: kBlack10, size: 20),
                    SizedBox(height: 5),
                    Text(
                      "Cart",
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: "ExtraBold",
                        color: kBlack10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 15),
            Flexible(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  // border: Border.all(
                  // color: AppColors.kDefault, // outline color
                  // width: 1.5,
                  // ),
                ),
                child: Row(
                  children: [
                    // Add to Cart (Transparent)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(40, 253, 118, 118),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            bottomLeft: Radius.circular(25),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Add to Cart",
                            style: TextStyle(
                              color: const Color.fromARGB(
                                223,
                                199,
                                45,
                                68,
                              ), // matches outline
                              fontFamily: "Bold",
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Buy Now (Solid)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.kDefault,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Buy Now",
                            style: TextStyle(color: kWhite, fontFamily: "Bold"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
