// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'LecturerAssessmentQuestionBankAdd.dart';

// ignore: must_be_immutable
class LecturerAssessmentQuestionBank extends StatefulWidget {
  @override
  // ignore: override_on_non_overriding_member
  int assessment_plan_id = 0;
  String mode = "";
  LecturerAssessmentQuestionBank(this.assessment_plan_id, this.mode);
  _LecturerAssessmentQuestionBankState createState() =>
      _LecturerAssessmentQuestionBankState();
}

class _LecturerAssessmentQuestionBankState
    extends State<LecturerAssessmentQuestionBank> {
  bool isLoading = false;
  bool isFound = false;
  bool isSubmitting = false;
  var question_bank_data;
  var success;
  int questionbank_length = 0;
  final form_key = GlobalKey<FormState>();

  @override
  void initState() {
    get_question_bank();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_question_bank() async {
    var data = {
      'assessment_plan_id': widget.assessment_plan_id,
    };
    var res = await Api().postData(data, "getQuestionBankList");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        if (body['message'] != "No question bank") {
          setState(() {
            question_bank_data = body['message'];
            questionbank_length = question_bank_data['count'];
            isLoading = false;
            print("Question bank:" + question_bank_data.toString());
          });
        } else {
          isLoading = false;
        }
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print("Get question bank error" + body.toString());
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
            title: Text("Question Bank"),
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
              title: Text('Question Bank'),
              backgroundColor: Colors.orange,
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          if (questionbank_length != 0) ...[
                            Expanded(
                                flex: 15,
                                child: SingleChildScrollView(
                                    physics: ScrollPhysics(),
                                    child: Column(
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: questionbank_length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 0),
                                              child: InkWell(
                                                child: Card(
                                                    elevation: 4.0,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                  "Question bank name:",
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        'Arial',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                )),
                                                            Expanded(
                                                                flex: 3,
                                                                child: Text(
                                                                  question_bank_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_bank_name']
                                                                      .toString(),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        'Arial',
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                  "Difficulty level:",
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        'Arial',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                )),
                                                            Expanded(
                                                                flex: 3,
                                                                child: Text(
                                                                  question_bank_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_bank_difficulty_level']
                                                                      .toString(),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        'Arial',
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                  "Number of question:",
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        'Arial',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                )),
                                                            Expanded(
                                                                flex: 3,
                                                                child: Text(
                                                                  question_bank_data[
                                                                              index.toString()]
                                                                          [
                                                                          'count']
                                                                      .toString(),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        'Arial',
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      ],
                                                    )),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => LecturerAssessmentQuestionBankAdd(
                                                              question_bank_data[
                                                                      index
                                                                          .toString()]
                                                                  [
                                                                  'assessment_plan_id'],
                                                              "edit",
                                                              question_bank_data[
                                                                      index
                                                                          .toString()]
                                                                  [
                                                                  'question_bank_id']))).then(
                                                      (value) {
                                                    setState(() {
                                                      get_question_bank();
                                                    });
                                                  });
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    )))
                          ] else ...[
                            Expanded(
                                flex: 15,
                                child: Column(
                                  children: [Text("No question bank found")],
                                )),
                          ],
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: () {
                                if (isSubmitting == false) {
                                  setState(() {
                                    isSubmitting = true;
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              LecturerAssessmentQuestionBankAdd(
                                                  widget.assessment_plan_id,
                                                  "add",
                                                  -1))).then((value) {
                                    setState(() {
                                      isSubmitting = false;

                                      get_question_bank();
                                    });
                                  });
                                }
                              },
                              child: Text('Add question bank'),
                            ),
                          )
                        ],
                      )),
                ),
              ],
            ),
          ));
    }
  }
}
