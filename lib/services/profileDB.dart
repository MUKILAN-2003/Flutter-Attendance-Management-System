// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileData {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final database = FirebaseDatabase.instance.reference();
  String userId = "";

  ProfileData() {
    SharedPreferences.getInstance().then((prefs) {
      userId = prefs.getString("userId")!;
    });
  }

  void addTakingClasses(String newClassname, String dept) async {
    final userclasses = database.child("/users/" + userId + "/classes");

    dynamic value = await userclasses.get();
    dynamic classList = value.value;

    if (classList != null) {
      userclasses.set(value.value + [dept + ' - ' + newClassname]);
    } else {
      userclasses.set([dept + ' - ' + newClassname]);
    }
  }

  void deleteTakingClass(className) async {
    final userclasses = database.child("/users/" + userId + "/classes");

    dynamic value = await userclasses.get();
    dynamic classList = value.value.toList();

    bool isRemoved = classList.remove(className);
    if (isRemoved) {
      userclasses.set(classList);
    }
  }

  Stream? getClassListRef() {
    final userclasses = database.child("/users/" + userId + "/classes");
    return userclasses.onValue;
  }

  Future getClasses() async {
    final deptclasses = database.child("/classes");
    dynamic deptClasses = await deptclasses.get();
    deptClasses = deptClasses.value;

    dynamic depts = deptClasses.keys.toList();

    for (int i = 0; i < depts.length; i++) {
      deptClasses[depts[i]] = deptClasses[depts[i]]["classes_list"];
    }

    return deptClasses;
  }
}
