/*import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
//import 'package:mini_project/screens/home_screen.dart';
import 'package:mini_project/screens/homescreen/home_screen.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable:ScreenHome().selectedIndexNotifier ,
      builder: (BuildContext ctx,int updatedIndex,Widget? _){
        return  BottomNavigationBar(
          currentIndex:updatedIndex ,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        onTap: (newIndex){
          ScreenHome().selectedIndexNotifier.value=newIndex;
        },
        items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home),
        label: 'Transactions'),
        BottomNavigationBarItem(icon: Icon(Icons.category),
        label: 'Category'),
      ]);
      },
      
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:mini_project/screens/Pointsscreen/screen_points.dart';

import '../screens/homescreen/home_screen.dart';
import '../screens/login.dart';

class BottomNav extends StatelessWidget {
  BottomNav({super.key});

  void _navigateToPage(BuildContext context, int newIndex) {
    if (newIndex == 1) {
      // Logout button clicked, navigate to the logout page or perform logout logic
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return ScreenPoints(); // Replace with the actual logout page
      }));
    } else if (newIndex == 0) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return ScreenHome(); // Replace with the actual home page
      }));
    } else if (newIndex == 2) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen()),
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
          items: [
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
