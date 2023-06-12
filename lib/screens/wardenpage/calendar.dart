import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_project/screens/wardenpage/billStatus.dart';
import 'package:mini_project/screens/wardenpage/generateBill.dart';

import 'DailyCount.dart';
import 'Roleassign_warden.dart';
import 'checkBox.dart';
import 'monthlyExp.dart';
import 'verify.dart';

class Calendar extends StatefulWidget {
  final String? uid;
  Calendar({Key? key, this.uid}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime? selectedValue = DateTime.now();

  int month = int.parse(DateFormat('MM').format(DateTime.now()));
  int year = int.parse(DateFormat('yy').format(DateTime.now()));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DatePicker(
          DateTime.now(),
          initialSelectedDate: DateTime.now(),
          selectionColor: Colors.blue,
          selectedTextColor: Colors.white,
          onDateChange: (date) {
            setState(() {
              selectedValue = date;
              print(selectedValue);
            });
          },
        ),
        CheckboxList(date: selectedValue, userId: widget.uid),
        Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return DailyCount();
                    }));
                  },
                  child: Text("Daily Count")),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return RoleAssign();
                    }));
                  },
                  child: Text("Role Assign")),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return VerifyUser();
                    }));
                  },
                  child: Text("User Verify")),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return MonthlyExp(uid: widget.uid);
                    }));
                  },
                  child: const Text("Monthly Expense")),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return generateBill();
                    }));
                  },
                  child: const Text("Generate Bill")),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return MonthlyBill();
                    }));
                  },
                  child: const Text("Payment Status")),
            )
          ],
        )

        //the announcement and review below
      ],
    );
  }
}
