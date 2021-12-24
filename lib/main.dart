import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_assessment/Screen/Student/student_home.dart';
import 'package:mobile_assessment/Screen/Lecturer/lecturer_home.dart';
import 'package:mobile_assessment/Screen/login_user_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Assessment',
      debugShowCheckedModeBanner: false,
      home: CheckAuth(),
    );
  }
}

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;
  var usertype;
  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    var user = localStorage.getString('user');
    if (token != null && token != "null") {
      setState(() {
        isAuth = true;
      });
      if (user != null) {
        setState(() {
          usertype = json.decode(user)["usertype"];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isAuth) {
      if (usertype == "Student") {
        child = StudentHome();
      } else if (usertype == "Lecturer") {
        child = LecturerHome();
      } else {
        child = StudentHome();
      }
    } else {
      child = LoginUserSelection();
    }
    return Scaffold(
      body: child,
    );
  }
}
