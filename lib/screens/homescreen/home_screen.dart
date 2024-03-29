import 'package:flutter/material.dart';
import 'package:mini_project/screens/wardenpage/changePass.dart';
import 'package:mini_project/supabase_config.dart';

import '../../widgets/bottomnav.dart';
import 'ScreenHome.dart';
//import 'package:intl/intl.dart';

class ScreenHome extends StatelessWidget {
  final String? u_id;
  final String? role;
  const ScreenHome({super.key, this.u_id, this.role});

  Future<String> getName(String uid) async {
    var resp = await supabase.from('users').select().eq('u_id', uid).execute();
    if (resp.error == null) {
      print(resp.data);
      print("-------------------------------");
      return "${resp.data[0]['first_name']} ${resp.data[0]['last_name']}";
    } else
      return Future.value("No name");
  }

  @override
  Widget build(BuildContext context) {
    // var date;
    //var day;

    return Scaffold(
      bottomNavigationBar: BottomNav(
        uid: u_id,
      ),
      appBar: AppBar(
          title: FutureBuilder(
            future: getName(u_id!),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data.toString() + " (User)");
              } else {
                return Text("Mess Lab");
              }
            },
          ),
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
                          title: const Text('Change Password'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (ctx1) => ChangePass(
                                        id: u_id,
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
          ]),
      body: CalendarPage(
        u_id: u_id,
      ),
    );

    // body:ScreenCheckBox();
  }
}
