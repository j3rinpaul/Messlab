import 'dart:async';

import 'package:flutter/material.dart';

class CheckboxList extends StatefulWidget {
  final DateTime? date; //date to be passed to the db along with this data
  final String? u_id;
  const CheckboxList({super.key, required this.date, this.u_id});

//u_id is the user id of the current user


  @override
  _CheckboxListState createState() => _CheckboxListState();
}

class _CheckboxListState extends State<CheckboxList> {
  bool toggleValue = false;
  bool isMorningSelected = false;
  bool isNoonSelected = false;
  bool isEveningSelected = false;

  @override
  void initState() {
    super.initState();

    // Get the current time
    DateTime currentTime = DateTime.now();

    // Deactivate Morning toggle button after 11 PM
    if (currentTime.hour >= 01) {
      setState(() {
        isMorningSelected = false;
      });
    }

    // Deactivate Noon toggle button after 9 AM
    if (currentTime.hour >= 9) {
      setState(() {
        isNoonSelected = false;
      });
    }

    // Deactivate Evening toggle button after 5 PM
    if (currentTime.hour >= 17) {
      setState(() {
        isEveningSelected = false;
      });
    }

    // Reset Morning toggle after 8 AM
    if (currentTime.hour >= 8) {
      Timer(Duration(minutes: 1), () {
        setState(() {
          isMorningSelected = false;
        });
      });
    }

    // Reset Noon toggle after 2 PM
    if (currentTime.hour >= 14) {
      Timer(Duration(minutes: 1), () {
        setState(() {
          isNoonSelected = false;
        });
      });
    }

    // Reset Evening toggle after 10 PM
    if (currentTime.hour >= 22) {
      Timer(Duration(minutes: 1), () {
        setState(() {
          isEveningSelected = false;
        });
      });
    }

    // Schedule timer to reset the toggles at the start of the next day
    Timer(
      Duration(
        hours: 24 - currentTime.hour,
        minutes: 60 - currentTime.minute,
        seconds: 60 - currentTime.second,
      ),
      () {
        setState(() {
          isMorningSelected = false;
          isNoonSelected = false;
          isEveningSelected = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                )),
            leading: CircleAvatar(
             backgroundColor: Colors.blue[400],
              child: Icon(Icons.wb_sunny, color: Colors.white,)
            ),
            title: Text('Morning'),
            trailing: Switch(
              value: isMorningSelected,
              activeColor: Colors.green,

              onChanged: canToggleMorning()
                  ? (value) {
                      setState(() {
                        isMorningSelected = value;
                      });
                      print("Selected mrng");
                    }
                  : null,
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 5)),
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                )),
            leading: CircleAvatar(
              backgroundColor:
                   Colors.blue[400] ,
              child: Icon(
                Icons.sunny,
                color: Colors.white ,
              ),
            ),
            title: Text(
              'Noon',
            ),
            trailing: Switch(
              value: isNoonSelected,
              activeColor: Colors.green,

              onChanged: canToggleNoon()
                  ? (value) {
                      setState(() {
                        isNoonSelected = value;
                      });
                    }
                  : null,
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 5)),
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                )),
            leading: CircleAvatar(
                backgroundColor: Colors.blue[400],
                child: Icon(
                  Icons.nightlight_round,
                  color: Colors.white,
                )),
            title: Text('Evening'),
            trailing: Switch(
              activeColor: Colors.green,
              value: isEveningSelected,
              onChanged: canToggleEvening()
                  ? (value) {
                      setState(() {
                        isEveningSelected = value;
                      });
                      print("selectre");
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  bool canToggleMorning() {
    DateTime currentTime = DateTime.now();
    return currentTime.hour < 1; // Allow toggle before 11 PM
  }

  bool canToggleNoon() {
    DateTime currentTime = DateTime.now();
    return currentTime.hour < 9; // Allow toggle before 9 AM
  }

  bool canToggleEvening() {
    DateTime currentTime = DateTime.now();
    return currentTime.hour < 17; // Allow toggle before 5 PM
  }
}
