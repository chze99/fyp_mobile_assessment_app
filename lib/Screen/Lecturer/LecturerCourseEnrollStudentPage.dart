// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class LecturerCourseEnrollStudentPage extends StatefulWidget {
  int assessment_plan_id = 0;
  LecturerCourseEnrollStudentPage(this.assessment_plan_id);
  @override
  _LecturerCourseEnrollStudentPageState createState() =>
      _LecturerCourseEnrollStudentPageState();
}

class _LecturerCourseEnrollStudentPageState
    extends State<LecturerCourseEnrollStudentPage> {
  var isLoading = true;
  var message;
  var student_list, programme_list;
  int studentValue = 1;
  String programmeValue = "ALL";
  List<DropdownMenuItem<String>> programme_list_items = [];
  List<DropdownMenuItem<int>> student_list_items = [];
  @override
  void initState() {
    load_programme_list();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  load_programme_list() async {
    var data = {"temp": "temp"};
    var res = await Api().postData(data, "getProgrammeList");
    var body = json.decode(res.body);
    if (body['success']) {
      setState(() {
        programme_list = body['programme_list'];
        print(programme_list);

        if (programme_list != "No programme") {
          programme_list_items.add(DropdownMenuItem(
            value: "all",
            child: Text("All"),
          ));
          programme_list_items.addAll(List.generate(
            programme_list.length,
            (i) => DropdownMenuItem(
              value: programme_list[i]["programme_code"],
              child: Text(
                  "${programme_list[i]["programme_code"]} - ${programme_list[i]["programme_name"]} "),
            ),
          ));

          programmeValue = "all";
        }
      });
      await load_student_list("all");
    } else {
      print(body);
    }
  }

  load_student_list(String programme) async {
    var data = {
      'programme': programme,
    };
    var res = await Api().postData(data, "getStudentList");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      setState(() {
        student_list = body['student_list'];
        if (student_list != "No student") {
          print(body);
          student_list_items = List.generate(
            student_list.length,
            (i) => DropdownMenuItem(
              value: student_list[i]["student_id"],
              child: Text(
                  "${student_list[i]["student_name"]} - ${student_list[i]["icats_id"]}"),
            ),
          );
          studentValue = student_list[0]["student_id"];
        }
      });
      isLoading = false;
    } else {
      print(body);
    }
  }

  enroll_student() async {
    var data = {
      'assessment_plan_id': widget.assessment_plan_id,
      'student_id': studentValue,
    };
    var res = await Api().postData(data, "enrollStudent");
    var body = json.decode(res.body);
    if (body['success']) {
      setState(() {
        message = body['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(message);
    if (isLoading == true) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Enrollment'),
          backgroundColor: Colors.orange,
        ),
        body: Container(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Enrollment'),
          backgroundColor: Colors.orange,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              height: 500,
              width: 500,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Programme:   "),
                        Expanded(
                          child: DropdownButton<String>(
                              isExpanded: true,
                              items: programme_list_items,
                              value: programmeValue,
                              onChanged: (value) => setState(() {
                                    programmeValue = value!;
                                    load_student_list(
                                        programmeValue.toString());
                                  })),
                        )
                      ],
                    ),
                    if (student_list != "No student" &&
                        student_list != "null") ...[
                      Row(children: [
                        Text("Student Name:   "),
                        Expanded(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            items: student_list_items,
                            value: studentValue,
                            onChanged: (value) =>
                                setState(() => studentValue = value!),
                          ),
                        ),
                      ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                print(studentValue);
                                enroll_student();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                              ),
                              child: Text(
                                'Enroll',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            )
                          ]),
                      SizedBox(height: 5),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (message != null) ...[
                              Text(
                                message,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15.0,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ]),
                    ] else ...[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No Student Found",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 15.0,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ]),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
