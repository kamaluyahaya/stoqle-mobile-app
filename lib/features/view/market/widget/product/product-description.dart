import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stoqle/component/colors/color.dart';

class ProductDescription extends StatelessWidget {
  final product;
  const ProductDescription(this.product);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  child: Row(
                    children: [
                      Text(
                        "₦",
                        style: TextStyle(
                          // color: kWhite10,
                          fontSize: 15,
                          color: AppColors.kDefault,
                          fontFamily: "",
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "25,400",
                        style: TextStyle(
                          // color: kWhite10,
                          fontSize: 25,
                          color: const Color.fromARGB(255, 238, 51, 79),
                          fontFamily: "Bold",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Stack(
                  clipBehavior: Clip.none, // allow overflow
                  children: [
                    // Main container
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 252, 76, 76),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: const Text(
                        "New buyer 30% Off",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: "Bold",
                        ),
                      ),
                    ),

                    // Spark icon floating on top-left edge
                    Positioned(
                      left: -10, // move outside a bit
                      // top: -2, // lift above container
                      child: Icon(
                        PhosphorIconsFill.lightning,
                        // .lightningFill(), // or PhosphorIcons.lightningBold
                        color: const Color.fromARGB(
                          248,
                          255,
                          129,
                          147,
                        ), // make it pop ⚡
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const Spacer(), // pushes next text to the right
                Text(
                  "4030 sold",
                  style: TextStyle(
                    color: kWhite20,
                    fontSize: 10,
                    fontFamily: "",
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Color.fromARGB(255, 252, 76, 76),
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  "Eid Promo | ${product.authorName}",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 252, 76, 76),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  // space between badges
                  // Promo Badge (teal like Friendly Market)
                  WidgetSpan(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                          255,
                          15,
                          107,
                          98,
                        ), // teal background
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Central Market",
                        style: TextStyle(
                          color: Colors.white, // white text
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: " "), // space between tag and post title
                  TextSpan(
                    text: "${product.text}",
                    style: TextStyle(
                      fontFamily: "Bold",
                      fontSize: 18,
                      color: kBlack,
                    ),
                  ),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 8),
            Text(
              "This is a short product description. You can replace this with post.text or product details.",
              style: TextStyle(
                fontSize: 15,
                color: AppColors.kDarkMode,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
