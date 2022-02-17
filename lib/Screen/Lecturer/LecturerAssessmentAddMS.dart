// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';

class LecturerAssessmentAddMS extends StatefulWidget {
  @override
  int question_paper_id = 0;
  String mode = "";
  int question_paper_detail_id = 0;
  LecturerAssessmentAddMS(
      this.question_paper_id, this.mode, this.question_paper_detail_id);

  _LecturerAssessmentAddMSState createState() =>
      _LecturerAssessmentAddMSState();
}

class _LecturerAssessmentAddMSState extends State<LecturerAssessmentAddMS> {
  bool isLoading = true;
  bool isInitial = true;
  bool tf_found = false;
  var assessment_data;
  var ms_data;
  TextEditingController raw_mark_text = TextEditingController();
  TextEditingController question_description = TextEditingController();
  List<TextEditingController> ms_left_desc = [];
  List<TextEditingController> ms_right_desc = [];
  int ms_selection_number = 2;
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
          get_ms();
        });
      }
    } else {
      print("Get section error" + body.toString());
    }
  }

  get_ms() async {
    var data = {
      'question_paper_detail_id': widget.question_paper_detail_id,
    };
    var res = await Api().postData(data, "getMSQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No MS found") {
        if (this.mounted) {
          setState(() {
            ms_data = body['message'];
            question_description.text =
                ms_data['matchingsentence_question_desc'];
            raw_mark_text.text = ms_data['question_detail']['raw_mark'];
            sectionValue = ms_data['question_detail']['section_id'];
            ms_selection_number = ms_data['selection_count'];
            for (int i = 0; i < ms_selection_number; i++) {
              if (ms_left_desc.length <= ms_selection_number) {
                ms_left_desc.add(new TextEditingController());
                ms_right_desc.add(new TextEditingController());
                ms_left_desc[i].text = ms_data['selection'][i]
                        ['matchingsentence_selection_left']
                    .toString();
                ms_right_desc[i].text = ms_data['selection'][i]
                        ['matchingsentence_selection_right']
                    .toString();
              }
            }
            isLoading = false;
          });
        }
      } else {
        setState(() {
          for (int i = 0; i < ms_selection_number; i++) {
            if (ms_left_desc.length <= ms_selection_number) {
              ms_left_desc.add(new TextEditingController());
              ms_right_desc.add(new TextEditingController());
            }
          }
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print("Get ms error" + body.toString());
    }
  }

  save_ms() async {
    var data = {
      'question_paper_id': widget.question_paper_id,
      'question_type_id': 5,
      'section_id': sectionValue,
      'raw_mark': raw_mark_text.text,
      'matchingsentence_question_desc': question_description.text,
    };

    var res = await Api().postData(data, "saveMSQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("Save MS error" + body.toString());
    }
  }

  save_ms_selection(qid, index) async {
    var data = {
      'matchingsentence_question_id': qid,
      'matchingsentence_selection_left': ms_left_desc[index].text,
      'matchingsentence_selection_right': ms_right_desc[index].text,
      'matchingsentence_selection_number': index + 1,
    };

    var res = await Api().postData(data, "saveMSQuestionSelection");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        if (index == ms_selection_number - 1) {
          return body['success'];
        }
      }
    } else {
      print("Save MS error" + body.toString());
    }
  }

  update_ms() async {
    var data = {
      'question_paper_id': widget.question_paper_id,
      'question_type_id': 5,
      'section_id': sectionValue,
      'raw_mark': raw_mark_text.text,
      'matchingsentence_question_desc': question_description.text,
      'question_paper_detail_id': widget.question_paper_detail_id,
      'matchingsentence_question_id': ms_data['matchingsentence_question_id'],
      'number': ms_selection_number,
    };
    print('number' + ms_selection_number.toString());
    var res = await Api().postData(data, "updateMSQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body['success'];
      }
    } else {
      print("Update MS error" + body.toString());
    }
  }

  update_ms_selection(index) async {
    var data;
    if (index < ms_data['selection_count']) {
      data = {
        'matchingsentence_question_selection_id': ms_data['selection'][index]
            ['matchingsentence_question_selection_id'],
        'matchingsentence_selection_left': ms_left_desc[index].text,
        'matchingsentence_selection_right': ms_right_desc[index].text,
        'matchingsentence_question_id': ms_data['matchingsentence_question_id'],
        'mode': 'update',
      };
    } else {
      data = {
        'matchingsentence_selection_left': ms_left_desc[index].text,
        'matchingsentence_selection_right': ms_right_desc[index].text,
        'matchingsentence_question_id': ms_data['matchingsentence_question_id'],
        'mode': 'add',
      };
    }
    print('number' + ms_data['selection_count'].toString());

    var res = await Api().postData(data, "updateMSQuestionSelection");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        if (index == ms_selection_number - 1) {
          return body['success'];
        }
      }
    } else {
      print("Save MS error" + body.toString());
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
            title: Text("Matching Sentences"),
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
              title: Text("Matching Sentences"),
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
                                          itemCount: ms_selection_number,
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return Container(
                                                child: Column(children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text("Matching " +
                                                          (index + 1)
                                                              .toString() +
                                                          " Left Descrption")),
                                                  Expanded(
                                                    flex: 2,
                                                    child: TextFormField(
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        controller:
                                                            ms_left_desc[index],
                                                        maxLines: null,
                                                        validator:
                                                            (optionValue) {
                                                          if (optionValue!
                                                              .isEmpty) {
                                                            return "Please enter left description";
                                                          }
                                                          ms_left_desc[index]
                                                                  .text =
                                                              optionValue;
                                                          return null;
                                                        }),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text("Matching " +
                                                          (index + 1)
                                                              .toString() +
                                                          " Right Descrption")),
                                                  Expanded(
                                                    flex: 2,
                                                    child: TextFormField(
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        controller:
                                                            ms_right_desc[
                                                                index],
                                                        maxLines: null,
                                                        validator:
                                                            (rightValue) {
                                                          if (rightValue!
                                                              .isEmpty) {
                                                            return "Please enter right description";
                                                          }
                                                          ms_right_desc[index]
                                                                  .text =
                                                              rightValue;
                                                          return null;
                                                        }),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 5),
                                            ]));
                                          }),
                                    )
                                  ],
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text("Add matching"),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                ms_selection_number += 1;
                                                ms_left_desc.add(
                                                    new TextEditingController());
                                                ms_right_desc.add(
                                                    new TextEditingController());
                                              });
                                            },
                                            icon: new Icon(Icons.add)),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                            onPressed: () {
                                              if (ms_selection_number - 1 >=
                                                  2) {
                                                setState(() {
                                                  ms_selection_number -= 1;
                                                  ms_left_desc.removeLast();
                                                  ms_right_desc.removeLast();
                                                });
                                              }
                                            },
                                            icon: new Icon(Icons.remove)),
                                      ),
                                    ]),
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
                                              if (widget.mode == "add") {
                                                save_ms().then((value) {
                                                  print(value);
                                                  if (value['success'] ==
                                                      true) {
                                                    for (int i = 0;
                                                        i < ms_selection_number;
                                                        i++) {
                                                      save_ms_selection(
                                                              value['data'][
                                                                  'matchingsentence_question_id'],
                                                              i)
                                                          .then((value) {
                                                        if (value == true) {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      });
                                                    }
                                                  }
                                                });
                                              } else if (widget.mode ==
                                                  "edit") {
                                                update_ms().then((value) {
                                                  if (value == true) {
                                                    for (int i = 0;
                                                        i < ms_selection_number;
                                                        i++) {
                                                      update_ms_selection(i)
                                                          .then((value) {
                                                        if (value == true) {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      });
                                                    }
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
                            ))),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}
