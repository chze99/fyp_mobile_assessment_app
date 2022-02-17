// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';

class LecturerAssessmentQuestionBankAddMCQ extends StatefulWidget {
  @override
  int question_bank_id = 0;
  String mode = "";
  int question_paper_detail_id = 0;
  LecturerAssessmentQuestionBankAddMCQ(
      this.question_bank_id, this.mode, this.question_paper_detail_id);

  _LecturerAssessmentQuestionBankAddMCQState createState() =>
      _LecturerAssessmentQuestionBankAddMCQState();
}

class _LecturerAssessmentQuestionBankAddMCQState
    extends State<LecturerAssessmentQuestionBankAddMCQ> {
  bool isLoading = true;
  bool isInitial = true;
  bool mcq_found = false;
  var assessment_data;
  var mcq_data;
  var mcq_retrived_data;
  double raw_mark = 0.0;
  TextEditingController raw_mark_text = TextEditingController();
  TextEditingController question_description = TextEditingController();
  bool isSubmitting = false;
  int mcq_option_length = 4;
  List<TextEditingController> mcq_option_desc = [];
  var mcqanswerValue;
  List<DropdownMenuItem<int>> mcq_answer_list_items = [];
  var sectionValue;
  var section_data;
  final form_key = GlobalKey<FormState>();

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
      'question_bank_id': widget.question_bank_id,
    };
    var res = await Api().postData(data, "getQuestionBankSection");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        setState(() {
          section_data = body['message'];
          sectionValue = section_data['0']['section_id'];
          print("Section data:" + body['message'].toString());
          get_mcq();
        });
      }
    } else {
      print("Get section error" + body.toString());
    }
  }

  get_mcq() async {
    var data = {
      'question_paper_detail_id': widget.question_paper_detail_id,
    };
    var res = await Api().postData(data, "getMCQQuestion");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      mcqanswerValue = 0;
      for (int i = 0; i < mcq_option_length; i++) {
        mcq_option_desc.add(new TextEditingController());

        mcq_answer_list_items.add(DropdownMenuItem(
            value: i, child: Text("Option" + (i + 1).toString())));
      }
      if (body['message'] != "No MCQ found") {
        if (this.mounted) {
          setState(() {
            mcq_retrived_data = body['message'];
            question_description.text = mcq_retrived_data['mcq_desc'];
            raw_mark_text.text =
                mcq_retrived_data['question_detail']['raw_mark'];
            sectionValue = mcq_retrived_data['question_detail']['section_id'];
            for (int i = 0; i < mcq_option_length; i++) {
              mcq_option_desc[i].text =
                  mcq_retrived_data['Option'][i]['mcq_option_desc'];

              if (mcq_retrived_data['Option'][i]['mcq_option_status'] == true) {
                mcqanswerValue = i;
              }
            }
            mcq_found = true;
            print(mcq_retrived_data);
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
      print("Get mcq error" + body.toString());
    }
  }

  save_mcq() async {
    var data = {
      'question_bank_id': widget.question_bank_id,
      'question_type_id': 3,
      'section_id': sectionValue,
      'raw_mark': raw_mark_text.text,
      'mcq_desc': question_description.text,
    };
    var res = await Api().postData(data, "saveMCQQuestionBank");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("Save mcq error" + body.toString());
    }
  }

  save_mcq_option(index, mcq_id) async {
    var data;
    print("MCQ OPTION Index" +
        index.toString() +
        ",MCQ_ID" +
        mcq_id.toString() +
        ", Test:" +
        mcq_option_desc[index].text);
    if (index != mcqanswerValue) {
      data = {
        'mcq_id': mcq_id,
        'mcq_option_desc': mcq_option_desc[index].text,
        'mcq_option_status': false,
      };
    } else {
      data = {
        'mcq_id': mcq_id,
        'mcq_option_desc': mcq_option_desc[index].text,
        'mcq_option_status': true,
      };
    }
    var res = await Api().postData(data, "saveMCQOption");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        print("MCQ Option Saved" + body.toString());
        if (index == mcq_option_length - 1) {
          return body['success'];
        }
      }
    } else {
      print("MCQ Option error" + body.toString());
    }
  }

  update_mcq() async {
    var data = {
      'question_bank_id': widget.question_bank_id,
      'question_type_id': 3,
      'section_id': sectionValue,
      'raw_mark': raw_mark_text.text,
      'mcq_desc': question_description.text,
      'question_paper_detail_id': widget.question_paper_detail_id,
    };

    var res = await Api().postData(data, "updateMCQQuestionBank");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("MCQ Updated" + body.toString());
    }
  }

  update_mcq_option(index) async {
    var data;

    if (index != mcqanswerValue) {
      data = {
        'mcq_option_id': mcq_retrived_data['Option'][index]['mcq_option_id'],
        'mcq_option_desc': mcq_option_desc[index].text,
        'mcq_option_status': false,
      };
    } else {
      data = {
        'mcq_option_id': mcq_retrived_data['Option'][index]['mcq_option_id'],
        'mcq_option_desc': mcq_option_desc[index].text,
        'mcq_option_status': true,
      };
    }
    var res = await Api().postData(data, "updateMCQOption");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (this.mounted) {
        print("MCQ Option Update" + body.toString());
        if (index == mcq_option_length - 1) {
          return body['success'];
        }
      }
    } else {
      print("MCQ Option error" + body.toString());
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
            title: Text("MCQ"),
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
              title: Text("MCQ"),
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
                                    Expanded(
                                      child: ListView.builder(
                                          itemCount: mcq_option_length,
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return Container(
                                                child: Row(children: [
                                              Expanded(
                                                  flex: 1,
                                                  child: Text("Option " +
                                                      (index + 1).toString() +
                                                      " Description")),
                                              SizedBox(width: 5),
                                              Expanded(
                                                flex: 2,
                                                child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                    controller:
                                                        mcq_option_desc[index],
                                                    maxLines: null,
                                                    validator: (optionValue) {
                                                      if (optionValue!
                                                          .isEmpty) {
                                                        return "Please enter option description";
                                                      }
                                                      mcq_option_desc[index]
                                                          .text = optionValue;
                                                      return null;
                                                    }),
                                              ),
                                              SizedBox(width: 5),
                                            ]));
                                          }),
                                    )
                                  ],
                                ),
                                Row(children: [
                                  Expanded(
                                      flex: 1, child: Text("Correct answer")),
                                  SizedBox(width: 5),
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButton<int>(
                                      isExpanded: true,
                                      items: mcq_answer_list_items,
                                      value: mcqanswerValue,
                                      onChanged: (value) => setState(() {
                                        mcqanswerValue = value;
                                      }),
                                    ),
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
                                                save_mcq().then((value) {
                                                  mcq_data = value['data'];
                                                  for (int i = 0;
                                                      i < mcq_option_length;
                                                      i++) {
                                                    save_mcq_option(i,
                                                            mcq_data['mcq_id'])
                                                        .then((value) {
                                                      if (value == true) {
                                                        Navigator.pop(context);
                                                      }
                                                    });
                                                  }
                                                });
                                              } else if (widget.mode ==
                                                  "edit") {
                                                update_mcq().then((value) {
                                                  for (int i = 0;
                                                      i < mcq_option_length;
                                                      i++) {
                                                    update_mcq_option(i)
                                                        .then((value) {
                                                      if (value == true) {
                                                        Navigator.pop(context);
                                                      }
                                                    });
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
