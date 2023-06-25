import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../supabase_config.dart';

class CheckboxList extends StatefulWidget {
  final DateTime? date; //date to be passed to the db along with this data
  final String? userId;
  const CheckboxList({super.key, required this.date, this.userId});

  @override
  _CheckboxListState createState() => _CheckboxListState();
}

Future<bool> getMorningToggleValue(String date, String uid) async {
  DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

  final morningVal = await supabase
      .from('food_morning')
      .select("morning_food")
      .eq('mark_date', formattedDate)
      .eq("u_id", uid)
      .execute();

  if (morningVal.error == null && morningVal.data.isNotEmpty) {
    bool morningFoodValue = morningVal.data[0]['morning_food'] as bool;
    if (morningFoodValue == true) {
      print(1 + 1 + 1);
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

Future<bool> getNoonToggleValue(String date, String uid) async {
  DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

  final morningVal = await supabase
      .from('food_noon')
      .select("noon_food")
      .eq('mark_date', formattedDate)
      .eq("u_id", uid)
      .execute();

  if (morningVal.error == null && morningVal.data.isNotEmpty) {
    bool morningFoodValue = morningVal.data[0]['noon_food'] as bool;
    if (morningFoodValue == true) {
      print("noon");
      return true;
    } else {
      return false;
    }
  } else {
    print("noon not found");
    return false;
  }
}

Future<bool> getEveningToggleValue(String date, String uid) async {
  DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

  final morningVal = await supabase
      .from('food_evening')
      .select("evening_food")
      .eq('mark_date', formattedDate)
      .eq("u_id", uid)
      .execute();

  if (morningVal.error == null && morningVal.data.isNotEmpty) {
    bool morningFoodValue = morningVal.data[0]['evening_food'] as bool;
    if (morningFoodValue == true) {
      print("evening");
      return true;
    } else {
      return false;
    }
  } else {
    print("not found evening" + formattedDate);
    return false;
  }
}

class _CheckboxListState extends State<CheckboxList> {
  ValueNotifier<bool> morningToggleValue = ValueNotifier<bool>(false);
  ValueNotifier<bool> noonToggleValue = ValueNotifier<bool>(false);
  ValueNotifier<bool> eveningToggleValue = ValueNotifier<bool>(false);
  int? mrngblock;
  int? evngblock;
  int? noonblock;
  String? mrngt;

  Future<int?> blockTime(
    String ntime,
  ) async {
    final timeblock = await supabase
        .from("timer")
        .select('value')
        .eq("time", ntime)
        .execute();

    if (timeblock.error == null) {
      String source = timeblock.data[0]['value'];
      List<String> timeComponents = source.split(':');
      int hours = int.parse(timeComponents[0]);
      int minutes = int.parse(timeComponents[1]);
      int seconds = int.parse(timeComponents[2]);

      int totalHours = hours + (minutes ~/ 60) + (seconds ~/ 3600);
      // print(totalHours); // Output: 2
      // print("---------------------------");
      return totalHours;
    } else {
      return null;
    }
  }

  void fetchMrng() async {
    final mrng = await blockTime("morning");
    final noon = await blockTime("noon");
    final evng = await blockTime("evening");
    setState(() {
      mrngblock = mrng;
      noonblock = noon;
      evngblock = evng;
    });
    // print(mrngblock);
    // print(noonblock);
    // print(evngblock);
  }

  List<bool> prev = [false, false, false];

  Future<void> setSwitch() async {
    int time = await blockTime("morning") ?? 1;
    int time1 = await blockTime("noon") ?? 1;
    int time2 = await blockTime("evening") ?? 1;

    prev[0] = currentTime.hour >= time;
    prev[1] = currentTime.hour >= time1;
    prev[2] = currentTime.hour >= time2;
    // fetchMrng();
    // Get the current time
    // print("-------------");
    // print(time);
    // print("-------------");
    // print("-------------");
    // print(time1);
    // print("-------------");
    // print("-------------");
    // print(time2);
    // print("-------------");
    // Deactivate Morning toggle button after 11 PM

    if (currentTime.hour >= time) {
      setState(() {
        mrng = false;
        // morningToggleValue.value = false;
      });
    }

    // Deactivate Noon toggle button after 9 AM
    if (currentTime.hour >= time1) {
      setState(() {
        noon = false;
        // noonToggleValue.value = false;
      });
    }

    // Deactivate Evening toggle button after 5 PM
    if (currentTime.hour >= time2) {
      print("Eventing ${currentTime.hour} $time2");
      print(currentTime.hour >= time2);
      setState(() {
        evening = false;
        // eveningToggleValue.value = false;
      });
    }
  }

  DateTime currentTime = DateTime.now();
  late int year;
  late int month;
  late int day;
  @override
  void initState() {
    super.initState();
    year = currentTime.year;
    month = currentTime.month;
    day = currentTime.day;
    // setSwitch();

    // Reset Morning toggle after 8 AM
    // if (currentTime.hour >= 8) {
    //   Timer(Duration(minutes: 1), () {
    //     setState(() {
    //       morningToggleValue.value = false;
    //     });
    //   });
    // }

    // // Reset Noon toggle after 2 PM
    // if (currentTime.hour >= 14) {
    //   Timer(Duration(minutes: 1), () {
    //     setState(() {
    //       noonToggleValue.value = false;
    //     });
    //   });
    // }

    // // Reset Evening toggle after 10 PM
    // if (currentTime.hour >= 22) {
    //   Timer(Duration(minutes: 1), () {
    //     setState(() {
    //       eveningToggleValue.value = false;
    //     });
    //   });
    // }

    // // Schedule timer to reset the toggles at the start of the next day
    // Timer(
    //   Duration(
    //     hours: 24 - currentTime.hour,
    //     minutes: 60 - currentTime.minute,
    //     seconds: 60 - currentTime.second,
    //   ),
    //   () {
    //     setState(() {
    //       morningToggleValue.value = false;
    //       noonToggleValue.value = false;
    //       eveningToggleValue.value = false;
    //     });
    //   },
    // );
  }

  void updateMorningToggleValue(String formattedDate, String userId) async {
    final value = await getMorningToggleValue(formattedDate, userId);
    // print(value);
    morningToggleValue.value = value;
  }

  void updateNoonToggleValue(String formattedDate, String userId) async {
    final value = await getNoonToggleValue(formattedDate, userId);
    // print(value);
    noonToggleValue.value = value;
  }

  void updateEveningToggleValue(String formattedDate, String userId) async {
    final value = await getEveningToggleValue(formattedDate, userId);
    // print(value);
    eveningToggleValue.value = value;
    // final block = await blockTime("evening");
  }

  bool mrng = true;
  bool noon = true;
  bool evening = true;

  bool ischanged = false;

  // DateTime currentTime = DateTime.now();
  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
    
  }

  @override
  Widget build(BuildContext context) {
    // print("buildin....");
    String formattedDate = '$year-$month-$day';
    print(formattedDate);

    DateTime setDate = widget.date!;
    int setyear = setDate.year;
    int setmonth = setDate.month;
    int setday = setDate.day;

    String setdDate = '$setyear-$setmonth-$setday';
    // print(setdDate);

    // updateMorningToggleValue(setdDate, widget.userId!);
    // updateNoonToggleValue(setdDate, widget.userId!);
    // updateEveningToggleValue(setdDate, widget.userId!);

    if (formattedDate != setdDate) {
      // print("ner"+setdDate);

      updateMorningToggleValue(setdDate, widget.userId!);
      updateNoonToggleValue(setdDate, widget.userId!);
      updateEveningToggleValue(setdDate, widget.userId!);
      // mrng = canToggleMorning();
      // noon = canToggleNoon();
      // evening = canToggleEvening();

      setState(() {
        mrng = true;
        noon = true;
        evening = true;
      });
      // updateNoonToggleValue(setdDate, widget.userId!);
      // updateEveningToggleValue(setdDate, widget.userId!);
      // getMorningToggleValue(formattedDate, widget.userId!).then((value) {
      //   setState(() {
      //     isMorningSelected = value;
      //   });
      // });
    } else {
      if (!(prev[0] == mrng && prev[1] == noon && prev[2] == evening)) {
        setSwitch();
      }
    }
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                )),
            leading: CircleAvatar(
                backgroundColor: Colors.blue[400],
                child: Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                )),
            title: Text('Morning'),
            trailing: ValueListenableBuilder(
                valueListenable: morningToggleValue,
                builder: (context, value, child) {
                  return Switch(
                    value: morningToggleValue.value,
                    activeColor: Colors.green,
                    onChanged: mrng
                        ? (value) async {
                            setState(() {
                              morningToggleValue.value = value;
                            });
                            // print("Selected Morning");
                            try {
                              final userId = widget.userId;
                              DateTime dateTime =
                                  DateTime.parse(widget.date.toString());
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(dateTime);

                              final existingDataResponse = await supabase
                                  .from('food_morning')
                                  .select()
                                  .eq('u_id', userId)
                                  .eq('mark_date', formattedDate)
                                  .execute();

                              if (existingDataResponse.error != null) {
                                // Handle error
                                throw existingDataResponse.error!;
                              }

                              final existingData = existingDataResponse.data;

                              if (existingData != null &&
                                  existingData.length == 1) {
                                // Existing data found, perform update
                                final updateResponse = await supabase
                                    .from('food_morning')
                                    .update({
                                      'morning_food': value,
                                    })
                                    .eq('u_id', userId)
                                    .eq('mark_date', formattedDate)
                                    .execute();

                                if (updateResponse.error != null) {
                                  // Handle error
                                  throw updateResponse.error!;
                                } else {
                                  print(formattedDate);
                                }

                                print(
                                    'Update operation completed successfully!');
                              } else {
                                // No existing data, perform insert
                                final insertResponse =
                                    await supabase.from('food_morning').insert([
                                  {
                                    'u_id': userId,
                                    'mark_date': formattedDate,
                                    'morning_food': value,
                                  }
                                ]).execute();

                                if (insertResponse.error != null) {
                                  // Handle error
                                  throw insertResponse.error!;
                                }

                                print(
                                    'Insert operation completed successfully!');
                              }
                            } catch (e) {
                              print('An error occurred: $e');
                            }
                          }
                        : null,
                  );
                }),
          ),
          Padding(padding: EdgeInsets.only(bottom: 5)),
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                )),
            leading: CircleAvatar(
              backgroundColor: Colors.blue[400],
              child: Icon(
                Icons.sunny,
                color: Colors.white,
              ),
            ),
            title: Text(
              'Noon',
            ),
            trailing: Switch(
              value: noonToggleValue.value,
              activeColor: Colors.green,
              onChanged: noon
                  ? (value) async {
                      setState(() {
                        noonToggleValue.value = value;
                      });
                      // print("Selected Noon");
                      try {
                        final userId = widget.userId;
                        DateTime dateTime =
                            DateTime.parse(widget.date.toString());
                        String date = DateFormat('yyyy-MM-dd').format(dateTime);
                        // final date =
                        //     DateTime.now().toLocal().toString().split(' ')[0];

                        final existingDataResponse = await supabase
                            .from('food_noon')
                            .select()
                            .eq('u_id', userId)
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
                              .from('food_noon')
                              .update({
                                'noon_food': value,
                              })
                              .eq('u_id', userId)
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
                              await supabase.from('food_noon').insert([
                            {
                              'u_id': userId,
                              'mark_date': date,
                              'noon_food': value,
                            }
                          ]).execute();

                          if (insertResponse.error != null) {
                            // Handle error
                            throw insertResponse.error!;
                          }

                          print('Insert operation completed successfully!');
                        }
                      } catch (e) {
                        print('An error occurred: $e');
                      }
                    }
                  : null,
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 5)),
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                )),
            leading: CircleAvatar(
                backgroundColor: Colors.blue[400],
                child: Icon(
                  Icons.nightlight_round,
                  color: Colors.white,
                )),
            title: Text('Evening'),
            trailing: Switch(
              value: eveningToggleValue.value,
              activeColor: Colors.green,
              onChanged: evening
                  ? (value) async {
                      setState(() {
                        eveningToggleValue.value = value;
                      });
                      // print("Selected Evening");
                      try {
                        final userId = widget.userId;
                        DateTime dateTime =
                            DateTime.parse(widget.date.toString());
                        String date = DateFormat('yyyy-MM-dd').format(dateTime);
                        // final date =
                        //     DateTime.now().toLocal().toString().split(' ')[0];

                        final existingDataResponse = await supabase
                            .from('food_evening')
                            .select()
                            .eq('u_id', userId)
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
                              .from('food_evening')
                              .update({
                                'evening_food': value,
                              })
                              .eq('u_id', userId)
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
                              await supabase.from('food_evening').insert([
                            {
                              'u_id': userId,
                              'mark_date': date,
                              'evening_food': value,
                            }
                          ]).execute();

                          if (insertResponse.error != null) {
                            // Handle error
                            throw insertResponse.error!;
                          }

                          print('Insert operation completed successfully!');
                        }
                      } catch (e) {
                        print('An error occurred: $e');
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  bool canToggleMorning(time) {
    DateTime currentTime = DateTime.now();

    return currentTime.hour < time; // Allow timetoggle before 11 PM
  }

  bool canToggleNoon(time) {
    DateTime currentTime = DateTime.now();
    return currentTime.hour < time; // Allow toggle before 9 AM
  }

  bool canToggleEvening(time) {
    DateTime currentTime = DateTime.now();

    return currentTime.hour < time; // Allow toggle before 5 PM
  }
}
