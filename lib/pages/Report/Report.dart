// ignore_for_file: file_names
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nscet_ams/pages/Report/SpecificReport.dart';
import 'package:nscet_ams/services/reportDB.dart';
import 'package:nscet_ams/utils/appBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  late SharedPreferences sharedPrefs;
  reportDB report = reportDB('', '');

  dynamic todayDate = DateTime.now();

  String selectedDate = '';
  String selectedClass = '';
  String role = '';
  List className = <Object>[];

  @override
  void initState() {
    super.initState();

    String todatDate = todayDate.day.toString() +
        "-" +
        todayDate.month.toString() +
        "-" +
        todayDate.year.toString();

    SharedPreferences.getInstance().then((prefs) {
      setState(() => sharedPrefs = prefs);
      report = reportDB(
          sharedPrefs.getString('dept'), sharedPrefs.getString('email'));
      report.getClass().then((value) {
        setState(() {
          selectedDate = todatDate;
          selectedClass = value[0];
          className = value;
          role = sharedPrefs.getString('role').toString();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> dropDownClassess = <DropdownMenuItem>[];
    for (int i = 0; i < className.length; i++) {
      dropDownClassess.add(DropdownMenuItem(
        alignment: Alignment.center,
        value: className[i],
        child: Text(className[i]),
      ));
    }

    return Scaffold(
      appBar: getAppbar(context, "Report"),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        children: [
          const SizedBox(height: 40.0),
          const Text(
            'Select a Date',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 24, color: Color.fromRGBO(27, 27, 27, 1)),
          ),
          const SizedBox(height: 10.0),
          Container(
            height: 120,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: DateTime.now(),
              maximumDate: DateTime.now(),
              onDateTimeChanged: (DateTime newDateTime) {
                String todatDate = newDateTime.day.toString() +
                    "-" +
                    newDateTime.month.toString() +
                    "-" +
                    newDateTime.year.toString();
                setState(() {
                  selectedDate = todatDate;
                });
              },
            ),
          ),
          const SizedBox(height: 40.0),
          const Text(
            "Select a class",
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 24, color: Color.fromRGBO(27, 27, 27, 1)),
          ),
          Form(
            child: DropdownButton(
              isExpanded: true,
              value: selectedClass,
              items: dropDownClassess,
              onChanged: (dynamic val) {
                setState(() {
                  selectedClass = val.toString();
                });
              },
            ),
          ),
          const SizedBox(height: 30.0),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpecificReport(
                      role: role,
                      selectedClass: selectedClass,
                      selectedDate: selectedDate,
                      report: report,
                    ),
                  ),
                );
              },
              child: const Text("Show Report"))
        ],
      ),
    );
  }
}
