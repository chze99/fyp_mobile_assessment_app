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

class LecturerProfileEdit extends StatefulWidget {
  @override
  var user_id;
  LecturerProfileEdit(this.user_id);
  _LecturerProfileEditState createState() => _LecturerProfileEditState();
}

class _LecturerProfileEditState extends State<LecturerProfileEdit> {
  String name = "";
  var profile_data, image_data;
  var isLoading = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = new TextEditingController();
  var notVisible;
  bool isSubmitting = false;
  TextEditingController contactnumber = new TextEditingController();
  TextEditingController realname = new TextEditingController();
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
      var res = await Api().postData(data, "getLecturerProfileData");
      var body = json.decode(res.body);
      if (body['success'] != null) {
        isLoading = false;

        profile_data = body['lecturer_data'];
        print(profile_data);
        email.text = profile_data[0]['lecturer_email'];
        contactnumber.text = profile_data[0]['lecturer_contact_number'];
        realname.text = profile_data[0]['lecturer_name'];
      } else {
        isLoading = false;
        error_alert().alert(context, "Error", body.toString());

        print(body);
      }
    }
  }

  update_profile() async {
    var data = {
      'user_id': profile_data[0]['user_id'],
      'usertype': profile_data[0]['usertype'],
      'username': profile_data[0]['username'],
      'lecturer_name': realname.text,
      'lecturer_email': email.text,
      'lecturer_contact_number': contactnumber.text,
      'lecturer_privilege': profile_data[0]['lecturer_privilege'],
    };
    var res = await Api().postData(data, "updateLecturerProfileData");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      print(body);
      return body['success'];
    } else {
      error_alert().alert(context, "Error", body.toString());

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
                                              "Real Name:",
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
                                                controller: realname,
                                                keyboardType:
                                                    TextInputType.text,
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r'^[a-zA-Z ]+$')),
                                                ],
                                                validator: (nameValue) {
                                                  if (nameValue!.isEmpty) {
                                                    return 'Please enter your name';
                                                  } else if (regex()
                                                          .isCharacterOnly(
                                                              nameValue) ==
                                                      false) {
                                                    return "Only accept character";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                                              "Email:",
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
                                                controller: email,
                                                keyboardType:
                                                    TextInputType.text,
                                                validator: (emailValue) {
                                                  if (emailValue!.isEmpty) {
                                                    return 'Please enter email';
                                                  } else if (regex()
                                                          .isEmailValid(
                                                              emailValue) ==
                                                      false) {
                                                    return 'Wrong email format';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                                              "Phone number:",
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
                                                controller: contactnumber,
                                                keyboardType:
                                                    TextInputType.text,
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                          RegExp(r'^[0-9]+$')),
                                                ],
                                                validator:
                                                    (contactnumberValue) {
                                                  if (contactnumberValue!
                                                      .isEmpty) {
                                                    return 'Please enter Phone number';
                                                  }

                                                  return null;
                                                },
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
                                              isSubmitting
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
                                              if (isSubmitting == false) {
                                                setState(() {
                                                  isSubmitting = true;
                                                });
                                                setState(() {
                                                  update_profile()
                                                      .then((value) {
                                                    print(value);
                                                    if (value) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  });
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
