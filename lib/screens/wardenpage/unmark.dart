import 'package:flutter/material.dart';
import 'package:mini_project/supabase_config.dart';

class Unmark extends StatefulWidget {
  const Unmark({super.key});

  @override
  State<Unmark> createState() => _UnmarkState();
}

class _UnmarkState extends State<Unmark> {
  Map<dynamic, String> userNames = {};
  bool isdetail = false;
  String now = DateTime.now().toIso8601String().substring(0, 10);

  String value = DateTime(DateTime.now().year, DateTime.now().month + 1, 0)
      .toIso8601String()
      .substring(0, 10);

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
      final fullName = "${user['first_name']} ${user['last_name']}";
      userNames[uId] = fullName;
    }
    if (respo.error == null) {
      final data = respo.data;

      final List<dynamic> userIds =
          data.map<dynamic>((user) => user['u_id']).toList();
    } else {
      print("Failed to fetch data: ${respo.error}");
    }
    setState(() {
      isdetail = false;
    });

    print(userNames);
  }

  bool isLoading = false;
  Future<void> Sort() async {
    setState(() {
      isLoading = true;
    });
    await userdetails();

    var l1 = userNames.entries.toList();
    l1.sort((a, b) {
      String nameA = userNames[a.key]!;
      String nameB = userNames[b.key]!;
      return nameA.compareTo(nameB);
    });
    userNames = Map.fromEntries(l1);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _unmark(String uid) async {
    //unmark the user from current date to end of the month
    // final response = await supabase
    //     .from('food_marking')
    //     .update({"morning": false, "noon": false, "evening": false})
    //     .eq('u_id', uid)
    //     .gte("mark_date", now)
    //     .lte("mark_date", value)
    //     .execute();
    final response = await supabase.from('food_marking').upsert([
      for (var date = DateTime.parse(now);
          date.isBefore(DateTime.parse(value).add(Duration(days: 1)));
          date = date.add(Duration(days: 1)))
        {
          'u_id': uid,
          'mark_date': date.toIso8601String(),
          'morning': false,
          'noon': false,
          'evening': false,
        },
    ]).execute();

    if (response.error == null) {
      print("Unmarked");
      //show alert dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Unmark'),
            content: const Text('Unmarked the user successfully'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      print("Failed to unmark: ${response.error}");
    }
  }

  //function to show the calendar to select the date range and add a confirm button to unmark the user

  Future<void> _selectDateRange(
      BuildContext context, String uids, String uname) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      //firstDate: DateTime(DateTime.now().year, DateTime.now().month - 1, 1),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked.start != null && picked.end != null) {
      setState(() {
        now = picked.start.toIso8601String().substring(0, 10);
        value = picked.end.toIso8601String().substring(0, 10);
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Unmark'),
            content: Text(
                //from $now to $value
                'Are you sure you want to unmark $uname from $now to $value ?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _unmark(uids);
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    } else {
      print("No date selected");
      return;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userdetails();
    Sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unmark'),
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userNames.length,
          itemBuilder: (BuildContext context, int index) {
            final uids = userNames.keys.elementAt(index);
            final foodList = userNames[uids];
            // final foodList = repons[uids];

            return Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            //show a warning
                            await _selectDateRange(
                                context, uids, userNames[uids]!);
                            // showDialog(
                            //   context: context,
                            //   builder: (BuildContext context) {
                            //     return AlertDialog(
                            //       title: const Text('Unmark'),
                            //       content:  Text(
                            //         //from $now to $value
                            //           'Are you sure you want to unmark the user from $now to $value ?'),
                            //       actions: [
                            //         TextButton(
                            //           onPressed: () {
                            //             Navigator.of(context).pop();
                            //           },
                            //           child: const Text('Cancel'),
                            //         ),
                            //         TextButton(
                            //           onPressed: () {
                            //             Navigator.of(context).pop();
                            //             _unmark(uids);
                            //           },
                            //           child: const Text('Confirm'),
                            //         ),
                            //       ],
                            //     );
                            //   },
                            // );
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
    );
  }
}
