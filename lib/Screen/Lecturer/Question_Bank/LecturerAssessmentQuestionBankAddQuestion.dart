// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Lecturer/Question_Bank/LecturerAssessmentQuestionBankAddMCQ.dart';
import 'package:mobile_assessment/Screen/Lecturer/Question_Bank/LecturerAssessmentQuestionBankAddSA.dart';
import 'package:mobile_assessment/Screen/Lecturer/Question_Bank/LecturerAssessmentQuestionBankAddTF.dart';
import 'package:mobile_assessment/Screen/Lecturer/Question_Bank/LecturerAssessmentQuestionBankAddEssay.dart';
import 'package:mobile_assessment/Screen/Lecturer/Question_Bank/LecturerAssessmentQuestionBankAddMS.dart';
import 'package:mobile_assessment/Screen/Lecturer/Question_Bank/LecturerAssessmentQuestionBankAddPractical.dart';
import 'package:mobile_assessment/Screen/dialog_template.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:mobile_assessment/Screen/loading_page.dart';

class LecturerAssessmentQuestionBankAddQuestion extends StatefulWidget {
  @override
  int question_bank_id = 0;
  LecturerAssessmentQuestionBankAddQuestion(this.question_bank_id);
  _LecturerAssessmentQuestionBankAddQuestionState createState() =>
      _LecturerAssessmentQuestionBankAddQuestionState();
}

class _LecturerAssessmentQuestionBankAddQuestionState
    extends State<LecturerAssessmentQuestionBankAddQuestion> {
  bool isLoading = true;
  bool isDeleting = false;

  var question_bank_data;
  var question_data;
  var question_type;
  double total_mark = 0;
  List<DropdownMenuItem<int>> question_type_list_items = [];
  var questiontypeValue;
  var current_question_type;
  int questionlistLength = 0;
  var questionlistValue;

  bool success = false;
  @override
  void initState() {
    get_question_bank();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_question_bank() async {
    var data = {'question_bank_id': widget.question_bank_id};
    var res = await Api().postData(data, "getQuestionBankDetail");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        if (body['message'] != "No question bank") {
          setState(() {
            question_bank_data = body['message'];
            get_question_list();
          });
        } else {}
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print("Get question bank error" + body.toString());
    }
  }

  get_question_list() async {
    var data = {
      'question_bank_id': widget.question_bank_id,
    };
    var res = await Api().postData(data, "getAddedQuestionBankQuestionList");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (body['message'] != "No question found") {
        if (this.mounted) {
          setState(() {
            question_data = body['message'];
            questionlistLength = question_data['count'];
            for (int i = 0; i < questionlistLength; i++) {
              total_mark +=
                  double.parse(question_data[i.toString()]['raw_mark']);
            }
            print("Get question:" + question_data.toString());
            get_question_type();
          });
        }
      } else {
        get_question_type();
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print("Get question error" + body.toString());
    }
  }

  get_question_type() async {
    var data = {"temp": ""};
    var res = await Api().postData(data, "getQuestionType");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        setState(() {
          question_type = body['message'];
          print("question_type" + question_type.toString());
          question_type_list_items = List.generate(
            question_type["count"],
            (i) => DropdownMenuItem(
              value: question_type[i.toString()]['question_type_id'],
              child:
                  Text("${question_type[i.toString()]['question_type_name']}"),
            ),
          );
          questiontypeValue = question_type["0"]['question_type_id'];
          isLoading = false;

          print(body);
        });
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      isLoading = false;
      print(" get_question_type" + body.toString());
    }
  }

  publish_assessment() async {
    var data = {};
    var res = await Api().postData(data, "publishAssessmentPaper");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      setState(() {
        get_question_bank();
      });
    } else {
      error_alert().alert(context, "Error", body.toString());
    }
  }

  delete_question(qpd_id, question_type_id) async {
    setState(() {
      isDeleting = true;
    });
    var data = {
      "question_paper_detail_id": qpd_id,
      "question_type_id": question_type_id,
    };
    var res = await Api().postData(data, "deleteQuestionPaperDetail");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        setState(() {
          isDeleting = false;
          get_question_bank();
        });
      }
    } else {
      error_alert().alert(context, "Error", body.toString());
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
            title: Text("Add question"),
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
              title: Text(question_bank_data['question_bank_name']),
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
                            flex: 1,
                            child: Row(children: [
                              Expanded(
                                  flex: 5,
                                  child: Text(
                                    "Question List",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Column(
                                    children: [
                                      Text("Total mark. :" +
                                          total_mark.toString())
                                    ],
                                  )),
                            ])),
                        Expanded(
                          flex: 17,
                          child: Card(
                              child: SingleChildScrollView(
                                  physics: ScrollPhysics(),
                                  child: Column(
                                    children: [
                                      Row(children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "Q. Number",
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            "Q. Type",
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            "Q. Content",
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "Q. Raw Mark",
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            "Edit",
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            "Delete",
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ]),
                                      if (questionlistLength == 0) ...[
                                        Text(
                                            "There is no question currently been added")
                                      ] else ...[
                                        Row(
                                          children: [
                                            Flexible(
                                              child: ListView.builder(
                                                  itemCount: questionlistLength,
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 5, 0, 5),
                                                        child: Row(children: [
                                                          Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                                (index + 1)
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ),
                                                          if (question_data[index
                                                                      .toString()]
                                                                  [
                                                                  'question_type_id'] ==
                                                              3) ...[
                                                            Expanded(
                                                              flex: 3,
                                                              child: Text("MCQ",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                          ] else ...[
                                                            Expanded(
                                                              flex: 3,
                                                              child: Text(
                                                                  question_data[
                                                                          index
                                                                              .toString()]
                                                                      [
                                                                      'question_type_name'],
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                          ],
                                                          Expanded(
                                                            flex: 5,
                                                            child: Text(
                                                                question_data[index
                                                                            .toString()]
                                                                        [
                                                                        'question_detail']
                                                                    ['desc'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                                question_data[index
                                                                        .toString()]
                                                                    [
                                                                    'raw_mark'],
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Center(
                                                              child: InkWell(
                                                                child: Icon(
                                                                  Icons.edit,
                                                                  size: 18.0,
                                                                  color: Colors
                                                                      .blue,
                                                                ),
                                                                onTap: () {
                                                                  if (question_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_type_id'] ==
                                                                      1) {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                LecturerAssessmentQuestionBankAddPractical(widget.question_bank_id, "edit", question_data[index.toString()]['question_paper_detail_id']))).then(
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            true;
                                                                        get_question_bank();
                                                                      });
                                                                    });
                                                                  } else if (question_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_type_id'] ==
                                                                      2) {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                LecturerAssessmentQuestionBankAddEssay(widget.question_bank_id, "edit", question_data[index.toString()]['question_paper_detail_id']))).then(
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            true;
                                                                        get_question_bank();
                                                                      });
                                                                    });
                                                                  } else if (question_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_type_id'] ==
                                                                      3) {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                LecturerAssessmentQuestionBankAddMCQ(widget.question_bank_id, "edit", question_data[index.toString()]['question_paper_detail_id']))).then(
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            true;
                                                                        get_question_bank();
                                                                      });
                                                                    });
                                                                  } else if (question_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_type_id'] ==
                                                                      4) {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                LecturerAssessmentQuestionBankAddTF(widget.question_bank_id, "edit", question_data[index.toString()]['question_paper_detail_id']))).then(
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            true;
                                                                        get_question_bank();
                                                                      });
                                                                    });
                                                                  } else if (question_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_type_id'] ==
                                                                      5) {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                LecturerAssessmentQuestionBankAddMS(widget.question_bank_id, "edit", question_data[index.toString()]['question_paper_detail_id']))).then(
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            true;
                                                                        get_question_bank();
                                                                      });
                                                                    });
                                                                  } else if (question_data[
                                                                              index.toString()]
                                                                          [
                                                                          'question_type_id'] ==
                                                                      6) {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                LecturerAssessmentQuestionBankAddSA(widget.question_bank_id, "edit", question_data[index.toString()]['question_paper_detail_id']))).then(
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            true;
                                                                        get_question_bank();
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Center(
                                                              child: InkWell(
                                                                child: Icon(
                                                                  Icons.delete,
                                                                  size: 18.0,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                onTap: () {
                                                                  dialog_template()
                                                                      .confirmation_dialog(
                                                                    context,
                                                                    "No",
                                                                    "Yes",
                                                                    "Delete confirmation",
                                                                    "Did you sure that you want to remove this question from this paper?",
                                                                    () => null,
                                                                    () => delete_question(
                                                                            question_data[index.toString()]['question_paper_detail_id'],
                                                                            question_data[index.toString()]['question_type_id'])
                                                                        .then,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ]));
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ]
                                    ],
                                  ))),
                        ),
                        SizedBox(height: 5),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              print(questiontypeValue);
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                        builder: (context, setState) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: Text('Question ' +
                                            (questionlistLength + 1)
                                                .toString()),
                                        content: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Form(
                                            child: Column(
                                              children: <Widget>[
                                                Row(children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                          "Question Type")),
                                                  SizedBox(width: 5),
                                                  Expanded(
                                                    flex: 2,
                                                    child: DropdownButton<int>(
                                                      isExpanded: true,
                                                      items:
                                                          question_type_list_items,
                                                      value: questiontypeValue,
                                                      onChanged: (value) =>
                                                          setState(() {
                                                        questiontypeValue =
                                                            value;
                                                      }),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                ]),
                                                if (questiontypeValue == 1) ...[
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    LecturerAssessmentQuestionBankAddPractical(
                                                                        widget
                                                                            .question_bank_id,
                                                                        "add",
                                                                        -1))).then(
                                                            (value) {
                                                          setState(() {
                                                            isLoading = true;
                                                            get_question_bank();
                                                          });
                                                        });
                                                      });
                                                    },
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  Colors.red),
                                                    ),
                                                    child: Text(
                                                      'Next',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15.0,
                                                        decoration:
                                                            TextDecoration.none,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ] else if (questiontypeValue ==
                                                    2) ...[
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    LecturerAssessmentQuestionBankAddEssay(
                                                                        widget
                                                                            .question_bank_id,
                                                                        "add",
                                                                        -1))).then(
                                                            (value) {
                                                          setState(() {
                                                            isLoading = true;
                                                            get_question_bank();
                                                          });
                                                        });
                                                      });
                                                    },
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  Colors.red),
                                                    ),
                                                    child: Text(
                                                      'Next',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15.0,
                                                        decoration:
                                                            TextDecoration.none,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ] else if (questiontypeValue ==
                                                    3) ...[
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    LecturerAssessmentQuestionBankAddMCQ(
                                                                        widget
                                                                            .question_bank_id,
                                                                        "add",
                                                                        -1))).then(
                                                            (value) {
                                                          setState(() {
                                                            isLoading = true;
                                                            get_question_bank();
                                                          });
                                                        });
                                                      });
                                                    },
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  Colors.red),
                                                    ),
                                                    child: Text(
                                                      'Next',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15.0,
                                                        decoration:
                                                            TextDecoration.none,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ] else if (questiontypeValue ==
                                                    4) ...[
                                                  Row(children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      LecturerAssessmentQuestionBankAddTF(
                                                                          widget
                                                                              .question_bank_id,
                                                                          "add",
                                                                          -1))).then(
                                                              (value) {
                                                            setState(() {
                                                              isLoading = true;
                                                              get_question_bank();
                                                            });
                                                          });
                                                        });
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors.red),
                                                      ),
                                                      child: Text(
                                                        'Next',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.0,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                  ])
                                                ] else if (questiontypeValue ==
                                                    5) ...[
                                                  Row(children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      LecturerAssessmentQuestionBankAddMS(
                                                                          widget
                                                                              .question_bank_id,
                                                                          "add",
                                                                          -1))).then(
                                                              (value) {
                                                            setState(() {
                                                              isLoading = true;
                                                              get_question_bank();
                                                            });
                                                          });
                                                        });
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors.red),
                                                      ),
                                                      child: Text(
                                                        'Next',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.0,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                  ])
                                                ] else if (questiontypeValue ==
                                                    6) ...[
                                                  Row(children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      LecturerAssessmentQuestionBankAddSA(
                                                                          widget
                                                                              .question_bank_id,
                                                                          "add",
                                                                          -1))).then(
                                                              (value) {
                                                            setState(() {
                                                              isLoading = true;
                                                              get_question_bank();
                                                            });
                                                          });
                                                        });
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors.red),
                                                      ),
                                                      child: Text(
                                                        'Next',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.0,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                  ])
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                                  });
                            },
                            child: Text('Add question'),
                          ),
                        ),
                        if (isDeleting) ...[
                          CircularProgressIndicator(),
                        ],
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
