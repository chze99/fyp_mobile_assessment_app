// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';

class StudentViewSubmissionMS extends StatefulWidget {
  @override
  int solution_questionpaper_id = 0;
  int solution_paperdetail_id = 0;
  int question_number = 0;
  StudentViewSubmissionMS(this.solution_questionpaper_id,
      this.solution_paperdetail_id, this.question_number);

  _StudentViewSubmissionMSState createState() =>
      _StudentViewSubmissionMSState();
}

class _StudentViewSubmissionMSState extends State<StudentViewSubmissionMS> {
  bool isLoading = true;
  var ms_retrived_data;
  var question_detail_data;
  var answer_data;
  var subquestion;
  var ms_answer;
  List<String> subms_answer = [];

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
                                      elevation: 5,
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 2,
                                                  child: Text("Your Answer",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
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
                                                          fontWeight: FontWeight
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
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              Expanded(
                                                  flex: 3,
                                                  child: Text("Result",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: ListView.builder(
                                                    itemCount: ms_retrived_data[
                                                        'selection_count'],
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Container(
                                                        child: Column(
                                                            children: [
                                                              Row(children: [
                                                                Expanded(
                                                                    flex: 12,
                                                                    child: Text(
                                                                      answer_data['selection'][index]
                                                                              [
                                                                              'matchingsentence_selection_left']
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15),
                                                                    )),
                                                                Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                        '')),
                                                                Expanded(
                                                                    flex: 12,
                                                                    child: Text(
                                                                      answer_data['selection'][index]
                                                                              [
                                                                              'matchingsentence_selection_right']
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15),
                                                                    )),
                                                                SizedBox(
                                                                    width: 5),
                                                                if (question_detail_data[
                                                                        'isReviewed'] ==
                                                                    true) ...[
                                                                  Expanded(
                                                                      flex: 3,
                                                                      child:
                                                                          Text(
                                                                        answer_data['selection'][index]['matchingsentence_result']
                                                                            ? "Correct"
                                                                            : "Wrong",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color: answer_data['selection'][index]['matchingsentence_result']
                                                                              ? Colors.green
                                                                              : Colors.red,
                                                                        ),
                                                                      ))
                                                                ] else ...[
                                                                  Expanded(
                                                                      flex: 3,
                                                                      child:
                                                                          Text(
                                                                        "Pending",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                11,
                                                                            color:
                                                                                Colors.red),
                                                                      ))
                                                                ],
                                                              ]),
                                                              Divider(
                                                                thickness: 1.0,
                                                                color: Colors
                                                                    .black,
                                                                endIndent: 0,
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
                                    Card(
                                      elevation: 5,
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
                                                                'feedback']
                                                            .toString()))
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
