// ignore_for_file: non_constant_identifier_names, import_of_legacy_library_into_null_safe, must_be_immutable, override_on_non_overriding_member

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Student/TakeAssessment/StudentTakeAssessmentEssay.dart';
import 'package:mobile_assessment/Screen/Student/TakeAssessment/StudentTakeAssessmentMCQ.dart';
import 'package:mobile_assessment/Screen/Student/TakeAssessment/StudentTakeAssessmentMS.dart';
import 'package:mobile_assessment/Screen/Student/TakeAssessment/StudentTakeAssessmentPractical.dart';
import 'package:mobile_assessment/Screen/Student/TakeAssessment/StudentTakeAssessmentSA.dart';
import 'package:mobile_assessment/Screen/Student/TakeAssessment/StudentTakeAssessmentTF.dart';
import 'package:mobile_assessment/Screen/Student/ViewSubmission/StudentViewSubmissionMCQ.dart';
import 'package:mobile_assessment/Screen/Student/ViewSubmission/StudentViewSubmissionTF.dart';
import 'package:mobile_assessment/Screen/Student/ViewSubmission/StudentViewSubmissionEssay.dart';
import 'package:mobile_assessment/Screen/Student/ViewSubmission/StudentViewSubmissionMS.dart';
import 'package:mobile_assessment/Screen/Student/ViewSubmission/StudentViewSubmissionPractical.dart';
import 'package:mobile_assessment/Screen/Student/ViewSubmission/StudentViewSubmissionSA.dart';
import 'package:mobile_assessment/Screen/dialog_template.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:toast/toast.dart';

import '../../loading_page.dart';

class StudentViewSubmissionPage extends StatefulWidget {
  @override
  int question_paper_id = 0;
  int solution_questionpaper_id = 0;
  StudentViewSubmissionPage(
      this.question_paper_id, this.solution_questionpaper_id);

  _StudentViewSubmissionPageState createState() =>
      _StudentViewSubmissionPageState();
}

class _StudentViewSubmissionPageState extends State<StudentViewSubmissionPage> {
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
  int completed_question = 0;
  var tabs;
  bool isDone = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    get_question_data();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
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
    if (body['success'] != null) {
      if (body['message'] != "No question paper") {
        if (this.mounted) {
          setState(() {
            question_paper_data = body['message'];
            solution_paper_data = body['sol'];
            question_paper_detail_data = body['question'];
            print(question_paper_data);
            print(question_paper_detail_data);
            print(solution_paper_data);
            for (int i = 0; i < question_paper_detail_data['count']; i++) {
              if (question_paper_detail_data[i.toString()]['student_answer'] !=
                  null) {
                completed_question += 1;
              }
            }
            if (completed_question == question_paper_detail_data['count']) {
              isDone = true;
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

  page(qtype, index) {
    print(qtype);
    if (qtype == 1) {
      return StudentViewSubmissionPractical(
          question_paper_detail_data[index.toString()]
              ['solution_questionpaper_id'],
          question_paper_detail_data[index.toString()]
              ['solution_paperdetail_id'],
          index + 1);
    } else if (qtype == 2) {
      return StudentViewSubmissionEssay(
          question_paper_detail_data[index.toString()]
              ['solution_questionpaper_id'],
          question_paper_detail_data[index.toString()]
              ['solution_paperdetail_id'],
          index + 1);
    } else if (qtype == 3) {
      return StudentViewSubmissionMCQ(
          question_paper_detail_data[index.toString()]
              ['solution_questionpaper_id'],
          question_paper_detail_data[index.toString()]
              ['solution_paperdetail_id'],
          index + 1);
    } else if (qtype == 4) {
      return StudentViewSubmissionTF(
          question_paper_detail_data[index.toString()]
              ['solution_questionpaper_id'],
          question_paper_detail_data[index.toString()]
              ['solution_paperdetail_id'],
          index + 1);
    } else if (qtype == 5) {
      return StudentViewSubmissionMS(
          question_paper_detail_data[index.toString()]
              ['solution_questionpaper_id'],
          question_paper_detail_data[index.toString()]
              ['solution_paperdetail_id'],
          index + 1);
    } else if (qtype == 6) {
      return StudentViewSubmissionSA(
          question_paper_detail_data[index.toString()]
              ['solution_questionpaper_id'],
          question_paper_detail_data[index.toString()]
              ['solution_paperdetail_id'],
          index + 1);
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
                              flex: 1,
                              child: Text(
                                "Course name:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Expanded(
                                flex: 2,
                                child: Text(question_paper_data['course_title']
                                    .toString()))
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text("Number of question:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                            Expanded(
                                flex: 2,
                                child: Text(question_paper_detail_data['count']
                                    .toString()))
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text("Submission Time:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    solution_paper_data['actual_end_time']
                                        .toString()))
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text("Score:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))),
                            if (solution_paper_data['isReviewed'] == true) ...[
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                      solution_paper_data['total_score'] +
                                          '/' +
                                          question_paper_data[
                                              'whole_solution_score'])),
                            ] else ...[
                              Expanded(
                                  flex: 2, child: Text("Pending for review")),
                            ]
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text("Weightage Score:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))),
                            if (solution_paper_data['isReviewed'] == true) ...[
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                      solution_paper_data['actual_score'] +
                                          '/' +
                                          question_paper_data[
                                              'assessment_detail_weightage'])),
                            ] else ...[
                              Expanded(
                                  flex: 2, child: Text("Pending for review")),
                            ]
                          ],
                        ),
                      ),
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
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => page(
                                            question_paper_detail_data[
                                                    index.toString()]
                                                ['question_type_id'],
                                            index))).then((value) {
                                  setState(() {
                                    completed_question = 0;
                                    isLoading = true;
                                    get_question_data();
                                  });
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Column(
                                  children: [
                                    Card(
                                        color: question_paper_detail_data[
                                                            index.toString()]
                                                        ['solution_total_score']
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
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                    "Your Answer ",
                                                    style: const TextStyle(
                                                        fontFamily: 'Arial',
                                                        fontSize: 15),
                                                  )),
                                                  if (question_paper_detail_data[
                                                              index.toString()]
                                                          ['student_answer'] !=
                                                      null) ...[
                                                    Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          question_paper_detail_data[
                                                                          index
                                                                              .toString()]
                                                                      [
                                                                      'student_answer']
                                                                  [
                                                                  'answer_desc']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
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
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .red,
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
                                            Row(
                                              children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: Text("Score:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15))),
                                                if (solution_paper_data[
                                                        'isReviewed'] ==
                                                    true) ...[
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text(question_paper_detail_data[
                                                                  index
                                                                      .toString()]
                                                              [
                                                              'solution_total_score']
                                                          .toString())),
                                                ] else ...[
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                          "Pending for review")),
                                                ]
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: Text("Feedback:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15))),
                                                if (solution_paper_data[
                                                        'isReviewed'] ==
                                                    true) ...[
                                                  if (question_paper_detail_data[
                                                                  index
                                                                      .toString()]
                                                              ['feedback']
                                                          .toString() !=
                                                      'null') ...[
                                                    Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                            question_paper_detail_data[
                                                                        index
                                                                            .toString()]
                                                                    ['feedback']
                                                                .toString()))
                                                  ] else ...[
                                                    Expanded(
                                                        flex: 3,
                                                        child:
                                                            Text("No comment"))
                                                  ],
                                                ] else ...[
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                          "Pending for review")),
                                                ]
                                              ],
                                            ),
                                          ],
                                        ))
                                  ],
                                ),
                              ));
                        },
                      )))
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
