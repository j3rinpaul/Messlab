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
      // print("noon");
      return true;
    } else {
      return false;
    }
  } else {
    // print("noon not found");
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
      // print("evening");
      return true;
    } else {
      return false;
    }
  } else {
    // print("not found evening" + formattedDate);
    return false;
  }
}

class _CheckboxListState extends State<CheckboxList> {
  ValueNotifier<bool> morningToggleValue = ValueNotifier<bool>(false);
  ValueNotifier<bool> noonToggleValue = ValueNotifier<bool>(false);
  ValueNotifier<bool> eveningToggleValue = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // fetchMrng();
    // Get the current time
    DateTime currentTime = DateTime.now();

    // Deactivate Morning toggle button after 11 PM
    if (currentTime.hour >= 01) {
      setState(() {
        morningToggleValue.value = false;
      });
    }

    // Deactivate Noon toggle button after 9 AM
    if (currentTime.hour >= 9) {
      setState(() {
        noonToggleValue.value = false;
      });
    }

    // Deactivate Evening toggle button after 5 PM
    if (currentTime.hour >= 17) {
      setState(() {
        eveningToggleValue.value = false;
      });
    }

    // Reset Morning toggle after 8 AM
    if (currentTime.hour >= 8) {
      Timer(Duration(minutes: 1), () {
        setState(() {
          morningToggleValue.value = false;
        });
      });
    }

    // Reset Noon toggle after 2 PM
    if (currentTime.hour >= 14) {
      Timer(Duration(minutes: 1), () {
        setState(() {
          noonToggleValue.value = false;
        });
      });
    }

    // Reset Evening toggle after 10 PM
    if (currentTime.hour >= 22) {
      Timer(Duration(minutes: 1), () {
        setState(() {
          eveningToggleValue.value = false;
        });
      });
    }

    Timer(
      Duration(
        hours: 24 - currentTime.hour,
        minutes: 60 - currentTime.minute,
        seconds: 60 - currentTime.second,
      ),
      () {
        setState(() {
          morningToggleValue.value = false;
          noonToggleValue.value = false;
          eveningToggleValue.value = false;
        });
      },
    );
  }

  void updateMorningToggleValue(String formattedDate, String userId) async {
    final value = await getMorningToggleValue(formattedDate, userId);

    morningToggleValue.value = value;
  }

  void updateNoonToggleValue(String formattedDate, String userId) async {
    final value = await getNoonToggleValue(formattedDate, userId);

    noonToggleValue.value = value;
  }

  void updateEveningToggleValue(String formattedDate, String userId) async {
    final value = await getEveningToggleValue(formattedDate, userId);

    eveningToggleValue.value = value;
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentTime = DateTime.now();
    int year = currentTime.year;
    int month = currentTime.month;
    int day = currentTime.day;

    String formattedDate = '$year-$month-$day';


    DateTime setDate = widget.date!;
    int setyear = setDate.year;
    int setmonth = setDate.month;
    int setday = setDate.day;

    String setdDate = '$setyear-$setmonth-$setday';


    bool mrng = canToggleMorning();
    bool noon = canToggleNoon();
    bool evening = canToggleEvening();
    updateMorningToggleValue(setdDate, widget.userId!);
    updateNoonToggleValue(setdDate, widget.userId!);
    updateEveningToggleValue(setdDate, widget.userId!);

    if (formattedDate != setdDate) {
      setState(() {
        mrng = true;
        noon = true;
        evening = true;
      });


      updateMorningToggleValue(setdDate, widget.userId!);
      updateNoonToggleValue(setdDate, widget.userId!);
      updateEveningToggleValue(setdDate, widget.userId!);
      
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
                      print("Selected Noon");
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
                      print("Selected Evening");
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

  bool canToggleMorning() {
    DateTime currentTime = DateTime.now();
    return currentTime.hour < 1; // Allow toggle before 11 PM
  }

  bool canToggleNoon() {
    DateTime currentTime = DateTime.now();
    return currentTime.hour < 9; // Allow toggle before 9 AM
  }

  bool canToggleEvening() {
    DateTime currentTime = DateTime.now();
    return currentTime.hour < 17; // Allow toggle before 5 PM
  }
}
