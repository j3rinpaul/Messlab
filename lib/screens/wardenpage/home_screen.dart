import 'package:flutter/material.dart';
import 'package:mini_project/screens/wardenpage/Roleassign_warden.dart';
import 'package:mini_project/screens/wardenpage/changePass.dart';
import 'package:mini_project/screens/wardenpage/generateBill.dart';
import 'package:mini_project/screens/wardenpage/messHoliday.dart';
import 'package:mini_project/screens/wardenpage/populate.dart';
import 'package:mini_project/screens/wardenpage/verify.dart';
import 'package:mini_project/widgets/bottomnav.dart';

import 'ScreenHome.dart';

class wardenPage extends StatelessWidget {
  final String? u_id;
  const wardenPage({super.key, this.u_id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNav(uid: u_id),
      appBar: AppBar(
        title: const Text("messLab - Warden"),
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
                        title: const Text('User Verification'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx1) => const VerifyUser()),
                          );
                        },
                      ),
                      ListTile(
                        leading:
                            const Icon(Icons.report_gmailerrorred_outlined),
                        title: const Text('Role Assign'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx1) => const RoleAssign()),
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
                      ListTile(
                        leading: const Icon(Icons.add_box_outlined),
                        title: const Text('Populate db'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx1) => const PopulateDb()),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.password),
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
                      // ListTile(
                      //   leading: const Icon(Icons.settings),
                      //   title: const Text('Mess Holiday'),
                      //   onTap: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(builder: (ctx1) => MessHoliday()),
                      //     );
                      //   },
                      // ),
                      // ListTile(
                      //   leading: const Icon(Icons.settings),
                      //   title: const Text('Settings'),
                      //   onTap: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(builder: (ctx1) => Settings()),
                      //     );
                      //   },
                      // ),
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
        ],
      ),
      body: CalendarPage(
        uid: u_id,
      ),
    );
  }
}
