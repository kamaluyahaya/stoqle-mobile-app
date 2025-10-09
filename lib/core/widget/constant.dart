import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

final crossStart = CrossAxisAlignment.start;

final stylesRegular = TextStyle(fontFamily: "Regular", fontSize: 15);
final stylesMedium = TextStyle(fontFamily: "Medium", fontSize: 18);
final stylesBold = TextStyle(fontFamily: "Bold", fontSize: 20);
final smallsize = SizedBox(height: 10);

void toastNotify(String msg) {
  Toast.show(
    msg,
    duration: Toast.lengthLong,
    gravity: Toast.center,
    backgroundColor: Colors.white,
    textStyle: const TextStyle(fontSize: 14, color: Colors.black),
  );
}
