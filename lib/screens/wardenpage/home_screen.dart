import 'package:flutter/material.dart';
import 'package:mini_project/widgets/bottomnav.dart';

import 'ScreenHome.dart';
//import 'package:intl/intl.dart';

class wardenPage extends StatelessWidget {
  const wardenPage({super.key});

  @override
  Widget build(BuildContext context) {
    // var date;
    //var day;

    return Scaffold(
      bottomNavigationBar: BottomNav(),
      appBar: AppBar(
        title: Text("Warden Home"),
      ),
      body: CalendarPage(),
      //body:ScreenCheckBox();
    );

    // body:ScreenCheckBox();
  }
}
