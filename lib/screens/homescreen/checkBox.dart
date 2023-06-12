import 'dart:async';

import 'package:flutter/material.dart';

import '../../supabase_config.dart';

class CheckboxList extends StatefulWidget {
  final DateTime? date; //date to be passed to the db along with this data
  final String? userId;
  const CheckboxList({super.key, required this.date, this.userId});

  @override
  _CheckboxListState createState() => _CheckboxListState();
}

Future<void> fetchToday(String date,String uid) async{
  final morningval = await supabase.from('food_morning').select("morning_food").eq('mark_date', date).eq("u_id",uid ).execute();
}

class _CheckboxListState extends State<CheckboxList> {
  bool toggleValue = false;
  bool isMorningSelected = false;
  bool isNoonSelected = false;
  bool isEveningSelected = false;

  @override
  void initState() {
    super.initState();
    // fetchMrng();
    // Get the current time
    DateTime currentTime = DateTime.now();
    // print(currentTime); //time now

    // //date selected

    // //if the user tries to mark another date these features will be disabled
    // if (widget.date == currentTime) {}

    // Deactivate Morning toggle button after 11 PM
    if (currentTime.hour >= 01) {
      setState(() {
        isMorningSelected = false;
      });
    }

    // Deactivate Noon toggle button after 9 AM
    if (currentTime.hour >= 9) {
      setState(() {
        isNoonSelected = false;
      });
    }

    // Deactivate Evening toggle button after 5 PM
    if (currentTime.hour >= 17) {
      setState(() {
        isEveningSelected = false;
      });
    }

    // Reset Morning toggle after 8 AM
    if (currentTime.hour >= 8) {
      Timer(Duration(minutes: 1), () {
        setState(() {
          isMorningSelected = false;
        });
      });
    }

    // Reset Noon toggle after 2 PM
    if (currentTime.hour >= 14) {
      Timer(Duration(minutes: 1), () {
        setState(() {
          isNoonSelected = false;
        });
      });
    }

    // Reset Evening toggle after 10 PM
    if (currentTime.hour >= 22) {
      Timer(Duration(minutes: 1), () {
        setState(() {
          isEveningSelected = false;
        });
      });
    }

    // Schedule timer to reset the toggles at the start of the next day
    Timer(
      Duration(
        hours: 24 - currentTime.hour,
        minutes: 60 - currentTime.minute,
        seconds: 60 - currentTime.second,
      ),
      () {
        setState(() {
          isMorningSelected = false;
          isNoonSelected = false;
          isEveningSelected = false;
        });
      },
    );
  }

  // Future<void> fetchMrng() async {
  //   final sharedprefs = await SharedPreferences.getInstance();
  //   final uid = sharedprefs.getString('u_id');
  //   final morningdb =
  //       await supabase.from('food_morning').select().eq('u_id', uid).execute();
  //   if (morningdb.data[0]['morning_food'] == true) {
  //     print(isMorningSelected);
  //     setState(() {
  //       isMorningSelected = true;
  //     });
  //   } else {
  //     setState(() {
  //       isMorningSelected = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    DateTime currentTime = DateTime.now();
    int year = currentTime.year;
    int month = currentTime.month;
    int day = currentTime.day;

    String formattedDate = '$year-$month-$day';
    print(formattedDate);

    DateTime setDate = widget.date!;
    int setyear = setDate.year;
    int setmonth = setDate.month;
    int setday = setDate.day;

    String setdDate = '$setyear-$setmonth-$setday';
    print(setdDate);

    bool mrng = canToggleMorning();
    bool noon = canToggleNoon();
    bool evening = canToggleEvening();

    if (formattedDate != setdDate) {
      setState(() {
        mrng = true;
        noon = true;
        evening = true;
      });
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
            trailing: Switch(
              value: isMorningSelected,
              activeColor: Colors.green,
              onChanged: mrng
                  ? (value) async {
                      setState(() {
                        isMorningSelected = value;
                      });
                      print("Selected Noon");
                      try {
                        final userId = widget.userId;
                        final date =
                            DateTime.now().toLocal().toString().split(' ')[0];

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
                Icons.sunny,
                color: Colors.white,
              ),
            ),
            title: Text(
              'Noon',
            ),
            trailing: Switch(
              value: isNoonSelected,
              activeColor: Colors.green,
              onChanged: noon
                  ? (value) async {
                      setState(() {
                        isNoonSelected = value;
                      });
                      print("Selected Noon");
                      try {
                        final userId = widget.userId;
                        final date =
                            DateTime.now().toLocal().toString().split(' ')[0];

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
              value: isEveningSelected,
              activeColor: Colors.green,
              onChanged: evening
                  ? (value) async {
                      setState(() {
                        isEveningSelected = value;
                      });
                      print("Selected Evening");
                      try {
                        final userId = widget.userId;
                        final date =
                            DateTime.now().toLocal().toString().split(' ')[0];

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
