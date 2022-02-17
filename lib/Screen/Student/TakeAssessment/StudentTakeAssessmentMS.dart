// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';
import 'package:mobile_assessment/Screen/regex.dart';
import 'package:toast/toast.dart';

class StudentTakeAssessmentMS extends StatefulWidget {
  @override
  int solution_questionpaper_id = 0;
  String mode = "";
  int solution_paperdetail_id = 0;
  int question_number = 0;
  StudentTakeAssessmentMS(this.solution_questionpaper_id, this.mode,
      this.solution_paperdetail_id, this.question_number);

  _StudentTakeAssessmentMSState createState() =>
      _StudentTakeAssessmentMSState();
}

class _StudentTakeAssessmentMSState extends State<StudentTakeAssessmentMS> {
  bool isLoading = true;
  bool isSubmitting = false;
  var ms_retrived_data;
  var question_detail_data;
  var answer_data;
  var selection_left;
  var selection_right;
  List<String> selection_right_value = [];
  List<String> selection_left_value = [];
  List<int> selection_left_id = [];
  List<DropdownMenuItem<String>> ms_right_list_items = [];
  TextEditingController ms_answer = new TextEditingController();
  bool isanswered = true;
  final form_key = GlobalKey<FormState>();
  bool success = false;
  @override
  void initState() {
    get_ms();

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_ms() async {
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
    };
    var res = await Api().postData(data, "getMSQuestionStudent");
    var body = json.decode(res.body);
    if (body['success'] == true) {
      if (body['message'] != "No MS found") {
        if (this.mounted) {
          setState(() {
            ms_retrived_data = body['q'];
            question_detail_data = body['qd'];
            answer_data = body['sqa'];
            selection_left = ms_retrived_data['selection_left'];
            selection_right = ms_retrived_data['selection_right'];
            ms_right_list_items.add(DropdownMenuItem(
              value: "No answer chosen",
              child: Text("No answer chosen"),
            ));
            if (answer_data != "No answer") {
              for (int i = 0; i < ms_retrived_data['selection_count']; i++) {
                selection_right_value.add(answer_data['selection'][i]
                    ['matchingsentence_selection_right']);
                selection_left_value.add(answer_data['selection'][i]
                    ['matchingsentence_selection_left']);
                selection_left_id.add(answer_data['selection'][i]
                    ['matchingsentence_left_question_id']);
              }
              ms_answer.text = answer_data['matchingsentence_answer'];
            } else {
              for (int i = 0; i < ms_retrived_data['selection_count']; i++) {
                selection_right_value.add("No answer chosen");
                selection_left_value
                    .add(selection_left[i]['matchingsentence_selection_left']);
                selection_left_id.add(selection_left[i]
                    ['matchingsentence_question_selection_id']);
              }
              ms_right_list_items.addAll(List.generate(
                ms_retrived_data['selection_count'],
                (i) => DropdownMenuItem(
                  value: selection_right[i]['matchingsentence_selection_right'],
                  child: Text(
                      selection_right[i]['matchingsentence_selection_right']),
                ),
              ));
            }

            print(ms_retrived_data);
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

  submit_ms() async {
    var data = {
      'solution_paperdetail_id': widget.solution_paperdetail_id,
    };
    var res = await Api().postData(data, "submitMSAnswerStudent");
    var body = json.decode(res.body);
    print('submit ms' + body.toString());
    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("Save sa error" + body.toString());
    }
  }

  submit_ms_selection(solid, index) async {
    var data = {
      'matchingsentence_solution_id': solid,
      'matchingsentence_selection_left': selection_left_value[index],
      'matchingsentence_selection_right': selection_right_value[index],
      'matchingsentence_left_question_id': selection_left_id[index],
    };
    var res = await Api().postData(data, "submitMSAnswerSelectionStudent");
    var body = json.decode(res.body);
    print('submit mss' + body.toString());

    if (body['success'] == true) {
      if (this.mounted) {
        if (index == ms_retrived_data['selection_count'] - 1) {
          return body;
        }
      }
    } else {
      print("Save sa error" + body.toString());
    }
  }

  update_ms_correct_number(solid) async {
    var data = {
      'matchingsentence_solution_id': solid,
    };
    var res = await Api().postData(data, "updateMSAnswerCorrectNumberStudent");
    var body = json.decode(res.body);
    print('update mss' + body.toString());

    if (body['success'] == true) {
      if (this.mounted) {
        return body;
      }
    } else {
      print("Save sa error" + body.toString());
    }
  }

  update_ms(index) async {
    var data = {
      'matchingsentence_answer_selection_id': answer_data['selection'][index]
          ['matchingsentence_answer_selection_id'],
      'matchingsentence_selection_left': selection_left_value[index],
      'matchingsentence_selection_right': selection_right_value[index],
      'matchingsentence_left_question_id': selection_left_id[index],
    };

    var res = await Api().postData(data, "updateMSAnswerStudent");
    var body = json.decode(res.body);
    print(body);
    if (body['success'] == true) {
      if (this.mounted) {
        if (index == ms_retrived_data['selection_count'] - 1) {
          return body;
        }
      }
    } else {
      print("MS Updated" + body.toString());
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
            title: Text("Matching Sentence"),
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
                                              child: Text(ms_retrived_data[
                                                      'matchingsentence_question_desc']
                                                  .toString())),
                                        ]),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(children: [
                                          Text("Answer",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold))
                                        ]),
                                        Row(children: [
                                          Expanded(
                                              flex: 12,
                                              child: Text("Left side",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                          Expanded(flex: 1, child: Text('')),
                                          Expanded(
                                              flex: 12,
                                              child: Text("Right side",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ]),
                                        Row(children: [
                                          Expanded(
                                            child: ListView.builder(
                                                itemCount: ms_retrived_data[
                                                    'selection_count'],
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                      child: Column(children: [
                                                    Row(
                                                      children: [
                                                        if (answer_data ==
                                                            "No answer") ...[
                                                          Expanded(
                                                              flex: 12,
                                                              child: Text(selection_left[
                                                                          index]
                                                                      [
                                                                      'matchingsentence_selection_left']
                                                                  .toString()))
                                                        ] else ...[
                                                          Expanded(
                                                              flex: 12,
                                                              child: Text(
                                                                  selection_left_value[
                                                                          index]
                                                                      .toString()))
                                                        ],
                                                        Expanded(
                                                            flex: 1,
                                                            child: Text('')),
                                                        if (selection_right_value[
                                                                index] ==
                                                            "No answer chosen") ...[
                                                          Expanded(
                                                            flex: 12,
                                                            child:
                                                                DropdownButton<
                                                                    String>(
                                                              isExpanded: true,
                                                              items:
                                                                  ms_right_list_items,
                                                              value:
                                                                  selection_right_value[
                                                                      index],
                                                              onChanged:
                                                                  (value) =>
                                                                      setState(
                                                                          () {
                                                                selection_right_value[
                                                                        index] =
                                                                    value!;

                                                                print(selection_left_value
                                                                    .toString());
                                                                if (value !=
                                                                    "No answer chosen") {
                                                                  ms_right_list_items
                                                                      .removeWhere((data) =>
                                                                          data.value ==
                                                                          value);
                                                                } else {
                                                                  isanswered =
                                                                      false;
                                                                }
                                                              }),
                                                            ),
                                                          )
                                                        ] else ...[
                                                          Expanded(
                                                              flex: 10,
                                                              child: Text(
                                                                  selection_right_value[
                                                                          index]
                                                                      .toString())),
                                                          Expanded(
                                                              flex: 2,
                                                              child: IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      ms_right_list_items.add(DropdownMenuItem(
                                                                          value: selection_right_value[
                                                                              index],
                                                                          child:
                                                                              Text(selection_right_value[index])));
                                                                      selection_right_value[
                                                                              index] =
                                                                          "No answer chosen";
                                                                      isanswered =
                                                                          false;
                                                                    });
                                                                  },
                                                                  icon: new Icon(
                                                                      Icons
                                                                          .close)))
                                                        ],
                                                      ],
                                                    ),
                                                    Divider(
                                                      thickness: 1.0,
                                                      color: Colors.black,
                                                      endIndent: 0,
                                                      indent: 0,
                                                    )
                                                  ]));
                                                }),
                                          ),
                                        ]),
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
                                            if (widget.mode == "take") {
                                              isanswered = true;
                                              for (int i = 0;
                                                  i <
                                                      ms_retrived_data[
                                                          'selection_count'];
                                                  i++) {
                                                if (selection_right_value[i] ==
                                                    "No answer chosen") {
                                                  isanswered = false;
                                                }
                                              }

                                              if (isanswered == true) {
                                                submit_ms().then((value) {
                                                  if (value['success']) {
                                                    for (int i = 0;
                                                        i <
                                                            ms_retrived_data[
                                                                'selection_count'];
                                                        i++) {
                                                      submit_ms_selection(
                                                              value['data'][
                                                                  'matchingsentence_solution_id'],
                                                              i)
                                                          .then((values) {
                                                        print("Value" +
                                                            values.toString());
                                                        if (values != null) {
                                                          update_ms_correct_number(
                                                                  values['data']
                                                                      [
                                                                      'matchingsentence_solution_id'])
                                                              .then((valuess) {
                                                            if (valuess[
                                                                'success']) {
                                                              Toast.show(
                                                                  "Saved",
                                                                  context);
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          });
                                                        }
                                                      });
                                                    }
                                                  }
                                                });
                                              } else {
                                                Toast.show(
                                                    "Please select all answer",
                                                    context);
                                              }
                                            } else if (widget.mode == "edit") {
                                              for (int i = 0;
                                                  i <
                                                      ms_retrived_data[
                                                          'selection_count'];
                                                  i++) {
                                                update_ms(i).then((values) {
                                                  print("Value" +
                                                      values.toString());
                                                  if (values != null) {
                                                    update_ms_correct_number(
                                                            answer_data[
                                                                'matchingsentence_solution_id'])
                                                        .then((valuess) {
                                                      if (valuess['success']) {
                                                        Toast.show(
                                                            "Saved", context);
                                                        Navigator.pop(context);
                                                      }
                                                    });
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
