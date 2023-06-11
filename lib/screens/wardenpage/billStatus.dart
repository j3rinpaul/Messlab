import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_project/supabase_config.dart';

class MonthlyBill extends StatefulWidget {
  @override
  _MonthlyBillState createState() => _MonthlyBillState();
}

class _MonthlyBillState extends State<MonthlyBill> {
  DateTime? selectedDate;
  List<BillItem> billItems = [];
  List<String> months = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
  ];
  List<int> years =
      List<int>.generate(10, (index) => DateTime.now().year - 5 + index);

  String? selectedMonth;
  int? selectedYear;

  Future<void> userAmount(String? date, String? year) async {
    final response = await supabase
        .from("user_bill")
        .select("total_bill,bill_status,u_id")
        .eq('month', date)
        .eq('year', year)
        .execute();

    if (response.data != null) {
      List<BillItem> items = [];
      for (var itemData in response.data) {
        final userId = itemData['u_id'];
        final userResponse = await supabase
            .from("users")
            .select("first_name,last_name")
            .eq('u_id', userId)
            .execute();
        if (userResponse.data != null && userResponse.data.isNotEmpty) {
          final name = userResponse.data[0]['first_name']+ " " + userResponse.data[0]['last_name'];
          BillItem item = BillItem(
            realname: name,
            name: itemData['u_id'],
            amount: itemData['total_bill'].toDouble(),
            status: itemData['bill_status'] ? 'Paid' : 'Not Paid',
          );
          items.add(item);
        } else {
          print(userResponse.error!.message.toString());
        }
      }
      setState(() {
        billItems = items;
      });
    } else {
      print(response.error!.message.toString());
    }
  }

  Future<void> _selectMonthAndYear() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Month and Year'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedMonth,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMonth = newValue;
                  });
                },
                items: months.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Month',
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: selectedYear,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedYear = newValue;
                  });
                },
                items: years.map((int year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Year',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  selectedMonth = null;
                  selectedYear = null;
                });
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                userAmount(selectedMonth, selectedYear.toString());
                // Perform actions with selectedMonth and selectedYear
                if (selectedMonth != null && selectedYear != null) {
                  print(
                      'Selected month and year: $selectedMonth $selectedYear');
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'Paid':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'Not Paid':
        return Icon(Icons.cancel, color: Colors.red);
      default:
        return Icon(Icons.error);
    }
  }

  void _showEditOptions(BillItem item) async {
    final status = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Status'),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context, 'Paid');
                if (selectedMonth == null && selectedYear == null) {
                  setState(() {
                    selectedMonth = DateTime.now().month.toString();
                    selectedYear = DateTime.now().year;
                  });
                }
                final response = await supabase
                    .from("user_bill")
                    .update({"bill_status": true})
                    .eq('u_id', item.name)
                    .eq('month', selectedMonth)
                    .eq('year', selectedYear.toString())
                    .execute();
                if (response.error != null) {
                  print(response.error!.message.toString());
                } else {
                  print("true");
                }
              },
              child: Row(
                children: [
                  _getStatusIcon('Paid'),
                  SizedBox(width: 8.0),
                  Text('Paid'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context, 'Not Paid');
                final response = await supabase
                    .from("user_bill")
                    .update({"bill_status": true})
                    .eq('u_id', item.name)
                    .eq('month', selectedMonth)
                    .eq('year', selectedYear.toString())
                    .execute();
                if (response.error != null) {
                  print(response.error!.message.toString());
                } else {
                  print("false");
                }
              },
              child: Row(
                children: [
                  _getStatusIcon('Not Paid'),
                  SizedBox(width: 8.0),
                  Text('Not Paid'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String month = DateFormat('MM').format(DateTime.now());
  String year = DateFormat('yyyy').format(DateTime.now());
  @override
  void initState() {
    super.initState();
    fetchBillItemsFromDatabase(); // Fetch bill items from the database
    userAmount(month, year);
  }

  Future<void> fetchBillItemsFromDatabase() async {
    // Replace with your own database connection and query logic
    await Future.delayed(Duration(seconds: 2)); // Simulating a delay
    await userAmount(selectedMonth, selectedYear.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Bill'),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () => _selectMonthAndYear(),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white),
                    SizedBox(width: 8.0),
                    Text(
                      selectedMonth != null && selectedYear != null
                          ? '$selectedMonth $selectedYear'
                          : 'Select Month',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // SizedBox(height: 5),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(
                color: const Color.fromARGB(255, 209, 206, 206),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'NAME',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'AMOUNT',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'STATUS',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...billItems.map((item) {
                        return TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(item.realname.toString()),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(item.amount.toString()),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () => _showEditOptions(item),
                                  child: Row(
                                    children: [
                                      _getStatusIcon(item.status),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BillItem {
  final String name;
  final String? realname;
  final double amount;
  String status;

  BillItem({
    required this.name,
    required this.amount,
    this.realname,
    this.status = 'Not Paid',
  });
}
