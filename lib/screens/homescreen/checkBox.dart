import 'dart:async';

import 'package:flutter/material.dart';

class CheckboxList extends StatefulWidget {
  final DateTime? date;
  const CheckboxList({super.key, required this.date});

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
              backgroundColor:
                  isMorningSelected ? Colors.green : Colors.transparent,
              child: Text(
                'M',
                style: TextStyle(color: Colors.black),
              ),
            ),
            title: Text('Morning'),
            trailing: Switch(
              value: isMorningSelected,
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
                  isNoonSelected ? Colors.blue[400] : Colors.transparent,
              child: Icon(
                Icons.sunny,
                color: isNoonSelected ? Colors.white : Colors.black,
              ),
            ),
            title: Text(
              'Noon',
            ),
            trailing: Switch(
              value: isNoonSelected,
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
                backgroundColor:
                    isEveningSelected ? Colors.blue[400] : Colors.transparent,
                child: Icon(
                  Icons.sunny,
                  color: isEveningSelected ? Colors.white : Colors.black,
                )),
            title: Text('Evening'),
            trailing: Switch(
              value: isEveningSelected,
              onChanged: canToggleEvening()
                  ? (value) {
                      setState(() {
                        isEveningSelected = value;
                      });
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
