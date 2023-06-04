import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyCount extends StatefulWidget {
  const DailyCount({Key? key}) : super(key: key);

  @override
  State<DailyCount> createState() => _DailyCountState();
}

class _DailyCountState extends State<DailyCount> {
  final List<DateTime> dates = [
    DateTime(2023, 6, 1),
    DateTime(2023, 6, 2),
    DateTime(2023, 6, 3),
    DateTime(2023, 6, 1),
    DateTime(2023, 6, 2),
    DateTime(2023, 6, 3),
    // Add more dates as needed
  ];

  List<List<bool>> foodConsumption = [
    [true, false, true], // Example consumption data for first date
    [false, true, false], // Example consumption data for second date
    [true, true, true],
    [true, false, true], // Example consumption data for first date
    [false, true, false], // Example consumption data for second date
    [true, true, true], // Example consumption data for third date
    // Add more consumption data as needed
  ];

  List<Map<String, dynamic>> parsedData = [
    {
      'date': '2023-06-01',
      'morning_food': 10,
      'noon_food': 15,
      'evening_food': 8,
    },
  ];

  String _getName(int index) {
    switch (index) {
      case 0:
        return 'Koothi';
      case 1:
        return 'Kunjoottan';
      case 2:
        return 'Punda paul';
      case 3:
        return 'vijayan';
      case 4:
        return 'hafi';
      case 5:
        return 'suni de andii';

      // Add more cases for additional food names
      default:
        return '';
    }
  }

  void _showEditDialog(int index) {
    List<bool> currentConsumption = List.from(foodConsumption[index]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Food Consumption'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text('Morning'),
                    value: currentConsumption[0],
                    onChanged: (bool? value) {
                      setState(() {
                        currentConsumption[0] = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Noon'),
                    value: currentConsumption[1],
                    onChanged: (bool? value) {
                      setState(() {
                        currentConsumption[1] = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Evening'),
                    value: currentConsumption[2],
                    onChanged: (bool? value) {
                      setState(() {
                        currentConsumption[2] = value ?? false;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  foodConsumption[index] = List.from(currentConsumption);
                });
                Navigator.pop(context);
                _showSuccessDialog();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Food consumption updated successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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
    final currentDate = DateTime.now().toString().substring(0, 10);

    return Scaffold(
      appBar: AppBar(
        title: Text('Food Markings'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Count : $currentDate',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color.fromARGB(255, 202, 195, 195),
              ),
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        parsedData[0]['morning_food'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                      Text(
                        'Morning',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        parsedData[0]['noon_food'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                      Text(
                        'Noon',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        parsedData[0]['evening_food'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                      Text(
                        'Evening',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Text(
                      'Consumption',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: dates.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    margin:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getName(index),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              for (int i = 0; i < 3; i++)
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: foodConsumption[index][i]
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showEditDialog(index);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
