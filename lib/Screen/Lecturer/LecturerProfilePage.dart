// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/login_user_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LecturerProfilePage extends StatefulWidget {
  @override
  _LecturerProfilePageState createState() => _LecturerProfilePageState();
}

class _LecturerProfilePageState extends State<LecturerProfilePage> {
  String name = "";
  var profile_data, image_data;
  var isLoading = true;
  @override
  void initState() {
    load_user_data();
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
        ;
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
      return Scaffold(
        body: Container(),
      );
    } else {
      return Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Welcome, $name,you are at profile page',
                    ),
                    Image(
                      image: NetworkImage(
                          "http://10.0.2.2:8000" + image_data['profile_image']),
                    ),
                    ElevatedButton(
                      child: Text("Logout"),
                      onPressed: () {
                        logout();
                      },
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
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginUserSelection()),
          (Route<dynamic> route) => false);
    } else {
      print(body);
    }
  }
}
