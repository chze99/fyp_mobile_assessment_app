// ignore_for_file: non_constant_identifier_names, import_of_legacy_library_into_null_safe

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCourseCreateAssessmentPlan2.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCourseDetailPage.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:toast/toast.dart';

import '../loading_page.dart';

// ignore: must_be_immutable
class LecturerCourseCreateAssessmentPlan extends StatefulWidget {
  int assessment_plan_id = 0;
  String mode = "";
  LecturerCourseCreateAssessmentPlan(this.assessment_plan_id, this.mode);
  @override
  _LecturerCourseCreateAssessmentPlanState createState() =>
      _LecturerCourseCreateAssessmentPlanState();
}

class _LecturerCourseCreateAssessmentPlanState
    extends State<LecturerCourseCreateAssessmentPlan> {
  var isLoading = true;
  var clo_saved_status;
  var clo_length = 1;
  var clo_test;
  var exist_clo;
  String addWarning = "";
  bool isLast = false;
  final _formKey = GlobalKey<FormState>();
  bool clo_found = false;
  List<TextEditingController> clo_description = [];
  List<TextEditingController> clo_taxonomy = [];
  List<TextEditingController> clo_plo = [];
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

  save_clo(int index, int length) async {
    var data = {
      'clo_description': clo_description[index].text,
      'clo_taxonomy': clo_taxonomy[index].text,
      'clo_plo': clo_plo[index].text,
      'clo_number': (index + 1),
      'assessment_plan_id': widget.assessment_plan_id,
    };
    var res = await Api().postData(data, "saveAssessmentPlanCLO");
    var body = json.decode(res.body);
    if (body['success']) {
      if (index == length - 1) {
        if (this.mounted) {
          clo_saved_status = true;
          return clo_saved_status;
        }
      }
    } else {
      clo_saved_status = false;
      print("Fail to save");
    }
  }

  get_clo() async {
    var data = {
      'assessment_plan_id': widget.assessment_plan_id,
    };
    var res = await Api().postData(data, "getAssessmentPlanCLO");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['found']) {
        if (this.mounted) {
          setState(() {
            clo_found = true;
            exist_clo = body['message'];
            if (clo_length < exist_clo['count']) {
              clo_length = exist_clo['count'];
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
      print("error get_clo");
    }
  }

  del_clo(int index) async {
    if (clo_found == true) {
      if (index < exist_clo['count']) {
        var data = {
          'assessment_clo_id': exist_clo[index.toString()]["assessment_clo_id"]
        };
        var res = await Api().postData(data, "deleteAssessmentPlanCLO");
        var body = json.decode(res.body);
        if (body['success'] != null) {
          Future.delayed(Duration.zero, () async {
            setState(() {
              for (int i = index; i < clo_length; i++) {
                if (i != clo_length - 1) {
                  clo_description[i] = clo_description[i + 1];
                  clo_taxonomy[i] = clo_taxonomy[i + 1];
                  clo_plo[i] = clo_plo[i + 1];
                }
              }
              clo_description.removeLast();
              clo_taxonomy.removeLast();
              clo_plo.removeLast();
              clo_length -= 1;
              isLoading = true;
              get_clo();
            });
          });
        } else {
          error_alert().alert(context, "Error", body.toString());

          print(body);
        }
      } else {
        Future.delayed(Duration.zero, () async {
          setState(() {
            for (int i = index; i < clo_length; i++) {
              if (i != clo_length - 1) {
                clo_description[i] = clo_description[i + 1];
                clo_taxonomy[i] = clo_taxonomy[i + 1];
                clo_plo[i] = clo_plo[i + 1];
              }
            }
            clo_description.removeLast();
            clo_taxonomy.removeLast();
            clo_plo.removeLast();
            clo_length -= 1;
          });
        });
      }
    } else {
      print("Status c");

      Future.delayed(Duration.zero, () async {
        setState(() {
          for (int i = index; i < clo_length; i++) {
            if (i != clo_length - 1) {
              clo_description[i] = clo_description[i + 1];
              clo_taxonomy[i] = clo_taxonomy[i + 1];
              clo_plo[i] = clo_plo[i + 1];
            }
          }
          clo_description.removeLast();
          clo_taxonomy.removeLast();
          clo_plo.removeLast();
          clo_length -= 1;
        });
      });
    }
    print("Deleted");
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
        del_clo(index);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete confirmation"),
      content: Text("Did you sure to delete this CLO?"),
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
            title: Text("Assessment CLO-Plan"),
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
              title: Text('Assessment Plan-CLO'),
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
                              flex: 18,
                              child: SingleChildScrollView(
                                  physics: ScrollPhysics(),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              "Description",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              "Taxonomy",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              "PLO",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                                itemCount: clo_length,
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  if (clo_description.length <
                                                      clo_length) {
                                                    print("Clo desc=" +
                                                        clo_description.length
                                                            .toString() +
                                                        " clo length=" +
                                                        clo_length.toString());
                                                    clo_description.add(
                                                        new TextEditingController());
                                                    clo_taxonomy.add(
                                                        new TextEditingController());
                                                    clo_plo.add(
                                                        new TextEditingController());
                                                  }
                                                  if (clo_found == true) {
                                                    if (isLast == false) {
                                                      if (index <
                                                          exist_clo['count']) {
                                                        clo_description[index]
                                                            .text = exist_clo[
                                                                index
                                                                    .toString()]
                                                            ['clo_description'];
                                                        clo_taxonomy[index]
                                                            .text = exist_clo[
                                                                index
                                                                    .toString()]
                                                            ['clo_taxonomy'];
                                                        clo_plo[index].text =
                                                            exist_clo[index
                                                                    .toString()]
                                                                ['clo_plo'];
                                                      }
                                                      if (index ==
                                                          exist_clo['count'] -
                                                              1) {
                                                        isLast = true;
                                                      }
                                                    }
                                                  }
                                                  print("CLO length" +
                                                      clo_description.length
                                                          .toString() +
                                                      "content" +
                                                      clo_description[
                                                              clo_description
                                                                      .length -
                                                                  1]
                                                          .text
                                                          .toString());
                                                  return Container(
                                                      child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                            "CLO " +
                                                                (index + 1)
                                                                    .toString() +
                                                                ": ",
                                                            textAlign: TextAlign
                                                                .right),
                                                      ),
                                                      Expanded(
                                                          flex: 4,
                                                          child: TextFormField(
                                                            textAlign:
                                                                TextAlign.start,
                                                            controller:
                                                                clo_description[
                                                                    index],
                                                            autofocus: false,
                                                            validator:
                                                                (descvalue) {
                                                              if (descvalue ==
                                                                      null ||
                                                                  descvalue
                                                                      .isEmpty) {
                                                                return 'Please enter some text';
                                                              }
                                                              return null;
                                                            },
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                          )),
                                                      Text("("),
                                                      Expanded(
                                                          flex: 2,
                                                          child: TextFormField(
                                                            textAlign:
                                                                TextAlign.start,
                                                            controller:
                                                                clo_taxonomy[
                                                                    index],
                                                            autofocus: false,
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            validator:
                                                                (taxovalue) {
                                                              if (taxovalue ==
                                                                      null ||
                                                                  taxovalue
                                                                      .isEmpty) {
                                                                return 'Please enter some text';
                                                              }
                                                              return null;
                                                            },
                                                          )),
                                                      Text(",",
                                                          textAlign:
                                                              TextAlign.right),
                                                      Expanded(
                                                          flex: 1,
                                                          child: TextFormField(
                                                            textAlign:
                                                                TextAlign.start,
                                                            controller:
                                                                clo_plo[index],
                                                            autofocus: false,
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            validator:
                                                                (plovalue) {
                                                              if (plovalue ==
                                                                      null ||
                                                                  plovalue
                                                                      .isEmpty) {
                                                                return 'Please enter some text';
                                                              }
                                                              return null;
                                                            },
                                                          )),
                                                      Text(")"),
                                                      if (clo_length > 1) ...[
                                                        Expanded(
                                                          flex: 1,
                                                          child: IconButton(
                                                            icon: const Icon(
                                                                Icons.delete),
                                                            color: Colors.red,
                                                            onPressed: () {
                                                              print(index);
                                                              Future.delayed(
                                                                  Duration.zero,
                                                                  () async {
                                                                delete_confirmation_dialog(
                                                                    context,
                                                                    index);
                                                              });
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    ],
                                                  ));
                                                }),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ))),
                          Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        addWarning,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 13.0,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )),
                          Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          if (clo_description.last.text != "" &&
                                              clo_plo.last.text != "" &&
                                              clo_taxonomy.last.text != "") {
                                            if (this.mounted) {
                                              setState(() {
                                                addWarning = "";
                                                clo_length++;
                                              });
                                            }
                                          } else {
                                            setState(() {
                                              addWarning =
                                                  "Pls fill in all blank field before add new CLO";
                                            });
                                          }
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.red),
                                        ),
                                        child: Text(
                                          'Add CLO',
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
                                                for (int i = 0;
                                                    i < clo_length;
                                                    i++) {
                                                  save_clo(i, clo_length)
                                                      .then((value) {
                                                    clo_saved_status = value;
                                                    if (clo_saved_status ==
                                                        true) {
                                                      Toast.show(
                                                          "CLO saved", context,
                                                          duration: Toast
                                                              .LENGTH_SHORT,
                                                          gravity:
                                                              Toast.BOTTOM);
                                                      Navigator.push(
                                                          context,
                                                          new MaterialPageRoute(
                                                              builder: (context) =>
                                                                  LecturerCourseCreateAssessmentPlan2(
                                                                      widget
                                                                          .assessment_plan_id,
                                                                      "add"))).then(
                                                          (value) {
                                                        setState(() {
                                                          isSubmitting = false;
                                                          isLoading = true;
                                                          get_clo();
                                                        });
                                                      });
                                                    }
                                                  });
                                                  print(i);
                                                }
                                              }
                                            }
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.red),
                                          ),
                                          child: Text(
                                            'Next',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.0,
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
                                                for (int i = 0;
                                                    i < clo_length;
                                                    i++) {
                                                  save_clo(i, clo_length)
                                                      .then((value) {
                                                    clo_saved_status = value;
                                                    if (clo_saved_status ==
                                                        true) {
                                                      Toast.show(
                                                          "CLO saved", context,
                                                          duration: Toast
                                                              .LENGTH_SHORT,
                                                          gravity:
                                                              Toast.BOTTOM);
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
                                                  print(i);
                                                }
                                              }
                                            }
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.red),
                                          ),
                                          child: Text(
                                            'Save',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.0,
                                              decoration: TextDecoration.none,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        )
                                      ],
                                    ],
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}
