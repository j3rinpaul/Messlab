import 'package:flutter/material.dart';

import '../../widgets/bottomnav.dart';
import '../Pointsscreen/screen_points.dart';
import 'ScreenHome.dart';
//import 'package:intl/intl.dart';

class ScreenHome extends StatelessWidget {
  final String? u_id;
  const ScreenHome({super.key,this.u_id});

  @override
  Widget build(BuildContext context) {
    // var date;
    //var day;

    return Scaffold(
      bottomNavigationBar: BottomNav(),
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: CalendarPage(u_id: u_id,),
    );

    // body:ScreenCheckBox();
  }
}
