import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import '../../supabase_config.dart';
// import 'package:path_provider/path_provider.dart';

class generateBill extends StatefulWidget {
  const generateBill({super.key});

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
          title: const Text('Select Month and Year'),
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
                decoration: const InputDecoration(
                  labelText: 'Month',
                ),
              ),
              const SizedBox(height: 10),
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
                decoration: const InputDecoration(
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
              child: const Text('Cancel'),
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
              child: const Text('OK'),
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

  String? lastBill;

  Future<void> _billg() async {
    if (selectedMonth == null || selectedYear == null || selectedMonth == 00) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Month and Year'),
            content: const Text(
                'Please select a month and year to generate the bill for'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
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
        // print(endDate);
        setState(() {
          isLoading = true;
        });
        final morningFoodResponse = await supabase
            .from('food_marking')
            .select('morning')
            .gte('mark_date', startDate)
            .lte('mark_date', endDate)
            .eq("morning", true)
            .execute();

        // print(morningFoodResponse.data.length);
        final noonFoodResponse = await supabase
            .from('food_marking')
            .select('noon')
            .gte('mark_date', startDate)
            .lte('mark_date', endDate)
            .eq("noon", true)
            .execute();
        // print(noonFoodResponse.data.length);

        final eveningFoodResponse = await supabase
            .from('food_marking')
            .select('evening')
            .gte('mark_date', startDate)
            .lte('mark_date', endDate)
            .eq("evening", true)
            .execute();
        // print(eveningFoodResponse.data.length);
        // print(endDate);
        // print(startDate);

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
            .gte('date', startDate)
            .lte('date', endDate)
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
        double ratePerPoint = double.parse(round.toStringAsFixed(2));

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
              content: SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.9, // Adjust the width as needed
                child: DataTable(
                  columns: const [
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
                        const DataCell(Text('Total Points')),
                        DataCell(Text(totalFoodCount.toString())),
                      ],
                    ),
                    DataRow(
                      cells: [
                        const DataCell(Text('Rate per Point')),
                        DataCell(Text(ratePerPoint.toString())),
                      ],
                    ),
                    DataRow(
                      cells: [
                        const DataCell(Text('Fixed Expenses')),
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
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirmation'),
                          content: const Text(
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
                                    'rate_per_cons': ratePerPoint,
                                    // Convert to decimal
                                    'total_exp': sum,
                                    'consumption': totalFoodCount,
                                    'generated_on': endDate,
                                  }
                                ]).execute();

                                if (monthly.error == null) {
                                  print("Bill generated successfully");
                                } else {
                                  showAlert("Error",
                                      "Fixed expense was update but bill was not generated\nGenerating bill.... ");
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
                                      "Bill of $selectedMonth $selectedYear has been generated successfully");
                                } else {
                                  showAlert("Error",
                                      "Bill not generated\n please try again ");
                                }
                              },
                              child: const Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('No'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Confirm'),
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
              title: const Text('Bill Already Generated'),
              content: const Text(
                  'Bill for the selected month and year has already been generated'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
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
        title: const Text('Generete Bill'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                return _selectDateRange(context);
              },
              child: const Text("Select Range ")),
          GestureDetector(
            onTap: () => _selectMonthAndYear(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white),
                    const SizedBox(width: 8.0),
                    Text(
                      selectedMonth != null && selectedYear != null
                          ? '$selectedMonth $selectedYear'
                          : 'Select Month',
                      style: const TextStyle(
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
          const SizedBox(height: 15),
          TextField(
            controller: fixedExpenses,
            maxLines: null,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              labelText: 'Fixed Expenses',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: () async {
                if (fixedExpenses.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Fixed Expenses'),
                        content: const Text('Please enter the fixed expenses'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                } else if (startDate.isEmpty || endDate.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Select Start and End date '),
                        content:
                            const Text('Please select the start and end date'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
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
          const SizedBox(height: 15),
          ElevatedButton(
              onPressed: () async {
                setState(() {
                  isSaveLoad = true;
                });

                await savePdf();
                setState(() {
                  isSaveLoad = false;
                });
              },
              child: Text("Download Bill")),

          SizedBox(height: 5),
          // Display a circular loading indicator based on the isSavingPdf flag
          isSaveLoad ? CircularProgressIndicator() : Container(),
          SizedBox(height: 5),
          Text("Last bill was on $lastBill"),
          SizedBox(height: 5),

          const Text('Previous Bills',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(child: TableView(tableData: expenses))
        ],
      ),
    );
  }

  bool isSaveLoad = false;

  Future<Uint8List> generatePdf() async {
    // Fetch data from Supabase
    final response = await supabase
        .from('user_bill')
        .select()
        .eq("month", selectedMonth)
        .eq("year", selectedYear)
        .execute();

    if (response.data.isEmpty) {
      showAlert("No data", "No data found for the selected month and year");
      return Uint8List(0);
    }

    Map<String, String> nameMap = {}; // Create a HashMap to store the names

    for (final record in response.data) {
      final sup = await supabase
          .from('users')
          .select('first_name,last_name')
          .eq("u_id", record['u_id'])
          .execute();

      // Check if the query returned data
      if (sup.data.isNotEmpty) {
        final String firstName = sup.data[0]['first_name'];
        final String lastName = sup.data[0]['last_name'];

        // Concatenate first name and last name
        final String fullName = '$firstName $lastName';

        // Save the full name to the HashMap
        nameMap[record['u_id']] = fullName;
      }
    }

    List<Map<String, dynamic>> data =
        (response.data as List<dynamic>).cast<Map<String, dynamic>>();

    // print(data);

    // Create a PDF document
    final pdf = pw.Document();

    // Add a page with A4 page format
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          // Create a list to hold the table data
          final tableData = <List<String>>[];

          // Add a header row
          tableData.add(['Name', 'Total Cons', 'Total Bill']);

          // Add data from the response
          for (final record in data) {
            // final name = nameEntry.keys;
            final name = nameMap[record['u_id']];
            final totalCons = record['total_cons'].toString();
            final totalBill = record['total_bill'].toString();

            tableData.add([name!, totalCons, totalBill]);
          }

          // Create a table from the data
          final table = pw.Table.fromTextArray(
            context: context,
            headers: selectedMonth!.length == 1
                ? ['Mess Bill for 0$selectedMonth/$selectedYear']
                : ['Mess Bill for $selectedMonth/$selectedYear'],
            data: tableData,
            border: pw.TableBorder.all(),
            headerAlignment: pw.Alignment.centerLeft,
            cellAlignment: pw.Alignment.centerLeft,
          );

          return [pw.Center(child: table)];
        },
      ),
    );

    // Save the PDF as bytes
    final Uint8List pdfBytes = await pdf.save();

    return pdfBytes;
  }

  Future<void> savePdf() async {
    if (selectedMonth == null || selectedYear == null) {
      showAlert("Date not selected", "Please select the Month and Year");
    } else {
      setState(() {
        isSaveLoad = true;
      });
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      // Wait for the PDF to be generated

      if (statuses[Permission.storage]!.isGranted) {
        String? downloadsDirectoryPath =
            (await DownloadsPath.downloadsDirectory())?.path;
        print(downloadsDirectoryPath);
        if (downloadsDirectoryPath != null) {
          final pdfBytes = await generatePdf();
          if (pdfBytes.lengthInBytes != 0) {
            final file = File('$downloadsDirectoryPath/bill.pdf');
            await file.writeAsBytes(pdfBytes);
            print(" File saved to $downloadsDirectoryPath/bill.pdf");
          }
        }
      }
      setState(() {
        isSaveLoad = false;
      });
      // showAlert("Saved", "Success");
    }
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
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

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
    }
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
          lastBill = data.isEmpty ? "Not" : data[0]['generated_on'];
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
    int fixedExp = fixed.data[0]['fixed'];
    //share of  fixed expenses to each users
    final fixedPerUser = fixedExp / user.data.length;
    print(fixedExp / user.data.length);
//fetching the rate per point
    final ratePerPoint = await supabase
        .from('monthly_bill')
        .select('rate_per_cons')
        .eq('month', selectedMonth)
        .eq('year', selectedYear)
        .execute();
    print(ratePerPoint.data[0]['rate_per_cons'].toString());
    final List<dynamic> data = user.data as List<dynamic>;
    for (final usd in data) {
      print(usd['u_id']);
      //fetching the morning noon and evening food count for each users

      final fetchmrng = await supabase
          .from('food_marking')
          .select('morning')
          .eq('u_id', usd['u_id'])
          .eq("morning", true)
          .gte('mark_date', startDate)
          .lte('mark_date', endDate)
          .execute();
      print(fetchmrng.data.length);

      final fetchnoon = await supabase
          .from('food_marking')
          .select('noon')
          .eq('u_id', usd['u_id'])
          .eq("noon", true)
          .gte('mark_date', startDate)
          .lte('mark_date', endDate)
          .execute();
      print("noon${fetchnoon.data.length}");

      final fetchevng = await supabase
          .from('food_marking')
          .select('evening')
          .eq('u_id', usd['u_id'])
          .eq("evening", true)
          .gte('mark_date', startDate)
          .lte('mark_date', endDate)
          .execute();
      print("evng${fetchevng.data.length}");
      int total =
          fetchmrng.data.length + fetchnoon.data.length + fetchevng.data.length;
      print("total$total");

      int bill = (fixedPerUser +
              total * ratePerPoint.data[0]['rate_per_cons'].toDouble())
          .ceil();

      print(ratePerPoint.data[0]['rate_per_cons'].toDouble().ceil());
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
              columns: const [
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
