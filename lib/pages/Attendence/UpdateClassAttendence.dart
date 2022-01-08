// ignore_for_file: file_names
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nscet_ams/pages/Attendence/UpdateSpecificClassAttedence.dart';
import 'package:nscet_ams/services/classesDB.dart';
import 'package:nscet_ams/utils/SidebarNav.dart';
import 'package:nscet_ams/utils/SnackBar.dart';
import 'package:nscet_ams/utils/appBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateClassAttedence extends StatefulWidget {
  const UpdateClassAttedence({Key? key}) : super(key: key);

  @override
  _UpdateClassAttedenceState createState() => _UpdateClassAttedenceState();
}

class _UpdateClassAttedenceState extends State<UpdateClassAttedence> {
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
      appBar: getAppbar(context, "UPDATE ATTEDENCE"),
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
                    tileColor: const Color.fromRGBO(199, 68, 109, 0.2),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateSpecificClassAttedence(
                            classname: contents[i].toString().split(" - ")[1],
                            dept: contents[i].toString().split(" - ")[0],
                          ),
                        ),
                      );
                    },
                    title: Text(
                      contents[i].toString(),
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 20),
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
                  "Create Classes First !",
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
