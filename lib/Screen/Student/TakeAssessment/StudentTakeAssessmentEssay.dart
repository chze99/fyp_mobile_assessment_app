// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';
import 'package:toast/toast.dart';

class StudentTakeAssessmentEssay extends StatefulWidget {
  @override
  int solution_questionpaper_id = 0;
  String mode = "";
  int solution_paperdetail_id = 0;
  int question_number = 0;
  StudentTakeAssessmentEssay(this.solution_questionpaper_id, this.mode,
      this.solution_paperdetail_id, this.question_number);

  _StudentTakeAssessmentEssayState createState() =>
      _StudentTakeAssessmentEssayState();
}

class _StudentTakeAssessmentEssayState
    extends State<StudentTakeAssessmentEssay> {
  bool isLoading = true;
  bool isSubmitting = false;
  var essay_retrived_data;
  var question_detail_data;
  var answer_data;
  var subquestion;
  TextEditingController essay_answer = new TextEditingController();
  List<TextEditingController> subessay_answer = [];

  final form_key = GlobalKey<FormState>();
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
    var res = await Api().postData(data, "getEssayQuestionStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No Essay found") {
        if (this.mounted) {
          setState(() {
            essay_retrived_data = body['q'];
            question_detail_data = body['qd'];
            answer_data = body['sqa'];
            if (answer_data != "No answer") {
              essay_answer.text = answer_data['essay_answer'];
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
                    subessay_answer.add(new TextEditingController());

                    subessay_answer[i].text = answer_data['subquestion'][i]
                        ['essay_subquestion_answer'];
                  } else {
                    subessay_answer.add(new TextEditingController());
                  }
                }
              }
            }
            print(essay_retrived_data);
            print(answer_data);
            print(widget.mode);
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

  submit_essay() async {
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
      'essay_answer': essay_answer.text,
    };
    var res = await Api().postData(data, "submitEssayAnswerStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("Save essay main error" + body.toString());
    }
  }

  update_essay() async {
    var data = {
      'essay_solution_id': answer_data['essay_solution_id'],
      'essay_answer': essay_answer.text,
    };

    var res = await Api().postData(data, "updateEssayAnswerStudent");
    var body = json.decode(res.body);
    print(body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("Essay Updated" + body.toString());
    }
  }

  submit_subessay(sid, index) async {
    var data = {
      'essay_solution_id': sid,
      'essay_subquestion_answer': subessay_answer[index].text,
    };
    var res = await Api().postData(data, "submitSubEssayAnswerStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        if (index == essay_retrived_data['subquestion_count'] - 1) {
          return body['success'];
        }
      }
    } else {
      print("Save essay error" + body.toString());
    }
  }

  update_subessay(index) async {
    var data = {
      'essay_subquestion_solution_id': answer_data['subquestion'][index]
          ['essay_subquestion_solution_id'],
      'essay_subquestion_answer': subessay_answer[index].text,
    };

    var res = await Api().postData(data, "updateSubEssayAnswerStudent");
    var body = json.decode(res.body);
    print(body);
    if (body['success'] == true) {
      if (this.mounted) {
        if (index == essay_retrived_data['subquestion_count'] - 1) {
          return body['success'];
        }
      }
    } else {
      print("Essay Updated" + body.toString());
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
                                              flex: 3,
                                              child: Text(
                                                "Question Description",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              )),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                                "Section " +
                                                    question_detail_data[
                                                            'section_number']
                                                        .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                                "(" +
                                                    question_detail_data[
                                                            'raw_mark']
                                                        .toString() +
                                                    " marks)",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                          )
                                        ]),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(children: [
                                          Expanded(
                                              flex: 1,
                                              child: Text(essay_retrived_data[
                                                      'essay_question_desc']
                                                  .toString())),
                                        ]),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(children: [
                                          Text("Answer",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold))
                                        ]),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.multiline,
                                                controller: essay_answer,
                                                maxLines: null,
                                                validator: (questiondescValue) {
                                                  if (questiondescValue!
                                                      .isEmpty) {
                                                    return 'Please enter answer';
                                                  }
                                                  essay_answer.text =
                                                      questiondescValue;
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
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
                                                    itemCount:
                                                        essay_retrived_data[
                                                            'subquestion_count'],
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
                                                                  flex: 3,
                                                                  child: Text(
                                                                    "SubQuestion " +
                                                                        (index +
                                                                                1)
                                                                            .toString() +
                                                                        " Description",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            15),
                                                                  )),
                                                            ]),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(children: [
                                                              Expanded(
                                                                  flex: 1,
                                                                  child: Text(subquestion[
                                                                              index]
                                                                          [
                                                                          'essay_subquestion_desc']
                                                                      .toString())),
                                                            ]),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(children: [
                                                              Expanded(
                                                                  flex: 1,
                                                                  child: Text(
                                                                      "Answer",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold))),
                                                            ]),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      TextFormField(
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .multiline,
                                                                    controller:
                                                                        subessay_answer[
                                                                            index],
                                                                    maxLines:
                                                                        null,
                                                                    validator:
                                                                        (questiondescValue) {
                                                                      if (questiondescValue!
                                                                          .isEmpty) {
                                                                        return 'Please enter answer';
                                                                      }
                                                                      subessay_answer[index]
                                                                              .text =
                                                                          questiondescValue;
                                                                      return null;
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ]));
                                                    }),
                                              ),
                                            ],
                                          )
                                        ],
                                      ],
                                    ))),
                            Column(
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 5),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (form_key.currentState!
                                              .validate()) {
                                            if (isSubmitting == false) {
                                              setState(() {
                                                isSubmitting = true;
                                              });
                                              if (widget.mode == "take") {
                                                submit_essay().then((value) {
                                                  if (value['success']) {
                                                    if (essay_retrived_data[
                                                                'essay_have_subquestion']
                                                            .toString() ==
                                                        'true') {
                                                      for (int i = 0;
                                                          i <
                                                              essay_retrived_data[
                                                                  'subquestion_count'];
                                                          i++) {
                                                        submit_subessay(
                                                                value['data'][
                                                                    'essay_solution_id'],
                                                                i)
                                                            .then((value) {
                                                          if (value == true) {
                                                            Toast.show("Saved",
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        });
                                                      }
                                                      ;
                                                    } else {
                                                      Toast.show(
                                                          "Saved", context);
                                                      Navigator.pop(context);
                                                    }
                                                  }
                                                });
                                              } else if (widget.mode ==
                                                  "edit") {
                                                update_essay().then((value) {
                                                  if (value['success']) {
                                                    if (essay_retrived_data[
                                                                'essay_have_subquestion']
                                                            .toString() ==
                                                        'true') {
                                                      for (int i = 0;
                                                          i <
                                                              essay_retrived_data[
                                                                  'subquestion_count'];
                                                          i++) {
                                                        update_subessay(i)
                                                            .then((value) {
                                                          if (value == true) {
                                                            Toast.show("Saved",
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        });
                                                      }
                                                    } else {
                                                      Toast.show(
                                                          "Saved", context);
                                                      Navigator.pop(context);
                                                    }
                                                  }
                                                });
                                              }
                                            }
                                          }
                                        },
                                        child: Text(isSubmitting
                                            ? "Submitting"
                                            : "Submit"),
                                      )
                                    ]),
                              ],
                            ),
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
