// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:mobile_assessment/Screen/login_user_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loading_page.dart';
import '../regex.dart';

class StudentProfileChangePassword extends StatefulWidget {
  @override
  var user_id;
  StudentProfileChangePassword(this.user_id);
  _StudentProfileChangePasswordState createState() =>
      _StudentProfileChangePasswordState();
}

class _StudentProfileChangePasswordState
    extends State<StudentProfileChangePassword> {
  String name = "";
  var profile_data, image_data;
  var isLoading = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController password = new TextEditingController();
  var notVisible;

  bool isUpdating = false;
  @override
  void initState() {
    load_user_data();
    isUpdating = false;
    notVisible = true;
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
    isLoading = false;

    if (user != null && user != "") {
      setState(() {
        name = user['username'];
      });
      var data = {
        'user_id': user["user_id"],
      };
      var res = await Api().postData(data, "getStudentProfileData");
      var body = json.decode(res.body);
      if (body['success'] != null) {
        isLoading = false;

        profile_data = body['student_data'];
        print(profile_data);
      } else {
        error_alert().alert(context, "Error", body.toString());

        isLoading = false;

        print(body);
      }
    }
  }

  update_profile() async {
    var data = {
      'user_id': profile_data[0]['user_id'],
      'password': password.text,
    };
    var res = await Api().postData(data, "updateStudentPassword");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      print(body);
      return body['success'];
    } else {
      print("Fail" + body);
    }
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
            title: Text("Profile Edit"),
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
          title: Text('Profile Edit'),
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10, 0, 10, 0),
                                            child: Text(
                                              "Password:",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 20, 0),
                                            child: Container(
                                              width: 240,
                                              child: TextFormField(
                                                controller: password,
                                                keyboardType:
                                                    TextInputType.text,
                                                obscureText: notVisible,
                                                validator: (passwordValue) {
                                                  if (passwordValue!.isEmpty) {
                                                    return 'Please enter password';
                                                  } else if (passwordValue
                                                          .length <
                                                      6) {
                                                    return 'Password length need to be more than 5';
                                                  }
                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      notVisible
                                                          ? Icons.visibility
                                                          : Icons
                                                              .visibility_off,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        notVisible =
                                                            !notVisible;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: FlatButton(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 8,
                                                bottom: 8,
                                                left: 10,
                                                right: 10),
                                            child: Text(
                                              isUpdating
                                                  ? 'Proccessing...'
                                                  : 'Update',
                                              textDirection: TextDirection.ltr,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          color: Colors.teal,
                                          disabledColor: Colors.grey,
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      20.0)),
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if (isUpdating == false) {
                                                setState(() {
                                                  isUpdating = true;
                                                });
                                                update_profile().then((value) {
                                                  print(value);
                                                  if (value) {
                                                    Navigator.of(context).pop();
                                                  }
                                                });
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
