// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerAssessmentAdd.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCourseCreateAssessmentPlan2.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCourseEnrollStudentPage.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCourseViewStudentResult.dart';
import 'package:mobile_assessment/Screen/Lecturer/Question_Bank/LecturerAssessmentQuestionBank.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:mobile_assessment/Screen/regex.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loading_page.dart';
import 'LecturerCourseCreateAssessmentPlan.dart';

// ignore: must_be_immutable
class LecturerCourseManageGrade extends StatefulWidget {
  int assessment_plan_id = 0;
  LecturerCourseManageGrade(this.assessment_plan_id);
  @override
  _LecturerCourseManageGradeState createState() =>
      _LecturerCourseManageGradeState();
}

class _LecturerCourseManageGradeState extends State<LecturerCourseManageGrade> {
  String name = "";
  var isLoading = true;
  var isSubmitting = false;
  var assessment_grade_data;
  TextEditingController grade_a = new TextEditingController();
  TextEditingController grade_b = new TextEditingController();
  TextEditingController grade_c = new TextEditingController();
  TextEditingController grade_d = new TextEditingController();
  TextEditingController grade_f = new TextEditingController();
  final form_key = GlobalKey<FormState>();
  @override
  void initState() {
    get_grade();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool isNumberOnly(String text) {
    return RegExp(r'^[0-9]+$').hasMatch(text);
  }

  get_grade() async {
    var data = {
      'assessment_plan_id': widget.assessment_plan_id,
    };
    var res = await Api().postData(data, "getAssessmentGrade");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        setState(() {
          assessment_grade_data = body['message'];
          grade_a.text = assessment_grade_data['grade_a'].toString();
          grade_b.text = assessment_grade_data['grade_b'].toString();
          grade_c.text = assessment_grade_data['grade_c'].toString();
          grade_d.text = assessment_grade_data['grade_d'].toString();
          grade_f.text = assessment_grade_data['grade_f'].toString();

          print("Assessment data" + body.toString());
          isLoading = false;
        });
      }
    } else {
      setState(() {
        error_alert().alert(context, "Error", body.toString());

        isLoading = false;
      });
      print("get_assessment error" + body.toString());
    }
  }

  update_grade() async {
    var data = {
      'assessment_plan_id': widget.assessment_plan_id,
      'grade_a': grade_a.text,
      'grade_b': grade_b.text,
      'grade_c': grade_c.text,
      'grade_d': grade_d.text,
      'grade_f': grade_f.text,
    };
    var res = await Api().postData(data, "updateAssessmentGrade");
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
    if (isLoading == true) {
      return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Grade management"),
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
              title: Text('Grade management'),
              backgroundColor: Colors.orange,
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  height: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Form(
                      key: form_key,
                      child: SingleChildScrollView(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text("Grade A")),
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: grade_a,
                                  maxLines: null,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.]'))
                                  ],
                                  validator: (scoreValue) {
                                    if (scoreValue!.isEmpty) {
                                      return 'Please enter score';
                                    } else if (regex()
                                            .isDoubleOnly(scoreValue) ==
                                        false) {
                                      return 'Please enter number only';
                                    } else if (double.parse(scoreValue) <
                                        double.parse(grade_b.text)) {
                                      return 'Score cannot small than grade b score';
                                    } else if (double.parse(scoreValue) > 100) {
                                      return 'Score cannot greater than 100';
                                    }
                                    grade_a.text = scoreValue;
                                    return null;
                                  },
                                ),
                              ),
                              Expanded(child: Text("- 100"))
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: Text("Grade B")),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: grade_b,
                                  maxLines: null,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.]'))
                                  ],
                                  validator: (scoreValue) {
                                    if (scoreValue!.isEmpty) {
                                      return 'Please enter score';
                                    } else if (regex()
                                            .isDoubleOnly(scoreValue) ==
                                        false) {
                                      return 'Please enter number only';
                                    } else if (double.parse(scoreValue) <
                                        double.parse(grade_c.text)) {
                                      return 'Score cannot small than grade c score';
                                    } else if (double.parse(scoreValue) >
                                        double.parse(grade_a.text)) {
                                      return 'Score cannot greater than grade a score';
                                    }
                                    grade_b.text = scoreValue;
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: Text("Grade C")),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: grade_c,
                                  maxLines: null,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.]'))
                                  ],
                                  validator: (scoreValue) {
                                    if (scoreValue!.isEmpty) {
                                      return 'Please enter score';
                                    } else if (regex()
                                            .isDoubleOnly(scoreValue) ==
                                        false) {
                                      return 'Please enter number only';
                                    } else if (double.parse(scoreValue) <
                                        double.parse(grade_d.text)) {
                                      return 'Score cannot small than grade d score';
                                    } else if (double.parse(scoreValue) >
                                        double.parse(grade_b.text)) {
                                      return 'Score cannot greater than grade b score';
                                    }
                                    grade_c.text = scoreValue;
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: Text("Grade D")),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: grade_d,
                                  maxLines: null,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.]'))
                                  ],
                                  validator: (scoreValue) {
                                    if (scoreValue!.isEmpty) {
                                      return 'Please enter score';
                                    } else if (regex()
                                            .isDoubleOnly(scoreValue) ==
                                        false) {
                                      return 'Please enter number only';
                                    } else if (double.parse(scoreValue) <
                                        double.parse(grade_f.text)) {
                                      return 'Score cannot small than grade f score';
                                    } else if (double.parse(scoreValue) >
                                        double.parse(grade_c.text)) {
                                      return 'Score cannot greater than grade c score';
                                    }
                                    setState(() {
                                      grade_d.text = scoreValue;
                                    });
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: Text("Grade F")),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  enabled: false,
                                  keyboardType: TextInputType.number,
                                  controller: grade_f,
                                  maxLines: null,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.]'))
                                  ],
                                  validator: (scoreValue) {
                                    if (scoreValue!.isEmpty) {
                                      return 'Please enter score';
                                    } else if (regex()
                                            .isDoubleOnly(scoreValue) ==
                                        false) {
                                      return 'Please enter number only';
                                    } else if (double.parse(scoreValue) <
                                        double.parse('0')) {
                                      return 'Score cannot small than 0 score';
                                    } else if (double.parse(scoreValue) >
                                        double.parse(grade_d.text)) {
                                      return 'Score cannot greater than grade d score';
                                    }
                                    grade_f.text = scoreValue;
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    if (form_key.currentState!.validate()) {
                                      if (isSubmitting == false) {
                                        setState(() {
                                          isSubmitting = true;
                                        });

                                        update_grade().then((value) {
                                          if (value == true) {
                                            Navigator.pop(context);
                                          }
                                        });
                                      }
                                    }
                                  },
                                  child: Text('Update')),
                            ],
                          ),
                        ],
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}
