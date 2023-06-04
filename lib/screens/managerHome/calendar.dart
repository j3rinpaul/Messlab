import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import '../wardenpage/DailyCount.dart';
import 'checkBox.dart';
import 'verify.dart';

class Calendar extends StatefulWidget {
  final String? uid;
  const Calendar({super.key, required this.uid});

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
        CheckboxList(date: selectedValue,userId:widget.uid,),
        Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  ElevatedButton(onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return const DailyCount();
                    }));
                  }, child: const Text("Daily Count")),
            ),
            
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: ElevatedButton(
            //       onPressed: () {
            //         Navigator.of(context)
            //             .push(MaterialPageRoute(builder: (ctx) {
            //           return const VerifyUser();
            //         }));
            //       },
            //       child: const Text("User Verify")),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  ElevatedButton(onPressed: () {}, child: const Text("Monthly Bill")),
            )
          ],
        )

        //the announcement and review below
      ],
    );
  }
}
