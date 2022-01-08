// ignore_for_file: file_names

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nscet_ams/services/classesDB.dart';
import 'package:nscet_ams/services/profileDB.dart';
import 'package:nscet_ams/utils/SidebarNav.dart';
import 'package:nscet_ams/utils/SnackBar.dart';
import 'package:nscet_ams/utils/appBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formkey = GlobalKey<FormState>();
  String newClassname = '';
  String dept = '';
  ProfileData profile_data = ProfileData();
  dynamic deptClasses = '';

  List<DropdownMenuItem<Object>> deptSpecificClasses = [];

  @override
  void initState() {
    super.initState();
    profile_data.getClasses().then((value) {
      setState(() {
        deptClasses = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppbar(context, "My Profile"),
      drawer: const SideBarnav(),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const Text(
            "MY PROFILE",
            textAlign: TextAlign.center,
            textScaleFactor: 2,
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "FULL NAME",
                    style: TextStyle(
                      fontSize: 22.0,
                    ),
                  ),
                  Text(
                    "DEPARTMENT",
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  Text(
                    "ROLE",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.person,
                size: 52.0,
              ),
            ],
          ),
          const Divider(
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
          const SizedBox(height: 10.0),
          const Text(
            "CLASSES TAKEN BY YOU",
            textAlign: TextAlign.center,
            textScaleFactor: 2,
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: StreamBuilder(
              stream: profile_data.getClassListRef(),
              builder: (context, snapshot) {
                final tilesList = <Widget>[];

                if (snapshot.hasData &&
                    !snapshot.hasError &&
                    snapshot.data != null) {
                  final contents = (snapshot.data as Event).snapshot.value;
                  if (contents != null) {
                    for (int i = 0; i < contents.length; i++) {
                      tilesList.add(
                        ListTile(
                          tileColor: const Color.fromRGBO(199, 68, 109, 0.2),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                contents[i].toString(),
                                textAlign: TextAlign.left,
                                style: const TextStyle(fontSize: 20),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  color: Color.fromRGBO(80, 53, 55, 1),
                                  size: 28,
                                ),
                                onPressed: () {
                                  profile_data.deleteTakingClass(
                                      contents[i].toString());
                                },
                              ),
                            ],
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
                        "No Classes Taken !",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    ));
                  }
                }

                return Column(
                  //padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  children: tilesList,
                );
              },
            ),
          ),
          const Divider(
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
          const SizedBox(height: 20.0),
          const Text(
            "ADD CLASS",
            textAlign: TextAlign.center,
            textScaleFactor: 2,
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  DropdownButtonFormField(
                    validator: (val) {
                      if (val == null) {
                        return "Department";
                      } else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      labelStyle:
                          TextStyle(color: Color.fromRGBO(66, 53, 55, 1)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(199, 68, 109, 1), width: 1.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(199, 68, 109, 1), width: 1.5),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        child: Text("Science and Humanites"),
                        value: "SNH",
                      ),
                      DropdownMenuItem(
                        child: Text("Computer Science & Engineering"),
                        value: "CSE",
                      ),
                      DropdownMenuItem(
                        child: Text("Mechanical Engineering"),
                        value: "MECH",
                      ),
                      DropdownMenuItem(
                        child: Text("Electronics & Communication Engg"),
                        value: "ECE",
                      ),
                      DropdownMenuItem(
                        child: Text("Civil Engineering"),
                        value: "CIVIL",
                      ),
                      DropdownMenuItem(
                        child: Text("Electrical & Electronics Engineering"),
                        value: "EEE",
                      ),
                    ],
                    onTap: () {
                      _formkey.currentState!.reset();
                    },
                    onChanged: (val) {
                      setState(() {
                        newClassname = '';
                        deptSpecificClasses = [];
                        dept = val.toString();
                        List<DropdownMenuItem<Object>> clsList = [];

                        if (deptClasses.keys.toList().contains(dept)) {
                          for (int i = 0; i < deptClasses[dept].length; i++) {
                            clsList.add(DropdownMenuItem(
                              child: Text(deptClasses[dept][i].toString()),
                              value: deptClasses[dept][i].toString(),
                            ));
                          }
                          deptSpecificClasses = clsList;
                        }
                      });
                    },
                  ),
                  DropdownButtonFormField(
                    validator: (val) {
                      if (val == null) {
                        return "Department";
                      } else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Class',
                      labelStyle:
                          TextStyle(color: Color.fromRGBO(66, 53, 55, 1)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(199, 68, 109, 1), width: 1.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(199, 68, 109, 1), width: 1.5),
                      ),
                    ),
                    items: deptSpecificClasses,
                    onChanged: (val) {
                      setState(() {
                        newClassname = val.toString();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
            child: ElevatedButton(
              onPressed: () async {
                if (_formkey.currentState!.validate()) {
                  profile_data.addTakingClasses(newClassname, dept);
                  _formkey.currentState!.reset();
                }
              },
              child: const Text(
                "Take Class",
                style: TextStyle(color: Color.fromRGBO(66, 53, 55, 1)),
              ),
              style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(235, 171, 81, 1)),
            ),
          )
        ],
      ),
    );
  }
}
