// import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:mini_project/widgets/bottomnav.dart';

import '../../supabase_config.dart';

class ScreenPoints extends StatefulWidget {
  final String? uid;
  ScreenPoints({super.key, this.uid});
  static ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);

  @override
  State<ScreenPoints> createState() => _ScreenPointsState();
}

class _ScreenPointsState extends State<ScreenPoints> {
  final List<DateTime> dates = [
    DateTime(2023, 6, 1),
    DateTime(2023, 6, 2),
    DateTime(2023, 6, 3),
    DateTime(2023, 6, 1),
    DateTime(2023, 6, 2),
    DateTime(2023, 6, 3),
    // Add more dates as needed
  ];

  final List<List<bool>> foodConsumption = [
    [true, false, true], // Example consumption data for first date
    [false, true, false], // Example consumption data for second date
    [true, true, true],
    [true, false, true], // Example consumption data for first date
    [false, true, false], // Example consumption data for second date
    [true, true, true], // Example consumption data for third date
    // Add more consumption data as needed
  ];
  final Map<String, List<bool>> dateMap = {};

  Future<void> getDate(String date, String year, String? uid) async {
    final int selectedYear = int.parse(year);
    final int selectedMonth = int.parse(date);

    final eveningFoodResponse = await supabase
        .from('food_evening')
        .select('mark_date,evening_food')
        .gte('mark_date', DateTime(selectedYear, selectedMonth, 1))
        .lte('mark_date', DateTime(selectedYear, selectedMonth + 1, 0))
        .eq("u_id", uid)
        .execute();

    final morningFoodResponse = await supabase
        .from('food_morning')
        .select('mark_date,morning_food')
        .gte('mark_date', DateTime(selectedYear, selectedMonth, 1))
        .lte('mark_date', DateTime(selectedYear, selectedMonth + 1, 0))
        .eq("u_id", uid)
        .execute();

    final noonFoodResponse = await supabase
        .from('food_noon')
        .select('mark_date,noon_food')
        .gte('mark_date', DateTime(selectedYear, selectedMonth, 1))
        .lte('mark_date', DateTime(selectedYear, selectedMonth + 1, 0))
        .eq("u_id", uid)
        .execute();

    for (final data in eveningFoodResponse.data) {
      final date = data['mark_date'].toString().split(' ')[0];
      dateMap[date] = [false, false, data['evening_food']];
    }

    for (final data in morningFoodResponse.data) {
      final date = data['mark_date'].toString().split(' ')[0];
      dateMap[date]?[0] = data['morning_food'];
    }

    for (final data in noonFoodResponse.data) {
      final date = data['mark_date'].toString().split(' ')[0];
      dateMap[date]?[1] = data['noon_food'];
    }

    print(dateMap);
  }

  Username? currentUser;
  DueDate? dueDate;
  final date = DateTime.now().month.toString();
  final year = DateTime.now().year.toString();

//get the detailed bill of the user of that month
//get all the data of that user in that month
  Future<void> detailedB(String month, String year, String? uid) async {
    final response = await supabase
        .from('food_morning')
        .select()
        .eq('u_id', uid)
        .eq('month', month)
        .eq('year', year)
        .execute();
    print(response.data);
  }

  Future<void> getDue(String? uid, String? date, String? year) async {
    final totalv = await supabase
        .from('user_bill')
        .select('total_bill,total_cons')
        .eq('month', date)
        .eq('year', year)
        .eq("u_id", uid)
        .execute();

    if (totalv.error == null && totalv.data.isNotEmpty) {
      print(totalv.data);
      dueDate = DueDate(
        points: totalv.data[0]['total_cons'].toString(),
        amount: totalv.data[0]['total_bill'].toString(),
      );
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
      print("Error: " + response.error!.toString());
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
    await detailedB(date, year, widget.uid);
    await getDate(date, year, widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNav(),
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder(
          future: Future.wait([
            userDetails(widget.uid),
            getDue(widget.uid, date, year),
            getDate(date, year, widget.uid)
          ]),
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return SingleChildScrollView(
                child: SafeArea(
                  /*child: ValueListenableBuilder(valueListenable: ScreenPoints.selectedIndexNotifier,
              builder: (BuildContext context,int updatedIndex,_){
                return _pages[updatedIndex];
              }),*/
                  child: Center(
                    child: Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              height: 100,
                              width: 350,
                              //width: 600,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color.fromARGB(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          currentUser!.name!,
                                          // "Rajesh",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          currentUser!.role!,
                                          // "User",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          currentUser!.designation!,
                                          // "Student",
                                          style: TextStyle(
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
                                    color: Color.fromARGB(255, 209, 204, 203)),
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
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Total Points',
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      dueDate!.points!,
                                                      style: TextStyle(
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
                                      VerticalDivider(
                                          color: Colors.black, width: 5),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  'Due Amount',
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  dueDate!.amount!,
                                                  style: TextStyle(
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
                          SizedBox(
                            height: 15,
                          ),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 300,
                            child: SingleChildScrollView(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: dateMap.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final date = dateMap.keys.toList()[index];
                                  final consumption = dateMap[date];

                                  return Card(
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
                                                margin:
                                                    const EdgeInsets.symmetric(
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: consumption![1]
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                              Container(
                                                width: 10,
                                                height: 10,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: consumption![2]
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
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
                          )
                        ]),
                  ),
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
