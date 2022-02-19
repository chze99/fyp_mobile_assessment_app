// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';
import 'package:toast/toast.dart';

class LecturerViewSubmissionSA extends StatefulWidget {
  @override
  int solution_questionpaper_id = 0;
  int solution_paperdetail_id = 0;
  int question_number = 0;
  String mode = '';
  LecturerViewSubmissionSA(this.solution_questionpaper_id,
      this.solution_paperdetail_id, this.question_number, this.mode);

  _LecturerViewSubmissionSAState createState() =>
      _LecturerViewSubmissionSAState();
}

class _LecturerViewSubmissionSAState extends State<LecturerViewSubmissionSA> {
  bool isLoading = true;
  var sa_retrived_data;
  var question_detail_data;
  var answer_data;
  var subquestion;
  var sa_answer;
  List<String> subsa_answer = [];
  TextEditingController feedback = new TextEditingController();
  TextEditingController score = new TextEditingController();
  final form_key = GlobalKey<FormState>();
  bool isSubmitting = false;
  bool success = false;
  @override
  void initState() {
    get_sa();

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_sa() async {
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
    };
    var res = await Api().postData(data, "getSASubmissionStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No SA found") {
        if (this.mounted) {
          setState(() {
            sa_retrived_data = body['q'];
            question_detail_data = body['qd'];
            answer_data = body['sqa'];
            if (answer_data != "No answer") {
              sa_answer = answer_data['shortanswer_answer'];
            }
            if (question_detail_data['solution_total_score'] != null) {
              score.text = question_detail_data['solution_total_score'];
            }
            if (question_detail_data['feedback'] != null) {
              feedback.text = question_detail_data['feedback'];
            }
            print(sa_retrived_data);
            print(question_detail_data);
            print(answer_data);
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print("Get sa error" + body.toString());
    }
  }

  update_score() async {
    var data;

    data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
      'solution_total_score': score.text,
      'feedback': feedback.text,
    };

    var res = await Api().postData(data, "updateSolutionSubmissionLecturer");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        print("Essay  Update" + body.toString());
        return body['success'];
      }
    } else {
      print("Essay  error" + body.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("SA"),
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
              title: Text("Question " + widget.question_number.toString()),
              backgroundColor: Colors.orange,
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                        key: form_key,
                        child: Column(
                          children: [
                            Expanded(
                                flex: 15,
                                child: SingleChildScrollView(
                                    physics: ScrollPhysics(),
                                    child: Column(
                                      children: [
                                        Row(children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text("Section ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              question_detail_data[
                                                      'section_number']
                                                  .toString(),
                                            ),
                                          ),
                                        ]),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Card(
                                          child: Column(
                                            children: [
                                              Row(children: [
                                                Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Question:",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    )),
                                                Expanded(
                                                    flex: 3,
                                                    child: Text(sa_retrived_data[
                                                            'shortanswer_question_desc']
                                                        .toString())),
                                              ]),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                          "Student Answer",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                        sa_answer.toString()),
                                                  ),
                                                ],
                                              ),
                                              Row(children: [
                                                Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Sample Answer:",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    )),
                                                Expanded(
                                                    flex: 3,
                                                    child: Text(sa_retrived_data[
                                                            'shortanswer_answer']
                                                        .toString()))
                                              ]),
                                            ],
                                          ),
                                        ),
                                        if (widget.mode == 'edit') ...[
                                          Card(
                                            child: Column(
                                              children: [
                                                Row(children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        "Lecturer Feedback:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15),
                                                      )),
                                                  Expanded(
                                                    flex: 3,
                                                    child: TextFormField(
                                                      keyboardType:
                                                          TextInputType
                                                              .multiline,
                                                      controller: feedback,
                                                      maxLines: null,
                                                    ),
                                                  ),
                                                ]),
                                              ],
                                            ),
                                          ),
                                          Card(
                                            child: Column(
                                              children: [
                                                Row(children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        "Score:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15),
                                                      )),
                                                  Expanded(
                                                    flex: 3,
                                                    child: TextFormField(
                                                      keyboardType:
                                                          TextInputType.number,
                                                      controller: score,
                                                      maxLines: null,
                                                      validator: (scoreValue) {
                                                        if (scoreValue!
                                                            .isEmpty) {
                                                          return 'Please enter score';
                                                        } else if (regex()
                                                                .isDoubleOnly(
                                                                    scoreValue) ==
                                                            false) {
                                                          return 'Please enter number only';
                                                        } else if (double.parse(
                                                                scoreValue) >
                                                            double.parse(
                                                                question_detail_data[
                                                                    'raw_mark'])) {
                                                          return 'Score cannot greater than total score';
                                                        }
                                                        score.text = scoreValue;
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text("/" +
                                                        question_detail_data[
                                                                'raw_mark']
                                                            .toString()),
                                                  ),
                                                ]),
                                              ],
                                            ),
                                          ),
                                        ] else ...[
                                          Card(
                                            child: Column(
                                              children: [
                                                Row(children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        "Lecturer Feedback:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15),
                                                      )),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      feedback.text,
                                                    ),
                                                  ),
                                                ]),
                                              ],
                                            ),
                                          ),
                                          Card(
                                            child: Column(
                                              children: [
                                                Row(children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        "Score:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15),
                                                      )),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      score.text +
                                                          "/" +
                                                          question_detail_data[
                                                                  'raw_mark']
                                                              .toString(),
                                                    ),
                                                  ),
                                                ]),
                                              ],
                                            ),
                                          ),
                                        ]
                                      ],
                                    ))),
                            if (widget.mode == 'edit') ...[
                              Expanded(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        if (form_key.currentState!.validate()) {
                                          if (isSubmitting == false) {
                                            setState(() {
                                              isSubmitting = true;
                                            });

                                            update_score().then((value) {
                                              if (value) {
                                                Toast.show("Saved", context);
                                                Navigator.pop(context);
                                              }
                                            });
                                          }
                                        }
                                      },
                                      child: Text(isSubmitting
                                          ? 'Updating...'
                                          : 'Update'))
                                ],
                              ))
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
