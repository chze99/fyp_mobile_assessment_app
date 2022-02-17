// ignore_for_file: non_constant_identifier_names, import_of_legacy_library_into_null_safe, must_be_immutable, override_on_non_overriding_member

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assessment/Backend/api.dart';

import 'package:mobile_assessment/Screen/Lecturer/ViewSubmission/LecturerViewSubmissionMCQ.dart';
import 'package:mobile_assessment/Screen/Lecturer/ViewSubmission/LecturerViewSubmissionTF.dart';
import 'package:mobile_assessment/Screen/Lecturer/ViewSubmission/LecturerViewSubmissionEssay.dart';
import 'package:mobile_assessment/Screen/Lecturer/ViewSubmission/LecturerViewSubmissionMS.dart';
import 'package:mobile_assessment/Screen/Lecturer/ViewSubmission/LecturerViewSubmissionPractical.dart';
import 'package:mobile_assessment/Screen/Lecturer/ViewSubmission/LecturerViewSubmissionSA.dart';
import 'package:mobile_assessment/Screen/dialog_template.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:toast/toast.dart';

import '../../loading_page.dart';

class LecturerViewSubmissionPage extends StatefulWidget {
  @override
  int question_paper_id = 0;
  int solution_questionpaper_id = 0;
  int student_id = 0;
  LecturerViewSubmissionPage(
      this.question_paper_id, this.solution_questionpaper_id, this.student_id);

  _LecturerViewSubmissionPageState createState() =>
      _LecturerViewSubmissionPageState();
}

class _LecturerViewSubmissionPageState
    extends State<LecturerViewSubmissionPage> {
  String name = "";
  var isLoading = true;
  var question_paper_data;
  bool isStarted = false;
  bool isEnded = false;
  DateTime now = DateTime.now();
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  String remaining_time = "";
  var question_paper_detail_data;
  var solution_paper_data;
  var student_data;
  int completed_question = 0;
  double raw_mark_total = 0.0;
  double total_mark = 0;
  bool isDone = false;
  bool isSubmitting = false;
  @override
  void initState() {
    super.initState();
    get_student_info();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_student_info() async {
    var data = {
      "student_id": widget.student_id,
    };
    var res = await Api().postData(data, "getStudentInformation");
    var body = json.decode(res.body);
    print(widget.student_id);
    if (body['success'] != null) {
      if (this.mounted) {
        setState(() {
          student_data = body['message'];
          print('SD' + student_data.toString());
          get_question_data();
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          error_alert().alert(context, "Error", body.toString());

          get_question_data();
        });
      }
    }
  }

  get_question_data() async {
    var data = {
      "solution_questionpaper_id": widget.solution_questionpaper_id,
      "question_paper_id": widget.question_paper_id
    };
    var res =
        await Api().postData(data, "getStudentDetailQuestionPaperLecturer");
    var body = json.decode(res.body);
    print(widget.question_paper_id);
    print("SOLID" + widget.solution_questionpaper_id.toString());
    if (body['success'] != null) {
      if (body['message'] != "No question paper") {
        if (this.mounted) {
          setState(() {
            question_paper_data = body['message'];
            solution_paper_data = body['sol'];
            question_paper_detail_data = body['question'];
            print(question_paper_data);
            print(question_paper_detail_data["2"]);
            print(solution_paper_data);
            for (int i = 0; i < question_paper_detail_data['count']; i++) {
              if (question_paper_detail_data[i.toString()]['student_answer'] !=
                  null) {
                raw_mark_total += double.parse(
                    question_paper_detail_data[i.toString()]['raw_mark']);
              }
            }
            for (int i = 0; i < question_paper_detail_data['count']; i++) {
              if (question_paper_detail_data[i.toString()]
                      ['solution_total_score'] !=
                  null) {
                total_mark += double.parse(
                    question_paper_detail_data[i.toString()]
                        ['solution_total_score']);
              }
            }
            start = DateTime.parse(
                question_paper_data['question_paper_start_date'].toString() +
                    " " +
                    question_paper_data['question_paper_start_time']
                        .toString());
            end = DateTime.parse(
                question_paper_data['question_paper_end_date'].toString() +
                    " " +
                    question_paper_data['question_paper_end_time'].toString());

            isLoading = false;
          });
        }
      } else {
        isLoading = false;
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print(body);
    }
  }

  reviewed() async {
    var data = {
      "solution_questionpaper_id": widget.solution_questionpaper_id,
    };
    var res = await Api().postData(data, "setSolutionPaperReviewedLecturer");
    var body = json.decode(res.body);
    print(body);
    if (body['success'] != null) {
      if (this.mounted) {
        return body;
      }
    } else {
      error_alert().alert(context, "Error", body.toString());
    }
  }

  page(qtype, index, mode) {
    print(qtype);
    if (qtype == 1) {
      return LecturerViewSubmissionPractical(
          question_paper_detail_data[index.toString()]
              ['solution_questionpaper_id'],
          question_paper_detail_data[index.toString()]
              ['solution_paperdetail_id'],
          index + 1,
          mode);
    } else if (qtype == 2) {
      return LecturerViewSubmissionEssay(
          question_paper_detail_data[index.toString()]
              ['solution_questionpaper_id'],
          question_paper_detail_data[index.toString()]
              ['solution_paperdetail_id'],
          index + 1,
          mode);
    } else if (qtype == 3) {
      return LecturerViewSubmissionMCQ(
          question_paper_detail_data[index.toString()]
              ['solution_questionpaper_id'],
          question_paper_detail_data[index.toString()]
              ['solution_paperdetail_id'],
          index + 1,
          mode);
    } else if (qtype == 4) {
      return LecturerViewSubmissionTF(
          question_paper_detail_data[index.toString()]
              ['solution_questionpaper_id'],
          question_paper_detail_data[index.toString()]
              ['solution_paperdetail_id'],
          index + 1,
          mode);
    } else if (qtype == 5) {
      return LecturerViewSubmissionMS(
          question_paper_detail_data[index.toString()]
              ['solution_questionpaper_id'],
          question_paper_detail_data[index.toString()]
              ['solution_paperdetail_id'],
          index + 1,
          mode);
    } else if (qtype == 6) {
      return LecturerViewSubmissionSA(
          question_paper_detail_data[index.toString()]
              ['solution_questionpaper_id'],
          question_paper_detail_data[index.toString()]
              ['solution_paperdetail_id'],
          index + 1,
          mode);
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
                    flex: 2,
                    child: Column(children: [
                      Expanded(
                          child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Course name:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                Text("Number of question:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text("Submission Time:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text("Student name:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text("Total score:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    question_paper_data['course_title']
                                        .toString(),
                                    style: TextStyle(fontSize: 15)),
                                Text(
                                    question_paper_detail_data['count']
                                        .toString(),
                                    style: TextStyle(fontSize: 15)),
                                Text(
                                    solution_paper_data['actual_end_time']
                                        .toString(),
                                    style: TextStyle(fontSize: 15)),
                                Text(student_data['student_name'],
                                    style: TextStyle(fontSize: 15)),
                                Text(
                                    total_mark.toString() +
                                        "/" +
                                        raw_mark_total.toString(),
                                    style: TextStyle(fontSize: 15)),
                              ],
                            ),
                          ),
                          if (solution_paper_data['isReviewed'] == false) ...[
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        dialog_template().confirmation_dialog(
                                            context,
                                            "No",
                                            "Yes",
                                            "Review confirmation",
                                            "Did you sure that you have review the answer? This action cannot be undo",
                                            () => null,
                                            () => reviewed().then((value) {
                                                  if (value['success'] ==
                                                      true) {
                                                    Navigator.pop(context);
                                                  }
                                                }));
                                      },
                                      child: Text("Reviewed",
                                          style: TextStyle(fontSize: 15))),
                                ],
                              ),
                            ),
                          ]
                        ],
                      )),
                    ]),
                  ),
                  Expanded(
                      flex: 11,
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: question_paper_detail_data['count'],
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                                onTap: () {
                                  if (solution_paper_data['isReviewed'] ==
                                      false) {
                                    Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) => page(
                                                question_paper_detail_data[
                                                        index.toString()]
                                                    ['question_type_id'],
                                                index,
                                                'edit'))).then((value) {
                                      setState(() {
                                        completed_question = 0;
                                        isLoading = true;
                                        total_mark = 0;
                                        raw_mark_total = 0;
                                        get_question_data();
                                      });
                                    });
                                  } else {
                                    Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) => page(
                                                question_paper_detail_data[
                                                        index.toString()]
                                                    ['question_type_id'],
                                                index,
                                                'view'))).then((value) {
                                      setState(() {
                                        completed_question = 0;
                                        isLoading = true;
                                        total_mark = 0;
                                        raw_mark_total = 0;
                                        get_question_data();
                                      });
                                    });
                                  }
                                  ;
                                },
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Column(
                                    children: [
                                      Card(
                                          color: question_paper_detail_data[
                                                              index.toString()][
                                                          'solution_total_score']
                                                      .toString() !=
                                                  '0'
                                              ? Colors.green
                                              : Colors.red,
                                          elevation: 4.0,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        "Question " +
                                                            (index + 1)
                                                                .toString() +
                                                            ":",
                                                        style: const TextStyle(
                                                            fontFamily: 'Arial',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15),
                                                      )),
                                                  Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        question_paper_detail_data[
                                                                    index
                                                                        .toString()]
                                                                [
                                                                'question_type_name']
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontFamily: 'Arial',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15),
                                                      )),
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        "(" +
                                                            question_paper_detail_data[
                                                                        index
                                                                            .toString()]
                                                                    ['raw_mark']
                                                                .toString() +
                                                            " Marks) ",
                                                        style: const TextStyle(
                                                            fontFamily: 'Arial',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15),
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
                                                    "Question Content ",
                                                    style: const TextStyle(
                                                        fontFamily: 'Arial',
                                                        fontSize: 15),
                                                  )),
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        question_paper_detail_data[
                                                                    index
                                                                        .toString()]
                                                                [
                                                                'question_detail']['desc']
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: 'Arial',
                                                            fontSize: 15),
                                                      )),
                                                ],
                                              ),
                                              if (question_paper_detail_data[
                                                          index.toString()]
                                                      ['question_type_id'] !=
                                                  5) ...[
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: Text(
                                                      "Student Answer ",
                                                      style: const TextStyle(
                                                          fontFamily: 'Arial',
                                                          fontSize: 15),
                                                    )),
                                                    if (question_paper_detail_data[
                                                                index
                                                                    .toString()]
                                                            [
                                                            'student_answer'] !=
                                                        null) ...[
                                                      Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            question_paper_detail_data[
                                                                            index.toString()]
                                                                        [
                                                                        'student_answer']
                                                                    [
                                                                    'answer_desc']
                                                                .toString(),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Arial',
                                                                fontSize: 15),
                                                          ))
                                                    ] else ...[
                                                      Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            "Not yet answer",
                                                            style: const TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Arial',
                                                                fontSize: 15),
                                                          ))
                                                    ],
                                                  ],
                                                )
                                              ],
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                    "Score ",
                                                    style: const TextStyle(
                                                        fontFamily: 'Arial',
                                                        fontSize: 15),
                                                  )),
                                                  if (question_paper_detail_data[
                                                                  index
                                                                      .toString()]
                                                              [
                                                              'solution_total_score']
                                                          .toString() !=
                                                      '0') ...[
                                                    Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          question_paper_detail_data[
                                                                      index
                                                                          .toString()]
                                                                  [
                                                                  'solution_total_score']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'Arial',
                                                                  fontSize: 15),
                                                        )),
                                                  ] else ...[
                                                    if (question_paper_detail_data[index.toString()]['question_type_id'].toString() != '1' &&
                                                        question_paper_detail_data[
                                                                        index
                                                                            .toString()]
                                                                    [
                                                                    'question_type_id']
                                                                .toString() !=
                                                            '2' &&
                                                        question_paper_detail_data[
                                                                        index
                                                                            .toString()]
                                                                    [
                                                                    'question_type_id']
                                                                .toString() !=
                                                            '6') ...[
                                                      Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            question_paper_detail_data[
                                                                        index
                                                                            .toString()]
                                                                    [
                                                                    'solution_total_score']
                                                                .toString(),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Arial',
                                                                fontSize: 15),
                                                          )),
                                                    ] else ...[
                                                      Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            question_paper_detail_data[
                                                                        index
                                                                            .toString()]
                                                                    [
                                                                    'solution_total_score']
                                                                .toString(),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Arial',
                                                                fontSize: 15),
                                                          )),
                                                    ]
                                                  ]
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                    "Feedback ",
                                                    style: const TextStyle(
                                                        fontFamily: 'Arial',
                                                        fontSize: 15),
                                                  )),
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        question_paper_detail_data[
                                                                            index.toString()]
                                                                        [
                                                                        'feedback']
                                                                    .toString() !=
                                                                'null'
                                                            ? question_paper_detail_data[
                                                                        index
                                                                            .toString()]
                                                                    ['feedback']
                                                                .toString()
                                                            : "No comment",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: 'Arial',
                                                            fontSize: 15),
                                                      )),
                                                ],
                                              ),
                                            ],
                                          )),
                                      Divider(
                                        thickness: 1.0,
                                        color: Colors.black,
                                        endIndent: 0,
                                        indent: 0,
                                      )
                                    ],
                                  ),
                                ));
                          },
                        ),
                      ))
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
