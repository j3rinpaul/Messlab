import 'package:flutter/material.dart';
import 'package:mini_project/screens/wardenpage/settings.dart';
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
      bottomNavigationBar: BottomNav(uid: u_id),
      appBar: AppBar(
        title: Text("Warden Home"),
        actions:[ IconButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx1) => Settings()));
        }, icon: Icon(Icons.settings))],
      ),
      body: CalendarPage(uid: u_id,),
      //body:ScreenCheckBox();
    );

    // body:ScreenCheckBox();
  }
}
