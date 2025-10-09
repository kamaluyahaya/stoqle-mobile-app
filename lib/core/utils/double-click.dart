import 'package:flutter/material.dart';
import 'package:stoqle/core/widget/constant.dart';

class DoubleClickButton extends StatefulWidget {
  final VoidCallback onConfirm; // function you want to call
  const DoubleClickButton({super.key, required this.onConfirm});

  @override
  State<DoubleClickButton> createState() => _DoubleClickButtonState();
}

class _DoubleClickButtonState extends State<DoubleClickButton> {
  DateTime? lastClickTime;

  void handleClick() {
    DateTime now = DateTime.now();

    if (lastClickTime == null ||
        now.difference(lastClickTime!) > const Duration(seconds: 2)) {
      // First click
      toastNotify("Press again to exist the program");

      lastClickTime = now;
    } else {
      // Second click within 2 seconds → run function
      widget.onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: handleClick,
      child: const Text("Delete Item"),
    );
  }
}
