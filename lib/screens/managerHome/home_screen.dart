import 'package:flutter/material.dart';
import 'package:mini_project/widgets/bottomnav.dart';

import '../wardenpage/changePass.dart';
import '../wardenpage/generateBill.dart';
import 'ScreenHome.dart';
//import 'package:intl/intl.dart';

class ManagerHome extends StatelessWidget {
  const ManagerHome({super.key, this.u_id});
  final String? u_id;

  @override
  Widget build(BuildContext context) {
    // var date;
    //var day;

    return Scaffold(
      bottomNavigationBar: BottomNav(
        uid: u_id,
      ),
      appBar: AppBar(
        title: const Text("messLab - Manager"),
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
                      ListTile(
                        leading: const Icon(Icons.bookmark_outline_outlined),
                        title: const Text('Generate Bill'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx1) => const generateBill()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Add more PopupMenuItems for other options
              ];
            },
          ),
        ],
      ),
      body: CalendarPage(
        uid: u_id,
      ),
      //body:ScreenCheckBox();
    );

    // body:ScreenCheckBox();
  }
}
