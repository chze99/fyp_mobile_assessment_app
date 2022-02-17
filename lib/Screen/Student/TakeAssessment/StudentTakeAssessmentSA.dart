// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';
import 'package:toast/toast.dart';

class StudentTakeAssessmentSA extends StatefulWidget {
  @override
  int solution_questionpaper_id = 0;
  String mode = "";
  int solution_paperdetail_id = 0;
  int question_number = 0;
  StudentTakeAssessmentSA(this.solution_questionpaper_id, this.mode,
      this.solution_paperdetail_id, this.question_number);

  _StudentTakeAssessmentSAState createState() =>
      _StudentTakeAssessmentSAState();
}

class _StudentTakeAssessmentSAState extends State<StudentTakeAssessmentSA> {
  bool isLoading = true;
  bool isSubmitting = false;
  var sa_retrived_data;
  var question_detail_data;
  var answer_data;
  TextEditingController sa_answer = new TextEditingController();

  final form_key = GlobalKey<FormState>();
  bool success = false;
  @override
  void initState() {
    get_sa();

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_sa() async {
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
    };
    var res = await Api().postData(data, "getSAQuestionStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No SA found") {
        if (this.mounted) {
          setState(() {
            sa_retrived_data = body['q'];
            question_detail_data = body['qd'];
            answer_data = body['sqa'];
            if (answer_data != "No answer") {
              sa_answer.text = answer_data['shortanswer_answer'];
            } else {}
            print(sa_retrived_data);
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

  submit_sa() async {
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
      'shortanswer_answer': sa_answer.text,
    };
    var res = await Api().postData(data, "submitSAAnswerStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("Save sa error" + body.toString());
    }
  }

  update_sa() async {
    var data = {
      'shortanswer_solution_id': answer_data['shortanswer_solution_id'],
      'shortanswer_answer': sa_answer.text,
    };

    var res = await Api().postData(data, "updateSAAnswerStudent");
    var body = json.decode(res.body);
    print(body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("SA Updated" + body.toString());
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
            title: Text("SA"),
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
                                              child: Text(sa_retrived_data[
                                                      'shortanswer_question_desc']
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
                                                controller: sa_answer,
                                                maxLines: null,
                                                validator: (questiondescValue) {
                                                  if (questiondescValue!
                                                      .isEmpty) {
                                                    return 'Please enter answer';
                                                  }
                                                  sa_answer.text =
                                                      questiondescValue;
                                                  return null;
                                                },
                                              ),
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
                                                submit_sa().then((value) {
                                                  if (value['success']) {
                                                    Toast.show(
                                                        "Saved", context);
                                                    Navigator.pop(context);
                                                  }
                                                });
                                              } else if (widget.mode ==
                                                  "edit") {
                                                update_sa().then((value) {
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
