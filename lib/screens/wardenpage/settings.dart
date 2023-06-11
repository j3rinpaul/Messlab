import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

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

  Future<void> _selectTime(
      BuildContext context, Function(TimeOfDay?) onTimeSelected) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: onTimeSelected(TimeOfDay.now()) ?? TimeOfDay.now(),
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
          title: Text('Confirm Update'),
          content: Text('Are you sure you want to update?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog

                _showSuccessMessage(context);
              },
              child: Text('Confirm'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
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
          title: Text('Success'),
          content: Text('Updated successfully.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
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
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
    final String formattedTime = DateFormat('hh:mm:ss a').format(now);

    return Scaffold(
      appBar: AppBar(
       
        title: const Text('Change Timings'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 216, 208, 208),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
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
                      text: selectedTime1.format(context),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Selected Time',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _selectTime(context, (TimeOfDay? time) {
                      setState(() {
                        selectedTime1 = time ?? selectedTime1;
                      });
                    });
                  },
                  icon: Icon(Icons.access_time),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
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
                      text: selectedTime2.format(context),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Selected Time',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _selectTime(context, (TimeOfDay? time) {
                      setState(() {
                        selectedTime2 = time ?? selectedTime2;
                      });
                    });
                  },
                  icon: Icon(Icons.access_time),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
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
                      text: selectedTime3.format(context),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Selected Time',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _selectTime(context, (TimeOfDay? time) {
                      setState(() {
                        selectedTime3 = time ?? selectedTime3;
                      });
                    });
                  },
                  icon: Icon(Icons.access_time),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showConfirmationDialog(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}
