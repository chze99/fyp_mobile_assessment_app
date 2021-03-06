// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:toast/toast.dart';

class StudentViewSubmissionPractical extends StatefulWidget {
  @override
  int solution_questionpaper_id = 0;
  int solution_paperdetail_id = 0;
  int question_number = 0;
  StudentViewSubmissionPractical(this.solution_questionpaper_id,
      this.solution_paperdetail_id, this.question_number);

  _StudentViewSubmissionPracticalState createState() =>
      _StudentViewSubmissionPracticalState();
}

class _StudentViewSubmissionPracticalState
    extends State<StudentViewSubmissionPractical> {
  Dio dio = Dio();

  bool isLoading = true;
  var practical_retrived_data;
  var question_detail_data;
  var answer_data;
  var practical_answer;
  var student_attachment;
  var attachment;
  List<String> subpractical_answer = [];
  bool downloading = false;
  String progress_student = '0';
  bool isDownloaded_student = false;
  bool downloading_student = false;
  String progress = '0';
  bool isDownloaded = false;
  bool success = false;
  @override
  void initState() {
    get_practical();

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  //code for download attachment
  downloadAttachment() async {
    var data = {
      "practical_attachment": practical_retrived_data['practical_attachment']
    };
    final res = await Api().postData(data, "getLecturerPracticalAttachment");
    var body = json.decode(res.body);
    Directory dir = Directory('/storage/emulated/0/Download');

    var downloaded_file = await dio.get(
      "http://192.168.0.15:80" + body['data'].toString(),
      onReceiveProgress: (received, total) {
        setState(() {
          progress = ((received / total) * 100).toStringAsFixed(0);
          print(progress);
        });

        if (progress == '100') {
          setState(() {
            isDownloaded = true;
            downloading = false;
            Toast.show(
                "File saved to" + dir.toString() + "/" + attachment.toString(),
                context,
                duration: Toast.LENGTH_LONG,
                gravity: Toast.BOTTOM);
          });
        } else if (double.parse(progress) < 100) {
          downloading = true;
        }
      },
      options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          }),
    );
    File file = File(dir.path + "/" + attachment);
    var raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(downloaded_file.data);
    await raf.close();
  }

  downloadAttachment_student() async {
    var data = {"practical_attachment": answer_data['practical_attachment']};
    final res = await Api().postData(data, "getLecturerPracticalAttachment");
    var body = json.decode(res.body);
    Directory dir = Directory('/storage/emulated/0/Download');

    var downloaded_file = await dio.get(
      "http://192.168.0.15:80" + body['data'].toString(),
      onReceiveProgress: (received, total) {
        setState(() {
          progress_student = ((received / total) * 100).toStringAsFixed(0);
        });

        if (progress_student == '100') {
          setState(() {
            isDownloaded_student = true;
            downloading_student = false;
            Toast.show(
                "File saved to" +
                    dir.toString() +
                    "/" +
                    student_attachment.toString(),
                context,
                duration: Toast.LENGTH_LONG,
                gravity: Toast.BOTTOM);
          });
        } else if (double.parse(progress) < 100) {
          downloading_student = true;
        }
      },
      options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          }),
    );
    File file = File(dir.path + "/" + student_attachment);
    var raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(downloaded_file.data);
    await raf.close();
  }

  get_practical() async {
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
    };
    var res = await Api().postData(data, "getPracticalSubmissionStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No Practical found") {
        if (this.mounted) {
          setState(() {
            practical_retrived_data = body['q'];
            question_detail_data = body['qd'];
            answer_data = body['sqa'];

            if (practical_retrived_data['practical_attachment'] != null) {
              attachment = practical_retrived_data['practical_attachment'];
              attachment = attachment.replaceAll('practical_attachments/', '');
            }
            if (answer_data != "No answer") {
              practical_answer = answer_data['practical_answer'];
              if (answer_data['practical_attachment'] != null) {
                student_attachment = answer_data['practical_attachment'];
                student_attachment = student_attachment.replaceAll(
                    'student_practical_answer_attachment/', '');
              }
            }

            print(practical_retrived_data);
            print(question_detail_data);
            print(answer_data);
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
      });
      print("Get sa error" + body.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Practical"),
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
      return WillPopScope(
          onWillPop: () {
            Navigator.pop(context);
            return Future.value(false);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text("Question " + widget.question_number.toString()),
              backgroundColor: Colors.orange,
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(
                            flex: 15,
                            child: SingleChildScrollView(
                                physics: ScrollPhysics(),
                                child: Column(
                                  children: [
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text("Section ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          question_detail_data['section_number']
                                              .toString(),
                                        ),
                                      ),
                                    ]),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text("Score:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                      ),
                                      if (question_detail_data['isReviewed'] ==
                                          true) ...[
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            question_detail_data[
                                                        'solution_total_score']
                                                    .toString() +
                                                "/" +
                                                question_detail_data['raw_mark']
                                                    .toString(),
                                          ),
                                        )
                                      ] else ...[
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            "Pending review",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        )
                                      ]
                                    ]),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Card(
                                      child: Column(
                                        children: [
                                          Row(children: [
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "Question:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                )),
                                            Expanded(
                                                flex: 3,
                                                child: Text(practical_retrived_data[
                                                        'practical_question_desc']
                                                    .toString())),
                                          ]),
                                          SizedBox(height: 10),
                                          if (practical_retrived_data[
                                                      'practical_attachment'] !=
                                                  null &&
                                              practical_retrived_data[
                                                      'practical_attachment'] !=
                                                  'none') ...[
                                            Row(children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                    "Question Attachment:",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(attachment),
                                              ),
                                            ]),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                    flex: 2, child: Text("")),
                                                Expanded(
                                                  flex: 3,
                                                  child: ElevatedButton(
                                                      onPressed: () {
                                                        downloadAttachment();
                                                      },
                                                      child: Text(
                                                        downloading
                                                            ? 'Downloading...'
                                                            : "Download",
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ],
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 2,
                                                  child: Text("Your Answer:",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              Expanded(
                                                flex: 3,
                                                child: Text(practical_answer),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          if (answer_data[
                                                      'practical_attachment'] !=
                                                  null &&
                                              answer_data[
                                                      'practical_attachment'] !=
                                                  'none') ...[
                                            Row(children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text("Your Attachment:",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(student_attachment),
                                              ),
                                            ]),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                    flex: 2, child: Text("")),
                                                Expanded(
                                                  flex: 3,
                                                  child: ElevatedButton(
                                                      onPressed: () {
                                                        downloadAttachment_student();
                                                      },
                                                      child: Text(
                                                        downloading_student
                                                            ? 'Downloading...'
                                                            : "Download",
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ]
                                        ],
                                      ),
                                    ),
                                    Card(
                                      child: Column(
                                        children: [
                                          Row(children: [
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "Lecturer Feedback:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                )),
                                            if (question_detail_data[
                                                    'isReviewed'] ==
                                                true) ...[
                                              if (question_detail_data[
                                                          'feedback'] !=
                                                      null &&
                                                  question_detail_data[
                                                          'feedback'] !=
                                                      '') ...[
                                                Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                        question_detail_data[
                                                            'feedback']))
                                              ] else ...[
                                                Expanded(
                                                    flex: 3,
                                                    child: Text("No comment"))
                                              ]
                                            ] else ...[
                                              Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    "Pending review",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ))
                                            ],
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ],
                                ))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}
