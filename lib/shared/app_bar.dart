import 'package:flutter/material.dart';

AppBar appBarWiget({String title, Widget actions}) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        fontSize: 18,
      ),
    ),
    centerTitle: true,
    actions: [actions == null ? Container() : actions],
  );
}
