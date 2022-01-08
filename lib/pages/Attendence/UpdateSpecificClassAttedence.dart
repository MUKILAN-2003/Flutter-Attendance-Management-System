// ignore_for_file: file_names
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nscet_ams/services/attendenceDB.dart';
import 'package:nscet_ams/services/classesDB.dart';
import 'package:nscet_ams/utils/SidebarNav.dart';
import 'package:nscet_ams/utils/SnackBar.dart';
import 'package:nscet_ams/utils/appBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateSpecificClassAttedence extends StatefulWidget {
  String classname;
  String dept;

  UpdateSpecificClassAttedence(
      {Key? key, required this.classname, required this.dept})
      : super(key: key);

  @override
  _UpdateSpecificClassAttedenceState createState() =>
      _UpdateSpecificClassAttedenceState();
}

class _UpdateSpecificClassAttedenceState
    extends State<UpdateSpecificClassAttedence> {
  AttendenceDB attendenceDb = AttendenceDB(dept: null, className: null);
  List<dynamic> regno = [];
  List<dynamic> mobno = [];
  List<dynamic> name = [];
  List<dynamic> presentFN = [];
  List<dynamic> presentAN = [];
  bool isTimeFN = true;
  int total = 0;
  int noOfPresent = 0;
  int noOfAbsent = 0;
  bool isAttedencemarked = false;
  bool isAttedencemarkedFN = false;
  bool isAttedencemarkedAN = false;

  void _loadAttedence(AttendenceDB attendenceDb) async {
    dynamic result = await attendenceDb.getMarkedAttendence();

    if (result != null) {
      setState(() {
        isAttedencemarked = true;
      });
      if (result["FN"] != null) {
        List stuReNos = <String>[];
        List stuNames = <String>[];
        List stuNumber = <int>[];
        for (int i = 0; i < result["FN"]['regNo'].length; i++) {
          stuReNos.add(result["FN"]['regNo'][i]);
          stuNames.add(result["FN"]['name'][i]);
          stuNumber.add(result["FN"]['mobileno'][i]);
        }
        setState(() {
          regno = stuReNos;
          name = stuNames;
          mobno = stuNumber;
          total = result["FN"]["total"];
          presentFN = result["FN"]["attedenceList"].toList();
          isAttedencemarkedFN = true;
        });
      } else {
        setState(() {
          isAttedencemarkedFN = false;
        });
      }

      if (result["AN"] != null) {
        List stuReNos = <String>[];
        List stuNames = <String>[];
        List stuNumber = <int>[];
        for (int i = 0; i < result["FN"]['regNo'].length; i++) {
          stuReNos.add(result["FN"]['regNo'][i]);
          stuNames.add(result["FN"]['name'][i]);
          stuNumber.add(result["FN"]['mobileno'][i]);
        }
        setState(() {
          regno = stuReNos;
          name = stuNames;
          mobno = stuNumber;
          total = result["FN"]["total"];
          presentAN = result["AN"]["attedenceList"];
          isAttedencemarkedAN = true;
        });
      } else {
        setState(() {
          isAttedencemarkedAN = false;
        });
      }
    } else {
      setState(() {
        isAttedencemarked = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      attendenceDb =
          AttendenceDB(dept: widget.dept, className: widget.classname);
    });
    _loadAttedence(attendenceDb);
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (isTimeFN) {
        noOfPresent = presentFN.where((c) => c == true).toList().length;
        noOfAbsent = total - noOfPresent;
      } else {
        noOfPresent = presentAN.where((c) => c == true).toList().length;
        noOfAbsent = total - noOfPresent;
      }
    });
    return Scaffold(
      appBar: getAppbar(context, widget.classname.toString().toUpperCase()),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
          ),
          Expanded(
            child: _getBody(),
          ),
          _getBtn(),
        ],
      ),
    );
  }

  Widget _getBody() {
    if (isAttedencemarked) {
      if (isTimeFN) {
        return _getFN();
      } else {
        return _getAN();
      }
    } else {
      return const Text("Attedence still not marked");
    }
  }

  Widget _getFN() {
    if (isAttedencemarkedFN) {
      List<Widget> stuListTiles = <Widget>[];

      for (int i = 0; i < total; i++) {
        stuListTiles.add(ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name[i],
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    regno[i],
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              Checkbox(
                checkColor: Colors.red.shade300,
                activeColor: Colors.brown.shade900,
                value: presentFN[i],
                onChanged: (bool? value) {
                  setState(() {
                    presentFN[i] = value!;
                  });
                },
              ),
            ],
          ),
        ));

        stuListTiles.add(
          const Divider(
            height: 20,
            thickness: 2,
            indent: 1,
            endIndent: 1,
          ),
        );
      }

      return ListView(
        children: stuListTiles,
      );
    } else {
      return const Text("Attedence not marked FN");
    }
  }

  Widget _getAN() {
    if (isAttedencemarkedAN) {
      List<Widget> stuListTiles = <Widget>[];

      for (int i = 0; i < total; i++) {
        stuListTiles.add(ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name[i],
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    regno[i],
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              Checkbox(
                checkColor: Colors.red.shade300,
                activeColor: Colors.brown.shade900,
                value: presentAN[i],
                onChanged: (bool? value) {
                  setState(() {
                    presentAN[i] = value!;
                  });
                },
              ),
            ],
          ),
        ));

        stuListTiles.add(
          const Divider(
            height: 20,
            thickness: 2,
            indent: 1,
            endIndent: 1,
          ),
        );
      }

      return ListView(
        children: stuListTiles,
      );
    } else {
      return const Text("Attedence not marked AN");
    }
  }

  Widget _getBtn() {
    if ((isTimeFN && isAttedencemarkedFN) ||
        (!isTimeFN && isAttedencemarkedAN)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("No.Of Present : " + noOfPresent.toString()),
          ElevatedButton(
            onPressed: () async {
              dynamic result = await attendenceDb.markAttendence(
                  isTimeFN: isTimeFN,
                  presentList: isTimeFN ? presentFN : presentAN,
                  regNoList: regno,
                  name: name,
                  mobileNoList: mobno,
                  isUpdate: true);
              if (result['value'] != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(getSnackBar(result["msg"].toString()));
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(getSnackBar(result["msg"].toString()));
                Navigator.pop(context, true);
              }
            },
            child: const Text("Update"),
          ),
          Text("No.Of Absent : " + noOfAbsent.toString()),
        ],
      );
    } else {
      return const Padding(
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Text("!"),
      );
    }
  }
}
