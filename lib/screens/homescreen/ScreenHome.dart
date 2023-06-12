import 'package:flutter/material.dart';

import 'ScreenReview.dart';
import 'calendar.dart';

class CalendarPage extends StatelessWidget {
  final String? u_id;
  const CalendarPage({super.key, this.u_id});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          child: Column(
            children: [Calendar(u_id: u_id), ScreenReview(uid: u_id,)],
          ),
        ),
      ),
    );
  }
}
