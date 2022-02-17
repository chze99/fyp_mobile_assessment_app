// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentHomePage extends StatefulWidget {
  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  String name = "";
  bool isLoading = true;
  var user_data;
  var question_paper_data;
  var ongoing_assessment;
  var today_submission;
  var due_today;
  DateTime todayData =
      new DateFormat("yyyy-MM-dd").parse(DateTime.now().toString());
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int today_count = 0, past_count = 0, future_count = 0;
  @override
  void initState() {
    load_user_data();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  load_user_data() async {
    SharedPreferences local_storage = await SharedPreferences.getInstance();
    var user = jsonDecode(local_storage.getString('user') ?? "");

    if (user != null && user != "") {
      if (this.mounted) {
        setState(() {
          name = user['username'];
          user_data = user;
          print("USER" + user_data.toString());
        });
      }
      var data = {
        'user_id': user["user_id"],
      };
      var res = await Api().postData(data, "getStudentQuestionPaperList");
      var body = json.decode(res.body);
      if (body['success'] != null) {
        if (body['message'] != "No question paper") {
          if (this.mounted) {
            setState(() {
              question_paper_data = body['message'];
              for (int i = 0; i < question_paper_data['count']; i++) {
                DateTime temp = new DateFormat("yyyy-MM-dd").parse(
                    question_paper_data[i.toString()]
                        ['question_paper_start_date']);

                if (temp.isAtSameMomentAs(todayData)) {
                  question_paper_data[i.toString()]['day'] = "today";
                  today_count += 1;
                } else if (temp.isBefore(todayData)) {
                  question_paper_data[i.toString()]['day'] = "past";
                  past_count += 1;
                } else if (temp.isAfter(todayData)) {
                  question_paper_data[i.toString()]['day'] = "future";
                  future_count += 1;
                }
              }
              print(future_count);
              print(question_paper_data);
              get_dashboard_content();
            });
          }
        }
        get_dashboard_content();
      } else {
        get_dashboard_content();
      }
    }
  }

  get_dashboard_content() async {
    var data = {
      'user_id': user_data["user_id"],
    };
    var res = await Api().postData(data, "getStudentDashboard");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      print("Assesment" + body.toString());
      if (this.mounted) {
        setState(() {
          ongoing_assessment = body['ongoing_assessment'];
          today_submission = body['submission_today'];
          due_today = body['due_today'];
        });
      }
      isLoading = false;
    } else {
      error_alert().alert(context, "Error", body.toString());

      isLoading = false;
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
            title: Text("Assessment"),
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
      return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          backgroundColor: Colors.orange,
        ),
        body: Stack(
          children: <Widget>[
            Container(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Card(
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Today assessment:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            )
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              today_count.toString(),
                                            )
                                          ]),
                                    ],
                                  )))),
                      Expanded(
                          child: Card(
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Today Submission:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            )
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              today_submission.toString(),
                                            )
                                          ]),
                                    ],
                                  )))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Card(
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Ongoing Assessment",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            )
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              ongoing_assessment.toString(),
                                            )
                                          ]),
                                    ],
                                  )))),
                      Expanded(
                          child: Card(
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Due today",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            )
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              due_today.toString(),
                                            )
                                          ]),
                                    ],
                                  )))),
                    ],
                  )
                ],
              ),
            )),
          ],
        ),
      );
    }
  }
}
