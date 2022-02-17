// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerAssessmentAdd.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCourseCreateAssessmentPlan2.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCourseEnrollStudentPage.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCourseManageGrade.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCourseViewStudentResult.dart';
import 'package:mobile_assessment/Screen/Lecturer/Question_Bank/LecturerAssessmentQuestionBank.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loading_page.dart';
import 'LecturerCourseCreateAssessmentPlan.dart';

// ignore: must_be_immutable
class LecturerCourseDetailPage extends StatefulWidget {
  int index = 0;
  LecturerCourseDetailPage(this.index);
  @override
  _LecturerCourseDetailPageState createState() =>
      _LecturerCourseDetailPageState();
}

class _LecturerCourseDetailPageState extends State<LecturerCourseDetailPage> {
  String name = "";
  var isLoading = true;
  var course_data;
  var course_student_data;
  var clo_data;
  var clo_count;
  var assessment_data;
  var assessment_grade_data;

  var assessment_count;
  var final_exam_data;
  @override
  void initState() {
    load_user_data();
    print("Inittial load course data: " + course_data.toString());
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

  load_user_data() async {
    SharedPreferences local_storage = await SharedPreferences.getInstance();
    var user = jsonDecode(local_storage.getString('user') ?? "");

    if (user != null && user != "") {
      setState(() {
        name = user['username'];
      });
      var data = {
        'assessment_plan_id': widget.index,
      };
      var res = await Api().postData(data, "getLecturerDetailCourseData");
      var body = json.decode(res.body);
      if (body['success']) {
        if (this.mounted) {
          setState(() {
            course_data = body['lecturer_course_data'][0];
            load_course_student_data();
          });
        }
      }
    }
  }

  load_course_student_data() async {
    var data = {
      'assessment_plan_id': widget.index,
    };
    var res = await Api().postData(data, "getCourseStudentListData");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      print("Course student data " + body.toString());
      if (this.mounted) {
        setState(() {
          course_student_data = body['course_student_data'];
          get_clo();
        });
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print("Course student data error" + body.toString());
    }
  }

  get_clo() async {
    var data = {
      'assessment_plan_id': widget.index,
    };
    var res = await Api().postData(data, "getAssessmentPlanCLO");
    var body = json.decode(res.body);
    if (body['success']) {
      if (this.mounted) {
        setState(() {
          clo_data = body['message'];
          clo_count = clo_data['count'];
          print("Clo count" + clo_count.toString());

          get_assessment();
        });
      }
    } else {
      print("get clo error" + body.toString());
    }
  }

  get_grade() async {
    var data = {
      'assessment_plan_id': widget.index,
    };
    var res = await Api().postData(data, "getAssessmentGrade");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        setState(() {
          assessment_grade_data = body['message'];

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

  get_assessment() async {
    var data = {
      'assessment_plan_id': widget.index,
    };
    var res = await Api().postData(data, "getAssessmentDetail");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        setState(() {
          assessment_data = body['message'];
          assessment_count = assessment_data['count'];
          if (body['final'] != null) {
            final_exam_data = body['final'][0];
          }

          print("Assessment data" + body['final'].toString());
          get_grade();
        });
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print("get_assessment error" + body.toString());
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
            title: Text("Course Detail"),
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
              title: Text('Course Detail'),
              backgroundColor: Colors.orange,
              actions: <Widget>[
                SizedBox(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Question bank",
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    LecturerAssessmentQuestionBank(
                                        widget.index, 'add'))).then((value) {
                          setState(() {
                            get_clo();
                          });
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  height: double.infinity,
                  color: Color.fromARGB(255, 210, 210, 210),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: SingleChildScrollView(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Course Title: ",
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              course_data['course_title'].toString(),
                              style: const TextStyle(
                                  fontFamily: 'Arial', fontSize: 25),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "Course Code: ",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              course_data['course_code'].toString(),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              "Credit Hour: ",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              course_data['course_credit_hour'].toString(),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              "Session: ",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              course_data['session_name'].toString(),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        if (clo_count > 0) ...[
                          Card(
                              color: Colors.green,
                              elevation: 10,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "CLO Listing",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Spacer(),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LecturerCourseCreateAssessmentPlan(
                                                          course_data[
                                                              'assessment_plan_id'],
                                                          "edit"))).then(
                                              (value) {
                                            setState(() {
                                              get_clo();
                                            });
                                          });
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.blue),
                                        ),
                                        child: Text(
                                          'Edit CLO',
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
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              "CLO Number",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              "CLO Description(Taxonomy,PLO)",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                            itemCount: clo_count,
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              print("Clo data" +
                                                  clo_data.toString());

                                              return Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 0, 0),
                                                  child: Container(
                                                      child: Column(children: [
                                                    Row(children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                            "CLO " +
                                                                clo_data[index
                                                                            .toString()]
                                                                        [
                                                                        'clo_number']
                                                                    .toString() +
                                                                ": ",
                                                            textAlign:
                                                                TextAlign.left),
                                                      ),
                                                      if (isNumberOnly(clo_data[
                                                                  index
                                                                      .toString()]
                                                              ['clo_plo']) ==
                                                          false) ...[
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                              clo_data[index
                                                                          .toString()]
                                                                      [
                                                                      'clo_description'] +
                                                                  "(" +
                                                                  clo_data[index
                                                                          .toString()]
                                                                      [
                                                                      'clo_taxonomy'] +
                                                                  "," +
                                                                  clo_data[index
                                                                          .toString()]
                                                                      [
                                                                      'clo_plo'] +
                                                                  ")",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                      ] else ...[
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                              clo_data[index
                                                                          .toString()]
                                                                      [
                                                                      'clo_description'] +
                                                                  "(" +
                                                                  clo_data[index
                                                                          .toString()]
                                                                      [
                                                                      'clo_taxonomy'] +
                                                                  ",PLO " +
                                                                  clo_data[index
                                                                          .toString()]
                                                                      [
                                                                      'clo_plo'] +
                                                                  ")",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                        ),
                                                      ],
                                                    ]),
                                                    Divider(
                                                      thickness: 1.0,
                                                      color: Colors.black,
                                                      endIndent: 0,
                                                      indent: 0,
                                                    ),
                                                  ])));
                                            }),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          SizedBox(height: 5),
                          if (assessment_count > 0) ...[
                            Card(
                                color: Colors.redAccent,
                                elevation: 10,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            "Planned Assessment Listing",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            LecturerCourseCreateAssessmentPlan2(
                                                                course_data[
                                                                    'assessment_plan_id'],
                                                                "edit"))).then(
                                                    (value) {
                                                  setState(() {
                                                    get_assessment();
                                                  });
                                                });
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.green),
                                              ),
                                              child: Text(
                                                'Edit assessment',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Assessment Name",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Assessment CLO",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Assessment Weightage",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                "",
                                              ),
                                            )
                                          ],
                                        )),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ListView.builder(
                                              itemCount: assessment_count,
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                print("Clo data" +
                                                    clo_data.toString());

                                                return Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 0, 00),
                                                    child: Container(
                                                        child: Column(
                                                            children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                    assessment_data[index.toString()]
                                                                            [
                                                                            'assessment_detail_title']
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                    "CLO" +
                                                                        assessment_data[index.toString()]['clo_number']
                                                                            .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                    assessment_data[
                                                                            index.toString()]
                                                                        [
                                                                        'assessment_detail_weightage'],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                              ),
                                                              if (assessment_data[
                                                                          index
                                                                              .toString()]
                                                                      [
                                                                      'question_paper'] !=
                                                                  "No question paper") ...[
                                                                if (assessment_data[index.toString()]['question_paper']
                                                                            [
                                                                            'isPublished']
                                                                        .toString() !=
                                                                    "true") ...[
                                                                  Expanded(
                                                                      flex: 1,
                                                                      child: InkWell(
                                                                          child: Text(
                                                                            "Create question",
                                                                            style:
                                                                                TextStyle(color: Colors.green),
                                                                          ),
                                                                          onTap: () {
                                                                            Navigator.push(context,
                                                                                MaterialPageRoute(builder: (context) => LecturerAssessmentAdd(assessment_data[index.toString()]['assessment_detail_id'], 'add'))).then((value) {
                                                                              setState(() {
                                                                                get_assessment();
                                                                              });
                                                                            });
                                                                          })),
                                                                ] else ...[
                                                                  Expanded(
                                                                      flex: 1,
                                                                      child: InkWell(
                                                                          child: Text(
                                                                            "Edit/View question",
                                                                            style:
                                                                                TextStyle(color: Colors.green),
                                                                          ),
                                                                          onTap: () {
                                                                            Navigator.push(context,
                                                                                MaterialPageRoute(builder: (context) => LecturerAssessmentAdd(assessment_data[index.toString()]['assessment_detail_id'], 'edit'))).then((value) {
                                                                              setState(() {
                                                                                get_assessment();
                                                                              });
                                                                            });
                                                                          })),
                                                                ]
                                                              ] else ...[
                                                                Expanded(
                                                                    flex: 1,
                                                                    child: InkWell(
                                                                        child: Text(
                                                                          "Create question",
                                                                          style:
                                                                              TextStyle(color: Colors.green),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => LecturerAssessmentAdd(assessment_data[index.toString()]['assessment_detail_id'], 'add'))).then((value) {
                                                                            setState(() {
                                                                              get_assessment();
                                                                            });
                                                                          });
                                                                        })),
                                                              ],
                                                            ],
                                                          ),
                                                          Divider(
                                                            thickness: 1.0,
                                                            color: Colors.black,
                                                            endIndent: 0,
                                                            indent: 0,
                                                          ),
                                                        ])));
                                              }),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                  final_exam_data[
                                                          'assessment_detail_title']
                                                      .toString(),
                                                  textAlign: TextAlign.left),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                  "CLO" +
                                                      final_exam_data[
                                                              'clo_number']
                                                          .toString(),
                                                  textAlign: TextAlign.left),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                  final_exam_data[
                                                      'assessment_detail_weightage'],
                                                  textAlign: TextAlign.left),
                                            ),
                                            if (final_exam_data[
                                                    'question_paper'] !=
                                                "No question paper") ...[
                                              if (final_exam_data[
                                                              'question_paper']
                                                          ['isPublished']
                                                      .toString() !=
                                                  "true") ...[
                                                Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                        child: Text(
                                                          "Create question",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green),
                                                        ),
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => LecturerAssessmentAdd(
                                                                      final_exam_data[
                                                                          'assessment_detail_id'],
                                                                      'add'))).then(
                                                              (value) {
                                                            setState(() {
                                                              get_assessment();
                                                            });
                                                          });
                                                        }))
                                              ] else ...[
                                                Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                        child: Text(
                                                          "Edit/View question",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green),
                                                        ),
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => LecturerAssessmentAdd(
                                                                      final_exam_data[
                                                                          'assessment_detail_id'],
                                                                      'edit'))).then(
                                                              (value) {
                                                            setState(() {
                                                              get_assessment();
                                                            });
                                                          });
                                                        }))
                                              ]
                                            ] else ...[
                                              Expanded(
                                                  flex: 1,
                                                  child: InkWell(
                                                      child: Text(
                                                        "Create question",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.green),
                                                      ),
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    LecturerAssessmentAdd(
                                                                        final_exam_data[
                                                                            'assessment_detail_id'],
                                                                        'add'))).then(
                                                            (value) {
                                                          setState(() {
                                                            get_assessment();
                                                          });
                                                        });
                                                      }))
                                            ],
                                            Divider(
                                              thickness: 1.0,
                                              color: Colors.black,
                                              endIndent: 0,
                                              indent: 0,
                                            ),
                                          ],
                                        )),
                                  ],
                                )),
                            SizedBox(height: 5)
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LecturerCourseCreateAssessmentPlan2(
                                                    course_data[
                                                        'assessment_plan_id'],
                                                    "add"))).then((value) {
                                      setState(() {
                                        get_assessment();
                                      });
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.red),
                                  ),
                                  child: Text(
                                    'Continue Add Assessment Plan',
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
                          ]
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              LecturerCourseCreateAssessmentPlan(
                                                  course_data[
                                                      'assessment_plan_id'],
                                                  "add"))).then((value) {
                                    setState(() {
                                      get_clo();
                                    });
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green),
                                ),
                                child: Text(
                                  'Create Assessment Plan',
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
                        SizedBox(
                          height: 5,
                        ),
                        Card(
                          color: Colors.orangeAccent,
                          elevation: 10,
                          child: Column(
                            children: [
                              Row(children: [
                                Text(
                                  "Student List: ",
                                  style: const TextStyle(fontSize: 20),
                                ),
                                Spacer(),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LecturerCourseEnrollStudentPage(
                                                    course_data[
                                                        'assessment_plan_id']))).then(
                                        (value) {
                                      setState(() {
                                        load_course_student_data();
                                      });
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.blue),
                                  ),
                                  child: Text(
                                    'Enroll Student',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                )
                              ]),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  if (course_student_data !=
                                      "No student assigned") ...[
                                    Expanded(
                                        child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: course_student_data['count'],
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        (index + 1).toString(),
                                                        style: const TextStyle(
                                                          fontFamily: 'Arial',
                                                        ),
                                                      )),
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        course_student_data[index
                                                                    .toString()]
                                                                ['student_name']
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontFamily: 'Arial',
                                                        ),
                                                      )),
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        course_student_data[index
                                                                    .toString()]
                                                                ['icats_id']
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontFamily: 'Arial',
                                                        ),
                                                      )),
                                                  Expanded(
                                                      flex: 1,
                                                      child: InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => LecturerCourseViewStudentResult(
                                                                        course_student_data[index.toString()]
                                                                            [
                                                                            'student_id'],
                                                                        course_data[
                                                                            'assessment_plan_id']))).then(
                                                                (value) {
                                                              setState(() {
                                                                load_course_student_data();
                                                              });
                                                            });
                                                          },
                                                          child: Text(
                                                            "View result",
                                                            style:
                                                                const TextStyle(
                                                                    fontFamily:
                                                                        'Arial',
                                                                    color: Colors
                                                                        .green),
                                                          ))),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 1.0,
                                                color: Colors.black,
                                                endIndent: 0,
                                                indent: 0,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ))
                                  ] else ...[
                                    Text(
                                      "No student assigned",
                                      style: const TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 25,
                                          color:
                                              Color.fromARGB(255, 255, 0, 0)),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: Colors.grey,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text("Grading",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 25))),
                                      Expanded(
                                          child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            LecturerCourseManageGrade(
                                                                course_data[
                                                                    'assessment_plan_id']))).then(
                                                    (value) {
                                                  setState(() {
                                                    load_course_student_data();
                                                  });
                                                });
                                              },
                                              child: Text(
                                                "Manage grade",
                                              )))
                                    ],
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Text("Grade",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ],
                                  )),
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Text("Score range",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ],
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    children: [Text("A")],
                                  )),
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Text(assessment_grade_data['grade_a']
                                              .toString() +
                                          '-' +
                                          "100")
                                    ],
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    children: [Text("B")],
                                  )),
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Text(assessment_grade_data['grade_b']
                                              .toString() +
                                          '-' +
                                          assessment_grade_data['grade_a']
                                              .toString())
                                    ],
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    children: [Text("C")],
                                  )),
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Text(assessment_grade_data['grade_c']
                                              .toString() +
                                          '-' +
                                          assessment_grade_data['grade_b']
                                              .toString())
                                    ],
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    children: [Text("D")],
                                  )),
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Text(assessment_grade_data['grade_d']
                                              .toString() +
                                          '-' +
                                          assessment_grade_data['grade_c']
                                              .toString())
                                    ],
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    children: [Text("F")],
                                  )),
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Text(assessment_grade_data['grade_f']
                                              .toString() +
                                          '-' +
                                          assessment_grade_data['grade_d']
                                              .toString())
                                    ],
                                  )),
                                ],
                              ),
                            ],
                          ),
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
