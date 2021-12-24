// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCourseCreateAssessmentPlan2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class LecturerCourseCreateAssessmentPlan extends StatefulWidget {
  int assessment_plan_id = 0;
  LecturerCourseCreateAssessmentPlan(this.assessment_plan_id);
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
  final _formKey = GlobalKey<FormState>();
  bool clo_found = false;
  List<TextEditingController> clo_description = [];
  List<TextEditingController> clo_taxonomy = [];
  List<TextEditingController> clo_plo = [];
  @override
  void initState() {
    get_clo();

    super.initState();
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
            clo_length = exist_clo['count'];

            isLoading = false;
          });
        }
      } else {
        isLoading = false;
      }
    } else {
      print("error get_clo");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == true) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Assessment Plan-CLO'),
          backgroundColor: Colors.orange,
        ),
        body: Container(),
      );
    } else {
      return Scaffold(
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
                              flex: 1,
                              child: Text(
                                "Taxonomy",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "PLO",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ListView.builder(
                                  itemCount: clo_length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    if (clo_description.length <= clo_length) {
                                      clo_description
                                          .add(new TextEditingController());
                                      clo_taxonomy
                                          .add(new TextEditingController());
                                      clo_plo.add(new TextEditingController());
                                    }
                                    if (clo_found == true) {
                                      if (index < exist_clo['count']) {
                                        clo_description[index].text =
                                            exist_clo[index.toString()]
                                                ['clo_description'];
                                        clo_taxonomy[index].text =
                                            exist_clo[index.toString()]
                                                ['clo_taxonomy'];
                                        clo_plo[index].text =
                                            exist_clo[index.toString()]
                                                ['clo_plo'];
                                      }
                                    }
                                    return Container(
                                        child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                              "CLO " +
                                                  (index + 1).toString() +
                                                  ": ",
                                              textAlign: TextAlign.right),
                                        ),
                                        Expanded(
                                            flex: 4,
                                            child: TextFormField(
                                              textAlign: TextAlign.start,
                                              controller:
                                                  clo_description[index],
                                              autofocus: false,
                                              validator: (descvalue) {
                                                if (descvalue == null ||
                                                    descvalue.isEmpty) {
                                                  return 'Please enter some text';
                                                }
                                                return null;
                                              },
                                              keyboardType: TextInputType.text,
                                            )),
                                        Text("("),
                                        Expanded(
                                            flex: 1,
                                            child: TextFormField(
                                              textAlign: TextAlign.start,
                                              controller: clo_taxonomy[index],
                                              autofocus: false,
                                              keyboardType: TextInputType.text,
                                              validator: (taxovalue) {
                                                if (taxovalue == null ||
                                                    taxovalue.isEmpty) {
                                                  return 'Please enter some text';
                                                }
                                                return null;
                                              },
                                            )),
                                        Text(",", textAlign: TextAlign.right),
                                        Expanded(
                                            flex: 1,
                                            child: TextFormField(
                                              textAlign: TextAlign.start,
                                              controller: clo_plo[index],
                                              autofocus: false,
                                              keyboardType: TextInputType.text,
                                              validator: (plovalue) {
                                                if (plovalue == null ||
                                                    plovalue.isEmpty) {
                                                  return 'Please enter some text';
                                                }
                                                return null;
                                              },
                                            )),
                                        Text(")"),
                                      ],
                                    ));
                                  }),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (this.mounted) {
                                  setState(() {
                                    clo_length++;
                                    clo_description
                                        .add(new TextEditingController());
                                    clo_taxonomy
                                        .add(new TextEditingController());
                                    clo_plo.add(new TextEditingController());
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
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  for (int i = 0; i < clo_length; i++) {
                                    save_clo(i, clo_length).then((value) {
                                      clo_saved_status = value;
                                      if (clo_saved_status == true) {
                                        Toast.show("CLO saved", context,
                                            duration: Toast.LENGTH_SHORT,
                                            gravity: Toast.BOTTOM);
                                        Navigator.push(
                                            context,
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    LecturerCourseCreateAssessmentPlan2(
                                                        widget
                                                            .assessment_plan_id)));
                                      }
                                    });
                                    print(i);
                                  }
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                              ),
                              child: Text(
                                'Next',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
