import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_project/screens/wardenpage/billStatus.dart';


import 'DailyCount.dart';
import 'checkBox.dart';
import 'monthlyExp.dart';

class Calendar extends StatefulWidget {
  final String? uid;
  const Calendar({Key? key, this.uid}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime? selectedValue = DateTime.now();

  int month = int.parse(DateFormat('MM').format(DateTime.now()));
  int year = int.parse(DateFormat('yy').format(DateTime.now()));
  bool morning = false;
  bool noon = false;

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
                      return const DailyCount();
                    }));
                  },
                  child: const Text("Daily Count")),
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
                 
                  child: const Text("Add Expense")),
            ),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return const MonthlyBill();
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
