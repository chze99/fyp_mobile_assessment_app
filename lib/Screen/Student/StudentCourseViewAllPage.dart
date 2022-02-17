// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Student/StudentCourseDetailPage.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loading_page.dart';

class StudentCourseViewAllPage extends StatefulWidget {
  @override
  _StudentCourseViewAllPageState createState() =>
      _StudentCourseViewAllPageState();
}

class _StudentCourseViewAllPageState extends State<StudentCourseViewAllPage> {
  String name = "";
  bool isLoading = true;
  var course_data;
  @override
  void initState() {
    load_user_data();
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
      print(user);
      setState(() {
        name = user['username'];
      });
      var data = {
        'user_id': user["user_id"],
      };
      var res = await Api().postData(data, "getStudentCourseData");
      var body = json.decode(res.body);
      if (body['success'] != null) {
        print(body);
        if (this.mounted) {
          setState(() {
            course_data = body['student_course_data'];
            print("test" + course_data['count'].toString());
            isLoading = false;
          });
        }
      } else {
        error_alert().alert(context, "Error", body.toString());

        isLoading = false;

        print(body);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == true) {
      return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Course"),
            backgroundColor: Colors.orange,
          ),
          body: Stack(children: <Widget>[
            Container(
              width: double.maxFinite,
              child: new loading_page(),
            )
          ]),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Course'),
          backgroundColor: Colors.orange,
        ),
        body: Stack(
          children: <Widget>[
            Container(
                child: SingleChildScrollView(
                    child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: course_data['count'],
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => StudentCourseDetailPage(
                                course_data[index.toString()]
                                    ['assessment_plan_id']))).then((value) {
                      setState(() {
                        isLoading = true;
                        load_user_data();
                      });
                    });
                    ;
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Card(
                        elevation: 4.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Course Title: ",
                                  style: const TextStyle(
                                      fontFamily: 'Arial', fontSize: 25),
                                ),
                                Text(
                                  course_data[index.toString()]['course_title']
                                      .toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Arial',
                                      fontSize: 25),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Course Code: ",
                                  style: const TextStyle(fontSize: 15),
                                ),
                                Text(
                                  course_data[index.toString()]['course_code']
                                      .toString(),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Session: ",
                                  style: const TextStyle(fontSize: 15),
                                ),
                                Text(
                                  course_data[index.toString()]['session_name']
                                      .toString(),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Number of assessment: ",
                                  style: const TextStyle(fontSize: 15),
                                ),
                                Text(
                                  course_data[index.toString()]
                                          ['assessment_count']
                                      .toString(),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Lecturer Name: ",
                                  style: const TextStyle(fontSize: 15),
                                ),
                                Text(
                                  course_data[index.toString()]['lecturer_name']
                                      .toString(),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                );
              },
            ))),
          ],
        ),
      );
    }
  }
}
