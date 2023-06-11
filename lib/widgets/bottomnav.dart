import 'package:flutter/material.dart';
import 'package:mini_project/screens/Pointsscreen/screen_points.dart';
import 'package:mini_project/screens/managerHome/home_screen.dart';
import 'package:mini_project/screens/wardenpage/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/homescreen/home_screen.dart';
import '../screens/login.dart';

class BottomNav extends StatefulWidget {
  final String? roles;
  final String? uid;
  const BottomNav({
    super.key,
    this.roles,
    this.uid,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  void _navigateToPage(
    BuildContext context,
    int newIndex,
  ) async {
    final sharedprefs = await SharedPreferences.getInstance();
    final role = sharedprefs.getString('role');
    await sharedprefs.setString("uiids", widget.uid.toString());

    if (newIndex == 0) {
      final uids = sharedprefs.getString('uiids');
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        if (widget.uid != null) {
          return ScreenPoints(
            uid: widget.uid,
          );
        } else {
          return ScreenPoints(
            uid: uids,
          );
        } // Replace with the actual logout page
      }));
    } else if (newIndex == 2) {
      if (role == "user") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ScreenHome(u_id: widget.uid)),
        );
      } else if (role == "warden") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => wardenPage(u_id: widget.uid)),
        );
      } else if (role == "manager") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => ManagerHome(u_id: widget.uid)),
        );
      }
    } else if (newIndex == 1) {
      await sharedprefs.clear();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      ScreenPoints.selectedIndexNotifier.value = newIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ScreenPoints.selectedIndexNotifier,
      builder: (BuildContext context, int updatedIndex, _) {
        return BottomNavigationBar(
          currentIndex: updatedIndex,
          onTap: (newIndex) {
            ScreenPoints.selectedIndexNotifier.value = newIndex;
            _navigateToPage(context, newIndex);
          },
          items: const [
            // BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.power_settings_new),
              label: 'Logout',
            ),
          ],
        );
      },
    );
  }
}
