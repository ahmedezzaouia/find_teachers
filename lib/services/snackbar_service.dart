import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SnackBarServie {
  BuildContext _context;

  static SnackBarServie instance = SnackBarServie();
  set buildcontext(BuildContext context) {
    _context = context;
  }

  showSnackBarSuccess(String message) {
    Scaffold.of(_context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  showSnackBarError(String message) {
    Scaffold.of(_context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
