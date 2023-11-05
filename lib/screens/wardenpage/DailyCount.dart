// import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import '../../supabase_config.dart';

class DailyCount extends StatefulWidget {
  const DailyCount({Key? key}) : super(key: key);

  @override
  State<DailyCount> createState() => _DailyCountState();
}

class _DailyCountState extends State<DailyCount> {
  bool? isdetail = false;
  String currentDate = DateTime.now().toString().substring(0, 10);

  Future<dynamic> fetchDataWithDateParameter(
      String date, String db, String pref) async {
    final response = await supabase
        .from(db)
        .select()
        .eq('mark_date', date)
        .eq(pref, true)
        .execute();
    if (response.error == null) {
      final data = response.data;
      final count = data.length;
      return count;
    } else {
      print("Failed to fetch data: ${response.error}");
    }
  }

  String date = DateTime.now().toLocal().toString().split(' ')[0];
  Map<dynamic, List<bool>> foodDetails = {};
  List<bool> foodList = [];
  Map<dynamic, String> userNames = {};
  bool isLoading = false;
  bool isuserloading = false;

  Future<dynamic> userdetails() async {
    setState(() {
      isdetail = true;
    });
    final respo = await supabase
        .from('users')
        .select('u_id ,first_name , last_name')
        .execute();

    for (final user in respo.data) {
      final uId = user['u_id'];
      final firstName = user['first_name'];
      final lastName = user['last_name'];
      final fullName = '$firstName $lastName';

      userNames[uId] = fullName;
    }
    if (respo.error == null) {
      final data = respo.data;

      final List<dynamic> userIds =
          data.map<dynamic>((user) => user['u_id']).toList();

      for (final uids in userIds) {
        final allFood = await supabase
            .from('food_marking')
            .select('morning , noon , evening')
            .eq('u_id', uids)
            .eq('mark_date', date)
            .execute();

        final foodData = allFood.data;
        final foodList = foodData.isNotEmpty
            ? [
                foodData[0]['morning'],
                foodData[0]['noon'],
                foodData[0]['evening'],
              ]
            : [true, true, true];
        setState(() {
          foodDetails[uids] = List.from(foodList);
        });
      }

      // print(foodDetails.toString());
    } else {
      print("Failed to fetch data: ${respo.error}");
    }
    setState(() {
      isdetail = false;
    });
  }

  Future<void> Sort() async {
    setState(() {
      isuserloading = true;
      isLoading = true;
    });
    await userdetails();
    await fetchDataCount();
    var l1 = foodDetails.entries.toList();
    l1.sort((a, b) {
      String nameA = userNames[a.key]!;
      String nameB = userNames[b.key]!;
      return nameA.compareTo(nameB);
    });
    foodDetails = Map.fromEntries(l1);
    setState(() {
      isLoading = false;
      isuserloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    Sort();
    monthlyC(DateTime.now());
  }

  Future<void> fetchDataCount() async {
    setState(() {
      isuserloading = true;
    });
    final morningFoodCount =
        await fetchDataWithDateParameter(date, "food_marking", "morning");
    final noonFoodCount =
        await fetchDataWithDateParameter(date, "food_marking", "noon");
    final eveningFoodCount =
        await fetchDataWithDateParameter(date, "food_marking", "evening");

    setState(() {
      parsedData[0]['date'] = date;
      parsedData[0]['morning_food'] = morningFoodCount;
      parsedData[0]['noon_food'] = noonFoodCount;
      parsedData[0]['evening_food'] = eveningFoodCount;
      isuserloading = false;
    });
  }

  List<Map<String, dynamic>> parsedData = [
    {},
  ];

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Food consumption updated successfully.'),
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

  DateTime passDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: passDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != passDate) {
      setState(() {
        passDate = picked;

        date = passDate.toString().substring(0, 10);
        fetchDataCount();
        userdetails();
        monthlyC(DateTime(passDate.year, passDate.month, passDate.day));
      });
    }
  }

  Map<String, List<dynamic>> downloadList = {};
  void fetchDownload() {
    final sortedUserNames = Map.fromEntries(userNames.entries.toList()
      ..sort((a, b) => a.value!.compareTo(b.value)));

    for (final entry in sortedUserNames.entries) {
      final key = entry.key;
      final name = entry.value;
      final List<dynamic> foodValues =
          foodDetails[key] ?? List.filled(3, false);
      downloadList[name] = foodValues;
    }
  }

  Map<String, int> mapMonthly = {};
  int totalCumulative = 0;

  Future<void> monthlyC(DateTime selectDate) async {
    setState(() {
      isuserloading = true;
      isLoading = true;
      totalCumulative = 0;
    });
    mapMonthly.clear();
    final now = selectDate;
    final startOfMonth = DateTime(now.year, now.month, 1);
    final monthlyUser = await supabase.from("users").select("u_id").execute();
    for (var user in monthlyUser.data) {
      int morningCumulative = 0;
      int noonCumulative = 0;
      int eveningCumulative = 0;
      final cumulative = await supabase
          .from("food_marking")
          .select("morning, noon, evening")
          .eq("u_id", user['u_id'])
          .gte("mark_date", startOfMonth.toString().substring(0, 10))
          .lte("mark_date", now.toString().substring(0, 10))
          .execute();
      for (var cum in cumulative.data) {
        if (cum['morning'] == true) {
          morningCumulative++;
        }
        if (cum['noon'] == true) {
          noonCumulative++;
        }
        if (cum['evening'] == true) {
          eveningCumulative++;
        }
      }
      final monthly = morningCumulative + noonCumulative + eveningCumulative;
      final first_name = await supabase
          .from("users")
          .select("first_name")
          .eq("u_id", user['u_id'])
          .execute();
      final last_name = await supabase
          .from("users")
          .select("last_name")
          .eq("u_id", user['u_id'])
          .execute();
      final fname = first_name.data[0]['first_name'] as String;
      final lname = last_name.data[0]['last_name'] as String;
      final name = fname + " " + lname;
      
      totalCumulative += monthly;

      mapMonthly[name] = monthly;
    }
    print(mapMonthly.toString());
    setState(() {
      isuserloading = false;
      isLoading = false;
    });
  }

  Future<Uint8List> generatePdfFun() async {
    fetchDownload();
    await monthlyC(DateTime(passDate.year, passDate.month, passDate.day));
    final pdf = pw.Document();

    // Define a custom page format for multiple pages
    final pageFormat = PdfPageFormat.a4.copyWith(
      marginTop: 10.0, // Adjust the margins as needed
    );

    List<List<String>> currentPageData = [];
    // Create a list of table data for each page
    final List<List<List<String>>> pages = [];

    // Initialize the current page data

    // Helper function to add a new page and reset current page data
    void addPage() {
      final tableData = [
        ['Name', 'Morning', 'Noon', 'Evening', 'Daily', 'Monthly'],
        ...currentPageData, // Add rows for the current page here
      ];

      if (downloadList.keys.isNotEmpty) {
        pages.add(tableData);
      }

      currentPageData = [];
    }

    for (var key in downloadList.keys) {
      final value = downloadList[key];
      final mrng = value![0] ? "Yes" : "No";
      final noon = value[1] ? "Yes" : "No";
      final evening = value[2] ? "Yes" : "No";
      final month = mapMonthly[key];
      print(totalCumulative.toString());

      // Calculate the Daily Cumulative (sum of Yes values)
      final dailyCumulative = (mrng == "Yes" ? 1 : 0) +
          (noon == "Yes" ? 1 : 0) +
          (evening == "Yes" ? 1 : 0);

      currentPageData.add([
        key,
        mrng,
        noon,
        evening,
        dailyCumulative.toString(),
        month.toString()
      ]);

      // Check if the current page is getting too long, and if so, add a new page
      if (currentPageData.length > 20) {
        addPage();
      }
    }

// Calculate the "Total" values and add them to the last page
    final total = [
      'Total',
      parsedData[0]['morning_food'].toString(),
      parsedData[0]['noon_food'].toString(),
      parsedData[0]['evening_food'].toString(),
      " ",
      totalCumulative.toString(),
    ];
    currentPageData.add(total);

// If the last page isn't empty, add it to the pages list without headings
    if (currentPageData.isNotEmpty) {
      addPage();
    }

    // Create a PDF with multiple pages
    for (final pageData in pages) {
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (pw.Context context) {
            // Create a table from the page data
            final table = pw.Table.fromTextArray(
              context: context,
              headers: ["Staff Hostel Daily Count $date"],
              data: pageData,
              border: pw.TableBorder.all(),
              headerAlignment: pw.Alignment.centerLeft,
              cellAlignment: pw.Alignment.centerLeft,
            );

            return pw.Center(
              child: table,
            );
          },
        ),
      );
    }

    final Uint8List pdfBytes = await pdf.save();

    return pdfBytes;
  }
// Import the 'html' package for web platform

  Future<void> savePdf() async {
/* 
//
//    final pdfBytes = await generatePdfFun(); // Wait for the PDF to be generated

    if (html.window.navigator.userAgent.contains("Android")) {
      // For Android platform, use the existing code to save the PDF
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      if (statuses[Permission.storage]!.isGranted) {
        String? downloadsDirectoryPath =
            (await DownloadsPath.downloadsDirectory())?.path;

        if (downloadsDirectoryPath != null) {
          final file = File('$downloadsDirectoryPath/dailyCount_$date.pdf');
          await file.writeAsBytes(pdfBytes);
          print("file saved: " + file.path);
        }
        showAlert("Saved", "PDF saved successfully");
      }
    } else {
      // For non-Android platforms (web), initiate the PDF download using an anchor element
      final blob = html.Blob([Uint8List.fromList(pdfBytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "dailyCount_$date.pdf")
        ..click();
      html.Url.revokeObjectUrl(url);
    }

    */
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
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Count'),
      ),
      body:
          // isloading! ? Center(child: CircularProgressIndicator(),) :
          Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () {
                  _selectDate(context);
                },
                child: const Text("Select Date")),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Count : $date',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color.fromARGB(255, 213, 209, 209),
              ),
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isuserloading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              parsedData[0]['morning_food'].toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 40),
                            ),
                            const Text(
                              'Morning',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              parsedData[0]['noon_food'].toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 40),
                            ),
                            const Text(
                              'Noon',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              parsedData[0]['evening_food'].toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 40),
                            ),
                            const Text(
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
          Padding(
            padding: EdgeInsets.all(10.0),
            child: ElevatedButton(
                onPressed: () {
                  savePdf();
                },
                child: Text("Download Daily Count")),
          ),
          const Row(
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
            child:
                // isdetail! ? Center(child: CircularProgressIndicator(),):
                SingleChildScrollView(
              child: isLoading
                  ? CircularProgressIndicator()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: foodDetails.length,
                      itemBuilder: (BuildContext context, int index) {
                        final uids = foodDetails.keys.elementAt(index);
                        final foodList = foodDetails[uids];
                        // final foodList = repons[uids];

                        final morningFood = foodList![0];
                        final noonFood = foodList[1];
                        final eveningFood = foodList[2];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    // '$uids',
                                    userNames[uids]!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  children: [
                                    for (int i = 0; i < 3; i++)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: foodList[i]
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
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

  void _showEditDialog(int index) {
    final mealTitles = ['Morning', 'Noon', 'Evening'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final uids = foodDetails.keys.elementAt(index);
        final foodList = foodDetails[uids]!;
        List<bool> currentConsumption = List.from(foodList);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit Food Consumption'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < 3; i++)
                    CheckboxListTile(
                      title: Text(mealTitles[i]),
                      value: currentConsumption[i],
                      onChanged: (bool? value) {
                        setState(() {
                          currentConsumption[i] = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Update the foodDetails map with the edited foodList
                    setState(() {
                      foodDetails[uids] = List.from(currentConsumption);
                    });

                    final mrngFood = currentConsumption[0];
                    final noonFood = currentConsumption[1];
                    final eveningFood = currentConsumption[2];

                    // Check if the entry already exists in the database
                    final existingDataResponse = await supabase
                        .from('food_marking')
                        .select()
                        .eq('u_id', uids)
                        .eq('mark_date', date)
                        .execute();

                    if (existingDataResponse.error != null) {
                      // Handle error
                      throw existingDataResponse.error!;
                    }

                    final existingData = existingDataResponse.data;

                    if (existingData != null && existingData.length == 1) {
                      // Existing data found, perform update
                      final updateResponse = await supabase
                          .from('food_marking')
                          .update({
                            'morning': mrngFood,
                          })
                          .eq('u_id', uids)
                          .eq('mark_date', date)
                          .execute();

                      if (updateResponse.error != null) {
                        // Handle error
                        throw updateResponse.error!;
                      }

                      print('Update operation completed successfully!');
                    } else {
                      // No existing data, perform insert
                      final insertResponse =
                          await supabase.from('food_marking').insert([
                        {
                          'u_id': uids,
                          'mark_date': date,
                          'morning': mrngFood,
                        }
                      ]).execute();

                      if (insertResponse.error != null) {
                        // Handle error
                        throw insertResponse.error!;
                      }

                      print('Insert operation completed successfully!');
                    }

                    await supabase.from('food_marking').upsert({
                      'u_id': uids,
                      'mark_date': date,
                      'noon': noonFood
                    }).execute();

                    await supabase.from('food_marking').upsert({
                      'u_id': uids,
                      'mark_date': date,
                      'evening': eveningFood
                    }).execute();

                    Navigator.pop(context); // Close the dialog
                    _showSuccessDialog();
                    fetchDataCount();

                    print(foodDetails.toString());
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
