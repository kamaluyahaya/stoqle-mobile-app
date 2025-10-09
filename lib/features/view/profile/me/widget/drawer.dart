import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DrawerList extends StatelessWidget {
  final title, onTap;
  Icon icon;
  DrawerList({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,

      // color: Theme.of(context).iconTheme.color,
      title: Text('$title', style: TextStyle()),
      onTap: onTap,
      // Handle the tap here.
    );
  }
}
