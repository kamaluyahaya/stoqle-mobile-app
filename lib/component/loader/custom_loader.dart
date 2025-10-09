import 'package:flutter/material.dart';

import '../colors/color.dart';

class CustomCircularProgressIndicator extends StatefulWidget {
  // final double strokeWidth;

  CustomCircularProgressIndicator(); // Default color is red

  @override
  _CustomCircularProgressIndicatorState createState() =>
      _CustomCircularProgressIndicatorState();
}

class _CustomCircularProgressIndicatorState
    extends State<CustomCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 1,
      ), // Adjust this duration for faster or slower spinning
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 9.141592653589793,
            child: child,
          );
        },
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.kDefault),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
