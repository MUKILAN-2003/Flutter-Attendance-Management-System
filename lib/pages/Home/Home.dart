// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:nscet_ams/utils/SidebarNav.dart';
import 'package:nscet_ams/utils/appBar.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideBarnav(),
      appBar: getAppbar(context, "NSCET AMS", isLogout: true),
      body: const Center(
        child: Text(
          "WELCOME !",
          style: TextStyle(
            fontSize: 45,
            color: Color.fromRGBO(27, 27, 27, 1),
            fontFamily: 'Times New Roman',
          ),
        ),
      ),
    );
  }
}
