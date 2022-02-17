// ignore_for_file: non_constant_identifier_names, duplicate_ignore

import 'package:flutter/material.dart';

// ignore: camel_case_types
class error_alert {
  // ignore: non_constant_identifier_names
  void alert(context, alertTitle, alertText) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              alertTitle != null ? alertTitle : 'Mobile assessment',
              style: TextStyle(color: Colors.black),
            ),
            content: Text(
              alertText,
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Text(
                      'Ok',
                      style: TextStyle(color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  )),
            ]);
      },
    );
  }
}
