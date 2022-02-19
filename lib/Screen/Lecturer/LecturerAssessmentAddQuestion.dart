// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerAssessmentAddMCQ.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerAssessmentAddSA.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerAssessmentAddTF.dart';
import 'package:mobile_assessment/Screen/dialog_template.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:toast/toast.dart';

import '../loading_page.dart';
import 'LecturerAssessmentAddEssay.dart';
import 'LecturerAssessmentAddMS.dart';
import 'LecturerAssessmentAddPractical.dart';

class LecturerAssessmentAddQuestion extends StatefulWidget {
  @override
  int question_paper_id = 0;
  int assessment_detail_id = 0;
  LecturerAssessmentAddQuestion(
      this.question_paper_id, this.assessment_detail_id);
  _LecturerAssessmentAddQuestionState createState() =>
      _LecturerAssessmentAddQuestionState();
}

class _LecturerAssessmentAddQuestionState
    extends State<LecturerAssessmentAddQuestion> {
  bool isLoading = true;
  bool isDeleting = false;
  // var course_data;
  // List<DropdownMenuItem<int>> course_list_items = [];
  // var courseValue;
  var assessment_data;
  var question_paper_data;
  var question_data;
  var question_type;
  var section;
  double total_mark = 0;
  List<DropdownMenuItem<int>> question_type_list_items = [];
  var questiontypeValue;
  var current_question_type;
  int questionlistLength = 0;
  var questionlistValue;
  bool success = false;
  bool isPublished = false;
  bool publishable = true;
  @override
  void initState() {
    print(widget.question_paper_id);
    get_assessment();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  get_assessment() async {
    var data = {
      'assessment_detail_id': widget.assessment_detail_id,
      "question_paper_id": widget.question_paper_id,
    };
    var res = await Api().postData(data, "getSpecificAssessmentDetail");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        setState(() {
          assessment_data = body['message'][0];
          total_mark = 0;
          section = body['section'];
          print("Assessment Add:" + assessment_data.toString());
          print(section);
          get_question_list();
        });
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print("Get assessment error" + body.toString());
    }
  }

  get_question_list() async {
    var data = {
      'question_paper_id': widget.question_paper_id,
    };
    var res = await Api().postData(data, "getAddedQuestionList");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (body['message'] != "No question found") {
        if (this.mounted) {
          setState(() {
            question_data = body['message'];
            questionlistLength = question_data['count'];
            question_paper_data = body['qp_detail'];
            for (int i = 0; i < questionlistLength; i++) {
              total_mark +=
                  double.parse(question_data[i.toString()]['raw_mark']);
            }
            if (question_paper_data['isPublished'].toString() == 'true') {
              isPublished = true;
            }
            print("Get paper" + question_paper_data.toString());
            print("Get question:" + question_data.toString());

            get_question_type();
          });
        }
      } else {
        question_data = body['message'];
        question_paper_data = body['qp_detail'];
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
    var data = {
      "question_paper_id": widget.question_paper_id,
    };
    var res = await Api().postData(data, "publishAssessmentPaper");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      setState(() {
        get_assessment();
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
          get_assessment();
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
              title:
                  Text(assessment_data['assessment_detail_title'].toString()),
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
                                      "Total mark. :" + total_mark.toString())),
                              if (question_paper_data['isPublished']
                                      .toString() !=
                                  'true') ...[
                                if (questionlistLength >=
                                    question_paper_data[
                                        'number_of_question']) ...[
                                  Expanded(
                                    flex: 4,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        for (int i = 0;
                                            i < section['count'];
                                            i++) {
                                          if (section[i.toString()]['count'] <
                                              section[i.toString()]
                                                  ['number_of_question']) {
                                            publishable = false;
                                          }
                                        }
                                        if (publishable == true) {
                                          setState(() {
                                            dialog_template().confirmation_dialog(
                                                context,
                                                "No",
                                                "Yes",
                                                "Publish confirmation",
                                                "Did you sure that you want to publish,this action cannot be undo?",
                                                () => null,
                                                () => publish_assessment());
                                          });
                                        } else {
                                          Toast.show(
                                              "Please ensure all section have enough question",
                                              context);
                                          publishable = true;
                                        }
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.red),
                                      ),
                                      child: Text(
                                        'Publish assessment',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  )
                                ]
                              ] else ...[
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Published',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 20.0,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ])),
                        Expanded(
                          child: Column(
                            children: [
                              ListView.builder(
                                  itemCount: section['count'],
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Container(
                                        child: Row(children: [
                                      Expanded(
                                          flex: 1,
                                          child: Text("Section " +
                                              section[index.toString()]
                                                      ['section_number']
                                                  .toString() +
                                              ":" +
                                              section[index.toString()]['count']
                                                  .toString() +
                                              "/" +
                                              section[index.toString()]
                                                      ['number_of_question']
                                                  .toString())),
                                      SizedBox(width: 5),
                                    ]));
                                  }),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 17,
                          child: Column(children: [
                            Text(
                              "Question List",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SingleChildScrollView(
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
                                      if (isPublished == false) ...[
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
                                      ]
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
                                                itemBuilder: (context, index) {
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
                                                                question_data[index
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
                                                                  ['raw_mark'],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        if (isPublished ==
                                                            false) ...[
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
                                                                                LecturerAssessmentAddPractical(widget.question_paper_id, "edit", question_data[index.toString()]['question_paper_detail_id']))).then(
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            true;
                                                                        get_assessment();
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
                                                                                LecturerAssessmentAddEssay(widget.question_paper_id, "edit", question_data[index.toString()]['question_paper_detail_id']))).then(
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            true;
                                                                        get_assessment();
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
                                                                                LecturerAssessmentAddMCQ(widget.question_paper_id, "edit", question_data[index.toString()]['question_paper_detail_id']))).then(
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            true;
                                                                        get_assessment();
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
                                                                                LecturerAssessmentAddTF(widget.question_paper_id, "edit", question_data[index.toString()]['question_paper_detail_id']))).then(
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            true;
                                                                        get_assessment();
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
                                                                                LecturerAssessmentAddMS(widget.question_paper_id, "edit", question_data[index.toString()]['question_paper_detail_id']))).then(
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            true;
                                                                        get_assessment();
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
                                                                                LecturerAssessmentAddSA(widget.question_paper_id, "edit", question_data[index.toString()]['question_paper_detail_id']))).then(
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            true;
                                                                        get_assessment();
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                        if (isPublished ==
                                                            false) ...[
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
                                                                        question_data[index.toString()]
                                                                            [
                                                                            'question_paper_detail_id'],
                                                                        question_data[index.toString()]
                                                                            [
                                                                            'question_type_id']),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ]));
                                                }),
                                          ),
                                        ],
                                      ),
                                    ]
                                  ],
                                ))
                          ]),
                        ),
                        SizedBox(height: 5),
                        if (isPublished == false) ...[
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
                                                      child:
                                                          DropdownButton<int>(
                                                        isExpanded: true,
                                                        items:
                                                            question_type_list_items,
                                                        value:
                                                            questiontypeValue,
                                                        onChanged: (value) =>
                                                            setState(() {
                                                          questiontypeValue =
                                                              value;
                                                        }),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5),
                                                  ]),
                                                  if (questiontypeValue ==
                                                      1) ...[
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      LecturerAssessmentAddPractical(
                                                                          widget
                                                                              .question_paper_id,
                                                                          "add",
                                                                          -1))).then(
                                                              (value) {
                                                            setState(() {
                                                              isLoading = true;
                                                              get_assessment();
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
                                                  ] else if (questiontypeValue ==
                                                      2) ...[
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      LecturerAssessmentAddEssay(
                                                                          widget
                                                                              .question_paper_id,
                                                                          "add",
                                                                          -1))).then(
                                                              (value) {
                                                            setState(() {
                                                              isLoading = true;
                                                              get_assessment();
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
                                                  ] else if (questiontypeValue ==
                                                      3) ...[
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      LecturerAssessmentAddMCQ(
                                                                          widget
                                                                              .question_paper_id,
                                                                          "add",
                                                                          -1))).then(
                                                              (value) {
                                                            setState(() {
                                                              isLoading = true;
                                                              get_assessment();
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
                                                  ] else if (questiontypeValue ==
                                                      4) ...[
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => LecturerAssessmentAddTF(
                                                                            widget
                                                                                .question_paper_id,
                                                                            "add",
                                                                            -1))).then(
                                                                    (value) {
                                                                  setState(() {
                                                                    isLoading =
                                                                        true;
                                                                    get_assessment();
                                                                  });
                                                                });
                                                              });
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .red),
                                                            ),
                                                            child: Text(
                                                              'Next',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15.0,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                            ),
                                                          ),
                                                        ])
                                                  ] else if (questiontypeValue ==
                                                      5) ...[
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => LecturerAssessmentAddMS(
                                                                            widget
                                                                                .question_paper_id,
                                                                            "add",
                                                                            -1))).then(
                                                                    (value) {
                                                                  setState(() {
                                                                    isLoading =
                                                                        true;
                                                                    get_assessment();
                                                                  });
                                                                });
                                                              });
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .red),
                                                            ),
                                                            child: Text(
                                                              'Next',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15.0,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                            ),
                                                          ),
                                                        ])
                                                  ] else if (questiontypeValue ==
                                                      6) ...[
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => LecturerAssessmentAddSA(
                                                                            widget
                                                                                .question_paper_id,
                                                                            "add",
                                                                            -1))).then(
                                                                    (value) {
                                                                  setState(() {
                                                                    isLoading =
                                                                        true;
                                                                    get_assessment();
                                                                  });
                                                                });
                                                              });
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .red),
                                                            ),
                                                            child: Text(
                                                              'Next',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15.0,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
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
                          )
                        ],
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
