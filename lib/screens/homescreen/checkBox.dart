import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../supabase_config.dart';

class CheckboxList extends StatefulWidget {
  final DateTime? date; //date to be passed to the db along with this data
  final String? userId;
  const CheckboxList({super.key, required this.date, this.userId});

  @override
  _CheckboxListState createState() => _CheckboxListState();
}

List<bool> dataValues = [];

String formatDate(DateTime date) {
  String formattedDate = DateFormat('yyyy-MM-dd').format(date);
  return formattedDate;
}

class _CheckboxListState extends State<CheckboxList> {
  ValueNotifier<bool> morningToggleValue = ValueNotifier<bool>(true);
  ValueNotifier<bool> noonToggleValue = ValueNotifier<bool>(true);
  ValueNotifier<bool> eveningToggleValue = ValueNotifier<bool>(true);
  bool mrng = true;
  bool noon = true;
  bool evening = true;
  String? mrngTime;
  String? noonTime;
  String? eveningTime;
  int? parseTimemrng = 12;
  int? parseTimenoon = 12;
  int? parseTimeevening = 12;

  DateTime currentTime = DateTime.now();
  DateTime tommorrow = DateTime.now().add(const Duration(days: 1));

  Future<List<bool>> getDataToggle(DateTime date) async {
    String needDate = formatDate(date);
    final response = await supabase
        .from('food_marking')
        .select("morning , noon , evening")
        .eq("mark_date", needDate)
        .eq('u_id', widget.userId)
        .execute();

    if (response.error != null) {
      // Handle error
      throw response.error!;
    }

    final data = response.data;
    print("date$data");
    List<bool> dataVal = data.isNotEmpty
        ? [
            data[0]['morning'] as bool,
            data[0]['noon'] as bool,
            data[0]['evening'] as bool,
          ]
        : [true, true, true];

    setState(() {
      dataValues = dataVal;
      //assign the variables to change here on another date
      morningToggleValue.value = dataValues[0];
      noonToggleValue.value = dataValues[1];
      eveningToggleValue.value = dataValues[2];
    });

    return dataValues;
  }

  bool isLoading = false;
  String month = DateFormat('MM').format(DateTime.now());
  String year = DateFormat('yy').format(DateTime.now());

//make markings for all the users for a month
  Future<void> makeMarkings(String month, String year) async {
    setState(() {
      isLoading = true;
    });
    final response = await supabase.from('users').select().execute();
    final valid = await supabase
        .from('food_marked')
        .select("created")
        .eq("month", month)
        .eq("year", year)
        .execute();
    print("Valis" + valid.data.toString());

    final DateTime now = DateTime.now();
    final DateTime month_end = DateTime(now.year, now.month + 1, 0);
    print(month_end);

    if (valid.data.isEmpty) {
      for (DateTime time = now;
          time.isBefore(month_end.add(const Duration(days: 1)));
          time = time.add(const Duration(days: 1))) {
        String date = time.toLocal().toString().split(' ')[0];
        for (var item in response.data) {
          final userId = item['u_id'];
          final insertResponse = await supabase.from('food_marking').insert([
            {
              'u_id': userId,
              'mark_date': date,
              'morning': true,
              'noon': true,
              'evening': true,
            }
          ]).execute();

          if (insertResponse.error != null) {
            // Handle error
            throw insertResponse.error!;
          }
          print('Insert operation completed successfully!');
        }
      }
      final dataEntry = await supabase
          .from("food_marked") //inserting into food_marked table
          .insert([
        {
          'month': month,
          'year': year,
          'created': true,
        }
      ]).execute();
      if (dataEntry.error != null) {
        // Handle error
        throw dataEntry.error!;
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<bool>> initToggle(DateTime date) async {
    String needDate = formatDate(date);
    final response = await supabase
        .from('food_marking')
        .select("morning , noon , evening")
        .eq("mark_date", needDate)
        .eq("u_id", widget.userId)
        .execute();

    if (response.error != null) {
      // Handle error
      throw response.error!;
    }

    final data = response.data;
    if (data.isEmpty) {
      mrng = false;
      noon = false;
      evening = false;
    }

    print("date$data");
    List<bool> dataVal = data.isNotEmpty
        ? [
            data[0]['morning'] as bool,
            data[0]['noon'] as bool,
            data[0]['evening'] as bool,
          ]
        : [false, false, false];

    setState(() {
      dataValues = dataVal;
      print(dataValues);
      //assign the variables to change here on another date
      morningToggleValue.value = dataValues[0];
      noonToggleValue.value = dataValues[1];
      eveningToggleValue.value = dataValues[2];
    });
    return dataValues;
  }

  Future<void> getActiveTime() async {
    final timeData = await supabase.from('timer').select().execute();

    Map<String, String> parsedTimeMap = {};
    for (var item in timeData.data) {
      parsedTimeMap[item["time"]] = item["value"];
    }

    setState(() {
      mrngTime = parsedTimeMap["morning"]!;
      noonTime = parsedTimeMap["noon"]!;
      eveningTime = parsedTimeMap["evening"]!;
    });

    parseTimemrng = int.parse(mrngTime!.split(":")[0]);
    parseTimenoon = int.parse(noonTime!.split(":")[0]);
    parseTimeevening = int.parse(eveningTime!.split(":")[0]);
    print(parseTimemrng);
    print(parseTimenoon);
    print(parseTimeevening);
  }

  Future<void> selectiveToggle() async {
    await getActiveTime();
    if (00 <= currentTime.hour) {
      setState(() {
        mrng = false;
      });
    }
    if (00 <= currentTime.hour) {
      setState(() {
        noon = false;
      });
    }
    if (00 <= currentTime.hour) {
      setState(() {
        evening = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getActiveTime();
    initToggle(widget.date!);
    selectiveToggle();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CheckboxList oldWidget) {
    if (widget.date != oldWidget.date) {
      setState(() {
        getDataToggle(widget.date!);
      });
    }
    if (currentTime.day == widget.date!.day &&
        currentTime.month == widget.date!.month &&
        currentTime.year == widget.date!.year) {
      setState(() {
        mrng = !(00 <= currentTime.hour);
        noon = !(00 <= currentTime.hour);
        evening = !(00 <= currentTime.hour);
      });
    } else {
      final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
      if (widget.date!.day == tomorrow.day &&
          widget.date!.month == tomorrow.month &&
          widget.date!.year == tomorrow.year) {
        print(currentTime.hour);
        setState(() {
          mrng = !(13 <= currentTime.hour);
          noon = !(13 <= currentTime.hour);
          evening = !(13 <= currentTime.hour);
        });
      } else {
        mrng = true;
        noon = true;
        evening = true;
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CircularProgressIndicator()
        : Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      )),
                  leading: CircleAvatar(
                      backgroundColor: Colors.blue[400],
                      child: const Icon(
                        Icons.sunny_snowing,
                        color: Colors.white,
                      )),
                  title: const Text('Morning'),
                  trailing: ValueListenableBuilder(
                      valueListenable: morningToggleValue,
                      builder: (context, value, child) {
                        return Switch(
                          value: morningToggleValue.value,
                          activeColor: Colors.green,
                          onChanged: mrng 
                              ? (value) async {
                                  DateTime now = DateTime.now();
                                  DateTime tomorrow = DateTime.now()
                                      .add(const Duration(days: 1));
                                  DateTime markingDate = widget.date!;
                                  if (now.hour < 13 ||
                                      (markingDate.day != tomorrow.day)) {
                                    // (markingDate.day > tommorrow.day &&
                                    // markingDate.month >
                                    //     tommorrow.month &&
                                    // markingDate.year != tommorrow.year)
                                    //markingDate.difference(tomorrow)>Duration(days: 1)

                                    setState(() {
                                      morningToggleValue.value = value;
                                    });
                                    // print("Selected Morning");
                                    try {
                                      final userId = widget.userId;
                                      DateTime dateTime = DateTime.parse(
                                          widget.date.toString());
                                      String formattedDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(dateTime);

                                      final existingDataResponse =
                                          await supabase
                                              .from('food_marking')
                                              .select()
                                              .eq('u_id', userId)
                                              .eq('mark_date', formattedDate)
                                              .execute();

                                      if (existingDataResponse.error != null) {
                                        // Handle error
                                        throw existingDataResponse.error!;
                                      }

                                      final existingData =
                                          existingDataResponse.data;

                                      if (existingData != null &&
                                          existingData.length == 1) {
                                        // Existing data found, perform update
                                        final updateResponse = await supabase
                                            .from('food_marking')
                                            .update({
                                              'morning': value,
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
                                        toastBar("Updated Morning");
                                        print(
                                            'Update operation completed successfully!');
                                      } else {
                                        // No existing data, perform insert
                                        final insertResponse = await supabase
                                            .from('food_marking')
                                            .insert([
                                          {
                                            'u_id': userId,
                                            'mark_date': formattedDate,
                                            'morning': value,
                                          }
                                        ]).execute();

                                        if (insertResponse.error != null) {
                                          // Handle error
                                          throw insertResponse.error!;
                                        }
                                        toastBar("Updated Morning");
                                        print(
                                            'Insert operation completed successfully!');
                                      }
                                    } catch (e) {
                                      toastBar("Error");
                                      print('An error occurred: $e');
                                    }
                                  } else {
                                    html.window.location.reload();
                                  }
                                }
                              : null,
                        );
                      }),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 5)),
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      )),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[400],
                    child: const Icon(
                      Icons.sunny,
                      color: Colors.white,
                    ),
                  ),
                  title: const Text(
                    'Noon',
                  ),
                  trailing: Switch(
                    value: noonToggleValue.value,
                    activeColor: Colors.green,
                    onChanged: noon 
                        ? (value) async {
                            DateTime now = DateTime.now();
                            DateTime tomorrow =
                                DateTime.now().add(const Duration(days: 1));
                            DateTime markingDate = widget.date!;
                            if (now.hour < 13 ||
                                (markingDate.day != tomorrow.day)) {
                              setState(() {
                                noonToggleValue.value = value;
                              });
                              print("Selected Noon");
                              try {
                                final userId = widget.userId;
                                DateTime dateTime =
                                    DateTime.parse(widget.date.toString());
                                String date =
                                    DateFormat('yyyy-MM-dd').format(dateTime);
                                // final date =
                                //     DateTime.now().toLocal().toString().split(' ')[0];

                                final existingDataResponse = await supabase
                                    .from('food_marking')
                                    .select()
                                    .eq('u_id', userId)
                                    .eq('mark_date', date)
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
                                      .from('food_marking')
                                      .update({
                                        'noon': value,
                                      })
                                      .eq('u_id', userId)
                                      .eq('mark_date', date)
                                      .execute();

                                  if (updateResponse.error != null) {
                                    // Handle error
                                    throw updateResponse.error!;
                                  }
                                  toastBar("Updated Noon");
                                  print(
                                      'Update operation completed successfully!');
                                } else {
                                  // No existing data, perform insert
                                  final insertResponse = await supabase
                                      .from('food_marking')
                                      .insert([
                                    {
                                      'u_id': userId,
                                      'mark_date': date,
                                      'noon': value,
                                    }
                                  ]).execute();

                                  if (insertResponse.error != null) {
                                    // Handle error
                                    throw insertResponse.error!;
                                  }
                                  toastBar("Updated Noon");
                                  print(
                                      'Insert operation completed successfully!');
                                }
                              } catch (e) {
                                toastBar("Error");
                                print('An error occurred: $e');
                              }
                            } else {
                              html.window.location.reload();
                            }
                          }
                        : null,
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 5)),
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      )),
                  leading: CircleAvatar(
                      backgroundColor: Colors.blue[400],
                      child: const Icon(
                        Icons.nightlight_round,
                        color: Colors.white,
                      )),
                  title: const Text('Evening'),
                  trailing: Switch(
                    value: eveningToggleValue.value,
                    activeColor: Colors.green,
                    onChanged: evening 
                        ? (value) async {
                            DateTime now = DateTime.now();
                            DateTime tomorrow =
                                DateTime.now().add(const Duration(days: 1));
                            DateTime markingDate = widget.date!;
                            if (now.hour < 13 ||
                                (markingDate.day != tomorrow.day)) {
                              setState(() {
                                eveningToggleValue.value = value;
                              });
                              print("Selected Evening");
                              try {
                                final userId = widget.userId;
                                DateTime dateTime =
                                    DateTime.parse(widget.date.toString());
                                String date =
                                    DateFormat('yyyy-MM-dd').format(dateTime);
                                // final date =
                                //     DateTime.now().toLocal().toString().split(' ')[0];

                                final existingDataResponse = await supabase
                                    .from('food_marking')
                                    .select()
                                    .eq('u_id', userId)
                                    .eq('mark_date', date)
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
                                      .from('food_marking')
                                      .update({
                                        'evening': value,
                                      })
                                      .eq('u_id', userId)
                                      .eq('mark_date', date)
                                      .execute();

                                  if (updateResponse.error != null) {
                                    // Handle error
                                    throw updateResponse.error!;
                                  }
                                  toastBar("Updated Evening");
                                  print(
                                      'Update operation completed successfully!');
                                } else {
                                  // No existing data, perform insert
                                  final insertResponse = await supabase
                                      .from('food_marking')
                                      .insert([
                                    {
                                      'u_id': userId,
                                      'mark_date': date,
                                      'evening': value,
                                    }
                                  ]).execute();

                                  if (insertResponse.error != null) {
                                    // Handle error
                                    throw insertResponse.error!;
                                  }
                                  toastBar("Updated Evening");
                                  print(
                                      'Insert operation completed successfully!');
                                }
                              } catch (e) {
                                print('An error occurred: $e');
                              }
                            } else {
                              html.window.location.reload();
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          );
  }

  void toastBar(String msgs) {
    Fluttertoast.showToast(
        msg: msgs,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 20);
  }
}
