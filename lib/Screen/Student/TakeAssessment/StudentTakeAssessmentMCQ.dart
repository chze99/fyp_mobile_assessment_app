// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';
import 'package:toast/toast.dart';

class StudentTakeAssessmentMCQ extends StatefulWidget {
  @override
  int solution_questionpaper_id = 0;
  String mode = "";
  int solution_paperdetail_id = 0;
  int question_number = 0;
  StudentTakeAssessmentMCQ(this.solution_questionpaper_id, this.mode,
      this.solution_paperdetail_id, this.question_number);

  _StudentTakeAssessmentMCQState createState() =>
      _StudentTakeAssessmentMCQState();
}

class _StudentTakeAssessmentMCQState extends State<StudentTakeAssessmentMCQ> {
  bool isLoading = true;
  bool isInitial = true;
  bool isSubmitting = false;
  bool mcq_found = false;
  var mcq_retrived_data;
  var question_detail_data;
  var answer_data;
  int mcq_option_length = 4;
  final form_key = GlobalKey<FormState>();
  var option_value;
  bool success = false;
  @override
  void initState() {
    get_mcq();
    option_value = '17';
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
    var res = await Api().postData(data, "getMCQQuestionStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No MCQ found") {
        if (this.mounted) {
          setState(() {
            mcq_retrived_data = body['mcq'];
            question_detail_data = body['qd'];
            answer_data = body['sqa'];
            if (answer_data != "No answer") {
              option_value = answer_data['mcq_answer'].toString();
            } else {
              option_value =
                  mcq_retrived_data['Option'][0]['mcq_option_id'].toString();
            }
            print(mcq_retrived_data);
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
      print("Get mcq error" + body.toString());
    }
  }

  submit_mcq() async {
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
      'mcq_answer': option_value,
    };
    var res = await Api().postData(data, "submitMCQAnswerStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("Save mcq error" + body.toString());
    }
  }

  update_mcq() async {
    var data = {
      'mcq_solution_id': answer_data['mcq_solution_id'],
      'mcq_answer': option_value,
    };

    var res = await Api().postData(data, "updateMCQAnswerStudent");
    var body = json.decode(res.body);
    print(body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("MCQ Updated" + body.toString());
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
                                              child: Text(mcq_retrived_data[
                                                  'mcq_desc'])),
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
                                              child: ListView.builder(
                                                  itemCount: mcq_option_length,
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Container(
                                                        child:
                                                            Column(children: [
                                                      RadioListTile(
                                                        value: mcq_retrived_data[
                                                                        'Option']
                                                                    [index][
                                                                'mcq_option_id']
                                                            .toString(),
                                                        groupValue:
                                                            option_value,
                                                        onChanged: (ind) =>
                                                            setState(() =>
                                                                option_value =
                                                                    ind),
                                                        title: Text(
                                                            mcq_retrived_data[
                                                                        'Option']
                                                                    [index][
                                                                'mcq_option_desc']),
                                                      ),
                                                    ]));
                                                  }),
                                            )
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
                                                submit_mcq().then((value) {
                                                  if (value['success']) {
                                                    Toast.show(
                                                        "Saved", context);
                                                    Navigator.pop(context);
                                                  }
                                                });
                                              } else if (widget.mode ==
                                                  "edit") {
                                                update_mcq().then((value) {
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
