// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';

class LecturerAssessmentAddTF extends StatefulWidget {
  @override
  int question_paper_id = 0;
  String mode = "";
  int question_paper_detail_id = 0;
  LecturerAssessmentAddTF(
      this.question_paper_id, this.mode, this.question_paper_detail_id);

  _LecturerAssessmentAddTFState createState() =>
      _LecturerAssessmentAddTFState();
}

enum TF_answer { yes, no }

class _LecturerAssessmentAddTFState extends State<LecturerAssessmentAddTF> {
  bool isLoading = true;
  bool isInitial = true;
  bool tf_found = false;
  bool isSubmitting = false;
  var assessment_data;
  var tf_data;
  TF_answer? _answer = TF_answer.yes;
  TextEditingController raw_mark_text = TextEditingController();
  TextEditingController question_description = TextEditingController();
  var sectionValue;
  List<DropdownMenuItem<int>> section_list_items = [];
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
      'question_paper_id': widget.question_paper_id,
    };
    var res = await Api().postData(data, "getQuestionPaperSection");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        setState(() {
          section_data = body['message'];
          section_list_items = List.generate(
            section_data["count"],
            (i) => DropdownMenuItem(
              value: section_data[i.toString()]['section_id'],
              child: Text("${section_data[i.toString()]['section_number']}"),
            ),
          );
          sectionValue = section_data['0']['section_id'];
          print("Section data:" + body['message'].toString());
          get_tf();
        });
      }
    } else {
      print("Get section error" + body.toString());
    }
  }

  get_tf() async {
    var data = {
      'question_paper_detail_id': widget.question_paper_detail_id,
    };
    var res = await Api().postData(data, "getTFQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No TF found") {
        if (this.mounted) {
          setState(() {
            tf_data = body['message'];
            question_description.text = tf_data['truefalse_question_desc'];
            raw_mark_text.text = tf_data['question_detail']['raw_mark'];
            sectionValue = tf_data['question_detail']['section_id'];
            if (tf_data['truefalse_answer'] == "true") {
              _answer = TF_answer.yes;
            } else if (tf_data['truefalse_answer'] == "false") {
              _answer = TF_answer.no;
            }
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
      print("Get mcq error" + body.toString());
    }
  }

  save_tf() async {
    var data;
    if (_answer == TF_answer.yes) {
      data = {
        'question_paper_id': widget.question_paper_id,
        'question_type_id': 4,
        'section_id': sectionValue,
        'raw_mark': raw_mark_text.text,
        'truefalse_question_desc': question_description.text,
        'truefalse_answer': "true",
      };
    } else if (_answer == TF_answer.no) {
      data = {
        'question_paper_id': widget.question_paper_id,
        'question_type_id': 4,
        'section_id': sectionValue,
        'raw_mark': raw_mark_text.text,
        'truefalse_question_desc': question_description.text,
        'truefalse_answer': "false",
      };
    }
    var res = await Api().postData(data, "saveTFQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body['success'];
      }
    } else {
      print("Save TF error" + body.toString());
    }
  }

  update_tf() async {
    var data;
    if (_answer == TF_answer.yes) {
      data = {
        'question_paper_id': widget.question_paper_id,
        'question_type_id': 4,
        'section_id': sectionValue,
        'raw_mark': raw_mark_text.text,
        'truefalse_question_desc': question_description.text,
        'truefalse_answer': "true",
        'question_paper_detail_id': widget.question_paper_detail_id,
      };
    } else if (_answer == TF_answer.no) {
      data = {
        'question_paper_id': widget.question_paper_id,
        'question_type_id': 4,
        'section_id': sectionValue,
        'raw_mark': raw_mark_text.text,
        'truefalse_question_desc': question_description.text,
        'truefalse_answer': "false",
        'question_paper_detail_id': widget.question_paper_detail_id,
      };
    }
    var res = await Api().postData(data, "updateTFQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body['success'];
      }
    } else {
      print("Save TF error" + body.toString());
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
            title: Text("True False"),
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
              title: Text("True False"),
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
                                    Expanded(flex: 1, child: Text("Section")),
                                    Expanded(
                                      flex: 2,
                                      child: DropdownButton<int>(
                                        isExpanded: true,
                                        items: section_list_items,
                                        value: sectionValue,
                                        onChanged: (value) => setState(() {
                                          sectionValue = value;
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(flex: 1, child: Text("Answer")),
                                    Radio<TF_answer>(
                                      value: TF_answer.yes,
                                      groupValue: _answer,
                                      onChanged: (TF_answer? value) {
                                        setState(() {
                                          _answer = value;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text("True"),
                                    ),
                                    Radio<TF_answer>(
                                      value: TF_answer.no,
                                      groupValue: _answer,
                                      onChanged: (TF_answer? value) {
                                        setState(() {
                                          _answer = value;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text("False"),
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
                                                save_tf().then((value) {
                                                  if (value == true) {
                                                    Navigator.pop(context);
                                                  }
                                                });
                                              } else if (widget.mode ==
                                                  "edit") {
                                                update_tf().then((value) {
                                                  if (value == true) {
                                                    Navigator.pop(context);
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
                            ))),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}
