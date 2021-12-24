// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerCourseEnrollStudentPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  @override
  void initState() {
    load_user_data();
    print(course_data);
    super.initState();
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
      print(body);
      if (this.mounted) {
        setState(() {
          course_student_data = body['course_student_data'];
          isLoading = false;
        });
      }
    } else {
      print(body);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == true) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Course Detail'),
          backgroundColor: Colors.orange,
        ),
        body: Container(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Course Detail'),
          backgroundColor: Colors.orange,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Card(
                    elevation: 4.0,
                    child: SingleChildScrollView(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Course Title: ",
                              style: const TextStyle(
                                  fontFamily: 'Arial', fontSize: 25),
                            ),
                            Text(
                              course_data['course_title'].toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Arial',
                                  fontSize: 25),
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
                              style: const TextStyle(fontSize: 15),
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
                              "Session: ",
                              style: const TextStyle(fontSize: 15),
                            ),
                            Text(
                              course_data['session'].toString(),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) =>
                                            LecturerCourseCreateAssessmentPlan(
                                                course_data[
                                                    'assessment_plan_id'])));
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
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
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              LecturerCourseEnrollStudentPage(
                                                  course_data[
                                                      'assessment_plan_id'])));
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.red),
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
                            Text(
                              "Student List: ",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
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
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              (index + 1).toString(),
                                              style: const TextStyle(
                                                  fontFamily: 'Arial',
                                                  fontSize: 25),
                                            ),
                                            SizedBox(width: 20),
                                            Text(
                                              course_student_data[
                                                          index.toString()]
                                                      ['student_name']
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontFamily: 'Arial',
                                                  fontSize: 25),
                                            ),
                                            SizedBox(width: 20),
                                            Text(
                                              course_student_data[index
                                                      .toString()]['icats_id']
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontFamily: 'Arial',
                                                  fontSize: 25),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
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
                                    color: Color.fromARGB(255, 255, 0, 0)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ))),
              ),
            ),
          ],
        ),
      );
    }
  }
}
