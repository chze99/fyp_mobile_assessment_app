// ignore_for_file: non_constant_identifier_names, import_of_legacy_library_into_null_safe, must_be_immutable, override_on_non_overriding_member, empty_statements

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/dialog_template.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';
import 'package:toast/toast.dart';

class StudentTakeAssessmentPractical extends StatefulWidget {
  @override
  int solution_questionpaper_id = 0;
  String mode = "";
  int solution_paperdetail_id = 0;
  int question_number = 0;
  StudentTakeAssessmentPractical(this.solution_questionpaper_id, this.mode,
      this.solution_paperdetail_id, this.question_number);

  _StudentTakeAssessmentPracticalState createState() =>
      _StudentTakeAssessmentPracticalState();
}

class _StudentTakeAssessmentPracticalState
    extends State<StudentTakeAssessmentPractical> {
  Dio dio = Dio();
  bool isSubmitting = false;
  bool isLoading = true;
  bool sending = false;
  bool data_found = false;
  var answer_data;
  var question_detail_data;
  var practical_retrived_data;
  String attachment = "none";
  String student_attachment = "none";
  TextEditingController practical_answer = TextEditingController();
  var sectionValue;
  List<DropdownMenuItem<int>> section_list_items = [];
  var section_data;
  final form_key = GlobalKey<FormState>();
  PlatformFile? practical_file;
  PlatformFile? student_practical_file;
  bool success = false;
  bool haveAttachment = false;
  var attachment_path;
  bool downloading = false;

  String progress = '0';
  String progress_student = '0';
  bool isDownloaded_student = true;
  bool downloading_student = false;
  bool isDownloaded = false;
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

  pick_file() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(withData: true);
    if (result != null) {
      setState(() {
        student_practical_file = result.files.first;
        student_attachment = student_practical_file!.name;
      });
    }
  }

  get_practical() async {
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
    };
    var res = await Api().postData(data, "getPracticalQuestionStudent");
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
              practical_answer.text = answer_data['practical_answer'];
              if (answer_data['practical_attachment'] != null) {
                student_attachment = answer_data['practical_attachment'];
                student_attachment = student_attachment.replaceAll(
                    'student_practical_answer_attachment/', '');
              }
            }

            print(practical_retrived_data);
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

  downloadStudentAttachment() async {
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

  save_file() async {
    var upload_file_res = await Api().uploadStudentPracticalAnswerFileToServer(
        student_practical_file,
        widget.solution_paperdetail_id,
        'upload_student_practical_answer_file');
    var body = json.decode(upload_file_res);
    if (body['success'] == true) {
      if (this.mounted) {
        setState(() {
          attachment_path = body['practical_answer_attachment_path'];
        });
        return body['success'];
      }
    } else {
      print(body);
    }
  }

  submit_practical() async {
    var data;
    if (haveAttachment == true) {
      data = {
        'solution_paperdetail_id': widget.solution_paperdetail_id,
        'practical_answer': practical_answer.text,
        'practical_attachment': attachment_path,
      };
    } else {
      data = {
        'solution_paperdetail_id': widget.solution_paperdetail_id,
        'practical_answer': practical_answer.text,
      };
    }
    var res = await Api().postData(data, "submitPracticalAnswerStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body['success'];
      }
    } else {
      print("Save practical error" + body.toString());
    }
  }

  update_practical() async {
    var data = {
      'practical_solution_id': answer_data['practical_solution_id'],
      'practical_answer': practical_answer.text,
    };

    var res = await Api().postData(data, "updatePracticalAnswerStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body['success'];
      }
    } else {
      print("Update practical error" + body.toString());
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
                    child: Form(
                        key: form_key,
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
                                              flex: 3,
                                              child: Text(
                                                "Question Description",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              )),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                                "Section " +
                                                    question_detail_data[
                                                            'section_number']
                                                        .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                                "(" +
                                                    question_detail_data[
                                                            'raw_mark']
                                                        .toString() +
                                                    " marks)",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                          )
                                        ]),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(children: [
                                          Expanded(
                                              flex: 1,
                                              child: Text(practical_retrived_data[
                                                      'practical_question_desc']
                                                  .toString())),
                                        ]),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        if (practical_retrived_data[
                                                    'practical_attachment'] !=
                                                null &&
                                            practical_retrived_data[
                                                    'practical_attachment'] !=
                                                'none') ...[
                                          Row(children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text("Attachment:",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(attachment),
                                            ),
                                          ]),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 1, child: Text("")),
                                              Expanded(
                                                flex: 2,
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      downloadAttachment();
                                                    },
                                                    child: Text(
                                                      downloading
                                                          ? 'Downloading...'
                                                          : "Download question attachment",
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ],
                                        Row(children: [
                                          Text("Answer",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold))
                                        ]),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.multiline,
                                                controller: practical_answer,
                                                maxLines: null,
                                                validator: (questiondescValue) {
                                                  if (questiondescValue!
                                                      .isEmpty) {
                                                    return 'Please enter answer';
                                                  }
                                                  practical_answer.text =
                                                      questiondescValue;
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (widget.mode == 'edit') ...[
                                          if (answer_data[
                                                      'practical_attachment'] !=
                                                  null &&
                                              answer_data[
                                                      'practical_attachment'] !=
                                                  'none') ...[
                                            Row(
                                              children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: Text("Attachment")),
                                                Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                        student_attachment))
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                    flex: 1, child: Text("")),
                                                Expanded(
                                                  flex: 2,
                                                  child: ElevatedButton(
                                                      onPressed: () {
                                                        downloadStudentAttachment();
                                                      },
                                                      child: Text(
                                                        downloading_student
                                                            ? 'Downloading...'
                                                            : "Download student attachment",
                                                      )),
                                                ),
                                              ],
                                            )
                                          ]
                                        ],
                                        if (widget.mode == 'take') ...[
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 1,
                                                  child: Text("Attachment")),
                                              Expanded(
                                                  flex: 1,
                                                  child:
                                                      Text(student_attachment))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 1, child: Text("")),
                                              Expanded(
                                                flex: 2,
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      pick_file();
                                                    },
                                                    child: Text('Upload file')),
                                              ),
                                            ],
                                          ),
                                        ]
                                      ],
                                    ))),
                            Column(
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 5),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (form_key.currentState!
                                              .validate()) {
                                            if (isSubmitting == false) {
                                              setState(() {
                                                isSubmitting = true;
                                              });

                                              if (widget.mode == "take") {
                                                if (student_practical_file !=
                                                    null) {
                                                  haveAttachment = true;
                                                  setState(() {
                                                    sending = true;
                                                  });
                                                  dialog_template()
                                                      .confirmation_dialog(
                                                          context,
                                                          "No",
                                                          "Yes",
                                                          "Publish confirmation",
                                                          "Did you sure that you want to submit practical? The uploaded attachment cannot be change.",
                                                          () => null,
                                                          () => save_file()
                                                                  .then(
                                                                      (value) {
                                                                if (value ==
                                                                    true) {
                                                                  submit_practical()
                                                                      .then(
                                                                          (value) {
                                                                    if (value) {
                                                                      Toast.show(
                                                                          "Saved",
                                                                          context);
                                                                      Navigator.pop(
                                                                          context);
                                                                    }
                                                                  });
                                                                }
                                                              }));
                                                } else {
                                                  submit_practical()
                                                      .then((value) {
                                                    if (value) {
                                                      Toast.show(
                                                          "Saved", context);
                                                      Navigator.pop(context);
                                                    }
                                                  });
                                                }
                                              } else if (widget.mode ==
                                                  "edit") {
                                                update_practical()
                                                    .then((value) {
                                                  if (value) {
                                                    Toast.show(
                                                        "Update", context);
                                                    Navigator.pop(context);
                                                  }
                                                });
                                              }
                                            }
                                          }
                                        },
                                        child: Text(isSubmitting
                                            ? "Submitting..."
                                            : "Submit"),
                                      )
                                    ]),
                              ],
                            ),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}
