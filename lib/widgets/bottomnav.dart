/*import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:mini_project/screens/home/home_screen.dart';
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