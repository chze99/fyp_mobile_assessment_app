// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';

class StudentViewSubmissionEssay extends StatefulWidget {
  @override
  int solution_questionpaper_id = 0;
  int solution_paperdetail_id = 0;
  int question_number = 0;
  StudentViewSubmissionEssay(this.solution_questionpaper_id,
      this.solution_paperdetail_id, this.question_number);

  _StudentViewSubmissionEssayState createState() =>
      _StudentViewSubmissionEssayState();
}

class _StudentViewSubmissionEssayState
    extends State<StudentViewSubmissionEssay> {
  bool isLoading = true;
  var essay_retrived_data;
  var question_detail_data;
  var answer_data;
  var subquestion;
  var essay_answer;
  List<String> subessay_answer = [];

  bool success = false;
  @override
  void initState() {
    get_essay();

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_essay() async {
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
    };
    var res = await Api().postData(data, "getEssaySubmissionStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No Essay found") {
        if (this.mounted) {
          setState(() {
            essay_retrived_data = body['q'];
            question_detail_data = body['qd'];
            answer_data = body['sqa'];
            if (answer_data != "No answer") {
              essay_answer = answer_data['essay_answer'];
            }
            if (essay_retrived_data['essay_have_subquestion'].toString() ==
                'true') {
              subquestion = essay_retrived_data['subquestion'];
              for (int i = 0;
                  i < essay_retrived_data['subquestion_count'];
                  i++) {
                if (subessay_answer.length <=
                    essay_retrived_data['subquestion_count']) {
                  if (answer_data != "No answer") {
                    subessay_answer.add("");
                    subessay_answer[i] = answer_data['subquestion'][i]
                        ['essay_subquestion_answer'];
                  }
                }
              }
            }
            print(essay_retrived_data);
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
            title: Text("Essay"),
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
                                                child: Text(essay_retrived_data[
                                                        'essay_question_desc']
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
                                                child: Text(essay_answer),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (essay_retrived_data[
                                                'essay_have_subquestion']
                                            .toString() ==
                                        'true') ...[
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: ListView.builder(
                                                itemCount: essay_retrived_data[
                                                    'subquestion_count'],
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                      child: Card(
                                                    child: Column(children: [
                                                      Row(children: [
                                                        Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                              "Sub " +
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
                                                            child: Text(subquestion[
                                                                        index][
                                                                    'essay_subquestion_desc']
                                                                .toString())),
                                                      ]),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(children: [
                                                        Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                                "Your Answer",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                              subessay_answer[
                                                                      index]
                                                                  .toString()),
                                                        ),
                                                      ]),
                                                    ]),
                                                  ));
                                                }),
                                          ),
                                        ],
                                      )
                                    ],
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
