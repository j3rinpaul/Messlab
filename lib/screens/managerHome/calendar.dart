import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';

import 'checkBox.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime? selectedValue = DateTime.now();
  final List<bool> isCheckedList = List.filled(items.length, false);
  final List<Color> _checkBoxc = List.filled(items.length, Colors.red);
  bool _formCheck = false;
  bool _submitCheck = false;

  @override
  Widget build(BuildContext context) {
    if (DateTime.now().hour == 0) {
      _submitCheck = false;
      _formCheck = false;
    }

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
              if (DateTime.now() != selectedValue) {
                isCheckedList.fillRange(0, items.length, false);
              }
            });
          },
        ),
        CheckboxList(date: selectedValue),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  ElevatedButton(onPressed: () {}, child: Text("Daily Count")),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  ElevatedButton(onPressed: () {}, child: Text("Role Assign")),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  ElevatedButton(onPressed: () {}, child: Text("Monthly Bill")),
            ),
          ],
        )
        //the announcement and review below
      ],
    );
  }
}

//isChecklist and selectedValue has the needed data for editing the db
//if the current date is filled then we should disable the checkbox

/*
to resolve whether the meal was selected or not(box checked or not) we can use the db
initally all the values in the db are false we load that into an array
[value_of_db_mrng,value_of_db_noon,value_of_db_evng]
and we feed this value to the value field in the checkbox
and on change the value inside the db is also changed and nextime on calendar change 
the value from the db is fetched
 */