// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';

class StudentViewSubmissionTF extends StatefulWidget {
  @override
  int solution_questionpaper_id = 0;
  int solution_paperdetail_id = 0;
  int question_number = 0;
  StudentViewSubmissionTF(this.solution_questionpaper_id,
      this.solution_paperdetail_id, this.question_number);

  _StudentViewSubmissionTFState createState() =>
      _StudentViewSubmissionTFState();
}

class _StudentViewSubmissionTFState extends State<StudentViewSubmissionTF> {
  bool isLoading = true;
  var tf_retrived_data;
  var question_detail_data;
  var answer_data;
  var subquestion;
  var tf_answer;
  List<String> subtf_answer = [];

  bool success = false;
  @override
  void initState() {
    get_tf();

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_tf() async {
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
    };
    var res = await Api().postData(data, "getTFSubmissionStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No TF found") {
        if (this.mounted) {
          setState(() {
            tf_retrived_data = body['q'];
            question_detail_data = body['qd'];
            answer_data = body['sqa'];
            if (answer_data != "No answer") {
              tf_answer = answer_data['truefalse_answer'];
            }
            print(tf_retrived_data);
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
            title: Text("TF"),
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
                                          question_detail_data['section_number']
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
                                      if (question_detail_data['isReviewed'] ==
                                          true) ...[
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            question_detail_data[
                                                        'solution_total_score']
                                                    .toString() +
                                                "/" +
                                                question_detail_data['raw_mark']
                                                    .toString(),
                                          ),
                                        )
                                      ] else ...[
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            "Pending review",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        )
                                      ]
                                    ]),
                                    SizedBox(
                                      height: 20,
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
                                                child: Text(tf_retrived_data[
                                                        'truefalse_question_desc']
                                                    .toString())),
                                          ]),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 2,
                                                  child: Text("Your Answer",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              Expanded(
                                                flex: 3,
                                                child:
                                                    Text(tf_answer.toString()),
                                              ),
                                            ],
                                          ),
                                          if (question_detail_data[
                                                  'isReviewed'] !=
                                              true) ...[
                                            Row(children: [
                                              Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "Correct Answer:",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                  )),
                                              Expanded(
                                                  flex: 3,
                                                  child: Text(tf_retrived_data[
                                                          'truefalse_answer']
                                                      .toString()))
                                            ]),
                                          ]
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
                                                  "Lecturer Feedback:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                )),
                                            if (question_detail_data[
                                                    'isReviewed'] ==
                                                true) ...[
                                              if (question_detail_data[
                                                          'feedback'] !=
                                                      null &&
                                                  question_detail_data[
                                                          'feedback'] !=
                                                      '') ...[
                                                Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                        question_detail_data[
                                                            'feedback']))
                                              ] else ...[
                                                Expanded(
                                                    flex: 3,
                                                    child: Text("No comment"))
                                              ]
                                            ] else ...[
                                              Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    "Pending review",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ))
                                            ],
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ],
                                ))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}
