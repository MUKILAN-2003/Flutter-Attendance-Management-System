// ignore_for_file: file_names

import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutDB {
  final database = FirebaseDatabase.instance.reference();

  Future addFeedback(new_feedback) async {
    final feedBackDb = database.child("/feedback");
    final prefs = await SharedPreferences.getInstance();

    feedBackDb.push().set({
      "name": prefs.getString('name'),
      "dept": prefs.getString('dept'),
      "role": prefs.getString('role'),
      "feedback": new_feedback
    });
    return "Thankyou for the feedback";
  }
}
