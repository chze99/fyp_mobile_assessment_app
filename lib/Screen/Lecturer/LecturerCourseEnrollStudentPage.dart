// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/dialog_template.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';

import '../loading_page.dart';

// ignore: must_be_immutable
class LecturerCourseEnrollStudentPage extends StatefulWidget {
  int assessment_plan_id = 0;
  LecturerCourseEnrollStudentPage(this.assessment_plan_id);
  @override
  _LecturerCourseEnrollStudentPageState createState() =>
      _LecturerCourseEnrollStudentPageState();
}

class _LecturerCourseEnrollStudentPageState
    extends State<LecturerCourseEnrollStudentPage> {
  var isLoading = true;
  var message;
  var student_list, programme_list;
  int studentValue = 1;
  String programmeValue = "ALL";
  List<DropdownMenuItem<String>> programme_list_items = [];
  List<DropdownMenuItem<int>> student_list_items = [];
  var course_student_data;
  int course_student_length = 0;
  bool isSubmitting = false;
  @override
  void initState() {
    load_programme_list();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  load_programme_list() async {
    var data = {"temp": "temp"};
    var res = await Api().postData(data, "getProgrammeList");
    var body = json.decode(res.body);
    if (body['success']) {
      setState(() {
        programme_list = body['programme_list'];
        print("Text" + programme_list[0]["programmes_id"].toString());

        if (programme_list != "No programme") {
          programme_list_items.add(DropdownMenuItem(
            value: "all",
            child: Text("All"),
          ));
          programme_list_items.addAll(List.generate(
            programme_list.length,
            (i) => DropdownMenuItem(
              value: programme_list[i]["programme_id"].toString(),
              child: Text(
                  "${programme_list[i]["programme_code"]} - ${programme_list[i]["programme_name"]} "),
            ),
          ));

          programmeValue = "all";
        }
      });
      await load_student_list("all");
    } else {
      print(body);
    }
  }

  load_student_list(String programme) async {
    var data;
    if (programme == "all") {
      data = {
        'programme': programme,
      };
    } else {
      data = {
        'programme': int.parse(programme),
      };
    }

    var res = await Api().postData(data, "getStudentList");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      setState(() {
        student_list = body['student_list'];
        print("Student" + student_list.toString());
        if (student_list != "No student") {
          student_list_items = List.generate(
            student_list.length,
            (i) => DropdownMenuItem(
              value: student_list[i]["student_id"],
              child: Text(student_list[i]["student_semester"] != null
                  ? "${student_list[i]["student_name"]} - ${student_list[i]["icats_id"]} - Semester ${student_list[i]["student_semester"]} "
                  : "${student_list[i]["student_name"]} - ${student_list[i]["icats_id"]}"),
            ),
          );
          studentValue = student_list[0]["student_id"];
          load_course_student_data();
        }
      });
    } else {
      error_alert().alert(context, "Error", body.toString());

      print(body);
    }
  }

  load_course_student_data() async {
    var data = {
      'assessment_plan_id': widget.assessment_plan_id,
    };
    var res = await Api().postData(data, "getCourseStudentListData");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      print(body);
      if (this.mounted) {
        course_student_data = body['course_student_data'];
        if (body['course_student_data'].toString() != "No student assigned") {
          setState(() {
            course_student_length = course_student_data['count'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  enroll_student() async {
    var data = {
      'assessment_plan_id': widget.assessment_plan_id,
      'student_id': studentValue,
    };
    var res = await Api().postData(data, "enrollStudent");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      setState(() {
        load_course_student_data();
        message = body['message'];
      });
    } else {
      print(body);
    }
  }

  del_student(int index) async {
    var data = {
      'assessment_student_id': course_student_data[index.toString()]
          ["assessment_student_id"]
    };
    var res = await Api().postData(data, "deleteStudentEnrollment");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      print(body);
      Future.delayed(Duration.zero, () async {
        setState(() {
          isLoading = true;
          load_student_list("all");
        });
      });
    } else {
      print(body);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(message);
    if (isLoading == true) {
      return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Enrollment"),
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
              title: Text('Enrollment'),
              backgroundColor: Colors.orange,
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  height: 500,
                  width: 500,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Programme:   "),
                            Expanded(
                              child: DropdownButton<String>(
                                  isExpanded: true,
                                  items: programme_list_items,
                                  value: programmeValue,
                                  onChanged: (value) => setState(() {
                                        print("Value" + value.toString());
                                        print("PValue" +
                                            programmeValue.toString());
                                        programmeValue = value!;
                                        load_student_list(
                                            programmeValue.toString());
                                      })),
                            )
                          ],
                        ),
                        if (student_list != "No student" &&
                            student_list != "null") ...[
                          Row(children: [
                            Text("Student Name:   "),
                            Expanded(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                items: student_list_items,
                                value: studentValue,
                                onChanged: (value) =>
                                    setState(() => studentValue = value!),
                              ),
                            ),
                          ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    enroll_student();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.red),
                                  ),
                                  child: Text(
                                    'Enroll',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                )
                              ]),
                          SizedBox(height: 5),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (message != null) ...[
                                  Text(
                                    message,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 15.0,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ]),
                        ] else ...[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "No Student Found",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 15.0,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ]),
                        ],
                        Card(
                          elevation: 10,
                          child: Column(
                            children: [
                              Row(children: [
                                Text(
                                  "Student List: ",
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ]),
                              SizedBox(
                                height: 5,
                              ),
                              Row(children: [
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "No.",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )),
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                      "Name",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )),
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                      "ICATS ID",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )),
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
                                              EdgeInsets.fromLTRB(0, 0, 0, 10),
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
                                                          fontSize: 18,
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
                                                          fontSize: 18,
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
                                                          fontSize: 18,
                                                        ),
                                                      )),
                                                  if (course_student_length >
                                                      1) ...[
                                                    Expanded(
                                                      flex: 1,
                                                      child: InkWell(
                                                          child: Icon(
                                                              Icons.delete,
                                                              size: 18.0,
                                                              color:
                                                                  Colors.red),
                                                          onTap: () =>
                                                              // Future.delayed(
                                                              //     Duration.zero,
                                                              //     () async {
                                                              dialog_template().confirmation_dialog(
                                                                  context,
                                                                  "No",
                                                                  "Yes",
                                                                  "Delete confirmation",
                                                                  "Did you sure that you want to remove this student from this course?",
                                                                  () => null,
                                                                  () =>
                                                                      del_student(
                                                                          index))
                                                          // }),
                                                          ),
                                                    )
                                                  ],
                                                ],
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}
