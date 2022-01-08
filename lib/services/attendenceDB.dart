// ignore_for_file: file_names

import 'package:firebase_database/firebase_database.dart';

class AttendenceDB {
  dynamic dept, className;
  final database = FirebaseDatabase.instance.reference();

  AttendenceDB({dept, className}) {
    this.dept = dept;
    this.className = className;
  }

  Stream? getClassStudentsRef() {
    final classDb = database
        .child("/classes/" + dept + "/" + className)
        .orderByChild('name');
    return classDb.onValue;
  }

  Future getMarkedAttendence() async {
    DateTime currentPhoneDate = DateTime.now();

    String todatDate = currentPhoneDate.day.toString() +
        "-" +
        currentPhoneDate.month.toString() +
        "-" +
        currentPhoneDate.year.toString();
    final attedenceDb = database
        .child("/attedence/" + dept + "/" + className + "/" + todatDate + "/");

    DataSnapshot result = await attedenceDb.get();

    return result.value;
  }

  Future markAttendence(
      {required List presentList,
      required List regNoList,
      required List mobileNoList,
      required bool isTimeFN,
      required List name,
      bool isUpdate = false}) async {
    print({presentList.length, regNoList.length});
    String noonTime;
    int noOfPresent, noOfAbsent, total;
    presentList = presentList.getRange(0, regNoList.length).toList();
    if (isTimeFN) {
      noonTime = "FN";
    } else {
      noonTime = "AN";
    }

    total = regNoList.length;
    noOfAbsent = presentList.where((c) => c == false).toList().length;
    noOfPresent = total - noOfAbsent;

    List absenteesRegNo = <String>[];
    List presentRegNo = <String>[];
    List absenteesName = <String>[];
    List presentName = <String>[];

    for (int i = 0; i < total; i++) {
      if (!presentList[i]) {
        absenteesRegNo.add(regNoList[i]);
        absenteesName.add(name[i]);
      } else {
        presentRegNo.add(regNoList[i]);
        presentName.add(name[i]);
      }
    }

    DateTime currentPhoneDate = DateTime.now();

    String todatDate = currentPhoneDate.day.toString() +
        "-" +
        currentPhoneDate.month.toString() +
        "-" +
        currentPhoneDate.year.toString();

    final attedenceDb = database.child("/attedence/" +
        dept +
        "/" +
        className +
        "/" +
        todatDate +
        "/" +
        noonTime);

    if (isUpdate) {
      attedenceDb.set({
        "dateTime": currentPhoneDate.toString(),
        "total": total,
        "no_of_present": noOfPresent,
        "no_of_absent": noOfAbsent,
        "regNo": regNoList,
        "name": name,
        "attedenceList": presentList,
        "mobileno": mobileNoList,
      });
      return {
        "value": null,
        "msg": "Today's attedence updated for the class $className"
      };
    } else {
      DataSnapshot result = await attedenceDb.get();

      if (result.value == null) {
        attedenceDb.set({
          "dateTime": currentPhoneDate.toString(),
          "total": total,
          "no_of_present": noOfPresent,
          "no_of_absent": noOfAbsent,
          "regNo": regNoList,
          "name": name,
          "attedenceList": presentList,
          "mobileno": mobileNoList,
        });

        return {
          "value": null,
          "msg": "Today attedence marked for the class $className"
        };
      } else {
        return {
          "value": null,
          "msg": "Attedence already marked for the class $className"
        };
      }
    }
  }
}
