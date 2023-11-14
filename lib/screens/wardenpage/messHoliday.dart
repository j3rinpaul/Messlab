import 'package:flutter/material.dart';
import 'package:mini_project/supabase_config.dart';

class MessHoliday extends StatefulWidget {
  const MessHoliday({super.key});

  @override
  State<MessHoliday> createState() => _MessHolidayState();
}

class _MessHolidayState extends State<MessHoliday> {
  String startDate = "";
  String endDate = "";
  DateTimeRange? selectedDateRange;
  void _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: selectedDateRange,
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
        startDate =
            selectedDateRange!.start.toLocal().toString().substring(0, 10);
        endDate = selectedDateRange!.end.toLocal().toString().substring(0, 10);
        print(selectedDateRange!.start.toLocal().toString().substring(0, 10));
        print(selectedDateRange!.end.toLocal().toString().substring(0, 10));
      });
      // messHoliday(
      //     startDate, endDate, selectedDateRange!.start, selectedDateRange!.end);
    }
  }

  Future<void> messHoliday(
      String start, String end, DateTime startD, DateTime endD) async {
    final resposnse = await supabase.from('users').select().execute();
    if (resposnse.error != null) {
      throw resposnse.error!;
    }
    if (start == end) {
      print("inside");

      for (var item in resposnse.data) {
        final userId = item['u_id'];
        final updateRes = await supabase
            .from("food_marking")
            .update({
              'morning': false,
              'noon': false,
              'evening': false,
            })
            .eq('u_id', userId)
            .eq('mark_date', start)
            .execute();
        if (updateRes.error != null) {
          throw updateRes.error!;
        }else{
          print('Insert operation completed successfully!');
        }
      }
    } else {
      // Convert your end date string to DateTime

      for (DateTime time = startD;
          time.isBefore(endD.add(const Duration(days: 1)));
          time = time.add(const Duration(days: 1))) {
        for (var item in resposnse.data) {
          final userId = item['u_id'];
          final updateRes = await supabase
              .from("food_marking")
              .update({
                'morning': false,
                'noon': false,
                'evening': false,
              })
              .eq('u_id', userId)
              .gt('mark_date', start)
              .lt("mark_date", end)
              .execute();
          if (updateRes.error != null) {
            // Handle error
            throw updateRes.error!;
          }
          print('Insert operation completed successfully!');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mess Holiday"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  return _selectDateRange(context);
                },
                child: Text("Select Range ")),
            ElevatedButton(
                onPressed: () async {
                  await messHoliday(startDate, endDate,
                      selectedDateRange!.start, selectedDateRange!.end);
                },
                child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}
