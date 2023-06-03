import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:mini_project/logout.dart';
import 'package:mini_project/screens/homescreen/home_screen.dart';
import 'package:mini_project/widgets/bottomnav.dart';
import 'package:intl/intl.dart';

class ScreenPoints extends StatelessWidget {
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

  ScreenPoints({super.key});
  static ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);
  final _pages = const [
    ScreenHome(),
    //ScreenLogout(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNav(),
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          /*child: ValueListenableBuilder(valueListenable: ScreenPoints.selectedIndexNotifier,
            builder: (BuildContext context,int updatedIndex,_){
              return _pages[updatedIndex];
            }),*/
          child: Center(
            child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 100,
                    width: 300,
                    //width: 600,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[300],
                    ),
                    child: Center(
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 30,
                          ),
                          //SizedBox(height: 30,),
                          Column(
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              CircleAvatar(
                                  radius: 25.0,
                                  backgroundImage:
                                      AssetImage('assets/profile_photo.jpg'))
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Name',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Role',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Design',
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
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    'Detailed Bill',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text(
                              'Date',
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
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: dates.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        margin: EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 4.0),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('yyyy-MM-dd').format(dates[index]),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  for (int i = 0; i < 3; i++)
                                    Container(
                                      width: 10,
                                      height: 10,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: foodConsumption[index][i]
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
                ]),
          ),
        ),
      ),
    );
  }
}
