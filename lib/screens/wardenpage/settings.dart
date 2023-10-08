import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../supabase_config.dart'; // Import the intl package for date formatting

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  List<dynamic> parsedData = [];

  TimeOfDay selectedTime1 = TimeOfDay.now();
  TimeOfDay selectedTime2 = TimeOfDay.now();
  TimeOfDay selectedTime3 = TimeOfDay.now();

  TimeOfDay? mrngTime;
  TimeOfDay? noonTime;
  TimeOfDay? evngTime;
  bool isLoading = false;

  Future<void> _initTime() async {
    setState(() {
      isLoading = true;
    });
    mrngTime = await setTime("morning");
    noonTime = await setTime("noon");
    evngTime = await setTime("evening");
    setState(() {
      isLoading = false;
    });
  }

  Future<TimeOfDay?> setTime(String time) async {
    final response =
        await supabase.from('timer').select('value').eq('time', time).execute();

    if (response.error != null) {
      // Handle the error
      print('Error retrieving data: ${response.error!.message}');
      return null;
    }

    final List<dynamic> data = response.data as List<dynamic>;
    if (data.isNotEmpty) {
      final String value = data[0]['value'] as String;
      final List<String> splitValue = value.split(':');
      final int hour = int.parse(splitValue[0]);
      final int minute = int.parse(splitValue[1]);
      final TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);
      print(timeOfDay);
      return timeOfDay;
    }

    return null; // Return null if no data is found
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initTIme,
      Function(TimeOfDay?) onTimeSelected) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initTIme,
    );

    if (pickedTime != null) {
      setState(() {
        onTimeSelected(pickedTime);
      });
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Update'),
          content: const Text('Are you sure you want to update?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                 updateDataInSupabase(mrngTime!, "morning");
              updateDataInSupabase(noonTime!, "noon");
              updateDataInSupabase(evngTime!, "evening");

                _showSuccessMessage(context);
              },
              child: const Text('Confirm'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Updated successfully.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setTime("morning");
    _initTime();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
    final String formattedTime = DateFormat('hh:mm:ss a').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Timings'),
      ),
      body:isLoading ? const Center(child: CircularProgressIndicator()): Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 216, 208, 208),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.local_cafe),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: mrngTime!.format(context),
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Morning',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _selectTime(context, mrngTime!, (TimeOfDay? time) {
                      setState(() {
                        mrngTime = time ?? selectedTime1;
                      });
                    });
                    // print("selected"+selectedTime1.toString());
                  },
                  icon: const Icon(Icons.access_time),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: noonTime!.format(context),
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Noon',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _selectTime(context, noonTime!, (TimeOfDay? time) {
                      setState(() {
                        noonTime = time ?? selectedTime2;
                      });
                    });
                  },
                  icon: const Icon(Icons.access_time),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.nightlight_round),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: evngTime!.format(context),
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Evening',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _selectTime(context, evngTime!, (TimeOfDay? time) {
                      setState(() {
                        evngTime = time ?? selectedTime3;
                      });
                    });
                  },
                  icon: const Icon(Icons.access_time),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showConfirmationDialog(context);
              // print(formattedTime);
             
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> updateDataInSupabase(TimeOfDay selectedTime, String time) async {
    final String formattedTime = DateFormat('hh:mm a').format(
      DateTime(0, 1, 1, selectedTime.hour, selectedTime.minute),
    );

    print(formattedTime);
    print(formattedTime.runtimeType);

    final response = await supabase
        .from('timer')
        .update({'value': formattedTime})
        .eq('time', time)
        .execute();

    if (response.error != null) {
      // Handle the error
      print('Error updating data: ${response.error!.message}');
    } else {
      // Data updated successfully
      print('Data updated successfully');
    }
  }
}
