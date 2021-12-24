// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'LecturerCourseCreateAssessmentPlan.dart';
import 'LecturerCourseDetailPage.dart';

// ignore: must_be_immutable
class LecturerCourseCreateAssessmentPlan2 extends StatefulWidget {
  int assessment_plan_id = 0;
  LecturerCourseCreateAssessmentPlan2(this.assessment_plan_id);
  @override
  _LecturerCourseCreateAssessmentPlan2State createState() =>
      _LecturerCourseCreateAssessmentPlan2State();
}

class _LecturerCourseCreateAssessmentPlan2State
    extends State<LecturerCourseCreateAssessmentPlan2> {
  var isLoading = true;
  int assessment_length = 1;
  var exist_assessment;
  var question_type;
  // List<int> questiontypeValue = [];
  var clo;
  var exist_final;
  List<int> cloValue = [];
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> assessment_name = [];
  List<TextEditingController> assessment_weightage = [];
  TextEditingController final_weightage = TextEditingController();
  List<DropdownMenuItem<int>> question_type_list_items = [];
  List<DropdownMenuItem<int>> clo_list_items = [];
  bool assessment_saved = false;
  bool assessment_found = false;
  double final_exam_weightage = 0;
  int final_exam_clo = 1;
  double overall_weightage = 0;
  double temp_weightage = 0;
  @override
  void initState() {
    get_clo();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool isNumberOnly(String text) {
    return RegExp(r'^[0-9.]+$').hasMatch(text);
  }

  // get_type() async {
  //   var data = {
  //     'assessment_plan_id': widget.assessment_plan_id,
  //   };
  //   var res = await Api().postData(data, "getQuestionType");
  //   var body = json.decode(res.body);
  //   if (body['success'] == true) {
  //     setState(() {
  //       question_type = body['message'];
  //       print(question_type.length);
  //       question_type_list_items = List.generate(
  //         question_type["count"],
  //         (i) => DropdownMenuItem(
  //           value: question_type[i.toString()]['question_type_id'],
  //           child: Text("${question_type[i.toString()]['question_type_name']}"),
  //         ),
  //       );
  //       get_clo();
  //     });
  //   } else {
  //     print(body);
  //   }
  // }

  get_assessment() async {
    var data = {
      'assessment_plan_id': widget.assessment_plan_id,
    };
    var res = await Api().postData(data, "getAssessmentDetail");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['found']) {
        if (this.mounted) {
          setState(() {
            assessment_found = true;
            exist_assessment = body['message'];
            assessment_length = exist_assessment['count'];
            exist_final = body['final'][0];
            print(exist_final);
            print(exist_assessment);
            final_exam_clo = exist_final['assessment_clo_id'];
            final_weightage.text = exist_final['assessment_detail_weightage'];

            isLoading = false;
          });
        }
      } else {
        isLoading = false;
      }
    } else {
      print(body);
    }
  }

  get_clo() async {
    var data = {
      'assessment_plan_id': widget.assessment_plan_id,
    };
    var res = await Api().postData(data, "getAssessmentPlanCLO");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      setState(() {
        clo = body['message'];
        clo_list_items = List.generate(
          clo["count"],
          (i) => DropdownMenuItem(
            value: clo[i.toString()]['assessment_clo_id'],
            child: Text("${clo[i.toString()]['clo_number']}"),
          ),
        );
        print(clo);
        assessment_name.add(new TextEditingController());
        assessment_weightage.add(new TextEditingController());
        cloValue.add(clo["0"]["assessment_clo_id"]);
        get_assessment();
      });
    } else {
      print(body);
    }
  }

  save_assessment(int index, String type) async {
    assessment_saved = false;
    var data;
    if (type == "normal") {
      data = {
        'assessment_plan_id': widget.assessment_plan_id,
        'assessment_CLO_id': cloValue[index],
        'assessment_number': (index + 1),
        'assessment_detail_title': assessment_name[index].text,
        'assessment_detail_weightage': assessment_weightage[index].text,
      };
    } else if (type == "final") {
      data = {
        'assessment_plan_id': widget.assessment_plan_id,
        'assessment_CLO_id': final_exam_clo,
        'assessment_number': (0),
        'assessment_detail_title': "Final Exam",
        'assessment_detail_weightage': final_weightage.text,
      };
    }
    var res = await Api().postData(data, "saveAssessmentDetail");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (type == "final") {
        setState(() {
          assessment_saved = true;
          isLoading = false;
        });
      }
    } else {
      print(body);
    }
  }

  calculate_weightage() {
    overall_weightage = 0;
    for (int i = 0; i < assessment_length; i++) {
      if (assessment_weightage[i].text != null &&
          assessment_weightage[i].text != "") {
        overall_weightage += double.parse(assessment_weightage[i].text);
      }
    }

    if (final_weightage.text != null &&
        final_weightage.text != "" &&
        double.parse(final_weightage.text) > 0) {
      print(final_weightage.text);
      overall_weightage += double.parse(final_weightage.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == true) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Assessment Plan-Assessment'),
          backgroundColor: Colors.orange,
        ),
        body: Container(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Assessment Plan-Assessment'),
          backgroundColor: Colors.orange,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 5),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  "Name",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "CLO to cover",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "Weightage",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: ListView.builder(
                                    itemCount: assessment_length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      if (assessment_name.length <=
                                          assessment_length) {
                                        assessment_name
                                            .add(new TextEditingController());
                                        assessment_weightage
                                            .add(new TextEditingController());
                                        cloValue
                                            .add(clo["0"]["assessment_clo_id"]);
                                      }
                                      print(index);

                                      if (assessment_found == true) {
                                        if (index < exist_assessment['count']) {
                                          assessment_name[index].text =
                                              exist_assessment[index.toString()]
                                                  ['assessment_detail_title'];
                                          assessment_weightage[index]
                                              .text = exist_assessment[
                                                  index.toString()]
                                              ['assessment_detail_weightage'];
                                          cloValue[index] =
                                              exist_assessment[index.toString()]
                                                  ['assessment_clo_id'];
                                          if (index ==
                                              exist_assessment['count'] - 1) {
                                            assessment_found = false;
                                            Future.delayed(Duration.zero,
                                                () async {
                                              setState(() {
                                                calculate_weightage();
                                              });
                                            });
                                          }
                                        } else {}
                                      }
                                      return Container(
                                          child: Row(
                                        children: [
                                          SizedBox(width: 5),
                                          Expanded(
                                              flex: 4,
                                              child: TextFormField(
                                                textAlign: TextAlign.start,
                                                controller:
                                                    assessment_name[index],
                                                autofocus: false,
                                                validator: (namevalue) {
                                                  if (namevalue == null ||
                                                      namevalue.isEmpty) {
                                                    return 'Please enter some text';
                                                  }
                                                  return null;
                                                },
                                                keyboardType:
                                                    TextInputType.text,
                                              )),
                                          SizedBox(width: 5),
                                          Expanded(
                                            flex: 2,
                                            child: DropdownButton<int>(
                                              isExpanded: true,
                                              items: clo_list_items,
                                              value: cloValue[index].toInt(),
                                              onChanged: (value) => setState(
                                                  () =>
                                                      cloValue[index] = value!),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                              flex: 3,
                                              child: TextFormField(
                                                textAlign: TextAlign.start,
                                                controller:
                                                    assessment_weightage[index],
                                                autofocus: false,
                                                onChanged: (text) {
                                                  setState(() {
                                                    calculate_weightage();
                                                  });
                                                },
                                                validator: (weightagevalue) {
                                                  if (weightagevalue == null ||
                                                      weightagevalue.isEmpty) {
                                                    return 'Please enter some text';
                                                  } else if (isNumberOnly(
                                                          weightagevalue) ==
                                                      false) {
                                                    return 'Only number is allow';
                                                  }

                                                  return null;
                                                },
                                                keyboardType:
                                                    TextInputType.text,
                                              )),
                                        ],
                                      ));
                                    }),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                  child: Container(
                                      child: Row(
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                        "Final Exam",
                                        textAlign: TextAlign.center,
                                      )),
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButton<int>(
                                      isExpanded: true,
                                      items: clo_list_items,
                                      value: final_exam_clo,
                                      onChanged: (value) => setState(
                                          () => final_exam_clo = value!),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        textAlign: TextAlign.start,
                                        autofocus: false,
                                        controller: final_weightage,
                                        onChanged: (text) {
                                          setState(() {
                                            calculate_weightage();
                                          });
                                        },
                                        validator: (weightagevalue) {
                                          if (weightagevalue == null ||
                                              weightagevalue.isEmpty) {
                                            return 'Please enter some text';
                                          } else if (isNumberOnly(
                                                  weightagevalue) ==
                                              false) {
                                            return 'Only number is allow';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.text,
                                      )),
                                ],
                              )))
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  LecturerCourseCreateAssessmentPlan(
                                                      widget
                                                          .assessment_plan_id)));
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.red),
                                  ),
                                  child: Text(
                                    'Back',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (this.mounted) {
                                    setState(() {
                                      assessment_name
                                          .add(new TextEditingController());
                                      assessment_weightage
                                          .add(new TextEditingController());

                                      cloValue
                                          .add(clo["0"]["assessment_clo_id"]);
                                      assessment_length++;
                                    });
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.red),
                                ),
                                child: Text(
                                  'Add assessment',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    if (overall_weightage == 100) {
                                      for (int i = 0;
                                          i < assessment_length;
                                          i++) {
                                        save_assessment(i, "normal");
                                      }
                                      save_assessment(0, "final");
                                      if (assessment_saved == true) {
                                        Navigator.push(
                                            context,
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    LecturerCourseDetailPage(widget
                                                        .assessment_plan_id)));
                                      }
                                    }
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.red),
                                ),
                                child: Text(
                                  'Finish',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                overall_weightage.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            ),
          ],
        ),
      );
    }
  }
}
