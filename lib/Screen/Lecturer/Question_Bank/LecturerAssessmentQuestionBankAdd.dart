// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Lecturer/Question_Bank/LecturerAssessmentQuestionBankAddQuestion.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';

class LecturerAssessmentQuestionBankAdd extends StatefulWidget {
  @override
  int assessment_plan_id = 0;
  String mode = "";
  int question_bank_id = -1;
  LecturerAssessmentQuestionBankAdd(
      this.assessment_plan_id, this.mode, this.question_bank_id);
  _LecturerAssessmentQuestionBankAddState createState() =>
      _LecturerAssessmentQuestionBankAddState();
}

class _LecturerAssessmentQuestionBankAddState
    extends State<LecturerAssessmentQuestionBankAdd> {
  bool isLoading = true;
  bool isFound = false;
  bool havePlan = false;
  bool isSubmitting = false;
  var assessment_data;
  var question_bank_data;
  var question_bank_pass;
  var success;
  int questionbank_length = 0;
  List<DropdownMenuItem<int>> assessment_detail_list_items = [];
  int assessmentdetailValue = 0;
  List<DropdownMenuItem<String>> difficulty_list_items = [];
  List<String> difficulty_text = ['Easy', 'Moderate', 'Hard'];
  String difficultyValue = 'Easy';
  TextEditingController question_bank_name = new TextEditingController();
  int assessment_length = 0;
  final form_key = GlobalKey<FormState>();

  @override
  void initState() {
    get_assessment();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_assessment() async {
    var data = {
      'assessment_plan_id': widget.assessment_plan_id,
    };
    var res = await Api().postData(data, "getAssessmentDetailList");
    var body = json.decode(res.body);
    print(body);
    if (body['success'] != null) {
      if (this.mounted) {
        if (body['found'] == true) {
          setState(() {
            havePlan = true;
            assessment_data = body['message'];
            assessment_length = assessment_data['count'];
            assessment_detail_list_items = List.generate(
              assessment_length,
              (i) => DropdownMenuItem(
                value: assessment_data[i.toString()]['assessment_detail_id'],
                child: Text(
                    "${assessment_data[i.toString()]['assessment_detail_title']}"),
              ),
            );
            difficulty_list_items = List.generate(
              3,
              (i) => DropdownMenuItem(
                value: difficulty_text[i],
                child: Text("${difficulty_text[i]}"),
              ),
            );
            assessmentdetailValue =
                assessment_data['0']['assessment_detail_id'];
            print("Assessment Add:" + assessment_data.toString());
            get_question_bank();
          });
        } else {
          get_question_bank();
        }
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print("Get assessment error" + body.toString());
    }
  }

  get_question_bank() async {
    var data = {'question_bank_id': widget.question_bank_id};
    var res = await Api().postData(data, "getQuestionBankDetail");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        if (body['message'] != "No question bank") {
          setState(() {
            question_bank_data = body['message'];
            print("Question bank:" + question_bank_data.toString());
            difficultyValue =
                question_bank_data['question_bank_difficulty_level'];
            question_bank_name.text = question_bank_data['question_bank_name'];
            assessmentdetailValue = question_bank_data['assessment_detail_id'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print("Get question bank error" + body.toString());
    }
  }

  save_question_bank() async {
    var data = {
      'question_bank_difficulty_level': difficultyValue,
      'question_bank_name': question_bank_name.text,
      'assessment_detail_id': assessmentdetailValue,
      'question_bank_id': widget.question_bank_id,
    };
    var res = await Api().postData(data, "saveQuestionBank");
    var body = json.decode(res.body);
    print(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        success = true;
        return body;
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      success = false;

      print(" save_question_paper" + body.toString());
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
            title: Text("Add question bank"),
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
              title: Text('Add question bank'),
              backgroundColor: Colors.orange,
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (havePlan == true) ...[
                          Row(
                            children: [
                              Expanded(flex: 1, child: Text("Course:")),
                              Expanded(
                                  flex: 2,
                                  child: Text(assessment_data['0']
                                          ['course_title']
                                      .toString()))
                            ],
                          ),
                          Form(
                              key: form_key,
                              child: Column(
                                children: [
                                  if (isFound == false) ...[
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Question bank name'),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          controller: question_bank_name,
                                          validator: (questionnameValue) {
                                            if (questionnameValue!.isEmpty) {
                                              return 'Please enter name';
                                            }
                                            question_bank_name.text =
                                                questionnameValue;
                                            return null;
                                          },
                                        ),
                                      ),
                                    ]),
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('For'),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButton<int>(
                                          isExpanded: true,
                                          items: assessment_detail_list_items,
                                          value: assessmentdetailValue,
                                          onChanged: (value) => setState(() {
                                            assessmentdetailValue = value!;
                                          }),
                                        ),
                                      ),
                                    ]),
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Difficulty level:'),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          items: difficulty_list_items,
                                          value: difficultyValue,
                                          onChanged: (value) => setState(() {
                                            difficultyValue = value!;
                                          }),
                                        ),
                                      ),
                                    ])
                                  ] else if (isFound == true) ...[
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Question name'),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          controller: question_bank_name,
                                          validator: (questionnameValue) {
                                            if (questionnameValue!.isEmpty) {
                                              return 'Please enter number';
                                            }
                                            question_bank_name.text =
                                                questionnameValue;
                                            return null;
                                          },
                                        ),
                                      ),
                                    ]),
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('For assessment:'),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButton<int>(
                                          isExpanded: true,
                                          items: assessment_detail_list_items,
                                          value: assessmentdetailValue,
                                          onChanged: (value) => setState(() {
                                            assessmentdetailValue = value!;
                                          }),
                                        ),
                                      ),
                                    ]),
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Difficulty level:'),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          items: difficulty_list_items,
                                          value: difficultyValue,
                                          onChanged: (value) => setState(() {
                                            difficultyValue = value!;
                                          }),
                                        ),
                                      ),
                                    ])
                                  ],
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {
                                            if (form_key.currentState!
                                                .validate()) {
                                              if (isSubmitting == false) {
                                                setState(() {
                                                  isSubmitting = true;
                                                });

                                                if (widget.mode == 'add') {
                                                  save_question_bank()
                                                      .then((value) {
                                                    if (value['success']) {
                                                      print(value[
                                                          'question_bank']);
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  LecturerAssessmentQuestionBankAddQuestion(
                                                                      value['question_bank']
                                                                          [
                                                                          'question_bank_id']))).then(
                                                          (value) {
                                                        setState(() {
                                                          isLoading = true;
                                                          isSubmitting = false;
                                                          get_assessment();
                                                        });
                                                      });
                                                    }
                                                  });
                                                } else {
                                                  save_question_bank()
                                                      .then((value) {
                                                    if (value['success']) {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  LecturerAssessmentQuestionBankAddQuestion(
                                                                      widget
                                                                          .question_bank_id))).then(
                                                          (value) {
                                                        setState(() {
                                                          isLoading = true;
                                                          get_assessment();
                                                        });
                                                      });
                                                    }
                                                  });
                                                }
                                              }
                                            }
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.green),
                                          ),
                                          child: Text("Next"))
                                    ],
                                  ),
                                ],
                              )),
                        ] else ...[
                          Text(
                            "Error:Please create assessment plan first.",
                            style: TextStyle(color: Colors.red, fontSize: 25),
                          )
                        ]
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
