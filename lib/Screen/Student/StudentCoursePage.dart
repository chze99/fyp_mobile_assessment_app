// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Student/StudentCourseDetailPage.dart';
import 'package:mobile_assessment/Screen/Student/StudentCourseViewAllPage.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loading_page.dart';

class StudentCoursePage extends StatefulWidget {
  @override
  _StudentCoursePageState createState() => _StudentCoursePageState();
}

class _StudentCoursePageState extends State<StudentCoursePage> {
  String name = "";
  bool isLoading = true;
  var course_data;
  var user_data;
  var session_data;
  var current_semester;
  String current_selection = "All";
  List<PopupMenuItem<String>> semester_list = [];
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
      setState(() {
        user_data = user;
        get_course("All");
      });
    }
  }

  get_course(session) async {
    var data = {
      'user_id': user_data["user_id"],
      'session': session,
    };
    var res = await Api().postData(data, "getStudentCourseData");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      print(body);
      if (this.mounted) {
        setState(() {
          course_data = body['student_course_data'];
          get_session();
        });
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      get_session();

      print(body);
    }
  }

  get_session() async {
    var data = {'temp': 'temp'};
    var res = await Api().postData(data, "getSessionList");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        setState(() {
          session_data = body['data'];
          print(session_data);
          semester_list.add(
            PopupMenuItem<String>(value: "All", child: Text("All")),
          );
          semester_list.addAll(List.generate(
            session_data['count'],
            (i) {
              if (session_data[i.toString()]["isCurrentSession"] == true) {
                current_semester = session_data[i.toString()]["session_id"];
                return PopupMenuItem<String>(
                  value: "${session_data[i.toString()]["session_name"]}",
                  child: Text(
                      "${session_data[i.toString()]["session_name"]} - Current semester"),
                );
              } else {
                return PopupMenuItem<String>(
                  value: session_data[i.toString()]["session_name"].toString(),
                  child: Text("${session_data[i.toString()]["session_name"]}"),
                );
              }
            },
          ));
          isLoading = false;
        });
      }
    } else {
      setState(() {
        error_alert().alert(context, "Error", body.toString());

        isLoading = false;
      });
      print(body);
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
          actions: <Widget>[
            // SizedBox(
            //   child: ElevatedButton(
            //     child: Text("View All"),
            //     onPressed: () {
            //       Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                   builder: (context) => StudentCourseViewAllPage()))
            //           .then((value) {
            //         setState(() {
            //           load_user_data();
            //         });
            //       });
            //     },
            //     style: ButtonStyle(
            //       backgroundColor:
            //           MaterialStateProperty.all<Color>(Colors.purple),
            //     ),
            //   ),
            // ),
            PopupMenuButton<String>(
              initialValue: "All",
              onSelected: ((String value) {
                setState(() {
                  current_selection = value;
                  isLoading = true;
                  semester_list = [];
                  get_course(value);
                });
              }),
              child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        current_selection,
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      )
                    ],
                  )),
              itemBuilder: (BuildContext context) {
                return semester_list;
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            if (course_data != "No assigned course") ...[
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
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Column(children: [
                        Card(
                            color: course_data[index.toString()]
                                        ['session_id'] ==
                                    current_semester
                                ? Colors.green
                                : Colors.red,
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
                                      course_data[index.toString()]
                                              ['course_title']
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
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      course_data[index.toString()]
                                              ['course_code']
                                          .toString(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Credit Hour: ",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      course_data[index.toString()]
                                              ['course_credit_hour']
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
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      course_data[index.toString()]
                                              ['session_name']
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
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      course_data[index.toString()]
                                              ['lecturer_name']
                                          .toString(),
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        Divider(
                          thickness: 2.0,
                          color: Colors.black,
                          endIndent: 0,
                          indent: 0,
                        ),
                      ]),
                    ),
                  );
                },
              ))),
            ] else ...[
              Text("No course available")
            ],
          ],
        ),
      );
    }
  }
}
