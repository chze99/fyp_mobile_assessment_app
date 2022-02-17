// ignore_for_file: non_constant_identifier_names, must_call_super, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Student/student_home.dart';
import 'package:mobile_assessment/Screen/login_user_selection.dart';
import 'package:mobile_assessment/Screen/regex.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //initialize vartiable
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var user_type;
  var username;
  var name;
  var password;
  var email;
  var icatsID;
  var iuklID;
  var contactnumber;
  var facepicture;
  var idpic;
  var notVisible;
  var usernameExist;
  var emailExist;
  bool isProfilePicEmpty = false, isIdPicEmpty = false;
  DateTime lastlogin = DateTime.now();
  //For upload image
  File? profile_image, id_image;
  final picker = ImagePicker();
  Future uploadImage(String type) async {
    var uploadedProfileImage =
        await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (uploadedProfileImage != null) {
        if (type == "Face") {
          profile_image = File(uploadedProfileImage.path);
        } else if (type == "Id") {
          id_image = File(uploadedProfileImage.path);
        }
      }
    });
  }

  //check if email is in valid format
  bool isEmailValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  //check if username is in valid format
  bool isUserNameValid(String text) {
    return RegExp(r"^(?=[a-zA-Z0-9._ ]{0,20}$)(?!.*[_.]{2})[^_.].*[^_.]$")
        .hasMatch(text);
  }

  bool isCharacterOnly(String text) {
    return RegExp(r'^[a-zA-Z ]+$').hasMatch(text);
  }

  bool isNumberOnly(String text) {
    return RegExp(r'^[0-9]+$').hasMatch(text);
  }

  //initilize screen with default password field not visible
  @override
  void initState() {
    notVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.orange,
        child: Stack(
          children: <Widget>[
            Positioned(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                      child: Text(
                        'Student Registration',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Card(
                              color: Colors.grey[300],
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
                                              "Username:",
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
                                                keyboardType:
                                                    TextInputType.text,
                                                validator: (usernameValue) {
                                                  if (usernameValue!.isEmpty) {
                                                    return 'Please enter username';
                                                  } else if (regex()
                                                          .isUserNameValid(
                                                              usernameValue) ==
                                                      false) {
                                                    return "only character and numeric is allowed";
                                                  } else if (usernameValue
                                                          .length <
                                                      7) {
                                                    return "Mininum length of username is 6";
                                                  } else if (usernameExist ==
                                                      true) {
                                                    usernameExist = false;
                                                    return "Username is exist";
                                                  }
                                                  username = usernameValue;
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
                                                  name = nameValue;
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
                                                  password = passwordValue;
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
                                              "Reconfirm Password:",
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
                                                keyboardType:
                                                    TextInputType.text,
                                                obscureText: notVisible,
                                                validator: (RepasswordValue) {
                                                  if (RepasswordValue!
                                                      .isEmpty) {
                                                    return 'Please reconfirm password';
                                                  } else if (RepasswordValue !=
                                                      password) {
                                                    return 'Password does not match';
                                                  } else if (RepasswordValue
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
                                                  } else if (emailExist ==
                                                      true) {
                                                    emailExist = false;
                                                    return "Email is exist";
                                                  }
                                                  email = emailValue;
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
                                              "Student ID(i-CATS UC):",
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 20, 0),
                                            child: Container(
                                              width: 240,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.text,
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                          RegExp(r'^[0-9]+$')),
                                                ],
                                                validator: (icatsIDValue) {
                                                  if (icatsIDValue!.isEmpty) {
                                                    return 'Please enter Student ID';
                                                  } else if (regex()
                                                          .isNumberOnly(
                                                              icatsIDValue) ==
                                                      false) {
                                                    return "Only accept number";
                                                  }
                                                  icatsID = icatsIDValue;
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
                                                0, 0, 10, 0),
                                            child: Text(
                                              "Student ID(IUKL):",
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
                                                keyboardType:
                                                    TextInputType.text,
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                          RegExp(r'^[0-9]+$')),
                                                ],
                                                validator: (iuklIDValue) {
                                                  if (iuklIDValue!.isEmpty) {
                                                    return 'Please enter Student ID';
                                                  } else if (regex()
                                                          .isNumberOnly(
                                                              iuklIDValue) ==
                                                      false) {
                                                    return "Only accept number";
                                                  }
                                                  iuklID = iuklIDValue;
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
                                                  contactnumber =
                                                      contactnumberValue;
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
                                                10, 0, 15, 0),
                                            child: Text(
                                              "Face Picture:",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          if (profile_image == null) ...[
                                            Container(
                                                width: 115,
                                                child: Text('No image')),
                                          ] else ...[
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  5, 10, 10, 0),
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                child:
                                                    Image.file(profile_image!),
                                              ),
                                            ),
                                          ],
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10, 0, 30, 0),
                                            child: Container(
                                              width: 100,
                                              child: ElevatedButton(
                                                child: Text("Upload"),
                                                onPressed: () {
                                                  uploadImage("Face");
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isProfilePicEmpty == true) ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 5, 15, 0),
                                              child: Container(
                                                  width: 240,
                                                  child: Text(
                                                      "Please select a face picture",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red))),
                                            ),
                                          ],
                                        ),
                                      ],
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10, 0, 15, 0),
                                            child: Text(
                                              "Student ID Picture:",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          if (id_image == null) ...[
                                            Container(
                                                width: 115,
                                                child: Text('No image')),
                                          ] else ...[
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  5, 20, 10, 0),
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                child: Image.file(id_image!),
                                              ),
                                            ),
                                          ],
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10, 0, 30, 0),
                                            child: Container(
                                              width: 100,
                                              child: ElevatedButton(
                                                child: Text("Upload"),
                                                onPressed: () {
                                                  uploadImage("Id");
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isIdPicEmpty == true) ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 5, 15, 0),
                                              child: Container(
                                                  width: 240,
                                                  child: Text(
                                                      "Please select a student ID picture",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red))),
                                            ),
                                          ],
                                        ),
                                      ],
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
                                              _isLoading
                                                  ? 'Proccessing...'
                                                  : 'Register',
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
                                              print(profile_image);
                                              if (profile_image != null &&
                                                  id_image != null) {
                                                setState(() {
                                                  isProfilePicEmpty = false;
                                                  isIdPicEmpty = false;
                                                });
                                                _register();
                                              }
                                            }
                                            if (profile_image == null) {
                                              setState(() {
                                                isProfilePicEmpty = true;
                                              });
                                            }
                                            if (id_image == null) {
                                              setState(() {
                                                isIdPicEmpty = true;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginUserSelection(
                                                            "")));
                                          },
                                          child: Text(
                                            'Already Have an Account',
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
            )
          ],
        ),
      ),
    );
  }

  void _register() async {
    setState(() {
      _isLoading = true;
    });
    var upload_image_res = await Api()
        .uploadImageToServer(profile_image, id_image, 'upload_image');
    var image_body = json.decode(upload_image_res);
    if (image_body['success']) {
      var data = {
        'usertype': "Student",
        'username': username,
        'password': password,
        'student_name': name,
        'student_email': email,
        'icats_id': icatsID,
        'iukl_id': iuklID,
        'student_account_status': "Pending",
        'student_contact_number': contactnumber,
        'student_face_picture': image_body['profile_path'],
        'student_id_picture': image_body['id_path'],
        'lastlogin': lastlogin.toString(),
      };
      var res = await Api().authData(data, 'register_student');
      var body = json.decode(res.body);
      if (body['success']) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (context) =>
                    LoginUserSelection("Please wait for admin approvement")),
            (route) => false);
      } else {
        if (body['message'] == "Username is exist") {
          setState(() {
            usernameExist = true;
            _formKey.currentState!.validate();
            print("test");
          });
        } else if (body['message'] == "Email is used") {
          setState(() {
            emailExist = true;
            _formKey.currentState!.validate();
            print("test");
          });
        }
      }
    } else {
      print(image_body);
    }
    setState(() {
      _isLoading = false;
    });
  }
}
