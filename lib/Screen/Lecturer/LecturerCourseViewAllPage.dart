// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loading_page.dart';
import 'LecturerCourseDetailPage.dart';

class LecturerCourseViewAllPage extends StatefulWidget {
  @override
  _LecturerCourseViewAllPageState createState() =>
      _LecturerCourseViewAllPageState();
}

class _LecturerCourseViewAllPageState extends State<LecturerCourseViewAllPage> {
  String name = "";
  var isLoading = true;
  var course_data;
  var course_student_data;
  @override
  void initState() {
    load_user_data();
    print(course_data);
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
      if (this.mounted) {
        setState(() {
          name = user['username'];
        });
      }
      var data = {
        'user_id': user["user_id"],
      };
      var res = await Api().postData(data, "getLecturerCourseData");
      var body = json.decode(res.body);
      if (body['success'] != null) {
        print(body);
        if (this.mounted) {
          setState(() {
            course_data = body['lecturer_course_data'];
            isLoading = false;
          });
        }
      } else {
        error_alert().alert(context, "Error", body.toString());

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
            title: Text("Course-All"),
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
          title: Text('Course-All'),
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
                  onTap: () => Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => LecturerCourseDetailPage(
                              course_data[index.toString()]
                                  ['assessment_plan_id']))).then((value) {
                    setState(() {
                      isLoading = true;
                      load_user_data();
                    });
                  }),
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
                                  "Student Number: ",
                                  style: const TextStyle(fontSize: 15),
                                ),
                                Text(
                                  course_data[index.toString()]['student_count']
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
