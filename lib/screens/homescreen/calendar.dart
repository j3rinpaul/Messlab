import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';

import 'checkBox.dart';

class Calendar extends StatefulWidget {
  final String? u_id;
  const Calendar({super.key, this.u_id});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime? selectedValue = DateTime.now();
  

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
        CheckboxList(date: selectedValue, u_id: "${widget.u_id}"),
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