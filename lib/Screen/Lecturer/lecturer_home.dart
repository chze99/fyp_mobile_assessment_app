// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/login_user_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerAssessmentPage.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCoursePage.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerProfilePage.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerHomePage.dart';

class LecturerHome extends StatefulWidget {
  @override
  _LecturerHomeState createState() => _LecturerHomeState();
}

class _LecturerHomeState extends State<LecturerHome> {
  int currentPage = 0;
  String name = "";
  bool isloading = true;

  @override
  void initState() {
    load_user_data();
    isloading = false;
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
    final tabs = [
      new LecturerHomePage(),
      new LecturerAssessmentPage(),
      new LecturerCoursePage(),
      new LecturerProfilePage(),
    ];
    if (isloading == true) {
      return Scaffold(
        body: Container(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mobile Assessment Application'),
          backgroundColor: Colors.orange,
        ),
        body: Stack(
          children: <Widget>[
            Container(child: tabs[currentPage]),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentPage = 0;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.home,
                                size: 36,
                                color: Color.fromRGBO(0, 0, 0, 1.0),
                              )),
                          Text(
                            "Home",
                            style: TextStyle(
                                color: currentPage == 0
                                    ? Colors.orange
                                    : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentPage = 1;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.book,
                                size: 36,
                                color: Color.fromRGBO(0, 0, 0, 1.0),
                              )),
                          Text(
                            "Assessment",
                            style: TextStyle(
                                color: currentPage == 1
                                    ? Colors.orange
                                    : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentPage = 2;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.bookmark,
                                size: 36,
                                color: Color.fromRGBO(0, 0, 0, 1.0),
                              )),
                          Text(
                            "Course",
                            style: TextStyle(
                                color: currentPage == 2
                                    ? Colors.orange
                                    : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentPage = 3;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.people,
                                size: 36,
                                color: Color.fromRGBO(0, 0, 0, 1.0),
                              )),
                          Text(
                            "Profile",
                            style: TextStyle(
                                color: currentPage == 3
                                    ? Colors.orange
                                    : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  void logout() async {
    var res = await Api().getData('logout');
    var body = json.decode(res.body);
    print(body);
    if (body['success'] != null) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('user');
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginUserSelection()),
          (Route<dynamic> route) => false);
    } else {
      print(body);
    }
  }
}
