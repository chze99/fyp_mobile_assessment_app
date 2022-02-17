// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';

class LecturerAssessmentQuestionBankAddSA extends StatefulWidget {
  @override
  int question_bank_id = 0;
  String mode = "";
  int question_paper_detail_id = 0;
  LecturerAssessmentQuestionBankAddSA(
      this.question_bank_id, this.mode, this.question_paper_detail_id);

  _LecturerAssessmentQuestionBankAddSAState createState() =>
      _LecturerAssessmentQuestionBankAddSAState();
}

class _LecturerAssessmentQuestionBankAddSAState
    extends State<LecturerAssessmentQuestionBankAddSA> {
  bool isLoading = true;
  bool isInitial = true;
  bool data_found = false;
  var assessment_data;
  var question_data;
  TextEditingController raw_mark_text = TextEditingController();
  TextEditingController question_description = TextEditingController();
  TextEditingController answer = TextEditingController();
  bool isSubmitting = false;
  var sectionValue;
  var section_data;
  final form_key = GlobalKey<FormState>();

  bool success = false;
  @override
  void initState() {
    get_section();

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_section() async {
    var data = {
      'question_bank_id': widget.question_bank_id,
    };
    var res = await Api().postData(data, "getQuestionBankSection");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        setState(() {
          section_data = body['message'];
          sectionValue = section_data['0']['section_id'];
          print("Section data:" + body['message'].toString());
          get_sa();
        });
      }
    } else {
      print("Get section error" + body.toString());
    }
  }

  get_sa() async {
    var data = {
      'question_paper_detail_id': widget.question_paper_detail_id,
    };
    var res = await Api().postData(data, "getSAQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No SA found") {
        if (this.mounted) {
          setState(() {
            question_data = body['message'];
            question_description.text =
                question_data['shortanswer_question_desc'];
            raw_mark_text.text = question_data['question_detail']['raw_mark'];
            sectionValue = question_data['question_detail']['section_id'];
            answer.text = question_data['shortanswer_answer'];

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

  save_sa() async {
    var data = {
      'question_bank_id': widget.question_bank_id,
      'question_type_id': 6,
      'section_id': sectionValue,
      'raw_mark': raw_mark_text.text,
      'shortanswer_question_desc': question_description.text,
      'shortanswer_answer': answer.text,
    };

    var res = await Api().postData(data, "saveSAQuestionBank");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body['success'];
      }
    } else {
      print("Save SA error" + body.toString());
    }
  }

  update_sa() async {
    var data = {
      'question_bank_id': widget.question_bank_id,
      'question_type_id': 6,
      'section_id': sectionValue,
      'raw_mark': raw_mark_text.text,
      'shortanswer_question_desc': question_description.text,
      'shortanswer_answer': answer.text,
      'question_paper_detail_id': widget.question_paper_detail_id,
    };

    var res = await Api().postData(data, "updateSAQuestionBank");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body['success'];
      }
    } else {
      print("Update SA error" + body.toString());
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
            title: Text("Short Answer"),
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
              title: Text("Short Answer"),
              backgroundColor: Colors.orange,
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                        key: form_key,
                        child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                              children: [
                                Row(children: [
                                  Expanded(
                                      flex: 1,
                                      child: Text("Question Description")),
                                  SizedBox(width: 5),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      keyboardType: TextInputType.multiline,
                                      controller: question_description,
                                      maxLines: null,
                                      validator: (questiondescValue) {
                                        if (questiondescValue!.isEmpty) {
                                          return 'Please enter description';
                                        }
                                        question_description.text =
                                            questiondescValue;
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                ]),
                                Row(children: [
                                  Expanded(flex: 1, child: Text("Raw mark")),
                                  SizedBox(width: 5),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: raw_mark_text,
                                      validator: (rawmarkValue) {
                                        if (rawmarkValue!.isEmpty) {
                                          return 'Please enter mark';
                                        } else if (regex()
                                                .isDoubleOnly(rawmarkValue) ==
                                            false) {
                                          return 'Please enter number only';
                                        }
                                        raw_mark_text.text = rawmarkValue;

                                        return null;
                                      },
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.]'))
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                ]),
                                Row(
                                  children: [
                                    Expanded(flex: 1, child: Text("Answer")),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                          keyboardType: TextInputType.multiline,
                                          controller: answer,
                                          maxLines: null,
                                          validator: (answerValue) {
                                            if (answerValue!.isEmpty) {
                                              return "Please enter left description";
                                            }
                                            answer.text = answerValue;
                                            return null;
                                          }),
                                    ),
                                  ],
                                ),
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
                                              if (widget.mode == "add") {
                                                save_sa().then((value) {
                                                  if (value == true) {
                                                    Navigator.pop(context);
                                                  }
                                                });
                                              } else if (widget.mode ==
                                                  "edit") {
                                                update_sa().then((value) {
                                                  if (value == true) {
                                                    Navigator.pop(context);
                                                  }
                                                });
                                              }
                                            }
                                          }
                                        },
                                        child: Text(isSubmitting
                                            ? "Submitting..."
                                            : "Submit"),
                                      )
                                    ]),
                              ],
                            ))),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}
