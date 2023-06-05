import 'package:flutter/material.dart';

import '../../widgets/bottomnav.dart';
import 'ScreenHome.dart';
//import 'package:intl/intl.dart';

class ScreenHome extends StatelessWidget {
  final String? u_id;
  final String? role;
  const ScreenHome({super.key,this.u_id,this.role});

  @override
  Widget build(BuildContext context) {
    // var date;
    //var day;

    return Scaffold(
      bottomNavigationBar: const BottomNav(),
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: CalendarPage(u_id: u_id,),
    );

    // body:ScreenCheckBox();
  }
}
