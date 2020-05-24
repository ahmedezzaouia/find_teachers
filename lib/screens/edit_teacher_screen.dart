import 'package:flutter/material.dart';

class EditTeacherScreen extends StatelessWidget {
  static const routeNamed = 'edit-teacher';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edite Teacher'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
