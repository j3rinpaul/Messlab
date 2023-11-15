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

  bool isLoading = false;

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
        startDate = selectedDateRange!.start.toLocal().toString().substring(0, 10);
        endDate = selectedDateRange!.end.toLocal().toString().substring(0, 10);
      });
    }
  }

  Future<void> messHoliday(
    String start,
    String end,
    DateTime startD,
    DateTime endD,
  ) async {
    setState(() {
      isLoading = true;
    });

    final response = await supabase.from('users').select().execute();
    if (response.error != null) {
      throw response.error!;
    }

    if (start == end) {
      for (var item in response.data) {
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
        }
      }
    } else {
      for (DateTime time = startD;
          time.isBefore(endD.add(const Duration(days: 1)));
          time = time.add(const Duration(days: 1))) {
        for (var item in response.data) {
          final userId = item['u_id'];
          final updateRes = await supabase
              .from("food_marking")
              .update({
                'morning': false,
                'noon': false,
                'evening': false,
              })
              .eq('u_id', userId)
              .eq('mark_date', time.toLocal().toString().substring(0, 10))
              .execute();

          if (updateRes.error != null) {
            throw updateRes.error!;
          }
        }
      }
    }

    setState(() {
      isLoading = false;
    });

    // Show a dialog after the process is completed
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Process Completed'),
          content: Text('Values updated for selected date.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

 
 @override
Widget build(BuildContext context) {
  return Dialog(
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Mess Holiday",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _selectDateRange(context);
              },
              child: Text("Select Range "),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await messHoliday(
                      startDate,
                      endDate,
                      selectedDateRange!.start,
                      selectedDateRange!.end,
                    );
                  },
                  child: Text("Submit"),
                ),
              ),
              TextButton(onPressed: (){
                Navigator.of(context).popUntil((route) => route.isFirst);

              }, child: Text("Cancel"))
            ],
          ),
          // Show loading indicator
          if (isLoading) CircularProgressIndicator(),
        ],
      ),
    ),
  );
}

  }

