// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:mobile_assessment/Screen/regex.dart';

import '../loading_page.dart';
import 'LecturerCourseDetailPage.dart';

// ignore: must_be_immutable
class LecturerCourseCreateAssessmentPlan2 extends StatefulWidget {
  int assessment_plan_id = 0;
  String mode = "";
  LecturerCourseCreateAssessmentPlan2(this.assessment_plan_id, this.mode);
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
  // List<DropdownMenuItem<int>> question_type_list_items = [];
  List<DropdownMenuItem<int>> clo_list_items = [];
  bool assessment_saved = false;
  bool assessment_found = false;
  double final_exam_weightage = 0;
  int final_exam_clo = 1;
  double overall_weightage = 0;
  double temp_weightage = 0;
  String overall_weightage_warning = "";
  bool isLast = false;
  String addWarning = "";
  bool isSubmitting = false;
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
            if (assessment_length < exist_assessment['count']) {
              assessment_length = exist_assessment['count'];
            }

            exist_final = body['final'][0];
            print(exist_final);
            print(exist_assessment);
            final_exam_clo = exist_final['assessment_clo_id'];
            final_weightage.text = exist_final['assessment_detail_weightage'];

            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
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
        // assessment_name.add(new TextEditingController());
        // assessment_weightage.add(new TextEditingController());
        // cloValue.add(clo["0"]["assessment_clo_id"]);
        final_exam_clo = clo["0"]["assessment_clo_id"];
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
        'assessment_clo_id': cloValue[index],
        'assessment_number': (index + 1),
        'assessment_detail_title': assessment_name[index].text,
        'assessment_detail_weightage': assessment_weightage[index].text,
      };
    } else if (type == "final") {
      data = {
        'assessment_plan_id': widget.assessment_plan_id,
        'assessment_clo_id': final_exam_clo,
        'assessment_number': (0),
        'assessment_detail_title': "Final Exam",
        'assessment_detail_weightage': final_weightage.text,
      };
    }
    var res = await Api().postData(data, "saveAssessmentDetail");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (type == "final") {
        assessment_saved = true;
        return assessment_saved;
      }
    } else {
      print(body);
    }
  }

  del_assessment(int index) async {
    if (assessment_found == true) {
      print("index" +
          index.toString() +
          " count " +
          exist_assessment['count'].toString());
      if (index < exist_assessment['count']) {
        print("delte ");
        var data = {
          'assessment_detail_id': exist_assessment[index.toString()]
              ["assessment_detail_id"]
        };
        var res = await Api().postData(data, "deleteAssessmentPlanDetail");
        var body = json.decode(res.body);
        if (body['success'] != null) {
          print(body);
          Future.delayed(Duration.zero, () async {
            setState(() {
              for (int i = index; i < assessment_length; i++) {
                if (i != assessment_length - 1) {
                  assessment_name[i] = assessment_name[i + 1];
                  assessment_weightage[i] = assessment_weightage[i + 1];
                  cloValue[i] = cloValue[i + 1];
                }
              }
              assessment_name.removeLast();
              assessment_weightage.removeLast();
              cloValue.removeLast();
              assessment_length -= 1;
              isLoading = true;
              get_clo();
              calculate_weightage();
            });
          });
        } else {
          error_alert().alert(context, "Error", body.toString());

          print(body);
        }
      } else {
        Future.delayed(Duration.zero, () async {
          setState(() {
            for (int i = index; i < assessment_length; i++) {
              if (i != assessment_length - 1) {
                assessment_name[i] = assessment_name[i + 1];
                assessment_weightage[i] = assessment_weightage[i + 1];
                cloValue[i] = cloValue[i + 1];
              }
            }
            assessment_name.removeLast();
            assessment_weightage.removeLast();
            cloValue.removeLast();
            assessment_length -= 1;
            calculate_weightage();
          });
        });
      }
    } else {
      Future.delayed(Duration.zero, () async {
        setState(() {
          for (int i = index; i < assessment_length; i++) {
            if (i != assessment_length - 1) {
              assessment_name[i] = assessment_name[i + 1];
              assessment_weightage[i] = assessment_weightage[i + 1];
              cloValue[i] = cloValue[i + 1];
            }
          }
          assessment_name.removeLast();
          assessment_weightage.removeLast();
          cloValue.removeLast();
          assessment_length -= 1;
          calculate_weightage();
        });
      });
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

  delete_confirmation_dialog(BuildContext context, int index) {
    Widget no_button = TextButton(
      child: Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget yes_button = TextButton(
      child: Text("Yes"),
      onPressed: () {
        del_assessment(index);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete confirmation"),
      content: Text("Did you sure to delete this assessment?"),
      actions: [
        no_button,
        yes_button,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
            title: Text("Assessment Plan-Assessment"),
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
                        child: Column(
                          children: [
                            Expanded(
                                flex: 15,
                                child: SingleChildScrollView(
                                    physics: ScrollPhysics(),
                                    child: Column(children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              "Overall weightage",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20.0,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            Text(
                                              overall_weightage.toString(),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20.0,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ]),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              "Name",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              "CLO to cover",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
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
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  if (assessment_name.length <
                                                      assessment_length) {
                                                    assessment_name.add(
                                                        new TextEditingController());
                                                    assessment_weightage.add(
                                                        new TextEditingController());
                                                    cloValue.add(clo["0"]
                                                        ["assessment_clo_id"]);
                                                  }
                                                  print(index);

                                                  if (assessment_found ==
                                                      true) {
                                                    if (isLast == false) {
                                                      if (index <
                                                          exist_assessment[
                                                              'count']) {
                                                        assessment_name[index]
                                                            .text = exist_assessment[
                                                                index
                                                                    .toString()]
                                                            [
                                                            'assessment_detail_title'];
                                                        assessment_weightage[
                                                                index]
                                                            .text = exist_assessment[
                                                                index
                                                                    .toString()]
                                                            [
                                                            'assessment_detail_weightage'];
                                                        cloValue[index] =
                                                            exist_assessment[index
                                                                    .toString()]
                                                                [
                                                                'assessment_clo_id'];
                                                      }
                                                      if (index ==
                                                          exist_assessment[
                                                                  'count'] -
                                                              1) {
                                                        Future.delayed(
                                                            Duration.zero,
                                                            () async {
                                                          setState(() {
                                                            isLast = true;
                                                            calculate_weightage();
                                                          });
                                                        });
                                                      }
                                                    }
                                                  }
                                                  print("Index:" +
                                                      assessment_name.length
                                                          .toString() +
                                                      " Name:" +
                                                      assessment_name[
                                                              assessment_name
                                                                      .length -
                                                                  1]
                                                          .text);

                                                  return Container(
                                                      child: Row(
                                                    children: [
                                                      SizedBox(width: 5),
                                                      Expanded(
                                                          flex: 4,
                                                          child: TextFormField(
                                                            textAlign:
                                                                TextAlign.start,
                                                            controller:
                                                                assessment_name[
                                                                    index],
                                                            autofocus: false,
                                                            validator:
                                                                (namevalue) {
                                                              if (namevalue ==
                                                                      null ||
                                                                  namevalue
                                                                      .isEmpty) {
                                                                return 'Please enter some text';
                                                              }
                                                              return null;
                                                            },
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                          )),
                                                      SizedBox(width: 5),
                                                      Expanded(
                                                        flex: 2,
                                                        child:
                                                            DropdownButton<int>(
                                                          isExpanded: true,
                                                          items: clo_list_items,
                                                          value: cloValue[index]
                                                              .toInt(),
                                                          onChanged: (value) =>
                                                              setState(() =>
                                                                  cloValue[
                                                                          index] =
                                                                      value!),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Expanded(
                                                          flex: 3,
                                                          child: TextFormField(
                                                            textAlign:
                                                                TextAlign.start,
                                                            controller:
                                                                assessment_weightage[
                                                                    index],
                                                            autofocus: false,
                                                            onChanged: (text) {
                                                              setState(() {
                                                                calculate_weightage();
                                                              });
                                                            },
                                                            validator:
                                                                (weightagevalue) {
                                                              if (weightagevalue ==
                                                                      null ||
                                                                  weightagevalue
                                                                      .isEmpty) {
                                                                return 'Please enter some text';
                                                              } else if (regex()
                                                                      .isDoubleOnly(
                                                                          weightagevalue) ==
                                                                  false) {
                                                                return 'Only number is allow';
                                                              }

                                                              return null;
                                                            },
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: <
                                                                TextInputFormatter>[
                                                              FilteringTextInputFormatter
                                                                  .allow(RegExp(
                                                                      r'[0-9.]'))
                                                            ],
                                                          )),
                                                      if (assessment_length >
                                                          1) ...[
                                                        Expanded(
                                                          flex: 1,
                                                          child: IconButton(
                                                              icon: const Icon(
                                                                  Icons.delete),
                                                              color: Colors.red,
                                                              onPressed: () =>
                                                                  Future.delayed(
                                                                      Duration
                                                                          .zero,
                                                                      () async {
                                                                    delete_confirmation_dialog(
                                                                        context,
                                                                        index);
                                                                  })),
                                                        )
                                                      ],
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
                                                  onChanged: (value) =>
                                                      setState(() =>
                                                          final_exam_clo =
                                                              value!),
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
                                                    validator:
                                                        (weightagevalue) {
                                                      if (weightagevalue ==
                                                              null ||
                                                          weightagevalue
                                                              .isEmpty) {
                                                        return 'Please enter some text';
                                                      } else if (regex()
                                                              .isDoubleOnly(
                                                                  weightagevalue) ==
                                                          false) {
                                                        return 'Only number is allow';
                                                      }
                                                      return null;
                                                    },
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: <
                                                        TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .allow(
                                                              RegExp(r'[0-9.]'))
                                                    ],
                                                  )),
                                            ],
                                          )))
                                        ],
                                      ),
                                    ]))),
                            Expanded(
                              flex: 4,
                              child: Column(children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        overall_weightage_warning,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 15.0,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        addWarning,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 15.0,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ]),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (assessment_name.last.text != "" &&
                                            assessment_weightage.last.text !=
                                                "") {
                                          if (this.mounted) {
                                            setState(() {
                                              addWarning = "";
                                              assessment_length++;
                                            });
                                          }
                                        } else {
                                          setState(() {
                                            addWarning =
                                                "Pls fill in all blank field before add new assessment";
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
                                    if (widget.mode == "add") ...[
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            if (isSubmitting == false) {
                                              setState(() {
                                                isSubmitting = true;
                                              });
                                              if (overall_weightage == 100) {
                                                setState(() {
                                                  overall_weightage_warning =
                                                      "";
                                                });
                                                for (int i = 0;
                                                    i < assessment_length;
                                                    i++) {
                                                  save_assessment(i, "normal");
                                                }
                                                save_assessment(0, "final")
                                                    .then((value) {
                                                  assessment_saved = value;
                                                  if (assessment_saved ==
                                                      true) {
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(
                                                            builder: (context) =>
                                                                LecturerCourseDetailPage(
                                                                    widget
                                                                        .assessment_plan_id))).then(
                                                        (value) {
                                                      setState(() {
                                                        isSubmitting = false;

                                                        isLoading = true;
                                                        get_clo();
                                                      });
                                                    });
                                                  }
                                                });
                                              } else {
                                                setState(() {
                                                  overall_weightage_warning =
                                                      "Overall weightage must equal 100";
                                                });
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
                                      )
                                    ] else if (widget.mode == "edit") ...[
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            if (isSubmitting == false) {
                                              setState(() {
                                                isSubmitting = true;
                                              });
                                              if (overall_weightage == 100) {
                                                setState(() {
                                                  overall_weightage_warning =
                                                      "";
                                                });
                                                for (int i = 0;
                                                    i < assessment_length;
                                                    i++) {
                                                  save_assessment(i, "normal");
                                                }
                                                save_assessment(0, "final")
                                                    .then((value) {
                                                  assessment_saved = value;
                                                  if (assessment_saved ==
                                                      true) {
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(
                                                            builder: (context) =>
                                                                LecturerCourseDetailPage(
                                                                    widget
                                                                        .assessment_plan_id))).then(
                                                        (value) {
                                                      setState(() {
                                                        isSubmitting = false;

                                                        isLoading = true;
                                                        get_clo();
                                                      });
                                                    });
                                                    ;
                                                  }
                                                });
                                              } else {
                                                setState(() {
                                                  overall_weightage_warning =
                                                      "Overall weightage must equal 100";
                                                });
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
                                          'Save',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                            decoration: TextDecoration.none,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      )
                                    ],
                                  ],
                                ),
                              ]),
                            )
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ));
    }
  }
}
