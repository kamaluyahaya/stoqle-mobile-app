import 'package:flutter/material.dart';

class IconButton extends StatelessWidget {
  final onPressed, loader, color, title;
  const IconButton(
      {super.key, this.onPressed, this.color, this.loader, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width,
      child: TextButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          // foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
          ), // Padding inside the button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Rounded corners
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            loader,
            SizedBox(
              width: 10,
            ),
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
