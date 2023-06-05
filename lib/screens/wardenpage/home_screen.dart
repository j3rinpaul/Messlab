import 'package:flutter/material.dart';
import 'package:mini_project/widgets/bottomnav.dart';

import 'ScreenHome.dart';
//import 'package:intl/intl.dart';

class wardenPage extends StatelessWidget {
  final String? u_id;
  const wardenPage({super.key, this.u_id});

  @override
  Widget build(BuildContext context) {
    // var date;
    //var day;

    return Scaffold(
      bottomNavigationBar: BottomNav(),
      appBar: AppBar(
        title: Text("Warden Home"),
      ),
      body: CalendarPage(uid: u_id,),
      //body:ScreenCheckBox();
    );

    // body:ScreenCheckBox();
  }
}
