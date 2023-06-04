import 'package:flutter/material.dart';
import 'package:mini_project/screens/Pointsscreen/screen_points.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/homescreen/home_screen.dart';
import '../screens/login.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
  });

  void _navigateToPage(BuildContext context, int newIndex) async {
    final sharedprefs = await SharedPreferences.getInstance();
    if (newIndex == 1) {
      // Logout button clicked, navigate to the logout page or perform logout logic
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return ScreenPoints(); // Replace with the actual logout page
      }));
    } else if (newIndex == 0) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return const ScreenHome(); // Replace with the actual home page
      }));
    } else if (newIndex == 2) {
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'profile',
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
