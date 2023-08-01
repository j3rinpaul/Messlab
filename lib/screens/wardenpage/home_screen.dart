import 'package:flutter/material.dart';
import 'package:mini_project/screens/wardenpage/verify.dart';
import 'package:mini_project/screens/wardenpage/Roleassign_warden.dart';
import 'package:mini_project/screens/wardenpage/generateBill.dart';
import 'package:mini_project/screens/wardenpage/settings.dart';
import 'package:mini_project/widgets/bottomnav.dart';

import 'ScreenHome.dart';

class wardenPage extends StatelessWidget {
  final String? u_id;
  const wardenPage({Key? key, this.u_id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNav(uid: u_id),
      appBar: AppBar(
        title: Text("Warden"),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person_add),
                        title: Text('User Verification'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx1) => VerifyUser()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.report_gmailerrorred_outlined),
                        title: Text('Role Assign'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx1) => RoleAssign()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.bookmark_outline_outlined),
                        title: Text('Generate Bill'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx1) => generateBill()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx1) => Settings()),
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
            offset: Offset(0, 56), // Offset the popup menu below the AppBar
            elevation: 4, // Set the elevation
          ),
        ],
      ),
      body: CalendarPage(
        uid: u_id,
      ),
    );
  }
}
