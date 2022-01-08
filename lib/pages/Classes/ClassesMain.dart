// ignore_for_file: file_names
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nscet_ams/services/classesDB.dart';
import 'package:nscet_ams/utils/SidebarNav.dart';
import 'package:nscet_ams/utils/SnackBar.dart';
import 'package:nscet_ams/utils/appBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassesMain extends StatefulWidget {
  const ClassesMain({Key? key}) : super(key: key);

  @override
  _ClassesMainState createState() => _ClassesMainState();
}

class _ClassesMainState extends State<ClassesMain> {
  String newClassname = '';
  final _formkey = GlobalKey<FormState>();
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
      appBar: getAppbar(context, "Classes"),
      floatingActionButton: FloatingActionButton.extended(
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
                    "ADD A CLASS",
                    textAlign: TextAlign.center,
                  ),
                  children: [
                    Form(
                      key: _formkey,
                      child: TextFormField(
                        validator: (val) =>
                            val!.isEmpty ? 'Enter a class name' : null,
                        decoration: const InputDecoration(
                          labelText: 'New class name',
                          labelStyle:
                              TextStyle(color: Color.fromRGBO(66, 53, 55, 1)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(199, 68, 109, 1),
                                width: 1.5),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(199, 68, 109, 1),
                                width: 1.5),
                          ),
                        ),
                        cursorColor: const Color.fromRGBO(199, 68, 109, 1),
                        onChanged: (val) {
                          setState(() {
                            newClassname = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          primary: const Color.fromRGBO(66, 53, 55, 1)),
                      onPressed: () async {
                        if (_formkey.currentState!.validate()) {
                          dynamic result = await classDb.addClass(newClassname);
                          if (result != null) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(getSnackBar(result.toString()));
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
      body: StreamBuilder(
        stream: classDb.getClassListRef(),
        builder: (context, snapshot) {
          final tilesList = <Widget>[];

          if (snapshot.hasData && !snapshot.hasError && snapshot.data != null) {
            final contents = (snapshot.data as Event).snapshot.value;
            if (contents != null) {
              for (int i = 0; i < contents.length; i++) {
                tilesList.add(ListTile(
                    tileColor: const Color.fromRGBO(199, 68, 109, 0.2),
                    onTap: () {
                      Navigator.pushNamed(context, "/specificClass",
                          arguments: [
                            sharedPrefs.getString('dept'),
                            contents[i].toString()
                          ]);
                    },
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
                            classDb.deleteClass(contents[i].toString());
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
              }
            } else {
              tilesList.add(const ListTile(
                title: Text(
                  "No Classes Created !",
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
