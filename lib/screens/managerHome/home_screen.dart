import 'package:flutter/material.dart';
import 'package:mini_project/widgets/bottomnav.dart';

import 'ScreenHome.dart';
//import 'package:intl/intl.dart';

class ManagerHome extends StatelessWidget {
  const ManagerHome({super.key, this.u_id});
  final String? u_id;

  @override
  Widget build(BuildContext context) {
    // var date;
    //var day;

    return Scaffold(
      bottomNavigationBar: BottomNav(),
      appBar: AppBar(
        title: Text("Manager Home"),
      ),
      body: CalendarPage(uid: u_id,),
      //body:ScreenCheckBox();
    );

    // body:ScreenCheckBox();
  }
}
