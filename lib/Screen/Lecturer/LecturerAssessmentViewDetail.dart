// ignore_for_file: non_constant_identifier_names, import_of_legacy_library_into_null_safe, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Lecturer/ViewSubmission/LecturerViewSubmissionPage.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:toast/toast.dart';

import '../loading_page.dart';
import 'LecturerAssessmentAddQuestion.dart';

class LecturerAssessmentViewDetail extends StatefulWidget {
  @override
  int question_paper_id = 0;
  String mode = "";
  int assessment_detail_id = 0;
  LecturerAssessmentViewDetail(
      this.question_paper_id, this.mode, this.assessment_detail_id);

  _LecturerAssessmentViewDetailState createState() =>
      _LecturerAssessmentViewDetailState();
}

class _LecturerAssessmentViewDetailState
    extends State<LecturerAssessmentViewDetail> {
  String name = "";
  var isLoading = true;
  var question_paper_data;
  var course_student_data;
  var student_submission_data;
  DateTime todayData =
      new DateFormat("yyyy-MM-dd").parse(DateTime.now().toString());
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int today_count = 0, past_count = 0, future_count = 0;
  @override
  void initState() {
    get_question_data();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_question_data() async {
    var data = {
      'question_paper_id': widget.question_paper_id,
    };
    var res = await Api().postData(data, "getDetailQuestionPaper");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (body['message'] != "No question paper") {
        if (this.mounted) {
          setState(() {
            question_paper_data = body['message'];
            print("QPD" + question_paper_data.toString());
            load_course_student_data();
          });
        }
      } else {
        load_course_student_data();
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print(body);
    }
  }

  load_course_student_data() async {
    var data = {
      'assessment_plan_id': question_paper_data['assessment_plan_id'],
    };
    var res = await Api().postData(data, "getCourseStudentListData");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        setState(() {
          course_student_data = body['course_student_data'];
          print("csD" + course_student_data.toString());
          get_submission_data();
        });
      }
    } else {
      get_submission_data();

      print("Course student data error" + body.toString());
    }
  }

  get_submission_data() async {
    var data = {
      'question_paper_id': widget.question_paper_id,
    };
    var res = await Api().postData(data, "getSubmissionDataLecturer");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      student_submission_data = body['message'];

      if (body['message'] != "No submission") {
        if (this.mounted) {
          setState(() {
            print("SSD" + student_submission_data.toString());
            for (int j = 0; j < course_student_data['count']; j++) {
              course_student_data[j.toString()]['temp_submission'] = 'false';
              course_student_data[j.toString()]['temp_solution_id'] = null;

              for (int i = 0; i < student_submission_data['count']; i++) {
                if (student_submission_data[i.toString()]['student_id'] ==
                    course_student_data[j.toString()]['student_id']) {
                  course_student_data[j.toString()]['temp_submission'] = 'true';
                  course_student_data[j.toString()]['temp_solution_id'] =
                      student_submission_data[i.toString()]
                          ['solution_questionpaper_id'];
                }
              }
            }
            isLoading = false;
          });
        }
      } else {
        setState(() {
          print("SSD" + student_submission_data.toString());
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
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
            title: Text("Assessment"),
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
          title: Text(question_paper_data['assessment_detail_title']),
          backgroundColor: Colors.orange,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Card(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Row(children: [
                                    Text(
                                      "Course: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      question_paper_data['course_title']
                                              .toString() +
                                          "(" +
                                          question_paper_data['course_code']
                                              .toString() +
                                          ")",
                                    )
                                  ])),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                      child: Row(children: [
                                    Text(
                                      "Start Time: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      question_paper_data[
                                                  'question_paper_start_date']
                                              .toString() +
                                          " " +
                                          question_paper_data[
                                                  'question_paper_start_time']
                                              .toString(),
                                    )
                                  ])),
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Text(
                                        "Total mark: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(question_paper_data[
                                              'assessment_detail_weightage']
                                          .toString())
                                    ],
                                  )),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(children: [
                                Expanded(
                                    child: Row(
                                  children: [
                                    Text(
                                      "End Time: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      question_paper_data[
                                                  'question_paper_start_date']
                                              .toString() +
                                          " " +
                                          question_paper_data[
                                                  'question_paper_start_time']
                                              .toString(),
                                    )
                                  ],
                                )),
                                Expanded(
                                    child: Row(
                                  children: [
                                    Text(
                                      "Number of question: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(question_paper_data[
                                            'number_of_question']
                                        .toString())
                                  ],
                                )),
                              ]),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    "Number of student involved: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (course_student_data !=
                                      "No student assigned") ...[
                                    Text(
                                        course_student_data['count'].toString())
                                  ] else ...[
                                    Text('0')
                                  ]
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LecturerAssessmentAddQuestion(
                                                    question_paper_data[
                                                        'question_paper_id'],
                                                    question_paper_data[
                                                        'assessment_detail_id'])))
                                    .then((value) {
                                  setState(() {
                                    get_question_data();
                                  });
                                });
                              });
                            },
                            child: Text("View question"))
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 21,
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        Text(
                          "Student List",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Card(
                            elevation: 4.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          "No.",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Expanded(
                                        flex: 3,
                                        child: Text(
                                          "Name",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Student ID",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Submission",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (course_student_data !=
                                        "No student assigned") ...[
                                      Expanded(
                                          child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: course_student_data['count'],
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Row(children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        (index + 1).toString(),
                                                        style: const TextStyle(
                                                          fontFamily: 'Arial',
                                                        ),
                                                      )),
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        course_student_data[index
                                                                    .toString()]
                                                                ['student_name']
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontFamily: 'Arial',
                                                        ),
                                                      )),
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        course_student_data[index
                                                                    .toString()]
                                                                ['icats_id']
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontFamily: 'Arial',
                                                        ),
                                                      )),
                                                  if (course_student_data[
                                                              index.toString()]
                                                          ['temp_submission'] ==
                                                      'true') ...[
                                                    Expanded(
                                                      flex: 2,
                                                      child: InkWell(
                                                        child: Text("View",
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
                                                                  builder: (context) => LecturerViewSubmissionPage(
                                                                      question_paper_data[
                                                                          'question_paper_id'],
                                                                      course_student_data[
                                                                              index.toString()]
                                                                          [
                                                                          'temp_solution_id'],
                                                                      course_student_data[
                                                                              index.toString()]
                                                                          [
                                                                          'student_id']))).then(
                                                              (value) {
                                                            setState(() {
                                                              isLoading = true;
                                                              get_question_data();
                                                            });
                                                          });
                                                        },
                                                      ),
                                                    )
                                                  ] else ...[
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          "Not yet submit",
                                                          style:
                                                              const TextStyle(
                                                            fontFamily: 'Arial',
                                                          ),
                                                        ))
                                                  ],
                                                ]),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ))
                                    ] else ...[
                                      Text(
                                        "No student assigned",
                                        style: const TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 25,
                                            color:
                                                Color.fromARGB(255, 255, 0, 0)),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ))
                      ],
                    )),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
