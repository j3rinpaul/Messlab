import 'package:flutter/material.dart';

import '../../widgets/bottomnav.dart';
import '../Pointsscreen/screen_points.dart';
import 'ScreenHome.dart';
//import 'package:intl/intl.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key});

  @override
  Widget build(BuildContext context) {
    // var date;
    //var day;

    return Scaffold(
      bottomNavigationBar: BottomNav(),
      appBar: AppBar(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25))),
          automaticallyImplyLeading: false,
          toolbarHeight: 130,
          title: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage('assets/images/profilepic.png'),
              ),
              SizedBox(width: 25),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Name',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    'Designation',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    'Role',
                    style: TextStyle(fontSize: 18),
                  )
                ],
              ),
              SizedBox(width: 180),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // do something
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ScreenPoints()),
                      );
                    },
                    icon: Image.asset(
                        'assets/images/bill.png'), // add your image here
                    label: Text('Bill'), // add your button text here
                  )
                ],
              )),
            ],
          )),
      body: CalendarPage(),
      //body:ScreenCheckBox();
    );

    // body:ScreenCheckBox();
  }
}
