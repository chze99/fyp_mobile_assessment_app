// ignore_for_file: non_constant_identifier_names, import_of_legacy_library_into_null_safe, must_be_immutable, override_on_non_overriding_member

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Student/TakeAssessment/StudentTakeAssessmentPage.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:toast/toast.dart';

import '../loading_page.dart';

class StudentAssessmentViewDetail extends StatefulWidget {
  @override
  int question_paper_id = 0;
  String mode = "";
  int assessment_detail_id = 0;
  int user_id = 0;
  StudentAssessmentViewDetail(this.question_paper_id, this.mode,
      this.assessment_detail_id, this.user_id);

  _StudentAssessmentViewDetailState createState() =>
      _StudentAssessmentViewDetailState();
}

class _StudentAssessmentViewDetailState
    extends State<StudentAssessmentViewDetail> {
  String name = "";
  var isLoading = true;
  var question_paper_data;
  var course_student_data;
  DateTime todayData =
      new DateFormat("yyyy-MM-dd").parse(DateTime.now().toString());
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int today_count = 0, past_count = 0, future_count = 0;
  bool isStarted = false;
  bool isEnded = false;
  bool isSubmitting = false;
  DateTime now = DateTime.now();
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  @override
  void initState() {
    get_question_data();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
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
            start = DateTime.parse(
                question_paper_data['question_paper_start_date'].toString() +
                    " " +
                    question_paper_data['question_paper_start_time']
                        .toString());
            end = DateTime.parse(
                question_paper_data['question_paper_end_date'].toString() +
                    " " +
                    question_paper_data['question_paper_end_time'].toString());
            print(question_paper_data);
            _getTime();
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

  validate_start_time() async {
    var data = {'start_time': start.toString(), 'end_time': end.toString()};
    var res = await Api().postData(data, "validateAssessmentStartTime");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        return body['message'];
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print(body);
    }
  }

  create_solution_paper() async {
    var data = {
      'user_id': widget.user_id,
      'question_paper_id': widget.question_paper_id
    };
    var res = await Api().postData(data, "createStudentSolutionPaper");
    var body = json.decode(res.body);
    print(body);
    print('test');
    print(body['message']);
    print(body['message']);
    print(body['message']['solution_questionpaper_id']);

    if (body['success'] != null) {
      if (this.mounted) {
        return body;
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print(body);
    }
  }

  void _getTime() {
    final DateTime now_time = DateTime.now();

    setState(() {
      now = now_time;
    });
    if (now.isAfter(start) && now.isBefore(end)) {
      isStarted = true;
    } else if (now.isAfter(end)) {
      isEnded = true;
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
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Text(
                              "Course Name: ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            )),
                            Expanded(
                                child: Text(
                              question_paper_data['course_title'].toString(),
                              style: TextStyle(fontSize: 20),
                            ))
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Text(
                              "Start Time: ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            )),
                            Expanded(
                                child: Text(
                              question_paper_data['question_paper_start_date']
                                      .toString() +
                                  " " +
                                  question_paper_data[
                                          'question_paper_start_time']
                                      .toString(),
                              style: TextStyle(fontSize: 20),
                            ))
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "End Time: ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  question_paper_data['question_paper_end_date']
                                          .toString() +
                                      " " +
                                      question_paper_data[
                                              'question_paper_end_time']
                                          .toString(),
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ]),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Text(
                              "Total mark: ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            )),
                            Expanded(
                                child: Text(
                              question_paper_data['assessment_detail_weightage']
                                  .toString(),
                              style: TextStyle(fontSize: 20),
                            ))
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Text(
                                "Number of question: ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              )),
                              Expanded(
                                  child: Text(
                                question_paper_data['number_of_question']
                                    .toString(),
                                style: TextStyle(fontSize: 20),
                              )),
                            ]),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (isSubmitting == false) {
                                  setState(() {
                                    isSubmitting = true;
                                  });
                                  if (isStarted == true) {
                                    validate_start_time().then((value) {
                                      if (value == true) {
                                        create_solution_paper().then((value) {
                                          if (value['success'] == true) {
                                            Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (context) =>
                                                        StudentTakeAssessmentPage(
                                                            question_paper_data[
                                                                'question_paper_id'],
                                                            value['message'][
                                                                'solution_questionpaper_id']))).then(
                                                (value) {
                                              setState(() {
                                                isLoading = true;
                                                get_question_data();
                                                isSubmitting = false;
                                              });
                                            });
                                            ;
                                          }
                                        });
                                      }
                                    });
                                  } else if (isEnded == true) {
                                    Toast.show("Already ended", context);
                                  } else {
                                    Toast.show("Not yet start", context);
                                  }
                                }
                              },
                              child: Text(
                                isEnded ? "Ended" : "Start",
                                style: (isStarted
                                    ? TextStyle(color: Colors.black)
                                    : isEnded
                                        ? TextStyle(color: Colors.white)
                                        : TextStyle(color: Colors.white)),
                              ),
                              style: ButtonStyle(
                                backgroundColor: isStarted
                                    ? MaterialStateProperty.all<Color>(
                                        Colors.green)
                                    : isEnded
                                        ? MaterialStateProperty.all<Color>(
                                            Colors.red)
                                        : MaterialStateProperty.all<Color>(
                                            Colors.grey),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
