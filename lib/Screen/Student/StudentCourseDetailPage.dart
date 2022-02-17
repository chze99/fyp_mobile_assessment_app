// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Student/ViewSubmission/StudentViewSubmissionPage.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../loading_page.dart';

// ignore: must_be_immutable
class StudentCourseDetailPage extends StatefulWidget {
  int index = 0;
  StudentCourseDetailPage(this.index);
  @override
  _StudentCourseDetailPageState createState() =>
      _StudentCourseDetailPageState();
}

class _StudentCourseDetailPageState extends State<StudentCourseDetailPage> {
  String name = "";
  var isLoading = true;
  var course_data;
  var course_student_data;
  var sol;
  var result;
  var clo_data;
  var clo_count;
  var assessment_data;
  var assessment_count;
  var final_exam_data;
  var user_data;
  double total_score = 0.0;
  double total_score_obtained = 0;
  int submission_number = 0;
  int assessment_number = 0;
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

  bool isNumberOnly(String text) {
    return RegExp(r'^[0-9]+$').hasMatch(text);
  }

  load_user_data() async {
    SharedPreferences local_storage = await SharedPreferences.getInstance();
    var user = jsonDecode(local_storage.getString('user') ?? "");

    if (user != null && user != "") {
      setState(() {
        user_data = user;
      });
      var data = {
        'assessment_plan_id': widget.index,
      };
      var res = await Api().postData(data, "getStudentDetailCourseData");
      var body = json.decode(res.body);
      if (body['success']) {
        if (this.mounted) {
          setState(() {
            course_data = body['student_course_data'][0];
            get_assessment();
          });
        }
      }
    }
  }

  get_assessment() async {
    var data = {
      'assessment_plan_id': widget.index,
      'user_id': user_data['user_id']
    };
    var res = await Api().postData(data, "getAssessmentDetailStudent");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        setState(() {
          assessment_data = body['message'];
          result = body['result'];
          print("+" + result.toString());

          assessment_count = assessment_data['count'];
          if (body['final'] != null) {
            assessment_number += 1;
            final_exam_data = body['final'][0];
            print("Final" + final_exam_data.toString());
            total_score +=
                double.parse(final_exam_data['assessment_detail_weightage']);
            if (final_exam_data['question_paper'].toString() !=
                'No question paper') {
              if (final_exam_data['solution'] != "No solution") {
                if (final_exam_data['solution']['actual_score'] != null) {
                  total_score_obtained +=
                      double.parse(final_exam_data['solution']['actual_score']);
                }
                if (final_exam_data['solution']['isSubmitted'] == true) {
                  submission_number += 1;
                }
              }
            }
          }
          for (int i = 0; i < assessment_count; i++) {
            assessment_number += 1;
            total_score += double.parse(
                assessment_data[i.toString()]['assessment_detail_weightage']);
            if (assessment_data[i.toString()]['question_paper'].toString() !=
                "No question paper") {
              if (assessment_data[i.toString()]['solution'] != "No solution") {
                if (assessment_data[i.toString()]['solution']['actual_score'] !=
                    null) {
                  total_score_obtained += double.parse(
                      assessment_data[i.toString()]['solution']
                          ['actual_score']);
                }
                if (assessment_data[i.toString()]['solution']['isSubmitted'] ==
                    true) {
                  submission_number += 1;
                }
              }
            }
          }
          print("Assessment data" + body['final'].toString());
          isLoading = false;
        });
      }
    } else {
      setState(() {
        error_alert().alert(context, "Error", body.toString());

        isLoading = false;
      });
      print("get_assessment error" + body.toString());
    }
  }

  // get_submission() async {
  //   var data = {
  //     'assessment_plan_id': widget.index,
  //     'user_id': user_data['user_id']
  //   };
  //   var res = await Api().postData(data, "getAssessmentDetailStudent");
  //   var body = json.decode(res.body);
  //   if (body['success'] != null) {
  //     if (this.mounted) {
  //       setState(() {
  //         assessment_data = body['message'];
  //         print("+" + assessment_data['0'].toString());

  //         assessment_count = assessment_data['count'];
  //         if (body['final'] != null) {
  //           final_exam_data = body['final'][0];
  //           total_score +=
  //               double.parse(final_exam_data['assessment_detail_weightage']);
  //         }
  //         for (int i = 0; i < assessment_count; i++) {
  //           total_score += double.parse(
  //               assessment_data[i.toString()]['assessment_detail_weightage']);
  //         }

  //         print("Assessment data" + body['final'].toString());
  //         isLoading = false;
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     print("get_assessment error" + body.toString());
  //   }
  // }

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
                    child: Card(
                        elevation: 4.0,
                        child: SingleChildScrollView(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Course Title: ",
                                  style: const TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  course_data['course_title'].toString(),
                                  style: const TextStyle(
                                      fontFamily: 'Arial', fontSize: 25),
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
                                  course_data['course_code'].toString(),
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
                                  "Credit Hour: ",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  course_data['course_credit_hour'].toString(),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Row(children: [
                                  Text(
                                    "Session: ",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    course_data['session_name'].toString(),
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  )
                                ])),
                                SizedBox(
                                  height: 5,
                                ),
                                if (total_score > 0) ...[
                                  Expanded(
                                      child: Row(children: [
                                    Text(
                                      "Total score: ",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      result['student_course_mark'].toString() +
                                          '/' +
                                          total_score.toString(),
                                      style: const TextStyle(fontSize: 15),
                                    )
                                  ])),
                                ],
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                if (result['student_course_grade'] != null) ...[
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Text(
                                        "Current grade: ",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        result['student_course_grade']
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      )
                                    ],
                                  ))
                                ],
                                Expanded(
                                    child: Row(children: [
                                  Text(
                                    "Completed assessment: ",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    submission_number.toString() +
                                        '/' +
                                        assessment_number.toString(),
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  )
                                ])),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Divider(
                              thickness: 3.0,
                              color: Colors.black,
                              endIndent: 0,
                              indent: 0,
                            ),
                            Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Assessment Name",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "Assessment Weightage",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "Submission",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                            if (assessment_count > 0) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                        itemCount: assessment_count,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          print(
                                              "Clo data" + clo_data.toString());

                                          return Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 10),
                                              child: Container(
                                                  child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                            assessment_data[index
                                                                        .toString()]
                                                                    [
                                                                    'assessment_detail_title']
                                                                .toString(),
                                                            textAlign:
                                                                TextAlign.left),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                            assessment_data[index
                                                                    .toString()]
                                                                [
                                                                'assessment_detail_weightage'],
                                                            textAlign:
                                                                TextAlign.left),
                                                      ),
                                                      if (assessment_data[index
                                                                  .toString()][
                                                              'question_paper'] !=
                                                          "No question paper") ...[
                                                        if (assessment_data[index
                                                                    .toString()]
                                                                ['solution'] !=
                                                            "No solution") ...[
                                                          if (assessment_data[index
                                                                          .toString()]
                                                                      [
                                                                      'solution']
                                                                  [
                                                                  'isSubmitted'] ==
                                                              false) ...[
                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                  "Not yet submitted",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left),
                                                            )
                                                          ] else ...[
                                                            Expanded(
                                                              flex: 1,
                                                              child: InkWell(
                                                                child: Text(
                                                                    "View",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .green)),
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      new MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              StudentViewSubmissionPage(assessment_data[index.toString()]['question_paper']['question_paper_id'], assessment_data[index.toString()]['solution']['solution_questionpaper_id']))).then(
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      total_score =
                                                                          0;
                                                                      total_score_obtained =
                                                                          0;
                                                                      submission_number =
                                                                          0;
                                                                      assessment_number =
                                                                          0;
                                                                      isLoading =
                                                                          true;
                                                                      load_user_data();
                                                                    });
                                                                  });
                                                                },
                                                              ),
                                                            )
                                                          ],
                                                        ] else ...[
                                                          Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                                "Not yet started",
                                                                textAlign:
                                                                    TextAlign
                                                                        .left),
                                                          )
                                                        ],
                                                      ] else ...[
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                              "Not yet started",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        )
                                                      ],
                                                    ],
                                                  ),
                                                  Divider(
                                                    thickness: 1.0,
                                                    color: Colors.black,
                                                    endIndent: 0,
                                                    indent: 0,
                                                  ),
                                                ],
                                              )));
                                        }),
                                  ),
                                ],
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 1, 0, 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                            final_exam_data[
                                                    'assessment_detail_title']
                                                .toString(),
                                            textAlign: TextAlign.left),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                            final_exam_data[
                                                'assessment_detail_weightage'],
                                            textAlign: TextAlign.left),
                                      ),
                                      if (final_exam_data['question_paper']
                                              .toString() !=
                                          "No question paper") ...[
                                        if (final_exam_data['solution'] !=
                                            "No solution") ...[
                                          if (final_exam_data['solution']
                                                  ['isSubmitted'] ==
                                              false) ...[
                                            Expanded(
                                              flex: 1,
                                              child: Text("Not yet submitted",
                                                  textAlign: TextAlign.left),
                                            )
                                          ] else ...[
                                            Expanded(
                                              flex: 1,
                                              child: InkWell(
                                                child: Text("View",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.green)),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      new MaterialPageRoute(
                                                          builder: (context) => StudentViewSubmissionPage(
                                                              final_exam_data[
                                                                      'question_paper']
                                                                  [
                                                                  'question_paper_id'],
                                                              final_exam_data[
                                                                      'solution']
                                                                  [
                                                                  'solution_questionpaper_id']))).then(
                                                      (value) {
                                                    setState(() {
                                                      total_score = 0;
                                                      total_score_obtained = 0;
                                                      submission_number = 0;
                                                      assessment_number = 0;
                                                      isLoading = true;
                                                      load_user_data();
                                                    });
                                                  });
                                                },
                                              ),
                                            )
                                          ],
                                        ] else ...[
                                          Expanded(
                                            flex: 1,
                                            child: Text("Not yet started",
                                                textAlign: TextAlign.left),
                                          )
                                        ],
                                      ] else ...[
                                        Expanded(
                                          flex: 1,
                                          child: Text("Not yet started",
                                              textAlign: TextAlign.left),
                                        )
                                      ],
                                    ],
                                  )),
                            ] else ...[
                              Text("No Question Found",
                                  style: TextStyle(color: Colors.red))
                            ]
                          ],
                        ))),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}
