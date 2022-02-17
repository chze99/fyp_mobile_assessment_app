// ignore_for_file: non_constant_identifier_names, override_on_non_overriding_member, deprecated_member_use, must_call_super

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/login_user_selection.dart';
import 'package:mobile_assessment/Screen/Student/student_home.dart';
import 'package:mobile_assessment/Screen/Lecturer/lecturer_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_assessment/Screen/register.dart';

class Login extends StatefulWidget {
  @override
  final String usertype;
  const Login(this.usertype);
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  bool isLoading = false;
  final form_key = GlobalKey<FormState>();
  var username;
  var password;
  var notVisible;
  var usertype;
  bool isSubmitting = false;
  final scaffold_key = GlobalKey<ScaffoldState>();
  showMsg(msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {},
      ),
    );
    scaffold_key.currentState!.showSnackBar(snackBar);
  }

  void initState() {
    usertype = widget.usertype;
    notVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffold_key,
      body: Container(
        width: double.infinity,
        color: Colors.orange,
        child: Stack(
          children: <Widget>[
            Positioned(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Card(
                      elevation: 4.0,
                      color: Colors.white,
                      child: Form(
                        key: form_key,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (usertype == "Student") ...[
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 20, 10, 30),
                                child: Text(
                                  'Student Login',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ] else if (usertype == "Lecturer") ...[
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 20, 10, 30),
                                child: Text(
                                  'Lecturer Login',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: Text(
                                    "Username:",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  width: 150,
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    validator: (usernameValue) {
                                      if (usernameValue!.isEmpty) {
                                        return 'Please enter name';
                                      }
                                      username = usernameValue;
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: Text(
                                    "Password:",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  width: 150,
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    obscureText: notVisible,
                                    validator: (passwordValue) {
                                      if (passwordValue!.isEmpty) {
                                        return 'Please enter password';
                                      }
                                      password = passwordValue;
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          notVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            notVisible = !notVisible;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              child: Text(
                                isSubmitting ? 'Proccessing...' : 'Login',
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              onPressed: () {
                                if (form_key.currentState!.validate()) {
                                  if (isSubmitting == false) {
                                    setState(() {
                                      _login();
                                      isSubmitting = true;
                                    });
                                  }
                                }
                              },
                            ),
                            if (usertype == "Student") ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) => Register()));
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.red),
                                  ),
                                  child: Text(
                                    'Register account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    setState(() {
      isLoading = true;
    });
    var data = {
      'usertype': widget.usertype,
      'username': username,
      'password': password
    };

    var res = await Api().authData(data, 'login');
    var body = json.decode(res.body);
    if (body['success']) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', json.encode(body['token']));
      localStorage.setString('user', json.encode(body['user']));
      var usertype_logged_temp = body['user'];
      var usertype_logged = usertype_logged_temp['usertype'];
      print(usertype_logged_temp.toString());
      if (usertype_logged == "Student") {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(builder: (context) => StudentHome()),
            (Route<dynamic> route) => false);
      } else if (usertype_logged == "Lecturer") {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(builder: (context) => LecturerHome()),
            (Route<dynamic> route) => false);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(builder: (context) => LoginUserSelection("")),
            (Route<dynamic> route) => false);
      }
    } else {
      isSubmitting = false;
      showMsg(body['message']);
    }

    setState(() {
      isLoading = false;
    });
  }
}
