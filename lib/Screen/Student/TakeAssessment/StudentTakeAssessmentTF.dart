// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';
import 'package:toast/toast.dart';

class StudentTakeAssessmentTF extends StatefulWidget {
  @override
  int solution_questionpaper_id = 0;
  String mode = "";
  int solution_paperdetail_id = 0;
  int question_number = 0;
  StudentTakeAssessmentTF(this.solution_questionpaper_id, this.mode,
      this.solution_paperdetail_id, this.question_number);

  _StudentTakeAssessmentTFState createState() =>
      _StudentTakeAssessmentTFState();
}

enum TF_answer { yes, no }

class _StudentTakeAssessmentTFState extends State<StudentTakeAssessmentTF> {
  bool isLoading = true;
  bool isSubmitting = false;
  var tf_retrived_data;
  var question_detail_data;
  var answer_data;
  final form_key = GlobalKey<FormState>();
  TF_answer? option_value = TF_answer.yes;
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
    var res = await Api().postData(data, "getTFQuestionStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No TF found") {
        if (this.mounted) {
          setState(() {
            tf_retrived_data = body['q'];
            question_detail_data = body['qd'];
            answer_data = body['sqa'];
            if (answer_data != "No answer") {
              if (answer_data['truefalse_answer'].toString() == 'true') {
                option_value = option_value = TF_answer.yes;
              } else {
                option_value = option_value = TF_answer.no;
              }
            } else {
              option_value = TF_answer.yes;
            }
            print(tf_retrived_data);
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
      print("Get tf error" + body.toString());
    }
  }

  submit_tf() async {
    var answer;
    if (option_value == TF_answer.yes) {
      answer = 'true';
    } else {
      answer = 'false';
    }
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
      'truefalse_answer': answer,
    };
    var res = await Api().postData(data, "submitTFAnswerStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("Save tf error" + body.toString());
    }
  }

  update_tf() async {
    var answer;
    if (option_value == TF_answer.yes) {
      answer = 'true';
    } else {
      answer = 'false';
    }
    var data = {
      'truefalse_solution_id': answer_data['truefalse_solution_id'],
      'truefalse_answer': answer,
    };

    var res = await Api().postData(data, "updateTFAnswerStudent");
    var body = json.decode(res.body);
    print(body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("TF Updated" + body.toString());
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
                                              child: Text(tf_retrived_data[
                                                      'truefalse_question_desc']
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
                                            Radio<TF_answer>(
                                              value: TF_answer.yes,
                                              groupValue: option_value,
                                              onChanged: (TF_answer? value) {
                                                setState(() {
                                                  option_value = value;
                                                });
                                              },
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text("True"),
                                            ),
                                            Radio<TF_answer>(
                                              value: TF_answer.no,
                                              groupValue: option_value,
                                              onChanged: (TF_answer? value) {
                                                setState(() {
                                                  option_value = value;
                                                });
                                              },
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text("False"),
                                            ),
                                          ],
                                        ),
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
                                                submit_tf().then((value) {
                                                  if (value['success']) {
                                                    Toast.show(
                                                        "Saved", context);
                                                    Navigator.pop(context);
                                                  }
                                                });
                                              } else if (widget.mode ==
                                                  "edit") {
                                                update_tf().then((value) {
                                                  if (value['success']) {
                                                    Toast.show(
                                                        "Update", context);
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
