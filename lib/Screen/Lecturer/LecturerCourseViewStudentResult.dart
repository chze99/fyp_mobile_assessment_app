// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerAssessmentAdd.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCourseCreateAssessmentPlan2.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCourseEnrollStudentPage.dart';
import 'package:mobile_assessment/Screen/Lecturer/Question_Bank/LecturerAssessmentQuestionBank.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loading_page.dart';
import 'LecturerCourseCreateAssessmentPlan.dart';

// ignore: must_be_immutable
class LecturerCourseViewStudentResult extends StatefulWidget {
  int student_id = 0;
  int assessment_plan_id = 0;
  LecturerCourseViewStudentResult(this.student_id, this.assessment_plan_id);
  @override
  _LecturerCourseViewStudentResultState createState() =>
      _LecturerCourseViewStudentResultState();
}

class _LecturerCourseViewStudentResultState
    extends State<LecturerCourseViewStudentResult> {
  String name = "";
  var isLoading = true;
  var course_data;
  var course_student_data;
  var clo_data;
  var clo_count;
  var assessment_data;
  var assessment_count;
  var final_exam_data;
  var result;
  @override
  void initState() {
    load_user_data();
    print("Inittial load course data: " + course_data.toString());
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  load_user_data() async {
    var data = {
      'assessment_plan_id': widget.assessment_plan_id,
    };
    var res = await Api().postData(data, "getLecturerDetailCourseData");
    var body = json.decode(res.body);
    if (body['success']) {
      if (this.mounted) {
        setState(() {
          course_data = body['lecturer_course_data'][0];
          load_course_student_data();
        });
      }
    }
  }

  load_course_student_data() async {
    var data = {
      'student_id': widget.student_id,
      'assessment_plan_id': widget.assessment_plan_id,
    };
    var res = await Api().postData(data, "getCourseStudentResult");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      print("Course student data " + body.toString());
      if (this.mounted) {
        setState(() {
          course_student_data = body['message'];
          result = body['detail'];
          print(result);
          isLoading = false;
        });
      }
    } else {
      setState(() {
        course_student_data = body['message'];
        result = body['detail'];
        error_alert().alert(context, "Error", body.toString());

        isLoading = false;
      });
      print("Course student data error" + body.toString());
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
            title: Text("Course Detail"),
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
      return WillPopScope(
          onWillPop: () {
            Navigator.pop(context);

            return Future.value(false);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Course Detail'),
              backgroundColor: Colors.orange,
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  height: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: SingleChildScrollView(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                              "Course Title: ",
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            Expanded(
                                child: Text(
                              course_data['course_title'].toString(),
                              style: const TextStyle(
                                  fontFamily: 'Arial', fontSize: 25),
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                              "Course Code: ",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            Expanded(
                                child: Text(
                              course_data['course_code'].toString(),
                              style: const TextStyle(fontSize: 15),
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                              "Credit Hour: ",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            Expanded(
                                child: Text(
                              course_data['course_credit_hour'].toString(),
                              style: const TextStyle(fontSize: 15),
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                              "Session: ",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            Expanded(
                                child: Text(
                              course_data['session_name'].toString(),
                              style: const TextStyle(fontSize: 15),
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        if (result != 'No result') ...[
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                "Current score",
                                style: const TextStyle(
                                    fontFamily: 'Arial',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              )),
                              Expanded(
                                  child: Text(
                                result['student_course_mark'],
                                style: const TextStyle(
                                    fontFamily: 'Arial', fontSize: 15),
                              )),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                "Current grade",
                                style: const TextStyle(
                                    fontFamily: 'Arial',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              )),
                              Expanded(
                                  child: Text(
                                result['student_course_grade'],
                                style: const TextStyle(
                                    fontFamily: 'Arial', fontSize: 15),
                              )),
                            ],
                          )
                        ],
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                              "Assessment Title",
                              style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            )),
                            Expanded(
                                child: Text(
                              "Assessment Score",
                              style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        if (course_student_data != 'No result') ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: course_student_data['count'],
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Column(children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            course_student_data[
                                                    index.toString()]
                                                ['assessment_detail_title'],
                                            style: const TextStyle(
                                                fontFamily: 'Arial',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          )),
                                          Expanded(
                                              child: Text(
                                            course_student_data[index
                                                .toString()]['actual_score'],
                                            style: const TextStyle(
                                                fontFamily: 'Arial',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          )),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    thickness: 1.0,
                                    color: Colors.black,
                                    endIndent: 0,
                                    indent: 0,
                                  ),
                                ]),
                              );
                            },
                          )
                        ] else ...[
                          Text("No result available",
                              style: const TextStyle(
                                  fontFamily: 'Arial',
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25)),
                        ]
                      ],
                    )),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}
