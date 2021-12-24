// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LecturerAssessmentPage extends StatefulWidget {
  @override
  _LecturerAssessmentPageState createState() => _LecturerAssessmentPageState();
}

class _LecturerAssessmentPageState extends State<LecturerAssessmentPage> {
  String name = "";
  @override
  void initState() {
    load_user_data();
    super.initState();
  }

  load_user_data() async {
    SharedPreferences local_storage = await SharedPreferences.getInstance();
    var user = jsonDecode(local_storage.getString('user') ?? "");

    if (user != null && user != "") {
      print(user);
      setState(() {
        name = user['username'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Welcome, $name,you are at assessment page',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
