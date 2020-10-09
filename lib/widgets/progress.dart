import 'package:flutter/material.dart';

linearProgress() {
  return Container(
    height: 15,
    padding: const EdgeInsets.only(bottom: 10),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.grey),
    ),
  );
}
