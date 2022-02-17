// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Student/StudentProfileChangePassword.dart';
import 'package:mobile_assessment/Screen/Student/StudentProfileEdit.dart';

import 'package:mobile_assessment/Screen/login_user_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loading_page.dart';

class LecturerApplicationSetting extends StatefulWidget {
  @override
  int user_id = 0;
  LecturerApplicationSetting(this.user_id);
  _LecturerApplicationSettingState createState() =>
      _LecturerApplicationSettingState();
}

enum assessment_filter { all, ongoing, history, soon }

class _LecturerApplicationSettingState
    extends State<LecturerApplicationSetting> {
  String name = "";
  var profile_data, image_data;
  var isLoading = true;
  bool isSubmitting = false;
  var users;
  assessment_filter assessment_filter_option = assessment_filter.all;
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
    if (local_storage.getString('default_assessment_filter') != null) {
      if (local_storage.getString('default_assessment_filter').toString() ==
          'All') {
        assessment_filter_option = assessment_filter.all;
      } else if (local_storage
              .getString('default_assessment_filter')
              .toString() ==
          'Ongoing') {
        assessment_filter_option = assessment_filter.ongoing;
      } else if (local_storage
              .getString('default_assessment_filter')
              .toString() ==
          'History') {
        assessment_filter_option = assessment_filter.history;
      } else if (local_storage
              .getString('default_assessment_filter')
              .toString() ==
          'Soon') {
        assessment_filter_option = assessment_filter.soon;
      }
    }
    if (user != null && user != "") {
      setState(() {
        users = user;
        name = user['username'];
        isLoading = false;
      });
    }
  }

  save() async {
    SharedPreferences local_storage = await SharedPreferences.getInstance();
    if (assessment_filter_option == assessment_filter.all) {
      local_storage.setString('default_assessment_filter', "All");
    } else if (assessment_filter_option == assessment_filter.history) {
      local_storage.setString('default_assessment_filter', "History");
    } else if (assessment_filter_option == assessment_filter.ongoing) {
      local_storage.setString('default_assessment_filter', "Ongoing");
    } else if (assessment_filter_option == assessment_filter.soon) {
      local_storage.setString('default_assessment_filter', "Soon");
    }
    print(local_storage.getString('default_assessment_filter').toString());
  }

  @override
  Widget build(BuildContext context) {
    print(isLoading);
    print(image_data);
    if (isLoading) {
      return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Application Setting"),
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
          title: Text('Application Setting'),
          backgroundColor: Colors.orange,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                            child: Card(
                          child: InkWell(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                              "Assessment default filter")),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<assessment_filter>(
                                        value: assessment_filter.all,
                                        groupValue: assessment_filter_option,
                                        onChanged: (assessment_filter? value) {
                                          setState(() {
                                            assessment_filter_option = value!;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text("All"),
                                      ),
                                      Radio<assessment_filter>(
                                        value: assessment_filter.history,
                                        groupValue: assessment_filter_option,
                                        onChanged: (assessment_filter? value) {
                                          setState(() {
                                            assessment_filter_option = value!;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text("History"),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<assessment_filter>(
                                        value: assessment_filter.ongoing,
                                        groupValue: assessment_filter_option,
                                        onChanged: (assessment_filter? value) {
                                          setState(() {
                                            assessment_filter_option = value!;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text("Ongoing"),
                                      ),
                                      Radio<assessment_filter>(
                                        value: assessment_filter.soon,
                                        groupValue: assessment_filter_option,
                                        onChanged: (assessment_filter? value) {
                                          setState(() {
                                            assessment_filter_option = value!;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text("Soon"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              save();
                            },
                            child: Text("Save"))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
