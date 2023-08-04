import 'package:flutter/material.dart';

import '../../supabase_config.dart';

class DailyCount extends StatefulWidget {
  const DailyCount({Key? key}) : super(key: key);

  @override
  State<DailyCount> createState() => _DailyCountState();
}

class _DailyCountState extends State<DailyCount> {
  bool? isuserloading = false;
  bool? isdetail = false;
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

  final date = DateTime.now().toLocal().toString().split(' ')[0];
  Map<dynamic, List<bool>> foodDetails = {};
  List<bool> foodList = [];
  Map<dynamic, String> userNames = {};
  bool isLoading = false;

  Future<dynamic> Userdetails() async {
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
      print(userNames.toString());
    }
    if (respo.error == null) {
      print(respo.data);
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
      
        print(uids.toString() +" "+allFood.data.toString());
        final foodData = allFood.data;
        final foodList = foodData.isNotEmpty
            ? [
                foodData[0]['morning'],
                foodData[0]['noon'],
                foodData[0]['evening'],
              ]
            : [false, false, false];    
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

  @override
  void initState() {
    super.initState();
    Userdetails();
    fetchDataCount();
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
    print("parse:" + parsedData.toString());
  }

  List<Map<String, dynamic>> parsedData = [
    {},
  ];

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Food consumption updated successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now().toString().substring(0, 10);

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Count'),
      ),
      body:
          // isloading! ? Center(child: CircularProgressIndicator(),) :
          Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Count : $currentDate',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Color.fromARGB(255, 213, 209, 209),
              ),
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isuserloading!
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              parsedData[0]['morning_food'].toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 40),
                            ),
                            Text(
                              'Morning',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              parsedData[0]['noon_food'].toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 40),
                            ),
                            Text(
                              'Noon',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              parsedData[0]['evening_food'].toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 40),
                            ),
                            Text(
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
          Row(
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
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: foodDetails.length,
                itemBuilder: (BuildContext context, int index) {
                  final uids = foodDetails.keys.elementAt(index);
                  final foodList = foodDetails[uids];
                  // final foodList = repons[uids];

                  final morningFood = foodList![0];
                  final noonFood = foodList![1];
                  final eveningFood = foodList![2];

                  return Card(
                    margin:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              // '$uids',
                              userNames[uids]!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: [
                              for (int i = 0; i < 3; i++)
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: foodList![i]
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              IconButton(
                                icon: Icon(Icons.edit),
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
              title: Text('Edit Food Consumption'),
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
                  child: Text('Cancel'),
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
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
