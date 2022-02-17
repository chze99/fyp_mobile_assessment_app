// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class loading_page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Loading,please wait",
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
