// ignore_for_file: non_constant_identifier_names, must_be_immutable, override_on_non_overriding_member

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assessment/Backend/api.dart';
import 'package:mobile_assessment/Screen/Lecturer/LecturerAssessmentAddQuestion.dart';
import 'package:mobile_assessment/Screen/Lecturer/Question_Bank/LecturerAssessmentQuestionBankAddQuestion.dart';
import 'package:mobile_assessment/Screen/error_alert.dart';
import 'package:mobile_assessment/Screen/regex.dart';
import 'package:toast/toast.dart';
import '../loading_page.dart';

class LecturerAssessmentAdd extends StatefulWidget {
  @override
  int index = 0;
  String mode = "";
  LecturerAssessmentAdd(this.index, this.mode);
  _LecturerAssessmentAddState createState() => _LecturerAssessmentAddState();
}

class _LecturerAssessmentAddState extends State<LecturerAssessmentAdd> {
  bool isLoading = true;
  bool isFound = false;
  // var course_data;
  // List<DropdownMenuItem<int>> course_list_items = [];
  // var courseValue;
  var assessment_data;
  var question_data;
  var question_bank_data;
  var question_data_pass;
  bool isSubmitting = false;
  DateTime StartDate = DateTime.now();
  DateTime EndDate = DateTime.now();
  TimeOfDay StartTime = TimeOfDay.now();
  TimeOfDay EndTime = TimeOfDay.now();
  String StartDateFormated = "";
  String EndDateFormated = "";
  List<String> random_selection = ['No', 'Sequence only', 'Full random'];
  List<DropdownMenuItem<int>> random_selection_list_items = [];
  var randomselectioneValue;
  var success;
  int questionbank_length = 0;
  List<DropdownMenuItem<int>> question_bank_list_items = [];
  var questionbankValue;
  TextEditingController number_of_question = new TextEditingController();
  TextEditingController number_of_section = new TextEditingController();
  List<TextEditingController> section_num_of_question = [];
  String title = '';
  final form_key = GlobalKey<FormState>();
  int num_temp = 0;
  var section;
  @override
  void initState() {
    StartDateFormated = DateFormat('yyyy-MM-dd').format(StartDate);
    EndDateFormated = DateFormat('yyyy-MM-dd').format(EndDate);
    get_assessment();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  double TimetoDouble(TimeOfDay time) {
    return time.hour + time.minute / 60.0;
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? start_date = await showDatePicker(
        context: context,
        initialDate: StartDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2121));
    if (start_date != null && start_date != StartDate)
      setState(() {
        StartDate = start_date;
        StartDateFormated = DateFormat('yyyy-MM-dd').format(StartDate);
        if (EndDate.isBefore(StartDate)) {
          EndDate = StartDate;
          EndDateFormated = DateFormat('yyyy-MM-dd').format(EndDate);
        }
      });
  }

  Future<void> selectStartTime(BuildContext context) async {
    final TimeOfDay? start_time = await showTimePicker(
      context: context,
      initialTime: StartTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (start_time != null && start_time != StartTime) {
      setState(() {
        StartTime = start_time;
      });
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? end_date = await showDatePicker(
        context: context,
        initialDate: EndDate,
        firstDate: StartDate,
        lastDate: DateTime(2121));
    if (end_date != null && end_date != EndDate)
      setState(() {
        EndDate = end_date;
        EndDateFormated = DateFormat('yyyy-MM-dd').format(EndDate);
      });
  }

  Future<void> selectEndTime(BuildContext context) async {
    final TimeOfDay? end_time = await showTimePicker(
      context: context,
      initialTime: EndTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (end_time != null && end_time != EndTime) {
      setState(() {
        EndTime = end_time;
      });
    }
  }

  // load_course_data() async {
  //   var data = {
  //     'user_id': widget.index,
  //   };
  //   var res = await Api().postData(data, "getLecturerCourseData");
  //   var body = json.decode(res.body);
  //   if (body['success'] != null) {
  //     if (this.mounted) {
  //       setState(() {
  //         course_data = body['lecturer_course_data'];
  //         print(course_data);
  //         if (course_data != "No programme") {
  //           course_list_items = List.generate(
  //             course_data['count'],
  //             (i) => DropdownMenuItem(
  //               value: course_data[i.toString()]["assessment_plan_id"],
  //               child: Text(
  //                   "${course_data[i.toString()]["session"]} -${course_data[i.toString()]["course_title"]} - ${course_data[i.toString()]["course_code"]} "),
  //             ),
  //           );
  //           courseValue = course_data["0"]["assessment_plan_id"];
  //           print(course_list_items);
  //         }
  //         isLoading = false;
  //       });
  //     }
  //   } else {
  //     print(body);
  //   }
  // }

  get_assessment() async {
    var data = {
      'assessment_detail_id': widget.index,
    };
    var res = await Api().postData(data, "getSpecificAssessmentDetail");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        setState(() {
          assessment_data = body['message'][0];
          random_selection_list_items = List.generate(
            3,
            (i) => DropdownMenuItem(
              value: i,
              child: Text(random_selection[i]),
            ),
          );
          randomselectioneValue = 0;
          print("Assessment Add:" + assessment_data.toString());
          if (widget.mode == "edit") {
            title = "Manage assessment";
          } else {
            title = "Add assessment";
          }
          get_question_bank();
        });
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print("Get assessment error" + body.toString());
    }
  }

  get_question_bank() async {
    var data = {
      'assessment_detail_id': widget.index,
    };
    var res = await Api().postData(data, "getQuestionBank");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        if (body['message'] != "No question bank") {
          setState(() {
            question_bank_data = body['message'];
            question_bank_list_items = [];
            question_bank_list_items.add(
              DropdownMenuItem(
                value: null,
                child: Text("No need question bank"),
              ),
            );
            question_bank_list_items.addAll(List.generate(
              question_bank_data["count"],
              (i) => DropdownMenuItem(
                value: question_bank_data[i.toString()]['question_bank_id'],
                child: Text(
                    "${question_bank_data[i.toString()]['assessment_detail_title']} - ${question_bank_data[i.toString()]['question_bank_name']} - ${question_bank_data[i.toString()]['question_bank_difficulty_level']} - No. Of Q.:${question_bank_data[i.toString()]['count']}"),
              ),
            ));
            questionbankValue = null;

            print("Question bank:" + question_bank_data.toString());
            print("question bank list item" +
                question_bank_list_items.toString());
            get_question_paper();
          });
        } else {
          get_question_paper();
        }
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      print("Get question bank error" + body.toString());
    }
  }

  get_question_paper() async {
    var data = {
      'assessment_detail_id': widget.index,
    };
    var res = await Api().postData(data, "getQuestionPaper");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        if (body['message'] != "No question paper") {
          setState(() {
            isFound = true;

            question_data = body['message'][0];
            section = body['section'];
            print("Question data:" + body.toString());
            print("sec data:" + section.toString());

            StartDate =
                DateTime.parse(question_data['question_paper_start_date']);
            EndDate = DateTime.parse(question_data['question_paper_end_date']);
            StartDateFormated = DateFormat('yyyy-MM-dd').format(StartDate);
            EndDateFormated = DateFormat('yyyy-MM-dd').format(EndDate);
            StartTime = TimeOfDay(
                hour: int.parse(
                    question_data['question_paper_start_time'].split(":")[0]),
                minute: int.parse(
                    question_data['question_paper_start_time'].split(":")[1]));
            EndTime = TimeOfDay(
                hour: int.parse(
                    question_data['question_paper_end_time'].split(":")[0]),
                minute: int.parse(
                    question_data['question_paper_end_time'].split(":")[1]));
            randomselectioneValue = question_data['random_type'];
            questionbankValue = question_data['question_bank_id'];
            number_of_question.text =
                question_data['number_of_question'].toString();
            number_of_section.text =
                question_data['number_of_section'].toString();
            for (int j = 0; j < int.parse(number_of_section.text); j++) {
              section_num_of_question.add(new TextEditingController());
              section_num_of_question[j].text =
                  section[j]['number_of_question'].toString();
            }

            isLoading = false;
          });
        } else {
          setState(() {
            print("No assessment found");
            number_of_section.text = '1';
            section_num_of_question.add(new TextEditingController());
            isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        error_alert().alert(context, "Error", body.toString());

        isLoading = false;
      });
      print("Get assessment error" + body.toString());
    }
  }

  cal_total_question() async {
    num_temp = 0;
    int length = int.parse(number_of_section.text);
    print(length);
    print(section_num_of_question);
    for (int i = 0; i < length; i++) {
      num_temp += int.parse(section_num_of_question[i].text);
    }

    return num_temp.toString();
  }

  save_question_paper() async {
    var data = {
      'assessment_detail_id': widget.index,
      'question_paper_start_date': StartDateFormated,
      'question_paper_start_time': StartTime.hour.toString().padLeft(2, '0') +
          ":" +
          StartTime.minute.toString().padLeft(2, '0'),
      'question_paper_end_date': EndDateFormated,
      'question_paper_end_time': EndTime.hour.toString().padLeft(2, '0') +
          ":" +
          EndTime.minute.toString().padLeft(2, '0'),
      'random_type': randomselectioneValue,
      'question_bank_id': questionbankValue,
      'number_of_question': number_of_question.text,
      'number_of_section': number_of_section.text,
    };
    var res = await Api().postData(data, "saveQuestionPaper");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        success = true;
        return body;
      }
    } else {
      error_alert().alert(context, "Error", body.toString());

      success = false;

      print(" save_question_paper" + body.toString());
    }
  }

  save_section(index, qpid) async {
    var data = {
      'question_paper_id': qpid,
      'number_of_question': section_num_of_question[index].text,
      'section_number': index + 1,
    };
    print(data);
    var res = await Api().postData(data, "saveQuestionPaperSection");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        if (index == int.parse(number_of_section.text) - 1) {
          return body['success'];
        }
      }
    } else {
      success = false;
      error_alert().alert(context, "Error", body.toString());

      print(" save_question_paper" + body.toString());
    }
  }

  insert_question_bank_data(qpid) async {
    var data = {
      'question_bank_id': questionbankValue,
      'question_paper_id': qpid
    };
    var res = await Api().postData(data, "insertQuestionBankData");
    var body = json.decode(res.body);
    if (body['success'] != null) {
      if (this.mounted) {
        success = true;
        setState(() {
          print(body);
        });
      }
    } else {
      success = false;
      error_alert().alert(context, "Error", body.toString());

      print(" insert_question_bank" + body.toString());
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
            title: Text(title),
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
              title: Text(title),
              backgroundColor: Colors.orange,
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(flex: 1, child: Text("Course:")),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    assessment_data['course_title'].toString()))
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(flex: 1, child: Text("Assessment:")),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    assessment_data['assessment_detail_title']
                                        .toString()))
                          ],
                        ),
                        SizedBox(height: 5),
                        Form(
                            key: form_key,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text("Start date and time:")),
                                    Expanded(
                                        flex: 3,
                                        child: Text(StartDateFormated +
                                            " " +
                                            StartTime.hour
                                                .toString()
                                                .padLeft(2, '0') +
                                            ":" +
                                            StartTime.minute
                                                .toString()
                                                .padLeft(2, '0'))),
                                  ],
                                ),
                                if (isFound == false) ...[
                                  Row(
                                    children: [
                                      Expanded(flex: 2, child: Text("")),
                                      Expanded(
                                          flex: 2,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                selectStartDate(context),
                                            child: Text('Select date'),
                                          )),
                                      SizedBox(width: 5),
                                      Expanded(
                                          flex: 2,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                selectStartTime(context),
                                            child: Text('Select time'),
                                          )),
                                    ],
                                  ),
                                ] else if (isFound == true) ...[
                                  if (question_data['isPublished'] != null &&
                                      question_data['isPublished'].toString() !=
                                          'true') ...[
                                    Row(
                                      children: [
                                        Expanded(flex: 2, child: Text("")),
                                        Expanded(
                                            flex: 2,
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  selectStartDate(context),
                                              child: Text('Select date'),
                                            )),
                                        SizedBox(width: 5),
                                        Expanded(
                                            flex: 2,
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  selectStartTime(context),
                                              child: Text('Select time'),
                                            )),
                                      ],
                                    ),
                                  ]
                                ],
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text("End date and time:")),
                                    Expanded(
                                        flex: 3,
                                        child: Text(EndDateFormated +
                                            " " +
                                            EndTime.hour
                                                .toString()
                                                .padLeft(2, '0') +
                                            ":" +
                                            EndTime.minute
                                                .toString()
                                                .padLeft(2, '0'))),
                                  ],
                                ),
                                if (isFound == false) ...[
                                  Row(children: [
                                    Expanded(flex: 2, child: Text("")),
                                    Expanded(
                                        flex: 2,
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              selectEndDate(context),
                                          child: Text('Select date'),
                                        )),
                                    SizedBox(width: 5),
                                    Expanded(
                                        flex: 2,
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              selectEndTime(context),
                                          child: Text('Select time'),
                                        )),
                                  ]),
                                ] else if (isFound == true) ...[
                                  if (question_data['isPublished'] != null &&
                                      question_data['isPublished'].toString() !=
                                          'true') ...[
                                    Row(children: [
                                      Expanded(flex: 2, child: Text("")),
                                      Expanded(
                                          flex: 2,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                selectEndDate(context),
                                            child: Text('Select date'),
                                          )),
                                      SizedBox(width: 5),
                                      Expanded(
                                          flex: 2,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                selectEndTime(context),
                                            child: Text('Select time'),
                                          )),
                                    ])
                                  ]
                                ],
                                if (isFound == false) ...[
                                  Row(children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text('Random question'),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: DropdownButton<int>(
                                        isExpanded: true,
                                        items: random_selection_list_items,
                                        value: randomselectioneValue,
                                        onChanged: (value) => setState(() {
                                          randomselectioneValue = value;
                                        }),
                                      ),
                                    ),
                                  ]),
                                  Row(children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text('Number of section'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        enabled: false,
                                        keyboardType: TextInputType.number,
                                        controller: number_of_section,
                                        validator: (sectionnumberValue) {
                                          if (sectionnumberValue!.isEmpty) {
                                            return 'Please enter number';
                                          } else if (regex().isNumberOnly(
                                                  sectionnumberValue) ==
                                              false) {
                                            return 'Please enter valid number';
                                          } else if (int.parse(
                                                  sectionnumberValue) <
                                              1) {
                                            return "Mininum section number is 1";
                                          }
                                          number_of_section.text =
                                              sectionnumberValue;
                                          return null;
                                        },
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.]'))
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              number_of_section.text =
                                                  (int.parse(number_of_section
                                                              .text) +
                                                          1)
                                                      .toString();
                                              section_num_of_question.add(
                                                  new TextEditingController());
                                            });
                                          },
                                          icon: new Icon(Icons.add)),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                          onPressed: () {
                                            if (int.parse(number_of_section
                                                        .text) -
                                                    1 >
                                                0) {
                                              setState(() {
                                                number_of_section.text =
                                                    (int.parse(number_of_section
                                                                .text) -
                                                            1)
                                                        .toString();
                                                section_num_of_question
                                                    .removeLast();
                                              });
                                            }
                                          },
                                          icon: new Icon(Icons.remove)),
                                    ),
                                  ]),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: ListView.builder(
                                              itemCount: int.parse(
                                                  number_of_section.text),
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return Container(
                                                    child: Row(children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text("Sec " +
                                                          (index + 1)
                                                              .toString() +
                                                          " num of Q.:")),
                                                  SizedBox(width: 5),
                                                  Expanded(
                                                    flex: 2,
                                                    child: TextFormField(
                                                      keyboardType:
                                                          TextInputType
                                                              .multiline,
                                                      controller:
                                                          section_num_of_question[
                                                              index],
                                                      maxLines: null,
                                                      validator:
                                                          (sectionnumberValue) {
                                                        if (sectionnumberValue!
                                                            .isEmpty) {
                                                          return 'Please enter number';
                                                        } else if (regex()
                                                                .isNumberOnly(
                                                                    sectionnumberValue) ==
                                                            false) {
                                                          return 'Please enter valid number';
                                                        } else if (int.parse(
                                                                sectionnumberValue) <
                                                            1) {
                                                          return "Mininum section number is 1";
                                                        }
                                                        section_num_of_question[
                                                                    index]
                                                                .text =
                                                            sectionnumberValue;
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                ]));
                                              })),
                                    ],
                                  )
                                ] else if (isFound == true) ...[
                                  if (question_data['isPublished'] != null &&
                                      question_data['isPublished'].toString() !=
                                          'true') ...[
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Random question'),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButton<int>(
                                          isExpanded: true,
                                          items: random_selection_list_items,
                                          value: randomselectioneValue,
                                          onChanged: (value) => setState(() {
                                            randomselectioneValue = value;
                                          }),
                                        ),
                                      ),
                                    ]),
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Number of section'),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          enabled: false,
                                          keyboardType: TextInputType.number,
                                          controller: number_of_section,
                                          validator: (sectionnumberValue) {
                                            if (sectionnumberValue!.isEmpty) {
                                              return 'Please enter number';
                                            } else if (regex().isNumberOnly(
                                                    sectionnumberValue) ==
                                                false) {
                                              return 'Please enter valid number';
                                            } else if (int.parse(
                                                    sectionnumberValue) <
                                                1) {
                                              return "Mininum section number is 1";
                                            }
                                            number_of_section.text =
                                                sectionnumberValue;
                                            return null;
                                          },
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.]'))
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                number_of_section.text =
                                                    (int.parse(number_of_section
                                                                .text) +
                                                            1)
                                                        .toString();
                                                section_num_of_question.add(
                                                    new TextEditingController());
                                              });
                                            },
                                            icon: new Icon(Icons.add)),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                            onPressed: () {
                                              if (int.parse(number_of_section
                                                          .text) -
                                                      1 >
                                                  0) {
                                                setState(() {
                                                  number_of_section
                                                      .text = (int.parse(
                                                              number_of_section
                                                                  .text) -
                                                          1)
                                                      .toString();
                                                  section_num_of_question
                                                      .removeLast();
                                                });
                                              }
                                            },
                                            icon: new Icon(Icons.remove)),
                                      ),
                                    ]),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: ListView.builder(
                                                itemCount: int.parse(
                                                    number_of_section.text),
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                      child: Row(children: [
                                                    Expanded(
                                                        flex: 1,
                                                        child: Text("Sec " +
                                                            (index + 1)
                                                                .toString() +
                                                            " num of Q.:")),
                                                    SizedBox(width: 5),
                                                    Expanded(
                                                      flex: 2,
                                                      child: TextFormField(
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        controller:
                                                            section_num_of_question[
                                                                index],
                                                        maxLines: null,
                                                        validator:
                                                            (sectionnumberValue) {
                                                          if (sectionnumberValue!
                                                              .isEmpty) {
                                                            return 'Please enter number';
                                                          } else if (regex()
                                                                  .isNumberOnly(
                                                                      sectionnumberValue) ==
                                                              false) {
                                                            return 'Please enter valid number';
                                                          } else if (int.parse(
                                                                  sectionnumberValue) <
                                                              1) {
                                                            return "Mininum section number is 1";
                                                          }
                                                          section_num_of_question[
                                                                      index]
                                                                  .text =
                                                              sectionnumberValue;
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(width: 5),
                                                  ]));
                                                })),
                                      ],
                                    )
                                  ] else if (question_data['isPublished']
                                          .toString() ==
                                      'true') ...[
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Random question'),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButton<int>(
                                          isExpanded: true,
                                          items: random_selection_list_items,
                                          value: randomselectioneValue,
                                          onChanged: null,
                                        ),
                                      ),
                                    ]),
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Number of section'),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          enabled: false,
                                          controller: number_of_section,
                                          validator: (sectionnumberValue) {
                                            if (sectionnumberValue!.isEmpty) {
                                              return 'Please enter number';
                                            } else if (regex().isNumberOnly(
                                                    sectionnumberValue) ==
                                                false) {
                                              return 'Please enter valid number';
                                            } else if (int.parse(
                                                    sectionnumberValue) <
                                                1) {
                                              return "Mininum section number is 1";
                                            }
                                            number_of_section.text =
                                                sectionnumberValue;
                                            return null;
                                          },
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.]'))
                                          ],
                                        ),
                                      ),
                                    ])
                                  ],
                                ],
                                if (widget.mode == 'add') ...[
                                  if (isFound == false) ...[
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Question bank'),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButton<int>(
                                          isExpanded: true,
                                          items: question_bank_list_items,
                                          value: questionbankValue,
                                          onChanged: (value) => setState(() {
                                            print("Value" +
                                                value.toString() +
                                                "QuestionTypeValue" +
                                                questionbankValue.toString());
                                            questionbankValue = value;
                                          }),
                                        ),
                                      ),
                                    ])
                                  ],
                                ],
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (questionbankValue != null &&
                                        isFound == false) ...[
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LecturerAssessmentQuestionBankAddQuestion(
                                                            questionbankValue))).then(
                                                (value) {
                                              setState(() {
                                                isLoading = true;
                                                get_assessment();
                                              });
                                            });
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.green),
                                          ),
                                          child: Text(
                                              "View question bank content"))
                                    ],
                                    ElevatedButton(
                                        onPressed: () {
                                          if (form_key.currentState!
                                              .validate()) {
                                            if (isSubmitting == false) {
                                              setState(() {
                                                isSubmitting = true;
                                              });
                                              if (EndDate.year ==
                                                      StartDate.year &&
                                                  EndDate.month ==
                                                      StartDate.month &&
                                                  EndDate.day ==
                                                      StartDate.day) {
                                                if (TimetoDouble(EndTime) >
                                                    TimetoDouble(StartTime)) {
                                                  cal_total_question()
                                                      .then((value) {
                                                    number_of_question.text =
                                                        value;
                                                    save_question_paper()
                                                        .then((value) {
                                                      success =
                                                          value['success'];
                                                      question_data_pass =
                                                          value[
                                                              'question_paper'];

                                                      if (success == true) {
                                                        for (int i = 0;
                                                            i <
                                                                int.parse(
                                                                    number_of_section
                                                                        .text);
                                                            i++) {
                                                          save_section(
                                                                  i,
                                                                  question_data_pass[
                                                                      'question_paper_id'])
                                                              .then((value) {
                                                            if (value == true) {
                                                              if (questionbankValue !=
                                                                      null &&
                                                                  isFound ==
                                                                      false) {
                                                                insert_question_bank_data(
                                                                    question_data_pass[
                                                                        'question_paper_id']);
                                                              }
                                                              setState(() {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => LecturerAssessmentAddQuestion(
                                                                            question_data_pass[
                                                                                'question_paper_id'],
                                                                            widget.index))).then(
                                                                    (value) {
                                                                  setState(() {
                                                                    isLoading =
                                                                        true;
                                                                    isSubmitting =
                                                                        false;
                                                                    get_assessment();
                                                                  });
                                                                });
                                                              });
                                                            }
                                                          });
                                                        }
                                                      }
                                                    });
                                                  });
                                                } else {
                                                  Toast.show("Invalid end time",
                                                      context);
                                                  isSubmitting = false;
                                                }
                                              } else {
                                                cal_total_question()
                                                    .then((value) {
                                                  number_of_question.text =
                                                      value;

                                                  save_question_paper()
                                                      .then((value) {
                                                    success = value['success'];
                                                    question_data_pass =
                                                        value['question_paper'];
                                                    if (success == true) {
                                                      for (int i = 0;
                                                          i <
                                                              int.parse(
                                                                  number_of_section
                                                                      .text);
                                                          i++) {
                                                        save_section(
                                                                i,
                                                                question_data_pass[
                                                                    'question_paper_id'])
                                                            .then((value) {
                                                          if (value == true) {
                                                            if (questionbankValue !=
                                                                    null &&
                                                                isFound ==
                                                                    false) {
                                                              insert_question_bank_data(
                                                                  question_data_pass[
                                                                      'question_paper_id']);
                                                            }
                                                            setState(() {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => LecturerAssessmentAddQuestion(
                                                                          question_data_pass[
                                                                              'question_paper_id'],
                                                                          widget
                                                                              .index))).then(
                                                                  (value) {
                                                                setState(() {
                                                                  isLoading =
                                                                      true;
                                                                  isSubmitting =
                                                                      false;
                                                                  get_assessment();
                                                                });
                                                              });
                                                            });
                                                          }
                                                        });
                                                      }
                                                    }
                                                  });
                                                });
                                              }
                                            }
                                          }
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.green),
                                        ),
                                        child: Text(isSubmitting
                                            ? "Submitting..."
                                            : "Next"))
                                  ],
                                ),
                              ],
                            )),
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
