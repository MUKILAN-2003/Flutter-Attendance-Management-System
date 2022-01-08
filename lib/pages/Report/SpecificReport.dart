// ignore_for_file: file_names
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nscet_ams/services/reportDB.dart';
import 'package:nscet_ams/utils/SnackBar.dart';
import 'package:nscet_ams/utils/appBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpecificReport extends StatefulWidget {
  String role, selectedDate, selectedClass;
  reportDB report;
  SpecificReport(
      {Key? key,
      required this.role,
      required this.selectedDate,
      required this.selectedClass,
      required this.report})
      : super(key: key);

  @override
  _SpecificReportState createState() => _SpecificReportState();
}

class _SpecificReportState extends State<SpecificReport> {
  bool isThereReport = false;
  bool isThereFN = false;
  bool isThereAN = false;
  List<dynamic> presentFN = <dynamic>[];
  List<dynamic> presentAN = <dynamic>[];
  List<dynamic> regno = <dynamic>[];
  List<dynamic> mobile = <dynamic>[];
  List<dynamic> name = <dynamic>[];
  int total = 0;
  int noOfAbsenteesFN = 0;
  int noOfAbsenteesAN = 0;
  int noOfPresentsFN = 0;
  int noOfPresentsAN = 0;

  @override
  void initState() {
    super.initState();
    widget.report
        .getDayReport(widget.selectedClass, widget.selectedDate)
        .then((value) {
      if (value != null) {
        setState(() {
          isThereReport = true;
          total = value['regNo'].length;
          regno = value['regNo'];
          mobile = value['mobileno'];
          name = value['name'];
        });
        if (value["presentFN"] != null) {
          setState(() {
            isThereFN = true;
            presentFN = value["presentFN"];

            noOfAbsenteesFN =
                value["presentFN"].where((c) => c == false).toList().length;
            noOfPresentsFN = value['regNo'].length - noOfAbsenteesFN;
          });
        }
        if (value["presentAN"] != null) {
          setState(() {
            isThereAN = true;
            presentAN = value["presentAN"];
            noOfAbsenteesAN =
                value["presentAN"].where((c) => c == false).toList().length;
            noOfPresentsAN = value['regNo'].length - noOfAbsenteesAN;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> absenteesListFN = <Widget>[];
    List<Widget> absenteesListAN = <Widget>[];

    if (isThereFN) {
      for (int i = 0; i < presentFN.length; i++) {
        if (!presentFN[i]) {
          absenteesListFN.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                regno[i],
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16),
              ),
              Text(name[i],
                  textAlign: TextAlign.start, style: TextStyle(fontSize: 16))
            ],
          ));
        }
      }
    }
    if (isThereAN) {
      for (int i = 0; i < presentAN.length; i++) {
        if (!presentAN[i]) {
          absenteesListAN.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                regno[i],
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.start,
              ),
              Text(
                name[i],
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.start,
              )
            ],
          ));
        }
      }
    }

    return Scaffold(
        appBar: getAppbar(context, 'Class Report'),
        body: isThereReport
            ? ListView(
                children: [
                  Text(
                    widget.selectedClass + " Report",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Date : " + widget.selectedDate,
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "Total No.Of Students : " + total.toString(),
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  Divider(color: Colors.black),
                  isThereFN
                      ? Column(
                          children: [
                            const Text(
                              "FORENOON",
                              style: TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    "No.Of Absentees : " +
                                        noOfAbsenteesFN.toString(),
                                    style: TextStyle(fontSize: 16)),
                                Text(
                                    "No.Of Presents : " +
                                        noOfPresentsFN.toString(),
                                    style: TextStyle(fontSize: 16))
                              ],
                            ),
                            const SizedBox(height: 5.0),
                            const Text(
                              "Absentees list",
                              style: TextStyle(fontSize: 22),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: absenteesListFN,
                            ),
                            const SizedBox(height: 20.0),
                            Divider(color: Colors.black),
                          ],
                        )
                      : const Padding(
                          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                          child: Text("No Report for FORENOON"),
                        ),
                  isThereFN
                      ? Column(
                          children: [
                            const Text(
                              "AFTERNOON",
                              style: TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("No.Of Absentees : " +
                                    noOfAbsenteesAN.toString()),
                                Text("No.Of Presents : " +
                                    noOfPresentsAN.toString())
                              ],
                            ),
                            const SizedBox(height: 5.0),
                            const Text(
                              "Absentees list",
                              style: TextStyle(fontSize: 22),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: absenteesListAN,
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        )
                      : const Padding(
                          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                          child: Text("No Report for AFTERNOON"),
                        ),
                  (widget.role == "HOD")
                      ? ElevatedButton(
                          onPressed: () async {
                            dynamic result = await widget.report.sendReport(
                                regno,
                                name,
                                mobile,
                                presentFN,
                                presentAN,
                                widget.selectedDate,
                                widget.selectedClass);
                            if (result == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  getSnackBar("Report sent to your mail ."));
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(getSnackBar(result.toString()));
                            }
                          },
                          child: const Text("Send To Mail"))
                      : const SizedBox(height: 10.0),
                ],
              )
            : const Padding(
                padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                child: Text("No Report"),
              ));
  }
}
