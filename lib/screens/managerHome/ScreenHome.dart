import 'package:flutter/material.dart';

import 'ScreenReview.dart';
import 'calendar.dart';

class CalendarPage extends StatelessWidget {
  final String? uid;
  const CalendarPage({super.key,  this.uid});
  

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          child: Column(
            children: [
              Calendar(
                uid: uid,
              ),
               ScreenReview(uid: uid)
            ],
          ),
        ),
      ),
    );
  }
}
