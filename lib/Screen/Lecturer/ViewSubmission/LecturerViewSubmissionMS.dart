// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';
import 'package:toast/toast.dart';

class LecturerViewSubmissionMS extends StatefulWidget {
  @override
  int solution_questionpaper_id = 0;
  int solution_paperdetail_id = 0;
  int question_number = 0;
  String mode = '';
  LecturerViewSubmissionMS(this.solution_questionpaper_id,
      this.solution_paperdetail_id, this.question_number, this.mode);

  _LecturerViewSubmissionMSState createState() =>
      _LecturerViewSubmissionMSState();
}

class _LecturerViewSubmissionMSState extends State<LecturerViewSubmissionMS> {
  bool isLoading = true;
  var ms_retrived_data;
  var question_detail_data;
  var answer_data;
  var subquestion;
  var ms_answer;
  List<String> subms_answer = [];
  TextEditingController feedback = new TextEditingController();
  TextEditingController score = new TextEditingController();
  final form_key = GlobalKey<FormState>();
  bool isSubmitting = false;
  bool success = false;
  @override
  void initState() {
    get_ms();

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_ms() async {
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
    };
    var res = await Api().postData(data, "getMSSubmissionStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No MS found") {
        if (this.mounted) {
          setState(() {
            ms_retrived_data = body['q'];
            question_detail_data = body['qd'];
            answer_data = body['sqa'];
            if (question_detail_data['solution_total_score'] != null) {
              score.text = question_detail_data['solution_total_score'];
            }
            if (question_detail_data['feedback'] != null) {
              feedback.text = question_detail_data['feedback'];
            }
            print(ms_retrived_data);
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
            title: Text("MS"),
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
                                        Row(children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text("Score:",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              question_detail_data[
                                                          'total_score']
                                                      .toString() +
                                                  "/" +
                                                  question_detail_data[
                                                          'raw_mark']
                                                      .toString(),
                                            ),
                                          )
                                        ]),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Card(
                                          elevation: 5,
                                          child: Column(
                                            children: [
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
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 12,
                                                      child: Text("Left",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        "",
                                                      )),
                                                  Expanded(
                                                      flex: 12,
                                                      child: Text("Right",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))),
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text("Result",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: ListView.builder(
                                                        itemCount:
                                                            ms_retrived_data[
                                                                'selection_count'],
                                                        shrinkWrap: true,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Container(
                                                            child: Column(
                                                                children: [
                                                                  Row(
                                                                      children: [
                                                                        Expanded(
                                                                            flex:
                                                                                12,
                                                                            child:
                                                                                Text(
                                                                              answer_data['selection'][index]['matchingsentence_selection_left'].toString(),
                                                                              style: TextStyle(fontSize: 15),
                                                                            )),
                                                                        Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Text('')),
                                                                        Expanded(
                                                                            flex:
                                                                                12,
                                                                            child:
                                                                                Text(
                                                                              answer_data['selection'][index]['matchingsentence_selection_right'].toString(),
                                                                              style: TextStyle(fontSize: 15),
                                                                            )),
                                                                        SizedBox(
                                                                            width:
                                                                                5),
                                                                        Expanded(
                                                                            flex:
                                                                                3,
                                                                            child:
                                                                                Text(
                                                                              answer_data['selection'][index]['matchingsentence_result'] ? "Correct" : "Wrong",
                                                                              style: TextStyle(
                                                                                fontSize: 12,
                                                                                color: answer_data['selection'][index]['matchingsentence_result'] ? Colors.green : Colors.red,
                                                                              ),
                                                                            ))
                                                                      ]),
                                                                  Divider(
                                                                    thickness:
                                                                        1.0,
                                                                    color: Colors
                                                                        .black,
                                                                    endIndent:
                                                                        0,
                                                                    indent: 0,
                                                                  )
                                                                ]),
                                                          );
                                                        }),
                                                  ),
                                                ],
                                              ),
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
