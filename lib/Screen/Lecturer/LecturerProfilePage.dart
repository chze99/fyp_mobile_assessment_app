// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerApplicationSetting.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerProfileChangePassword.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerProfileEdit.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:mobile_assessment/Screen/login_user_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loading_page.dart';

class LecturerProfilePage extends StatefulWidget {
  @override
  _LecturerProfilePageState createState() => _LecturerProfilePageState();
}

class _LecturerProfilePageState extends State<LecturerProfilePage> {
  String name = "";
  var profile_data, image_data;
  var isLoading = true;
  var users;
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
      setState(() {
        users = user;
        name = user['username'];
      });
      var data = {
        'user_id': user["user_id"],
      };
      var res = await Api().postData(data, "getLecturerProfileData");
      var body = json.decode(res.body);
      if (body['success'] != null) {
        profile_data = body['lecturer_data'];
      } else {
        print(body);
      }
      var imagedata = {
        'profile': profile_data[0]['lecturer_face_picture'],
      };
      var res_image = await Api().postData(imagedata, "getLecturerImage");
      var image_body = json.decode(res_image.body);
      if (body['success']) {
        setState(() {
          profile_data = body['lecturer_data'];
          image_data = image_body;
          isLoading = false;
        });
      }
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
            title: Text("Profile"),
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
          title: Text('Profile'),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image(
                            image: NetworkImage("http://192.168.0.15:80" +
                                image_data['profile_image']),
                            width: 150,
                            height: 150),
                        SizedBox(width: 50),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              profile_data[0]['lecturer_name'],
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              profile_data[0]['lecturer_id'].toString(),
                              style: TextStyle(fontSize: 20),
                            )
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Card(
                          child: InkWell(
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                child: Text(
                                  "Profile Setting",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                )),
                            onTap: () {
                              setState(() {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LecturerProfileEdit(
                                                    users['user_id'])))
                                    .then((value) {
                                  setState(() {
                                    isLoading = true;
                                    load_user_data();
                                  });
                                });
                              });
                            },
                          ),
                        ))
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Card(
                          child: InkWell(
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                child: Text(
                                  "Change Password",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                )),
                            onTap: () {
                              setState(() {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LecturerProfileChangePassword(
                                                    users['user_id'])))
                                    .then((value) {
                                  setState(() {
                                    isLoading = true;
                                    load_user_data();
                                  });
                                });
                              });
                            },
                          ),
                        ))
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Card(
                          child: InkWell(
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                child: Text(
                                  "Application Setting",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                )),
                            onTap: () {
                              setState(() {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LecturerApplicationSetting(
                                                    users['user_id'])))
                                    .then((value) {
                                  setState(() {
                                    isLoading = true;
                                    load_user_data();
                                  });
                                });
                              });
                            },
                          ),
                        ))
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Card(
                          child: InkWell(
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: Text(
                                  "Logout",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                )),
                            onTap: () {
                              logout();
                            },
                          ),
                        ))
                      ],
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

  void logout() async {
    var res = await Api().getData('logout');
    var body = json.decode(res.body);
    print(body);
    if (body['success'] != null) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('user');
      localStorage.remove('token');
      FirebaseMessaging.instance.deleteToken();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginUserSelection("")),
          (Route<dynamic> route) => false);
    } else {
      error_alert().alert(context, "Error", body.toString());

      print(body);
    }
  }
}
