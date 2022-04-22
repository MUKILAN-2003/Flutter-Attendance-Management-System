// ignore_for_file: file_names
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nscet_ams/services/attendenceDB.dart';
import 'package:nscet_ams/services/classesDB.dart';
import 'package:nscet_ams/utils/SidebarNav.dart';
import 'package:nscet_ams/utils/SnackBar.dart';
import 'package:nscet_ams/utils/appBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpecificClassAttedence extends StatefulWidget {
  const SpecificClassAttedence({Key? key}) : super(key: key);

  @override
  _SpecificClassAttedenceState createState() => _SpecificClassAttedenceState();
}

class _SpecificClassAttedenceState extends State<SpecificClassAttedence> {
  List<bool> present = List.filled(80, true);
  bool isTimeFN = true;
  int total = 0;
  int noOfPresent = 0;
  int noOfAbsent = 0;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List;
    AttendenceDB attendenceDb = AttendenceDB(dept: args[0], className: args[1]);

    return Scaffold(
      appBar: getAppbar(context, args[1].toString().toUpperCase()),
      body: StreamBuilder(
        stream: attendenceDb.getClassStudentsRef(),
        builder: (context, snapshot) {
          final tilesList = <Widget>[];
          final regNos = <String>[];
          final name = <String>[];

          if (snapshot.hasData && !snapshot.hasError && snapshot.data != null) {
            final contents = (snapshot.data as Event).snapshot.value;

            if (contents != null) {
              Map<dynamic, dynamic> orders = Map.from(contents);
              List studentOrders = orders.values.toList();
              total = studentOrders.length;
              List<bool> presentList =
                  present.getRange(0, studentOrders.length).toList();

              noOfAbsent = presentList.where((c) => c == false).toList().length;
              noOfPresent = total - noOfAbsent;

              tilesList.add(Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text("FN"),
                      Checkbox(
                          value: isTimeFN,
                          onChanged: (bool? val) {
                            setState(() {
                              isTimeFN = !isTimeFN;
                            });
                          })
                    ],
                  ),
                  Row(
                    children: [
                      const Text("AN"),
                      Checkbox(
                          value: !isTimeFN,
                          onChanged: (bool? val) {
                            setState(() {
                              isTimeFN = !isTimeFN;
                            });
                          })
                    ],
                  )
                ],
              ));

              tilesList.add(const SizedBox(height: 20.0));

              for (int i = 0; i < studentOrders.length; i++) {
                regNos.add(studentOrders[i]['reg_no']);
                name.add(studentOrders[i]['name']);
                tilesList.add(ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentOrders[i]['name'],
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontSize: 20),
                          ),
                          Text(
                            studentOrders[i]['reg_no'],
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Checkbox(
                        checkColor: Colors.red.shade300,
                        activeColor: Colors.brown.shade900,
                        value: present[i],
                        onChanged: (bool? value) {
                          setState(() {
                            present[i] = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ));

                tilesList.add(
                  const Divider(
                    height: 20,
                    thickness: 2,
                    indent: 1,
                    endIndent: 1,
                  ),
                );
              }
              tilesList.add(Column(
                children: [
                  Column(
                    children: [
                      Text("Total No.Of students : " + total.toString()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("No.Of Presents : " + noOfPresent.toString()),
                          ElevatedButton(
                            onPressed: () async {
                              dynamic result =
                                  await attendenceDb.markAttendence(
                                      isTimeFN: isTimeFN,
                                      presentList: present,
                                      regNoList: regNos,
                                      name: name);
                              if (result['value'] != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    getSnackBar(result["msg"].toString()));
                                Navigator.pop(context, true);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    getSnackBar(result["msg"].toString()));
                                Navigator.pop(context, true);
                              }
                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          Text("No.Of Absentees : " + noOfAbsent.toString())
                        ],
                      ),
                    ],
                  ),
                ],
              ));
            } else {
              tilesList.add(const ListTile(
                title: Text(
                  "Create students first !",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ));
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            children: tilesList,
          );
        },
      ),
    );
  }
}
