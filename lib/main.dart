import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nscet_ams/pages/About/AboutPage.dart';
import 'package:nscet_ams/pages/Attendence/ClassAttendence.dart';
import 'package:nscet_ams/pages/Attendence/SpecificClassAttedence.dart';
import 'package:nscet_ams/pages/Attendence/UpdateClassAttendence.dart';
import 'package:nscet_ams/pages/Attendence/UpdateSpecificClassAttedence.dart';
import 'package:nscet_ams/pages/Classes/ClassesMain.dart';
import 'package:nscet_ams/pages/Classes/specificClass.dart';
import 'package:nscet_ams/pages/Profile/Profile.dart';
import 'package:nscet_ams/pages/Report/Report.dart';
import 'package:nscet_ams/pages/Wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nscet_ams/services/auth.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        home: const Wrapper(),
        routes: {
          '/classes': (context) => const ClassesMain(),
          '/specificClass': (context) => const SpecificClass(),
          '/about': (context) => const AboutPage(),
          '/markAttendence': (context) => const ClassAttendence(),
          '/specificMarkAttendence': (context) =>
              const SpecificClassAttedence(),
          '/updateMarkAttedence': (context) => const UpdateClassAttedence(),
          '/todayReport': (context) => const Report(),
          '/profile': (context) => const Profile(),
        },
      ),
    );
  }
}
