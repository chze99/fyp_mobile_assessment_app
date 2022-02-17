// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';

class StudentViewSubmissionMCQ extends StatefulWidget {
  @override
  int solution_questionpaper_id = 0;
  int solution_paperdetail_id = 0;
  int question_number = 0;
  StudentViewSubmissionMCQ(this.solution_questionpaper_id,
      this.solution_paperdetail_id, this.question_number);

  _StudentViewSubmissionMCQState createState() =>
      _StudentViewSubmissionMCQState();
}

class _StudentViewSubmissionMCQState extends State<StudentViewSubmissionMCQ> {
  bool isLoading = true;
  var mcq_retrived_data;
  var question_detail_data;
  var answer_data;
  var subquestion;
  var mcq_answer;
  List<String> submcq_answer = [];
  var mcq_correct_answer;
  bool success = false;
  @override
  void initState() {
    get_mcq();

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_mcq() async {
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
    };
    var res = await Api().postData(data, "getMCQSubmissionStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No MCQ found") {
        if (this.mounted) {
          setState(() {
            mcq_retrived_data = body['q'];
            question_detail_data = body['qd'];
            answer_data = body['sqa'];
            if (answer_data != "No answer") {
              for (int i = 0; i < 4; i++) {
                if (answer_data['answer']['mcq_option_desc'].toString() ==
                    mcq_retrived_data['Option'][i]['mcq_option_desc']
                        .toString()) {
                  mcq_answer = "Option " + (i + 1).toString();
                }
                if (mcq_retrived_data['mcq_answer']['mcq_option_desc']
                        .toString() ==
                    mcq_retrived_data['Option'][i]['mcq_option_desc']
                        .toString()) {
                  mcq_correct_answer = "Option " + (i + 1).toString();
                }
              }
            }
            print(mcq_retrived_data);
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
            title: Text("MCQ"),
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
                                                child: Text(mcq_retrived_data[
                                                        'mcq_desc']
                                                    .toString())),
                                          ]),
                                        ],
                                      ),
                                    ),
                                    Card(
                                        child: Column(
                                      children: [
                                        ListView.builder(
                                            itemCount: 4,
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return Container(
                                                child: Column(children: [
                                                  Row(children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          "Option " +
                                                              (index + 1)
                                                                  .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15),
                                                        )),
                                                    Expanded(
                                                        flex: 3,
                                                        child: Text(mcq_retrived_data[
                                                                        'Option']
                                                                    [index][
                                                                'mcq_option_desc']
                                                            .toString())),
                                                  ]),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ]),
                                              );
                                            }),
                                        Row(
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: Text("Your Answer",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            Expanded(
                                              flex: 3,
                                              child: Text(mcq_answer.toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        if (question_detail_data[
                                                'isReviewed'] ==
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
                                                child: Text(
                                                    mcq_correct_answer
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))
                                          ]),
                                        ]
                                      ],
                                    )),
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
