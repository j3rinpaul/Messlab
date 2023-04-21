/*import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';

class ScreenCheckBox extends StatefulWidget {
  const ScreenCheckBox({super.key});

  @override
  State<ScreenCheckBox> createState() => _ScreenCheckBoxState();
}

class _ScreenCheckBoxState extends State<ScreenCheckBox> {

  bool value =false;
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        buildCheckbox(),
      ],
    );
  }

Widget buildCheckbox(){
  return ListView(
    children: [
      ListTile(
        onTap: (){
          setState(() {
            value=!value;
          });
        },
        leading: Image.asset('assets/images/sunrise-symbol_1343440.jpg'),
        title: Text('Morning Breakfast'),
        subtitle: Text('Mess Schedule'),
        trailing: Checkbox(value: value,
         onChanged: (value){
          setState(() {
            this.value=value!;
          });
         }),
      ),
      ListTile(
        onTap: (){
          setState(() {
            value=!value;
          });
        },
        leading: Image.asset('assets/images/Screenshot from 2023-04-20 15-46-32.png'),
        title: Text('Noon Lunch'),
        subtitle: Text('Mess Schedule'),
        trailing: Checkbox(value: value,
         onChanged: (value){
          setState(() {
            this.value=value!;
          });
         }),
      ),
      ListTile(
        onTap: (){
          setState(() {
            value=!value;
          });
        },
        leading: Image.asset('name'),
        title: Text('Night Supper'),
        subtitle: Text('Mess Schedule'),
        trailing:Checkbox(value: value, 
        onChanged: (value){
          this.value=value!;
        }) ,
        )
    ],
  );
}

 
}*/

