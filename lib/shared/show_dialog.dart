import 'package:flutter/material.dart';

class ShowDialogWidget {
  static ShowDialogWidget instance = ShowDialogWidget();

  showSimpleDialog({BuildContext context, String title, List<Widget> options}) {
    showDialog(
      context: context,
      child: SimpleDialog(
        title: Text(title),
        children: options,
      ),
    );
  }
}
