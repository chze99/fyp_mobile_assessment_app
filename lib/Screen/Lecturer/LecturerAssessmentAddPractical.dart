// ignore_for_file: non_constant_identifier_names, import_of_legacy_library_into_null_safe, must_be_immutable, override_on_non_overriding_member, empty_statements

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';
import 'package:toast/toast.dart';

class LecturerAssessmentAddPractical extends StatefulWidget {
  @override
  int question_paper_id = 0;
  String mode = "";
  int question_paper_detail_id = 0;
  LecturerAssessmentAddPractical(
      this.question_paper_id, this.mode, this.question_paper_detail_id);

  _LecturerAssessmentAddPracticalState createState() =>
      _LecturerAssessmentAddPracticalState();
}

class _LecturerAssessmentAddPracticalState
    extends State<LecturerAssessmentAddPractical> {
  Dio dio = Dio();
  bool isSubmitting = false;
  bool isLoading = true;
  bool sending = false;
  bool data_found = false;
  var assessment_data;
  var question_data;
  String attachment = "none";
  TextEditingController raw_mark_text = TextEditingController();
  TextEditingController question_description = TextEditingController();
  var sectionValue;
  List<DropdownMenuItem<int>> section_list_items = [];
  var section_data;
  final form_key = GlobalKey<FormState>();
  PlatformFile? practical_file;
  bool success = false;
  bool haveAttachment = false;
  var attachment_path;
  bool downloading = false;

  String progress = '0';

  bool isDownloaded = false;
  @override
  void initState() {
    get_section();
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
        practical_file = result.files.first;
        attachment = practical_file!.name;
      });
    }
  }

  get_section() async {
    var data = {
      'question_paper_id': widget.question_paper_id,
    };
    var res = await Api().postData(data, "getQuestionPaperSection");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        setState(() {
          section_data = body['message'];
          section_list_items = List.generate(
            section_data["count"],
            (i) => DropdownMenuItem(
              value: section_data[i.toString()]['section_id'],
              child: Text("${section_data[i.toString()]['section_number']}"),
            ),
          );
          sectionValue = section_data['0']['section_id'];
          print("Section data:" + body['message'].toString());
          get_practical();
        });
      }
    } else {
      print("Get section error" + body.toString());
    }
  }

  get_practical() async {
    var data = {
      'question_paper_detail_id': widget.question_paper_detail_id,
    };
    var res = await Api().postData(data, "getPracticalQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No Practical found") {
        if (this.mounted) {
          setState(() {
            question_data = body['message'];
            print(question_data);
            question_description.text =
                question_data['practical_question_desc'];
            raw_mark_text.text = question_data['question_detail']['raw_mark'];
            sectionValue = question_data['question_detail']['section_id'];
            if (question_data['practical_attachment'] != null) {
              attachment = question_data['practical_attachment'];
              attachment = attachment.replaceAll('practical_attachments/', '');
            }
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
    var data = {"practical_attachment": question_data['practical_attachment']};
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

  save_file() async {
    var upload_file_res = await Api().uploadFileToServer(practical_file,
        widget.question_paper_id, 'upload_practical_question_file');
    var body = json.decode(upload_file_res);
    if (body['success'] == true) {
      if (this.mounted) {
        setState(() {
          attachment_path = body['practical_attachment_path'];
        });
        return body['success'];
      }
    } else {
      print(body);
    }
  }

  save_practical() async {
    var data;
    if (haveAttachment == true) {
      data = {
        'question_paper_id': widget.question_paper_id,
        'question_type_id': 1,
        'section_id': sectionValue,
        'raw_mark': raw_mark_text.text,
        'practical_question_desc': question_description.text,
        'practical_attachment': attachment_path,
        'have_attachment': "true",
      };
    } else {
      data = {
        'question_paper_id': widget.question_paper_id,
        'question_type_id': 1,
        'section_id': sectionValue,
        'raw_mark': raw_mark_text.text,
        'practical_question_desc': question_description.text,
        'have_attachment': "false",
      };
    }
    var res = await Api().postData(data, "savePracticalQuestion");
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
      'question_paper_id': widget.question_paper_id,
      'question_type_id': 1,
      'section_id': sectionValue,
      'raw_mark': raw_mark_text.text,
      'practical_question_desc': question_description.text,
      'question_paper_detail_id': widget.question_paper_detail_id,
    };

    var res = await Api().postData(data, "updatePracticalQuestion");
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
              title: Text("Practical"),
              backgroundColor: Colors.orange,
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                        key: form_key,
                        child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                              children: [
                                Row(children: [
                                  Expanded(
                                      flex: 1,
                                      child: Text("Question Description")),
                                  SizedBox(width: 5),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      keyboardType: TextInputType.multiline,
                                      controller: question_description,
                                      maxLines: null,
                                      validator: (questiondescValue) {
                                        if (questiondescValue!.isEmpty) {
                                          return 'Please enter description';
                                        }
                                        question_description.text =
                                            questiondescValue;
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                ]),
                                Row(children: [
                                  Expanded(flex: 1, child: Text("Raw mark")),
                                  SizedBox(width: 5),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: raw_mark_text,
                                      validator: (rawmarkValue) {
                                        if (rawmarkValue!.isEmpty) {
                                          return 'Please enter mark';
                                        } else if (regex()
                                                .isDoubleOnly(rawmarkValue) ==
                                            false) {
                                          return 'Please enter number only';
                                        }
                                        raw_mark_text.text = rawmarkValue;

                                        return null;
                                      },
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.]'))
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                ]),
                                Row(
                                  children: [
                                    Expanded(flex: 1, child: Text("Section")),
                                    Expanded(
                                      flex: 2,
                                      child: DropdownButton<int>(
                                        isExpanded: true,
                                        items: section_list_items,
                                        value: sectionValue,
                                        onChanged: (value) => setState(() {
                                          sectionValue = value;
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 1, child: Text("Attachment")),
                                    Expanded(flex: 2, child: Text(attachment)),
                                  ],
                                ),
                                if (widget.mode == "add") ...[
                                  Row(
                                    children: [
                                      Expanded(flex: 1, child: Text("")),
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
                                ] else if (widget.mode == "edit" &&
                                    question_data['practical_attachment'] !=
                                        null) ...[
                                  Row(
                                    children: [
                                      Expanded(flex: 1, child: Text("")),
                                      Expanded(
                                        flex: 2,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              if (downloading == false) {
                                                downloadAttachment();
                                              }
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
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          if (form_key.currentState!
                                              .validate()) {
                                            if (isSubmitting == false) {
                                              setState(() {
                                                isSubmitting = true;
                                              });
                                              if (widget.mode == "add") {
                                                if (practical_file != null) {
                                                  haveAttachment = true;
                                                  setState(() {
                                                    sending = true;
                                                  });
                                                  save_file().then((value) {
                                                    if (value == true) {
                                                      save_practical()
                                                          .then((value) {
                                                        if (value == true) {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      });
                                                    }
                                                  });
                                                } else {
                                                  haveAttachment = false;
                                                  save_practical()
                                                      .then((value) {
                                                    if (value == true) {
                                                      Navigator.pop(context);
                                                    }
                                                  });
                                                }
                                              } else if (widget.mode ==
                                                  "edit") {
                                                update_practical()
                                                    .then((value) {
                                                  if (value == true) {
                                                    Navigator.pop(context);
                                                  }
                                                });
                                              }
                                              ;
                                            }
                                          }
                                        },
                                        child: Text(
                                          isSubmitting
                                              ? 'Submitting...'
                                              : "Submit",
                                        ),
                                      )
                                    ]),
                              ],
                            ))),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}
