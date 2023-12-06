import 'dart:collection';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;

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

  int totalFixed = 0;

  Future<void> _fixedCal() async {
    setState(() {
      totalFixed = 0;
    });
    print(selectedMonth);
    print(selectedYear);
    final response = await supabase
        .from('fixed')
        .select("amount")
        .eq("month", selectedMonth)
        .eq("year", selectedYear)
        .execute();
    print(response.data);
    if (response.data == null) {
      setState(() {
        totalFixed = 0;
      });
    } else {
      for (final data in response.data) {
        totalFixed += int.parse(data['amount'].toString());
      }
    }
    print("Fixed :" + totalFixed.toString());
  }

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
        print(noonFoodResponse.data.length);

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
        print(morningFoodCount);
        print(noonFoodCount);
        print(eveningFoodCount);
        print(totalFoodCount);

        final amount = await supabase
            .from('daily_expense')
            .select('amount')
            .gte('date', startDate)
            .lte('date', endDate)
            .execute();

        final fixed = await supabase
            .from('monthly_bill')
            .select('fixed')
            .eq('month', selectedMonth)
            .eq('year', selectedYear)
            .execute();

        await _fixedCal();
        int fixedExpe = totalFixed;
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
                        DataCell(Text(fixedExpe.toString())),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    print(totalFixed);

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
                                await _fixedCal();
                                Navigator.pop(context);
                                final monthly =
                                    await supabase.from('monthly_bill').insert([
                                  {
                                    'month': selectedMonth,
                                    'year': selectedYear,
                                    'fixed': totalFixed,
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
          // TextField(
          //   controller: fixedExpenses,
          //   maxLines: null,
          //   keyboardType: TextInputType.number,
          //   decoration: const InputDecoration(
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.all(Radius.circular(10)),
          //     ),
          //     labelText: 'Fixed Expenses',
          //   ),
          // ),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: () async {
                if (startDate.isEmpty || endDate.isEmpty) {
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
          ElevatedButton(
              onPressed: () async {
                await _excelData();
              },
              child: Text("Excel bill")),

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

  Map<String, Map<String, List<bool>>> excelData = {};
  final pageSize = 1000; // Set your desired page size

  Future<void> _excelData() async {
    if (startDate.isEmpty ||
        endDate.isEmpty ||
        selectedMonth == null ||
        selectedYear == null) {
      showAlert("Date not selected", "Please select the Month, Year & range");
      return;
    } else {
      // print(sumList);

      // Assuming mark_date is a date column
      // final DateTime startDate = DateTime(int.parse(year), int.parse(month), 1);
      // final DateTime endDate =
      //     DateTime(int.parse(year), int.parse(month) + 1, 1)
      //         .subtract(Duration(days: 1));

      int offset = 0;

      while (true) {
        final data = await supabase
            .from('food_marking')
            .select(
                "mark_date,morning,noon,evening,u_id,users(u_id,first_name,last_name)")
            .gte("mark_date", startDate)
            .lte("mark_date", endDate)
            .range(offset, offset + pageSize - 1)
            .execute();

        if (data.error != null) {
          // Handle error
          print("Error fetching data: ${data.error}");
          break;
        }

        final List<dynamic> responseData = data.data as List<dynamic>;
        final List<Map<String, dynamic>> rows =
            (responseData as List?)?.cast<Map<String, dynamic>>() ?? [];

        for (var variables in rows) {
          final name = variables['users']['first_name'] +
              " " +
              variables['users']['last_name'];

          if (excelData.containsKey(name)) {
            excelData[name]![variables['mark_date']] = [
              variables['morning'],
              variables['noon'],
              variables['evening']
            ];
          } else {
            excelData[name] = {
              variables['mark_date']: [
                variables['morning'],
                variables['noon'],
                variables['evening']
              ]
            };
          }

          // print(excelData);
        }

        // Break the loop if there are fewer rows than the page size, indicating no more data
        if (rows.length < pageSize) {
          break;
        }

        offset += pageSize;
      }

      //sort the excelData by name
      excelData = SplayTreeMap<String, Map<String, List<bool>>>.from(
          excelData, (key1, key2) => key1.compareTo(key2));

      final workbook = excel.Workbook();
      String month = selectedMonth!;
      String year = selectedYear!.toString();
      final sheet = workbook.worksheets[0];
      //merge the cells from A1 to AH1,B1 to BH1,C1 to CH1
      sheet.getRangeByName('A1:AN3').merge();

      // add text to merged cells
      //with font being bold and size 40 and centered
      sheet
          .getRangeByName('A1')
          .setText('GECI SH Mess Attendence for $month/$year');
      sheet.getRangeByName('A1').cellStyle.fontSize = 40;
      sheet.getRangeByName('A1').cellStyle.bold = true;
      sheet.getRangeByName('A1').cellStyle.hAlign = excel.HAlignType.center;
      sheet.getRangeByName('A4').setText('SL No');
      sheet.getRangeByName('A4').cellStyle.fontSize = 16;
      sheet.getRangeByName('A4').cellStyle.bold = true;
      sheet.getRangeByName('A4:A5').merge();
      sheet.getRangeByName('B4').cellStyle.fontSize = 16;
      sheet.getRangeByName('B4').cellStyle.bold = true;
      sheet.getRangeByName('B4:C5').merge();
      sheet.getRangeByName('B4').setText('Name');

      //insert name under the name field
      int i = 6;
      int j = 1;

      List<String> dates = [];

      for (final details in excelData.values) {
        for (final date in details.keys) {
          if (!dates.contains(date)) {
            dates.add(date);
          }
        }
      }

      dates.sort((a, b) => a.compareTo(b));

      int namelen = excelData.length * 3;
      List<bool> flattenOrginal = [];

      //get the last used column

      for (final name in excelData.keys) {
        int l = i + 2;

        // Merge cells in column A
        sheet.getRangeByName('A$i:A$l').merge();

        // Set serial number in column A
        sheet.getRangeByName('A$i').setText(j.toString());

        // Set the name in columns B and C
        sheet.getRangeByName('B$i:C$l').merge();
        sheet.getRangeByName('B$i').setText(name);

        final details = excelData[name]!;
        // print(details);

        //sort details

        final sortedDetails = SplayTreeMap<String, List<bool>>.from(
            details, (key1, key2) => key1.compareTo(key2));

        // print(sortedDetails);

        //convert the sorted details values to list
        final List<List<bool>> sortedDetailsList = [];
        for (final value in sortedDetails.values) {
          sortedDetailsList.add(value);
        }

        // print(sortedDetailsList);
        List<bool> flatten2DList(List<List<bool>> inputList) {
          return inputList.expand((innerList) => innerList).toList();
        }

        List<bool> flattenedList1 = flatten2DList(sortedDetailsList);
        //append the each flattaned list to the main list
        flattenOrginal.addAll(flattenedList1);

        i += 3;
        j++;
      }
      // print(flattenOrginal);
      int m = 6;
      int n = 4;
      int z = 0;
      int u = 0;

      for (int s = 6; s < namelen + 6; s += 3) {
        for (n = 4; n <= dates.length + 3; n++) {
          for (m = u; m < u + 3; m++, z++) {
            sheet
                .getRangeByIndex(m + 6, n)
                .setNumber(flattenOrginal[z] ? 1 : 0);
          }
        }
        u += 3;
      }

      //date
      int firstRow = 4;
      int firstCol = 4;
      final bool isVertical = false;
      sheet.importList(dates, firstRow, firstCol, isVertical);
      sheet.getRangeByIndex(4, 4, 4, 35).autoFitColumns();

      // int lastCol = sheet.getLastColumn();
      // print(lastCol);

      //create a hashmap to store the name as keys and their morning noon and evening count as values from excelData
      Map<String, List<int>> sumM = {};
      Map<String, int> sumN = {};
      for (final name in excelData.keys) {
        int sumMrg = 0;
        int sumNoon = 0;
        int sumEvng = 0;
        final details = excelData[name]!;
        for (final date in details.keys) {
          if (details[date]![0] == true) {
            sumMrg++;
          }
          if (details[date]![1] == true) {
            sumNoon++;
          }
          if (details[date]![2] == true) {
            sumEvng++;
          }
        }
        sumM[name] = [sumMrg, sumNoon, sumEvng];
        sumN[name] = sumMrg + sumNoon + sumEvng;
      }

      //sort the sumMap by name
      print(sumN);
      //sort the sumN by name
      sumN = SplayTreeMap<String, int>.from(
          sumN, (key1, key2) => key1.compareTo(key2));

      //convert to list
      final List<int> sumList = [];
      for (final value in sumN.values) {
        sumList.add(value);
      }

      // print(sumMap);

      int firstR = dates.length + 5;
      int firstC = 6;
      //loop through the sumList and insert the values in the excel sheet
      for (int m = 0; m < sumList.length; m++) {
        sheet.getRangeByIndex(firstC, firstR).setValue(sumList[m]);
        //merge the cells
        sheet.getRangeByIndex(firstC, firstR, firstC + 2, firstR).merge();
        firstC += 3;
      }

      //make a list of the values of the hashmap
      final List<List<int>> sumMList = [];
      for (final value in sumM.values) {
        sumMList.add(value);
      }

      //make it a single list
      List<int> flattenMList = [];
      for (final value in sumMList) {
        flattenMList.addAll(value);
      }

      sheet.getRangeByIndex(4, dates.length + 4).setText('Cons');
      sheet.getRangeByIndex(4, dates.length + 4).cellStyle.fontSize = 12;

      sheet.getRangeByIndex(4, dates.length + 5).autoFit();

      sheet.getRangeByIndex(4, dates.length + 5).setText("Total");
      sheet.getRangeByIndex(4, dates.length + 5).cellStyle.fontSize = 12;

      sheet.getRangeByIndex(4, dates.length + 5).autoFitColumns();

      int firstRe = dates.length + 4;
      int firstCe = 6;
      //loop through the sumList and insert the values in the excel sheet
      for (int m = 0; m < flattenMList.length; m++) {
        sheet.getRangeByIndex(firstCe, firstRe).setValue(flattenMList[m]);
        firstCe++;
      }

      //save the excel file

      final List<int> bytes = workbook.saveAsStream();
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = 'bill.xlsx'
        ..click();
    }
  }

  Future<Uint8List> generatePdf() async {
    // Fetch data from Supabase
    final response = await supabase
        .from('user_bill')
        .select()
        .eq("month", selectedMonth)
        .eq("year", selectedYear)
        .execute();
    // print(response.data.toString());

    if (response.data == null) {
      showAlert("No data", "No data found for the selected month and year");
      return Uint8List(0);
    }

    final monthlydata = await supabase
        .from('monthly_bill')
        .select("fixed,rate_per_cons")
        .eq("month", selectedMonth)
        .eq("year", selectedYear)
        .execute();

    int fixedE = monthlydata.data[0]['fixed'];
    int length = response.data.length;
    double myround = fixedE / length;
    int fixedExp = myround.round();
    double rate_per_point = monthlydata.data[0]['rate_per_cons'];

    print(monthlydata.data.toString());

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
        record['Name'] = fullName;
      }
    }

    List<Map<String, dynamic>> data =
        (response.data as List<dynamic>).cast<Map<String, dynamic>>();

    data.sort((a, b) {
      final nameA = nameMap[a['u_id']] ?? '';
      final nameB = nameMap[b['u_id']] ?? '';
      return nameA.compareTo(nameB);
    });
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
          tableData.add([
            'Name',
            'Consumption',
            "Point Rate",
            "Consumption Charge",
            "Fixed",
            'Amount',
          ]);

          // Add data from the response
          for (final record in data) {
            // final name = nameEntry.keys;
            final name = nameMap[record['u_id']];
            final totalCons = record['total_cons'].toString();
            final ratePoint = rate_per_point.toString();
            final sub =
                (record['total_cons'] * rate_per_point).ceil().toString();
            final fixed = fixedExp.toString();
            final totalBill = record['total_bill'].toString();

            tableData.add([name!, totalCons, ratePoint, sub, fixed, totalBill]);
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

      final pdfBytes = await generatePdf();

      if (pdfBytes.lengthInBytes != 0) {
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = 'bill.pdf'
          ..click();

        html.Url.revokeObjectUrl(url);
      }

      setState(() {
        isSaveLoad = false;
      });
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
        print(data);
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
          lastBill =
              data.isEmpty ? "Not" : data.last['generated_on'].toString();
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
                DataColumn(label: Text('Delete')),
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
                    DataCell(IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        print(expense.month);
                        print(expense.year);
                           final response = await supabase
                              .from('bill_generated')
                              .delete()
                              .eq('month',expense.month)
                              .eq('year',expense.year)
                              .execute();
                          if (response.error == null) {
                            print("deleted");
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Deleted"),
                                  content: Text(
                                      "Bill deleted successfully"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"))
                                  ],
                                );
                              },
                            );

                          } else {
                            print(response.error);
                          }
                      },
                    ))
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
