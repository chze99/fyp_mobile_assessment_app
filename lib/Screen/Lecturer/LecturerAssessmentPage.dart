// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerAssessmentViewDetail.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loading_page.dart';

class LecturerAssessmentPage extends StatefulWidget {
  @override
  _LecturerAssessmentPageState createState() => _LecturerAssessmentPageState();
}

class _LecturerAssessmentPageState extends State<LecturerAssessmentPage> {
  String name = "";
  var isLoading = true;
  var question_paper_data;
  DateTime todayData =
      new DateFormat("yyyy-MM-dd").parse(DateTime.now().toString());
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int ongoing_count = 0, past_count = 0, future_count = 0;
  List<PopupMenuItem<String>> time_list = [];
  String current_selection = "All";
  @override
  void initState() {
    get_setting();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_setting() async {
    SharedPreferences local_storage = await SharedPreferences.getInstance();
    setState(() {
      if (local_storage.getString('default_assessment_filter') != null &&
          local_storage.getString('default_assessment_filter') != '') {
        current_selection =
            local_storage.getString('default_assessment_filter').toString();
      }
    });
    load_user_data();
  }

  load_user_data() async {
    SharedPreferences local_storage = await SharedPreferences.getInstance();
    var user = jsonDecode(local_storage.getString('user') ?? "");

    if (user != null && user != "") {
      if (this.mounted) {
        setState(() {
          name = user['username'];
        });
      }
      var data = {
        'user_id': user["user_id"],
      };
      var res = await Api().postData(data, "getQuestionPaperList");
      var body = json.decode(res.body);
      if (body['success'] != null) {
        if (body['message'] != "No question paper") {
          if (this.mounted) {
            setState(() {
              question_paper_data = body['message'];
              for (int i = 0; i < question_paper_data['count']; i++) {
                DateTime temp_start = new DateFormat("yyyy-MM-dd").parse(
                    question_paper_data[i.toString()]
                        ['question_paper_start_date']);
                DateTime temp_end = new DateFormat("yyyy-MM-dd").parse(
                    question_paper_data[i.toString()]
                        ['question_paper_end_date']);
                if ((temp_start.isAtSameMomentAs(todayData) ||
                        temp_start.isBefore(todayData)) &&
                    (temp_end.isAtSameMomentAs(todayData) ||
                        temp_end.isAfter(todayData))) {
                  question_paper_data[i.toString()]['day'] = "ongoing";
                  ongoing_count += 1;
                } else if ((temp_start.isBefore(todayData)) &&
                    (temp_end.isBefore(todayData))) {
                  question_paper_data[i.toString()]['day'] = "past";
                  past_count += 1;
                } else if (temp_start.isAfter(todayData) &&
                    (temp_end.isAfter(todayData))) {
                  question_paper_data[i.toString()]['day'] = "future";
                  future_count += 1;
                }
              }
              time_list.add(
                PopupMenuItem<String>(value: "All", child: Text("All")),
              );
              time_list.add(
                PopupMenuItem<String>(value: "Ongoing", child: Text("Ongoing")),
              );
              time_list.add(
                PopupMenuItem<String>(value: "History", child: Text("History")),
              );
              time_list.add(
                PopupMenuItem<String>(value: "Soon", child: Text("Soon")),
              );
              print(future_count);
              print(question_paper_data);
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
          error_alert().alert(context, "Error", body.toString());
        });
      }
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
          title: Text('Assessment'),
          backgroundColor: Colors.orange,
          actions: <Widget>[
            PopupMenuButton<String>(
              initialValue: "All",
              onSelected: ((String value) {
                setState(() {
                  current_selection = value;
                  isLoading = true;
                  time_list = [];

                  load_user_data();
                  print("Session" + value.toString());
                });
              }),
              child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        current_selection,
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      )
                    ],
                  )),
              itemBuilder: (BuildContext context) {
                return time_list;
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Container(
                child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (current_selection == "Ongoing" ||
                      current_selection == "All") ...[
                    Column(
                      children: [
                        Text("Ongoing",
                            style: const TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 25,
                                color: Colors.green)),
                        if (ongoing_count != 0) ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: question_paper_data['count'],
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                LecturerAssessmentViewDetail(
                                                    question_paper_data[
                                                            index.toString()]
                                                        ['question_paper_id'],
                                                    'view',
                                                    question_paper_data[
                                                            index.toString()][
                                                        'assessment_detail_id'])))
                                    .then((value) {
                                  setState(() {
                                    isLoading = true;
                                    load_user_data();
                                    time_list = [];
                                  });
                                }),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Column(
                                    children: [
                                      if (question_paper_data[index.toString()]
                                                  ['day']
                                              .toString() ==
                                          "ongoing") ...[
                                        Card(
                                            color: Colors.green,
                                            elevation: 4.0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Assessment Title: ",
                                                      style: const TextStyle(
                                                        fontFamily: 'Arial',
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      question_paper_data[index
                                                                  .toString()][
                                                              'assessment_detail_title']
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
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Course Code: ",
                                                      style: const TextStyle(
                                                        fontFamily: 'Arial',
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      question_paper_data[index
                                                                  .toString()]
                                                              ['course_code']
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontFamily: 'Arial',
                                                          fontSize: 15),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 3,
                                                        child: Row(children: [
                                                          Text(
                                                            "Course title: ",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            question_paper_data[
                                                                        index
                                                                            .toString()]
                                                                    [
                                                                    'course_title']
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          )
                                                        ])),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Row(children: [
                                                          Text(
                                                            "Total mark: ",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            question_paper_data[
                                                                        index
                                                                            .toString()]
                                                                    [
                                                                    'assessment_detail_weightage']
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          )
                                                        ]))
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Start time: ",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            question_paper_data[
                                                                            index.toString()]
                                                                        [
                                                                        'question_paper_start_date']
                                                                    .toString() +
                                                                " " +
                                                                question_paper_data[
                                                                            index.toString()]
                                                                        [
                                                                        'question_paper_start_time']
                                                                    .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Number of question: ",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            question_paper_data[
                                                                        index
                                                                            .toString()]
                                                                    [
                                                                    'number_of_question']
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 3,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "End time: ",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              question_paper_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_paper_end_date']
                                                                      .toString() +
                                                                  " " +
                                                                  question_paper_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_paper_end_time']
                                                                      .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                          ],
                                                        )),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "Session: ",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              question_paper_data[
                                                                          index
                                                                              .toString()]
                                                                      [
                                                                      'session_name']
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                          ],
                                                        ))
                                                  ],
                                                ),
                                              ],
                                            ))
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        ] else ...[
                          Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "No Assessment",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 25),
                                    )
                                  ])
                            ],
                          )
                        ],
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                  if (current_selection == "Soon" ||
                      current_selection == "All") ...[
                    Column(
                      children: [
                        Text("Tommorow onward",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 25,
                                color: Colors.blue)),
                        if (future_count != 0) ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: question_paper_data['count'],
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                LecturerAssessmentViewDetail(
                                                    question_paper_data[
                                                            index.toString()]
                                                        ['question_paper_id'],
                                                    'view',
                                                    question_paper_data[
                                                            index.toString()][
                                                        'assessment_detail_id'])))
                                    .then((value) {
                                  setState(() {
                                    isLoading = true;
                                    load_user_data();
                                    time_list = [];
                                  });
                                }),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Column(
                                    children: [
                                      if (question_paper_data[index.toString()]
                                                  ['day']
                                              .toString() ==
                                          "future") ...[
                                        Card(
                                            color: Colors.blueAccent,
                                            elevation: 4.0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Assessment Title: ",
                                                      style: const TextStyle(
                                                        fontFamily: 'Arial',
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      question_paper_data[index
                                                                  .toString()][
                                                              'assessment_detail_title']
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                      style: const TextStyle(
                                                        fontFamily: 'Arial',
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      question_paper_data[index
                                                                  .toString()]
                                                              ['course_code']
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily: 'Arial',
                                                          fontSize: 15),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 3,
                                                        child: Row(children: [
                                                          Text(
                                                            "Course title: ",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            question_paper_data[
                                                                        index
                                                                            .toString()]
                                                                    [
                                                                    'course_title']
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          )
                                                        ])),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Row(children: [
                                                          Text(
                                                            "Total mark: ",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            question_paper_data[
                                                                        index
                                                                            .toString()]
                                                                    [
                                                                    'assessment_detail_weightage']
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          )
                                                        ]))
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Start time: ",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            question_paper_data[
                                                                            index.toString()]
                                                                        [
                                                                        'question_paper_start_date']
                                                                    .toString() +
                                                                " " +
                                                                question_paper_data[
                                                                            index.toString()]
                                                                        [
                                                                        'question_paper_start_time']
                                                                    .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Number of question: ",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            question_paper_data[
                                                                        index
                                                                            .toString()]
                                                                    [
                                                                    'number_of_question']
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 3,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "End time: ",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              question_paper_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_paper_end_date']
                                                                      .toString() +
                                                                  " " +
                                                                  question_paper_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_paper_end_time']
                                                                      .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                          ],
                                                        )),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "Session: ",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              question_paper_data[
                                                                          index
                                                                              .toString()]
                                                                      [
                                                                      'session_name']
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                          ],
                                                        ))
                                                  ],
                                                ),
                                              ],
                                            ))
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        ] else ...[
                          Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "No Assessment",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 25),
                                    )
                                  ])
                            ],
                          )
                        ],
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                  if (current_selection == "History" ||
                      current_selection == "All") ...[
                    Column(
                      children: [
                        Text("History",
                            style: const TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 25,
                                color: Colors.red)),
                        if (past_count != 0) ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: question_paper_data['count'],
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                LecturerAssessmentViewDetail(
                                                    question_paper_data[
                                                            index.toString()]
                                                        ['question_paper_id'],
                                                    'view',
                                                    question_paper_data[
                                                            index.toString()][
                                                        'assessment_detail_id'])))
                                    .then((value) {
                                  setState(() {
                                    isLoading = true;
                                    load_user_data();
                                    time_list = [];
                                  });
                                }),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Column(
                                    children: [
                                      if (question_paper_data[index.toString()]
                                                  ['day']
                                              .toString() ==
                                          "past") ...[
                                        Card(
                                            color: Colors.red,
                                            elevation: 4.0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Assessment Title: ",
                                                      style: const TextStyle(
                                                          fontFamily: 'Arial',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 25),
                                                    ),
                                                    Text(
                                                      question_paper_data[index
                                                                  .toString()][
                                                              'assessment_detail_title']
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
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Course Code: ",
                                                      style: const TextStyle(
                                                          fontFamily: 'Arial',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    ),
                                                    Text(
                                                      question_paper_data[index
                                                                  .toString()]
                                                              ['course_code']
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontFamily: 'Arial',
                                                          fontSize: 15),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 3,
                                                        child: Row(children: [
                                                          Text(
                                                            "Course title: ",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            question_paper_data[
                                                                        index
                                                                            .toString()]
                                                                    [
                                                                    'course_title']
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          )
                                                        ])),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Row(children: [
                                                          Text(
                                                            "Total mark: ",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            question_paper_data[
                                                                        index
                                                                            .toString()]
                                                                    [
                                                                    'assessment_detail_weightage']
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          )
                                                        ]))
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Start time: ",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            question_paper_data[
                                                                            index.toString()]
                                                                        [
                                                                        'question_paper_start_date']
                                                                    .toString() +
                                                                " " +
                                                                question_paper_data[
                                                                            index.toString()]
                                                                        [
                                                                        'question_paper_start_time']
                                                                    .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Number of question: ",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            question_paper_data[
                                                                        index
                                                                            .toString()]
                                                                    [
                                                                    'number_of_question']
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 3,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "End time: ",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              question_paper_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_paper_end_date']
                                                                      .toString() +
                                                                  " " +
                                                                  question_paper_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_paper_end_time']
                                                                      .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                          ],
                                                        )),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "Session: ",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              question_paper_data[
                                                                          index
                                                                              .toString()]
                                                                      [
                                                                      'session_name']
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                          ],
                                                        ))
                                                  ],
                                                ),
                                              ],
                                            ))
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        ] else ...[
                          Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "No Assessment",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 25),
                                    )
                                  ])
                            ],
                          )
                        ],
                      ],
                    )
                  ],
                ],
              ),
            )),
          ],
        ),
      );
    }
  }
}
