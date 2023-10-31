// import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:mini_project/screens/Pointsscreen/editProfile.dart';

import '../../supabase_config.dart';

class ScreenPoints extends StatefulWidget {
  final String? uid;
  const ScreenPoints({super.key, this.uid});
  static ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);

  @override
  State<ScreenPoints> createState() => _ScreenPointsState();
}

class _ScreenPointsState extends State<ScreenPoints> {
  final Map<String, List<bool>> dateMap = {};
  Future<void> getDate(String date, String year, String? uid) async {
    dateMap.clear();
    final int selectedYear = int.parse(year);
    final int selectedMonth = int.parse(date);
    print(selectedYear);
    print(selectedMonth);
    final eveningFoodResponse = await supabase
        .from('food_marking')
        .select('mark_date, evening')
        .gte('mark_date', DateTime(selectedYear, selectedMonth, 1))
        .lte('mark_date', DateTime(selectedYear, selectedMonth + 1, 0))
        .eq('u_id', uid)
        .execute();

    final morningFoodResponse = await supabase
        .from('food_marking')
        .select('mark_date, morning')
        .gte('mark_date', DateTime(selectedYear, selectedMonth, 1))
        .lte('mark_date', DateTime(selectedYear, selectedMonth + 1, 0))
        .eq('u_id', uid)
        .execute();

    final noonFoodResponse = await supabase
        .from('food_marking')
        .select('mark_date, noon')
        .gte('mark_date', DateTime(selectedYear, selectedMonth, 1))
        .lte('mark_date', DateTime(selectedYear, selectedMonth + 1, 0))
        .eq('u_id', uid)
        .execute();

    // dateMap.clear(); // Clear the existing data in the dateMap

    for (final data in eveningFoodResponse.data) {
      final date = data['mark_date'].toString().split(' ')[0];
      dateMap[date] = [false, false, data['evening']];
    }

    for (final data in morningFoodResponse.data) {
      final date = data['mark_date'].toString().split(' ')[0];
      dateMap.putIfAbsent(date, () => [false, false, false])[0] =
          data['morning'];
    }

    for (final data in noonFoodResponse.data) {
      final date = data['mark_date'].toString().split(' ')[0];
      dateMap.putIfAbsent(date, () => [false, false, false])[1] = data['noon'];
    }
    List<MapEntry<String, List<bool>>> entries = dateMap.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    dateMap.clear();
    for (final entry in entries) {
      dateMap[entry.key] = entry.value;
    }

    print('dateMap');
    print(dateMap);
  }

  Username? currentUser;
  DueDate? dueDate;
  String date = DateTime.now().month.toString();
  String year = DateTime.now().year.toString();

  Future<void> getDue(String? uid, String? date, String? year) async {
    final paid = await supabase
        .from('user_bill')
        .select('bill_status')
        .eq('month', date)
        .eq('year', year)
        .eq("u_id", uid)
        .execute();

    if (paid.error == null) {
      print(paid.data);
    } else {
      print(paid.error);
    }

    final totalv = await supabase
        .from('user_bill')
        .select('total_bill,total_cons')
        .eq('month', date)
        .eq('year', year)
        .eq("u_id", uid)
        .execute();

    if (totalv.error == null && totalv.data.isNotEmpty) {
      print(totalv.data);
      if (paid.data.isNotEmpty && paid.data[0]['bill_status'] == false) {
        dueDate = DueDate(
          points: totalv.data[0]['total_cons'].toString(),
          amount: totalv.data[0]['total_bill'].toString(),
        );
      } else {
        dueDate = DueDate(
            points: totalv.data[0]['total_cons'].toString(), amount: "Paid");
      }
    } else {
      dueDate = DueDate(points: "0", amount: "0");
    }
  }

  Future<void> userDetails(String? uid) async {
    print(uid);
    final response =
        await supabase.from('users').select().eq('u_id', uid).execute();

    if (response.error == null) {
      if (response.data != null && response.data!.isNotEmpty) {
        String name = response.data![0]['first_name'] +
            " " +
            response.data![0]['last_name'];

        currentUser = Username(
          name: name,
          role: response.data![0]['role'],
          designation: response.data![0]['designation'],
        );
        print(currentUser!.name);

        if (currentUser != null) {
          print(currentUser!.role);
        } else {
          print("Error: Unable to set user details");
        }
      } else {
        print("Error: No data found for the provided user ID");
      }
    } else {
      print("Error: ${response.error!}");
    }

    print(response.data);
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await userDetails(widget.uid);
    await getDue(widget.uid, date, year);
    // await detailedB(date, year, widget.uid);
    await getDate(date, year, widget.uid);
  }

  Future<void> _selectMonthAndYear(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(selectedDate.year - 1),
      lastDate: DateTime(selectedDate.year + 1),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue, // Set your preferred color
            hintColor: Colors.blue,
            colorScheme: ColorScheme.light(primary: Colors.blue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final selectedMonth = picked.month;
      final selectedYear = picked.year;
      final formattedDate =
          '$selectedMonth/$selectedYear'; // Customize the format as needed
      print('Selected Month and Year: $formattedDate');
      setState(() {
        year = selectedYear.toString();
        date = selectedMonth.toString();
        dateMap.clear();
        print("datemap" + dateMap.toString());
        getDate(date, year, widget.uid);
      });
      // You can return or use the selected month and year as needed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_add),
                        title: const Text('Edit Profile'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx1) => EditProfile(
                                      id: widget.uid!,
                                    )),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ];
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Set the border radius
            ),
            offset:
                const Offset(0, 56), // Offset the popup menu below the AppBar
            elevation: 4, // Set the elevation
          ),
        ],
      ),
      body: FutureBuilder(
          future: Future.wait([
            // userDetails(widget.uid),
            getDue(widget.uid, date, year),
            getDate(date, year, widget.uid)
          ]),
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Reload '),
              );
            } else {
              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            height: 100,
                            width: 350,
                            //width: 600,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color.fromARGB(
                                  255,
                                  209,
                                  204,
                                  203,
                                )),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //SizedBox(height: 30,),

                                  Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        currentUser!.name!,
                                        // "Rajesh",
                                        style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        currentUser!.designation!,
                                        // "Student",
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        currentUser!.role!,
                                        // "User",
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  )
                                  // Text('Rs.7200',style: TextStyle(fontSize: 40),)
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              height: 75,
                              width: 800,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color:
                                      const Color.fromARGB(255, 209, 204, 203)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              const Row(
                                                children: [
                                                  Text(
                                                    'Total Points',
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    dueDate!.points!,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    const VerticalDivider(
                                        color: Colors.black, width: 5),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              const Text(
                                                'Due Amount',
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                dueDate!.amount!,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              _selectMonthAndYear(context);
                            },
                            child: Text("Select Month")),
                        const Text(
                          'Detailed Bill',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    'Date',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // height: 300,
                        SizedBox(
                            height: MediaQuery.of(context).size.height - 450,
                            child: ListView.builder(
                              itemCount: dateMap.length,
                              itemBuilder: (BuildContext context, int index) {
                                final date = dateMap.keys.toList()[index];
                                final consumption = dateMap[date];

                                // Wrap each item in a `Column` to avoid clipping issues
                                return Column(
                                  children: [
                                    Card(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 4.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              date,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 5.0),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: consumption![0]
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                ),
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 5.0),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: consumption[1]
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                ),
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 5.0),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: consumption[2]
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Add a divider to separate each item
                                    Divider(
                                      height: 0.5,
                                      color: Colors.grey,
                                    ),
                                  ],
                                );
                              },
                            )),
                      ]),
                ),
              );
            }
          }),
    );
  }
}

class Username {
  final String? name;
  final String? role;
  final String? designation;
  Username({this.name, this.role, this.designation});
}

class DueDate {
  final String? points;
  final String? amount;
  DueDate({this.points, this.amount});
}
