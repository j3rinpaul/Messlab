import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';


import 'ScreenReview.dart';
import 'calendar.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 10,top: 10),
          child: Column(
            children: [Calendar(), ScreenReview()],
          ),
        ),
      ),
    );
  }
}
