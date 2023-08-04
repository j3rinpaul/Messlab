import 'package:flutter/material.dart';

import '../../supabase_config.dart';

class generateBill extends StatefulWidget {
  @override
  _generateBillState createState() => _generateBillState();
}

class _generateBillState extends State<generateBill> {
  DateTime? selectedDate;
  bool isLoading = false;
  List<billTable> expenses = [];
  TextEditingController fixedExpenses = TextEditingController();
  // List<BillItem> billItems = [];
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

  @override
  void initState() {
    super.initState();
    table_data();
    // Fetch bill items from the database
  }

  Future<void> _billg() async {
    if (selectedMonth == null || selectedYear == null || selectedMonth == 00) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Month and Year'),
            content:
                Text('Please select a month and year to generate the bill for'),
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
      return;
    } else {
      final response = await supabase
          .from('bill_generated')
          .select('generate_bill')
          .eq('month', selectedMonth)
          .eq('year', selectedYear)
          .execute();

      // print(response.data);

      if (response.data.isEmpty) {
        // print(DateTime(selectedYear!, int.parse(selectedMonth!) + 1, 0));
        setState(() {
          isLoading = true;
        });
        final morningFoodResponse = await supabase
            .from('food_marking')
            .select('morning')
            .gte('mark_date',
                DateTime(selectedYear!, int.parse(selectedMonth!), 0))
            .lte('mark_date',
                DateTime(selectedYear!, int.parse(selectedMonth!) + 1, 0))
            .eq("morning", true)
            .execute();

        // print(morningFoodResponse.data.length);
        final noonFoodResponse = await supabase
            .from('food_marking')
            .select('noon')
            .gte('mark_date',
                DateTime(selectedYear!, int.parse(selectedMonth!), 0))
            .lte('mark_date',
                DateTime(selectedYear!, int.parse(selectedMonth!) + 1, 0))
            .eq("noon", true)
            .execute();
        // print(noonFoodResponse.data.length);

        final eveningFoodResponse = await supabase
            .from('food_marking')
            .select('evening')
            .gte('mark_date',
                DateTime(selectedYear!, int.parse(selectedMonth!), 0))
            .lte('mark_date',
                DateTime(selectedYear!, int.parse(selectedMonth!) + 1, 0))
            .eq("evening", true)
            .execute();
        // print(eveningFoodResponse.data.length);
        // print(DateTime(selectedYear!, int.parse(selectedMonth!) + 1, 0));
        // print(DateTime(selectedYear!, int.parse(selectedMonth!), 0));

        // Calculate the sum of true values in 'morning_food', 'noon_food', 'evening_food'
        int morningFoodCount = morningFoodResponse.data
            .where((data) => data['morning'] == true)
            .length;
        int noonFoodCount =
            noonFoodResponse.data.where((data) => data['noon'] == true).length;
        int eveningFoodCount = eveningFoodResponse.data
            .where((data) => data['evening'] == true)
            .length;
        // Calculate the total
        int totalFoodCount =
            morningFoodCount + noonFoodCount + eveningFoodCount;

        final amount = await supabase
            .from('daily_expense')
            .select('amount')
            .gte('date', DateTime(selectedYear!, int.parse(selectedMonth!), 1))
            .lte('date',
                DateTime(selectedYear!, int.parse(selectedMonth!) + 1, 0))
            .execute();
        setState(() {
          isLoading = false;
        });
        print(amount.data);
        final List<dynamic> data = amount.data as List<dynamic>;
        final List<double> amounts =
            data.map((item) => item['amount'] as double).toList();

        double sum = 0;
        for (final amount in amounts) {
          sum += amount;
        }
        double round = sum / totalFoodCount;
        double rate_per_point = double.parse(round.toStringAsFixed(2));

        // print(selectedMonth);
        // print(selectedYear);
        // print(fixedExpenses.text);
        // print(totalFoodCount);
        // print(sum);
        // print(rate_per_point);
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Container(
                width: MediaQuery.of(context).size.width *
                    0.9, // Adjust the width as needed
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text(
                        'Billing Details ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        ' ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        DataCell(Text('Total Points')),
                        DataCell(Text(totalFoodCount.toString())),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text('Rate per Point')),
                        DataCell(Text(rate_per_point.toString())),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text('Fixed Expenses')),
                        DataCell(Text(fixedExpenses.text)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmation'),
                          content: Text(
                              'Are you sure you want to generate the bill of the current mess cycle?'),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                final monthly =
                                    await supabase.from('monthly_bill').insert([
                                  {
                                    'month': selectedMonth,
                                    'year': selectedYear,
                                    'fixed': int.parse(fixedExpenses.text),
                                    'rate_per_cons': rate_per_point,
                                    // Convert to decimal
                                    'total_exp': sum,
                                    'consumption': totalFoodCount,
                                  }
                                ]).execute();

                                if (monthly.error == null) {
                                  print("Bill generated successfully");
                                } else {
                                  showAlert("Error","Fixed expense was update but bill was not generated\nGenerating bill.... ");
                                }
                                await user_bill();

                                print("Bill Generation reached");
                                //data
                                final response = await supabase
                                    .from('bill_generated')
                                    .insert([
                                  {
                                    'month': selectedMonth,
                                    'year': selectedYear,
                                    'generate_bill': true,
                                  }
                                ]).execute();
                                if (response.error == null) {
                                  showAlert("Bill generated Successfully",
                                      "Bill of ${selectedMonth} ${selectedYear} has been generated successfully");
                                } else {
                                  showAlert("Error",
                                      "Bill not generated\n please try again ");
                                }
                              },
                              child: Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('No'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
        return;
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Bill Already Generated'),
              content: Text(
                  'Bill for the selected month and year has already been generated'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generete Bill'),
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
          SizedBox(height: 15),
          TextField(
            controller: fixedExpenses,
            maxLines: null,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              labelText: 'Fixed Expenses',
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
              onPressed: () async {
                if (fixedExpenses.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Fixed Expenses'),
                        content: Text('Please enter the fixed expenses'),
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
                  return;
                } else {
                  return _billg();
                }
              },
              child: const Text("Generate Bill")),
          SizedBox(height: 15),
          // ElevatedButton(
          //     onPressed: () {
          //       user_bill();
          //     },
          //     child: Text("Test")),
          Text('Previous Bills', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Expanded(child: TableView(tableData: expenses))
        ],
      ),
    );
  }

  void showAlert(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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

//for diplaying the previous bills
  Future<void> table_data() async {
    final response = await supabase.from('monthly_bill').select().execute();
    print(response.data);
    if (response.error == null) {
      final data = response.data;

      if (data != null && data.isNotEmpty) {
        final list = data.map((expense) => billTable(
              expense['month'],
              expense['year'],
              expense['consumption'],
              expense['fixed'],
              expense['total_exp'],
              expense['rate_per_cons'],
            ));

        setState(() {
          expenses = List<billTable>.from(list);
        });
      }
    } else {
      print('Error: ${response.error?.message}');
    }
  }

  Future<void> user_bill() async {
    setState(() {
      isLoading = true;
    });
    //userdetails are fetched
    final user = await supabase.from("users").select('u_id').execute();
    print(user.data);
//fixed is fetched
    final fixed = await supabase
        .from('monthly_bill')
        .select('fixed')
        .eq('month', selectedMonth)
        .eq('year', selectedYear)
        .execute();
    int fixed_exp = fixed.data[0]['fixed'];
    //share of  fixed expenses to each users
    final fixed_per_user = fixed_exp / user.data.length;
    print(fixed_exp / user.data.length);
//fetching the rate per point
    final rate_per_point = await supabase
        .from('monthly_bill')
        .select('rate_per_cons')
        .eq('month', selectedMonth)
        .eq('year', selectedYear)
        .execute();
    print(rate_per_point.data[0]['rate_per_cons'].toString());
    final List<dynamic> data = user.data as List<dynamic>;
    for (final usd in data) {
      print(usd['u_id']);
      //fetching the morning noon and evening food count for each users

      final fetchmrng = await supabase
          .from('food_marking')
          .select('morning')
          .eq('u_id', usd['u_id'])
          .eq("morning", true)
          .gte('mark_date',
              DateTime(selectedYear!, int.parse(selectedMonth!), 1))
          .lte('mark_date',
              DateTime(selectedYear!, int.parse(selectedMonth!) + 1, 0))
          .execute();
      print(fetchmrng.data.length);

      final fetchnoon = await supabase
          .from('food_marking')
          .select('noon')
          .eq('u_id', usd['u_id'])
          .eq("noon", true)
          .gte('mark_date',
              DateTime(selectedYear!, int.parse(selectedMonth!), 1))
          .lte('mark_date',
              DateTime(selectedYear!, int.parse(selectedMonth!) + 1, 0))
          .execute();
      print("noon" + fetchnoon.data.length.toString());

      final fetchevng = await supabase
          .from('food_marking')
          .select('evening')
          .eq('u_id', usd['u_id'])
          .eq("evening", true)
          .gte('mark_date',
              DateTime(selectedYear!, int.parse(selectedMonth!), 1))
          .lte('mark_date',
              DateTime(selectedYear!, int.parse(selectedMonth!) + 1, 0))
          .execute();
      print("evng" + fetchevng.data.length.toString());
      int total =
          fetchmrng.data.length + fetchnoon.data.length + fetchevng.data.length;
      print("total" + total.toString());

      int bill = (fixed_per_user +
              total * rate_per_point.data[0]['rate_per_cons'].toDouble())
          .ceil();

      print(rate_per_point.data[0]['rate_per_cons'].toDouble().ceil());
      print(bill);

      final response = await supabase.from('user_bill').insert([
        {
          'u_id': usd['u_id'],
          'month': selectedMonth,
          'year': selectedYear,
          'total_bill': bill,
          'total_cons': total,
        }
      ]).execute();
      if (response.error == null) {
        print("Bill generated for user_bill");
      } else {
        print("Error for user_bill: ${response.error}");
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}

class billTable {
  int? month;
  int? year;
  int? total_points; //consumption
  int? fixed_exp; //fixed
  double? total_exp; //total exp
  double? rate_per_point; //rate per point

  billTable(
    this.month,
    this.year,
    this.total_points,
    this.fixed_exp,
    this.total_exp,
    this.rate_per_point,
  );
}

class TableView extends StatelessWidget {
  final List<billTable> tableData;
  const TableView({super.key, required this.tableData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          children: [
            DataTable(
              columns: [
                DataColumn(label: Text('Month')),
                DataColumn(label: Text('Year')),
                DataColumn(label: Text('Total Points')),
                DataColumn(label: Text('Fixed')),
                DataColumn(label: Text('Total Exp')),
                DataColumn(label: Text('Rate per Point')),
              ],
              rows: tableData.map<DataRow>((expense) {
                return DataRow(
                  cells: [
                    DataCell(Text(expense.month.toString())),
                    DataCell(Text(expense.year.toString())),
                    DataCell(Text(expense.total_points.toString())),
                    DataCell(Text(expense.fixed_exp.toString())),
                    DataCell(Text(expense.total_exp.toString())),
                    DataCell(Text(expense.rate_per_point.toString())),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
