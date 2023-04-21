import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';

class ScreenLogout extends StatelessWidget {
  const ScreenLogout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Center(
            child: Text('Logging out',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          Text('Yes'),
          Text("No")
        ],
      ),
    );
  }
}