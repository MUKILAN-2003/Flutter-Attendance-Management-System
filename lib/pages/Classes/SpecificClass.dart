// ignore_for_file: file_names

import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nscet_ams/services/studentDb.dart';
import 'package:nscet_ams/utils/SidebarNav.dart';
import 'package:nscet_ams/utils/SnackBar.dart';
import 'package:nscet_ams/utils/appBar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class SpecificClass extends StatefulWidget {
  const SpecificClass({Key? key}) : super(key: key);

  @override
  _SpecificClassState createState() => _SpecificClassState();
}

class _SpecificClassState extends State<SpecificClass> {
  String newStudentName = '';
  String newStudentNumber = '';
  String newRegNo = '';
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List;

    StudentDb studentDb = StudentDb(dept: args[0], className: args[1]);

    return Scaffold(
      appBar: getAppbar(context, args[1].toString().toUpperCase()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton.extended(
              label: const Text("Add by Excel"),
              icon: const Icon(Icons.add),
              backgroundColor: const Color.fromRGBO(66, 53, 55, 1),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['xlsx'],
                );
                var bytes = File(result!.paths[0].toString()).readAsBytesSync();
                var excel = Excel.decodeBytes(bytes);

                var listStudents = [];
                var what_show = 'Students added successfuly !';
                for (var table in excel.tables.keys) {
                  var i = 0;
                  for (var row in excel.tables[table]!.rows) {
                    if (i == 0) {
                      if (row[0]!.value == 'Name' &&
                          row[1]!.value == 'Roll Number' &&
                          row[2]!.value == 'Mobile Number') {
                        i = 1;
                        continue;
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(getSnackBar("Check XLSX file !"));
                        Navigator.pop(context, true);
                        what_show = 'Check XLSX file !';
                        break;
                      }
                    }
                    if (row.length >= 3) {
                      listStudents.add([
                        row[0]!.value,
                        row[1]!.value,
                        row[2]!.value,
                      ]);
                    }
                  }
                  var addByXlsx = await studentDb.addStudentXLSX(listStudents);
                  if (addByXlsx == null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(getSnackBar(what_show));
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(getSnackBar("try Again !"));
                  }
                }
              },
            ),
            FloatingActionButton.extended(
              heroTag: null,
              label: const Text("Add"),
              icon: const Icon(Icons.add),
              backgroundColor: const Color.fromRGBO(66, 53, 55, 1),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        elevation: 5.0,
                        contentPadding: const EdgeInsets.all(25.0),
                        title: const Text(
                          "ADD A STUDENT",
                          textAlign: TextAlign.center,
                        ),
                        children: [
                          Form(
                              key: _formkey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    validator: (val) => val!.isEmpty
                                        ? 'Enter a student name'
                                        : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Student Name',
                                      labelStyle: TextStyle(
                                          color: Color.fromRGBO(66, 53, 55, 1)),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Color.fromRGBO(199, 68, 109, 1),
                                            width: 1.5),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Color.fromRGBO(199, 68, 109, 1),
                                            width: 1.5),
                                      ),
                                    ),
                                    cursorColor:
                                        const Color.fromRGBO(199, 68, 109, 1),
                                    onChanged: (val) {
                                      setState(() {
                                        newStudentName = val;
                                      });
                                    },
                                  ),
                                  TextFormField(
                                    validator: (val) => val!.isEmpty
                                        ? 'Enter Mobile Number'
                                        : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Student Number',
                                      labelStyle: TextStyle(
                                          color: Color.fromRGBO(66, 53, 55, 1)),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Color.fromRGBO(199, 68, 109, 1),
                                            width: 1.5),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Color.fromRGBO(199, 68, 109, 1),
                                            width: 1.5),
                                      ),
                                    ),
                                    cursorColor:
                                        const Color.fromRGBO(199, 68, 109, 1),
                                    onChanged: (val) {
                                      setState(() {
                                        newStudentNumber = val;
                                      });
                                    },
                                  ),
                                  TextFormField(
                                    validator: (val) => val!.isEmpty
                                        ? 'Enter a register number'
                                        : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Register Number',
                                      labelStyle: TextStyle(
                                          color: Color.fromRGBO(66, 53, 55, 1)),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Color.fromRGBO(199, 68, 109, 1),
                                            width: 1.5),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Color.fromRGBO(199, 68, 109, 1),
                                            width: 1.5),
                                      ),
                                    ),
                                    cursorColor:
                                        const Color.fromRGBO(199, 68, 109, 1),
                                    onChanged: (val) {
                                      setState(() {
                                        newRegNo = val;
                                      });
                                    },
                                  ),
                                ],
                              )),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                primary: const Color.fromRGBO(66, 53, 55, 1)),
                            onPressed: () async {
                              if (_formkey.currentState!.validate()) {
                                dynamic result = await studentDb.addStudent(
                                    newStudentName, newRegNo, newStudentNumber);
                                if (result != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      getSnackBar(result.toString()));
                                }
                                Navigator.pop(context, true);
                              }
                            },
                            child: const Text(
                              "ADD",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: studentDb.getClassStudentsRef(),
        builder: (context, snapshot) {
          final tilesList = <Widget>[];

          if (snapshot.hasData && !snapshot.hasError && snapshot.data != null) {
            final contents = (snapshot.data as Event).snapshot.value;

            if (contents != null) {
              Map<dynamic, dynamic> orders = Map.from(contents);

              tilesList.add(ListTile(
                title: Padding(
                  padding: EdgeInsets.fromLTRB(2, 8, 2, 8),
                  child: Text(
                    "Total number of students : " + orders.length.toString(),
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ));

              orders.forEach((key, value) {
                tilesList.add(ListTile(
                    tileColor: const Color.fromRGBO(199, 68, 109, 0.2),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              value['name'],
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontSize: 20),
                            ),
                            Text(
                              value['reg_no'],
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_rounded,
                            color: Color.fromRGBO(80, 53, 55, 1),
                            size: 28,
                          ),
                          onPressed: () {
                            studentDb.deleteClass(key);
                          },
                        ),
                      ],
                    )));

                tilesList.add(
                  const Divider(
                    height: 20,
                    thickness: 2,
                    indent: 1,
                    endIndent: 1,
                  ),
                );
              });
            } else {
              tilesList.add(const ListTile(
                title: Text(
                  "No Students Added !",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ));
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 80),
            children: tilesList,
          );
        },
      ),
    );
  }
}
