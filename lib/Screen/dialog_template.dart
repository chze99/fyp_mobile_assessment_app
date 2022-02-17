// ignore_for_file: non_constant_identifier_names, duplicate_ignore

import 'package:flutter/material.dart';

// ignore: camel_case_types
class dialog_template {
  // ignore: non_constant_identifier_names
  confirmation_dialog(BuildContext context, String no_text, String yes_text,
      String title, String content, Function() no_btn, Function() yes_btn) {
    Widget no_button = TextButton(
      child: Text(no_text),
      onPressed: () {
        no_btn();
        Navigator.pop(context);
      },
    );
    Widget yes_button = TextButton(
      child: Text(yes_text),
      onPressed: () {
        yes_btn();

        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        no_button,
        yes_button,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
