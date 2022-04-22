// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class reportDB {
  final database = FirebaseDatabase.instance.reference();
  final pdf = pw.Document();

  dynamic dept;
  dynamic email;

  reportDB(this.dept, this.email);

  Future getClass() async {
    final classDb = database.child("/classes/" + dept! + '/classes_list');
    dynamic value = await classDb.get();

    return value.value;
  }

  Future getDayReport(classname, date) async {
    final attedenceDb =
        database.child("/attedence/" + dept! + "/" + classname + "/" + date);
    DataSnapshot result = await attedenceDb.get();

    if (result.value != null) {
      dynamic resultFN = result.value["FN"];
      dynamic resultAN = result.value["AN"];

      dynamic regNo = result.value["FN"]['regNo'];
      dynamic name = result.value["FN"]['name'];

      if (resultFN != null && resultAN != null) {
        dynamic presentFN = resultFN["attedenceList"];
        dynamic presentAN = resultAN["attedenceList"];
        return {
          "regNo": regNo,
          "name": name,
          "presentFN": presentFN,
          "presentAN": presentAN
        };
      }
      if (resultFN != null && resultAN == null) {
        dynamic presentFN = resultFN["attedenceList"];
        return {
          "regNo": result.value["FN"]['regNo'],
          "name": result.value["FN"]['name'],
          "presentFN": presentFN,
          "presentAN": null
        };
      }
      if (resultFN == null && resultAN != null) {
        dynamic presentAN = resultAN["attedenceList"];
        return {
          "regNo": result.value["AN"]['regNo'],
          "name": result.value["AN"]['name'],
          "presentFN": null,
          "presentAN": presentAN
        };
      }
    }
    return null;
  }

  void writeOnPdf(
      regNo, name, presentFN, presentAN, selectedDate, selectedClass) {
    List<List<dynamic>> table = [
      <dynamic>['Register No', 'Name', 'Forenoon', 'Afternoon']
    ];
    List<String> morningA = <String>[];
    List<String> afternoonA = <String>[];

    for (int i = 0; i < regNo.length; i++) {
      if (!presentFN.isEmpty) {
        if (presentFN[i]) {
          morningA.add("Present");
        } else {
          morningA.add("Absent X");
        }
      } else {
        morningA.add(" ");
      }

      if (!presentAN.isEmpty) {
        if (presentAN[i]) {
          afternoonA.add("Present");
        } else {
          afternoonA.add("Absent X");
        }
      } else {
        afternoonA.add(" ");
      }
    }
    for (int i = 0; i < regNo.length; i++) {
      if (afternoonA[i] == ' ') {
        if (morningA[i] == 'Absent X') {
          table.add(<dynamic>[
            regNo[i],
            name[i],
            morningA[i],
            afternoonA[i],
          ]);
        }
      } else if (afternoonA[i] == 'Absent X') {
        table.add(<dynamic>[
          regNo[i],
          name[i],
          morningA[i],
          afternoonA[i],
        ]);
      }
    }

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        DateTime currentPhoneDate = DateTime.now();

        String todatDate = currentPhoneDate.day.toString() +
            "-" +
            currentPhoneDate.month.toString() +
            "-" +
            currentPhoneDate.year.toString();

        return <pw.Widget>[
          pw.Text('NADAR SARASWATHI COLLLAGE OF ENGINEERING AND TECHNOLOGY',
              textScaleFactor: 2.1, textAlign: pw.TextAlign.center),
          pw.Padding(padding: const pw.EdgeInsets.all(10)),
          pw.Header(
              level: 0,
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: <pw.Widget>[
                    pw.Text('Department : ' + dept, textScaleFactor: 1.7),
                    pw.Text('Date : ' + selectedDate, textScaleFactor: 1.7),
                  ])),
          pw.Text('Class : ' + selectedClass, textScaleFactor: 1.5),
          pw.Padding(padding: const pw.EdgeInsets.all(10)),
          pw.Table.fromTextArray(context: context, data: table),
          pw.Expanded(child: pw.Text('')),
          pw.Align(
            alignment: pw.Alignment.bottomCenter,
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text('Class Incharge', textScaleFactor: 1.4),
                  pw.Text('Head Of Department', textScaleFactor: 1.4),
                  pw.Text('Principal', textScaleFactor: 1.4),
                ]),
          ),
        ];
      },
    ));
  }

  Future savePdf(documentPath) async {
    File file = File(documentPath);
    file.writeAsBytesSync(List.from(await pdf.save()));
  }

  void sendMail(path, mailto, selectedClass) async {
    String username = 'mukilan069@gmail.com';
    String password = 'bjdpeoscqbnbcrvw';

    final smtpServer = gmail(username, password);
    final equivalentMessage = Message()
      ..from = Address(username, 'NSCET@AMS')
      ..recipients.add(Address(email))
      ..subject = 'Today Attendance Report for ' + selectedClass
      ..text = "Today's Report"
      ..html = '<h1>Hey,</h1>\n<p>Here is the PDF File for Today Attendance</p>'
      ..attachments = [FileAttachment(File(path))];

    final sendReport = await send(equivalentMessage, smtpServer);
  }

  Future sendReport(
      regNo, name, presentFN, presentAN, selectedDate, selectedClass) async {
    try {
      Directory documentDirectory = await getApplicationDocumentsDirectory();
      String documentPath = documentDirectory.path + "/TodayReport.pdf";

      writeOnPdf(
          regNo, name, presentFN, presentAN, selectedDate, selectedClass);

      await savePdf(documentPath);
      sendMail(documentPath, email, selectedClass);

      return null;
    } catch (e) {
      print(e);
      return "Error ! Try Again !";
    }
  }
}
