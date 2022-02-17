// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';

class LecturerAssessmentAddEssay extends StatefulWidget {
  @override
  int question_paper_id = 0;
  String mode = "";
  int question_paper_detail_id = 0;
  LecturerAssessmentAddEssay(
      this.question_paper_id, this.mode, this.question_paper_detail_id);

  _LecturerAssessmentAddEssayState createState() =>
      _LecturerAssessmentAddEssayState();
}

class _LecturerAssessmentAddEssayState
    extends State<LecturerAssessmentAddEssay> {
  bool isLoading = true;
  bool isInitial = true;
  bool data_found = false;
  var assessment_data;
  var question_id_data;
  var question_data;
  int essay_subquestion_length = 0;
  TextEditingController raw_mark_text = TextEditingController();
  TextEditingController question_description = TextEditingController();
  List<TextEditingController> sub_essay_question = [];
  List<TextEditingController> sub_essay_mark = [];
  var sectionValue;
  List<DropdownMenuItem<int>> section_list_items = [];
  var section_data;
  final form_key = GlobalKey<FormState>();
  bool isSubmitting = false;
  bool success = false;
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
          get_essay();
        });
      }
    } else {
      print("Get section error" + body.toString());
    }
  }

  get_essay() async {
    var data = {
      'question_paper_detail_id': widget.question_paper_detail_id,
    };
    var res = await Api().postData(data, "getEssayQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No Essay found") {
        if (this.mounted) {
          setState(() {
            question_data = body['message'];
            print(question_data);
            question_description.text = question_data['essay_question_desc'];
            raw_mark_text.text = question_data['question_detail']['raw_mark'];
            sectionValue = question_data['question_detail']['section_id'];
            essay_subquestion_length = question_data['subquestion_count'];
            for (int i = 0; i < essay_subquestion_length; i++) {
              sub_essay_question.add(new TextEditingController());
              sub_essay_mark.add(new TextEditingController());
              sub_essay_question[i].text =
                  question_data['subquestion'][i]['essay_subquestion_desc'];
              sub_essay_mark[i].text =
                  question_data['subquestion'][i]['essay_subquestion_mark'];
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

  save_essay() async {
    var data;
    if (essay_subquestion_length == 0) {
      data = {
        'question_paper_id': widget.question_paper_id,
        'question_type_id': 2,
        'section_id': sectionValue,
        'raw_mark': raw_mark_text.text,
        'essay_question_desc': question_description.text,
        'essay_have_subquestion': false,
      };
    } else {
      data = {
        'question_paper_id': widget.question_paper_id,
        'question_type_id': 2,
        'section_id': sectionValue,
        'raw_mark': raw_mark_text.text,
        'essay_question_desc': question_description.text,
        'essay_have_subquestion': true,
      };
    }
    var res = await Api().postData(data, "saveEssayQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("Save essay error" + body.toString());
    }
  }

  save_subessay(index, essay_id) async {
    var data;

    data = {
      'essay_question_id': essay_id,
      'essay_subquestion_desc': sub_essay_question[index].text,
      'essay_subquestion_mark': sub_essay_mark[index].text,
    };

    var res = await Api().postData(data, "saveSubEssayQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        print("subessay Saved" + body.toString());
        if (index == essay_subquestion_length - 1) {
          return body['success'];
        }
      }
    } else {
      print("subessay save error" + body.toString());
    }
  }

  update_essay() async {
    var data;
    if (essay_subquestion_length == 0) {
      data = {
        'question_paper_id': widget.question_paper_id,
        'question_type_id': 2,
        'section_id': sectionValue,
        'raw_mark': raw_mark_text.text,
        'essay_question_desc': question_description.text,
        'essay_have_subquestion': false,
        'question_paper_detail_id': widget.question_paper_detail_id,
      };
    } else {
      data = {
        'question_paper_id': widget.question_paper_id,
        'question_type_id': 2,
        'section_id': sectionValue,
        'raw_mark': raw_mark_text.text,
        'essay_question_desc': question_description.text,
        'essay_have_subquestion': true,
        'question_paper_detail_id': widget.question_paper_detail_id,
      };
    }

    var res = await Api().postData(data, "updateEssayQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body['success'];
      }
    } else {
      print("Update essay error" + body.toString());
    }
  }

  update_subessay(index) async {
    var data;

    data = {
      'essay_subquestion_id': question_data['subquestion'][index]
          ['essay_subquestion_id'],
      'essay_subquestion_desc': sub_essay_question[index].text,
      'essay_subquestion_mark': sub_essay_mark[index].text,
    };

    var res = await Api().postData(data, "updateSubEssayQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        print("Essay sub Update" + body.toString());
        if (index == essay_subquestion_length - 1) {
          return body['success'];
        }
      }
    } else {
      print("Essay sub error" + body.toString());
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
            title: Text("Essay"),
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
              title: Text("Essay"),
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
                                      child: ListView.builder(
                                          itemCount: essay_subquestion_length,
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            if (sub_essay_question.length <
                                                essay_subquestion_length) {
                                              sub_essay_question.add(
                                                  new TextEditingController());
                                              sub_essay_mark.add(
                                                  new TextEditingController());
                                            }
                                            return Container(
                                                child: Column(
                                              children: [
                                                Row(children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                          "Subquestion " +
                                                              (index + 1)
                                                                  .toString() +
                                                              " Description")),
                                                  SizedBox(width: 5),
                                                  Expanded(
                                                    flex: 2,
                                                    child: TextFormField(
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        controller:
                                                            sub_essay_question[
                                                                index],
                                                        maxLines: null,
                                                        validator:
                                                            (optionValue) {
                                                          if (optionValue!
                                                              .isEmpty) {
                                                            return "Please enter subquestion description";
                                                          }
                                                          sub_essay_question[
                                                                      index]
                                                                  .text =
                                                              optionValue;
                                                          return null;
                                                        }),
                                                  ),
                                                  SizedBox(width: 5),
                                                ]),
                                                Row(children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                          "Subquestion " +
                                                              (index + 1)
                                                                  .toString() +
                                                              " Mark")),
                                                  SizedBox(width: 5),
                                                  Expanded(
                                                    flex: 2,
                                                    child: TextFormField(
                                                      keyboardType:
                                                          TextInputType.number,
                                                      controller:
                                                          sub_essay_mark[index],
                                                      maxLines: null,
                                                      validator: (optionValue) {
                                                        if (optionValue!
                                                            .isEmpty) {
                                                          return "Please enter subquestion mark";
                                                        } else if (regex()
                                                                .isDoubleOnly(
                                                                    optionValue) ==
                                                            false) {
                                                          return "Please enter number";
                                                        }
                                                        sub_essay_mark[index]
                                                            .text = optionValue;
                                                        return null;
                                                      },
                                                      inputFormatters: <
                                                          TextInputFormatter>[
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                r'[0-9.]'))
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                ])
                                              ],
                                            ));
                                          }),
                                    )
                                  ],
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (widget.mode == 'add') ...[
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              essay_subquestion_length += 1;
                                            });
                                          },
                                          child: Text("Add subquestion"),
                                        )
                                      ],
                                      SizedBox(width: 5),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (form_key.currentState!
                                              .validate()) {
                                            if (isSubmitting == false) {
                                              setState(() {
                                                isSubmitting = true;
                                              });
                                              if (widget.mode == "add") {
                                                save_essay().then((value) {
                                                  question_id_data =
                                                      value['data']
                                                          ['essay_question_id'];
                                                  if (essay_subquestion_length !=
                                                      0) {
                                                    for (int i = 0;
                                                        i < essay_subquestion_length;
                                                        i++) {
                                                      save_subessay(i,
                                                              question_id_data)
                                                          .then((value) {
                                                        if (value == true) {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      });
                                                    }
                                                  } else if (value['success']) {
                                                    Navigator.pop(context);
                                                  }
                                                });
                                              } else if (widget.mode ==
                                                  "edit") {
                                                update_essay().then((value) {
                                                  if (essay_subquestion_length !=
                                                      0) {
                                                    for (int i = 0;
                                                        i < essay_subquestion_length;
                                                        i++) {
                                                      update_subessay(i)
                                                          .then((value) {
                                                        if (value == true) {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      });
                                                    }
                                                  } else if (value == true) {
                                                    Navigator.pop(context);
                                                  }
                                                });
                                              }
                                            }
                                          }
                                        },
                                        child: Text("Submit"),
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
