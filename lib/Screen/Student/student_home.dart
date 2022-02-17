// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Student/StudentAssessmentPage.dart';
import 'package:mobile_assessment/Screen/Student/StudentCoursePage.dart';
import 'package:mobile_assessment/Screen/Student/StudentProfilePage.dart';
import 'package:mobile_assessment/Screen/Student/StudentHomePage.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentHome extends StatefulWidget {
  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int currentPage = 0;
  var user_data;
  bool isloading = true;
  @override
  void initState() {
    load_user_data();
    isloading = false;
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  load_user_data() async {
    SharedPreferences local_storage = await SharedPreferences.getInstance();
    var user = jsonDecode(local_storage.getString('user') ?? "");

    if (user != null && user != "") {
      setState(() {
        user_data = user;
        insert_token();
      });
    }
  }

  insert_token() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    var data = {
      'token': token,
      'user_id': user_data['user_id'],
      'user_type': user_data['usertype'],
    };
    var res = await Api().postData(data, "insertFCMToken");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        setState(() {
          print('token' + token.toString());
        });
      }
    } else {
      print(body);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      new StudentHomePage(),
      new StudentAssessmentPage(),
      new StudentCoursePage(),
      new StudentProfilePage(),
    ];
    if (isloading == true) {
      return Scaffold(
        body: Stack(children: <Widget>[
          Container(
            width: double.maxFinite,
            child: new loading_page(),
          )
        ]),
      );
    } else {
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  size: 36,
                  color: Color.fromRGBO(0, 0, 0, 1.0),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.book,
                  size: 36,
                  color: Color.fromRGBO(0, 0, 0, 1.0),
                ),
                label: 'Assessment',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.bookmark,
                  size: 36,
                  color: Color.fromRGBO(0, 0, 0, 1.0),
                ),
                label: 'Course',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.people,
                  size: 36,
                  color: Color.fromRGBO(0, 0, 0, 1.0),
                ),
                label: 'Profile',
              ),
            ],
            selectedItemColor: Colors.amber,
            unselectedItemColor: Colors.black,
            currentIndex: currentPage,
            showUnselectedLabels: true,
            onTap: _onItemTapped),
        body: Stack(
          children: <Widget>[
            Container(child: tabs[currentPage]),
          ],
        ),
      );
    }
  }
}
