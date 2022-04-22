// ignore_for_file: file_names
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nscet_ams/services/classesDB.dart';
import 'package:nscet_ams/utils/SidebarNav.dart';
import 'package:nscet_ams/utils/SnackBar.dart';
import 'package:nscet_ams/utils/appBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassAttendence extends StatefulWidget {
  const ClassAttendence({Key? key}) : super(key: key);

  @override
  _ClassAttendenceState createState() => _ClassAttendenceState();
}

class _ClassAttendenceState extends State<ClassAttendence> {
  late SharedPreferences sharedPrefs;
  ClassDB classDb = ClassDB('');

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() => sharedPrefs = prefs);
      setState(() {
        classDb = ClassDB(sharedPrefs.getString('dept'));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideBarnav(),
      appBar: getAppbar(context, "MARK ATTENDENCE"),
      body: StreamBuilder(
        stream: classDb.getselectedClassListRef(),
        builder: (context, snapshot) {
          final tilesList = <Widget>[];

          if (snapshot.hasData && !snapshot.hasError && snapshot.data != null) {
            final contents = (snapshot.data as Event).snapshot.value;
            if (contents != null) {
              for (int i = 0; i < contents.length; i++) {
                tilesList.add(
                  ListTile(
                    leading: contents[i].toString().split(" - ")[0] == 'S&H'
                        ? Image.asset(
                            'images/' +
                                contents[i].toString().split(" - ")[1] +
                                '.png',
                            fit: BoxFit.fill,
                          )
                        : Image.asset(
                            'images/' +
                                contents[i].toString().split(" - ")[0] +
                                '.png',
                            fit: BoxFit.fill,
                          ),
                    tileColor: const Color.fromRGBO(199, 68, 109, 0.2),
                    onTap: () {
                      Navigator.pushNamed(context, "/specificMarkAttendence",
                          arguments: [
                            contents[i].toString().split(" - ")[0],
                            contents[i].toString().split(" - ")[1]
                          ]);
                    },
                    title: Text(
                      contents[i].toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                );

                tilesList.add(
                  const Divider(
                    height: 20,
                    thickness: 2,
                    indent: 1,
                    endIndent: 1,
                  ),
                );
              }
            } else {
              tilesList.add(const ListTile(
                title: Text(
                  "Select classes from profile !",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ));
            }
            tilesList.add(ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, "/updateMarkAttedence",
                      arguments: {});
                },
                child: const Text(
                  "UPDATE MARKED ATTEDENCE",
                  style: TextStyle(fontSize: 18),
                )));
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
