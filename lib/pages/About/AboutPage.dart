// ignore_for_file: file_names

import 'package:nscet_ams/services/aboutDB.dart';
import 'package:nscet_ams/utils/SidebarNav.dart';
import 'package:nscet_ams/utils/SnackBar.dart';
import 'package:nscet_ams/utils/appBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final _formkey = GlobalKey<FormState>();
  String feedback = '';
  AboutDB aboutDb = AboutDB();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppbar(context, "NSCET AMS"),
      drawer: const SideBarnav(),
      body: ListView(
        children: [
          const SizedBox(height: 20.0),
          const Text(
            "ABOUT US",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Color.fromRGBO(27, 27, 27, 1),
              fontFamily: 'Times New Roman',
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Text(
              "Lorem ipsum dolor sit amet, nec admodum vivendo similique ad, id modo quas appetere has. Has ad melius sanctus expetenda. Vis sumo graecis ad, vix latine apeirian menandri cu",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color.fromRGBO(27, 27, 27, 1),
              ),
            ),
          ),
          const SizedBox(height: 40.0),
          const Text(
            "FEEDBACK",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
          Form(
            key: _formkey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: TextFormField(
                    maxLines: 5,
                    minLines: 3,
                    validator: (val) =>
                        val!.isEmpty ? 'Provide a valid feedback!' : null,
                    decoration: const InputDecoration(
                      labelText: 'Feedback about the app',
                      labelStyle:
                          TextStyle(color: Color.fromRGBO(66, 53, 55, 1)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(235, 171, 81, 1),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(235, 171, 81, 1),
                          width: 2.5,
                        ),
                      ),
                    ),
                    cursorColor: const Color.fromRGBO(235, 171, 81, 1),
                    onChanged: (val) {
                      setState(() {
                        feedback = val;
                      });
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      dynamic result = await aboutDb.addFeedback(feedback);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(getSnackBar(result.toString()));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Send a feedback",
                    style: TextStyle(color: Color.fromRGBO(66, 53, 55, 1)),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(235, 171, 81, 1)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
