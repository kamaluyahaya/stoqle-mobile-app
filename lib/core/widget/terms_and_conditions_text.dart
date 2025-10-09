import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class TermsAndConditionsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(context).textTheme.labelSmall,
          children: [
            TextSpan(
              text: 'I have read and agree to the following policies: ',
            ),
            TextSpan(
              text: 'Terms',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Handle Terms link
                  print("Terms clicked");
                },
            ),
            TextSpan(
              text: ', ',
            ),
            TextSpan(
              text: 'Privacy',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Handle Privacy link
                  print("Privacy clicked");
                },
            ),
            TextSpan(
              text: ', and ',
            ),
            TextSpan(
              text: 'Protection Rules for Children/Teenagers',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Handle Protection Rules link
                  print("Protection Rules clicked");
                },
            ),
          ],
        ),
      ),
    );
  }
}
