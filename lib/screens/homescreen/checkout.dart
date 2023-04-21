import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:mini_project/screens/homescreen/home_screen.dart';

class ScreenCheckBox extends StatefulWidget {
  const ScreenCheckBox({super.key});

  @override
  State<ScreenCheckBox> createState() => _ScreenCheckBoxState();
}

class _ScreenCheckBoxState extends State<ScreenCheckBox> {

  bool value =false;
  // ignore: non_constant_identifier_names
  List<ListTile> ?Tiles;
  //@override
  Widget build(BuildContext context) {
    /*return ListView(
      children: [
        buildCheckbox(),
      ],
    );
  }*/

 //buildCheckbox();
  List<ListTile> Tiles=[
    ListTile(
        onTap: (){
          setState(() {
            value=!value;
          });
        },
        leading: Image.asset('assets/images/sunrise-symbol_1343440.jpg'),
        title: Text('Morning Breakfast'),
        subtitle: Text('Mess Schedule'),
        trailing: Checkbox(value:value,
         onChanged: null
           
            //this.value=value!;
          ),
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
        leading: Image.asset('assets/images/moon.png'),
        title: Text('Night Supper'),
        subtitle: Text('Mess Schedule'),
        trailing:Checkbox(value: value, 
        onChanged: (value){
          this.value=value!;
        }) ,
        )
    ];
    

  return ListView(
    children: 
      Tiles,
      
    
  );

 
} 


}
  /*
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:mini_project/screens/home_screen.dart';

class ScreenCheckBox extends StatefulWidget {
  const ScreenCheckBox({super.key});

  @override
  State<ScreenCheckBox> createState() => _ScreenCheckBoxState();
}

class _ScreenCheckBoxState extends State<ScreenCheckBox> {

  List<Map<String, dynamic>> items =[
    {
      'title':'Morning Breakfast',
      'subtitle':'Mess Schedule',
      'image':'assets/images/sunrise-symbol_1343440.jpg'
    },
    {
      'title':'Noon Lunch',
      'subtitle':'Mess Schedule',
      'image':'assets/images/Screenshot from 2023-04-20 15-46-32.png'
    },
    {
      'title':'Night Supper',
      'subtitle':'Mess Schedule',
      'image':'assets/images/moon.png'
    },
  ];
  List <bool> checked =[false,false,false];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      );
        //automaticallyImplyLeading: false,
      
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: ( (context, index) {
          return CheckboxListTile(
             title: Text(items[index]['title']),
            subtitle: Text(items[index]['subtitle']),
            secondary: Image.asset(
              items[index]['image'],
              height: 40,
              width: 40,
            ),
            value: checked[index],
            onChanged: (value) {
              setState(() {
                checked[index]= bool as bool; value;
              });
            },);
        }),
      );
    
  }
}*/

/*class CheckBoxListTileDemo extends StatefulWidget {
  @override
  CheckBoxListTileDemoState createState() => new CheckBoxListTileDemoState();
}

class CheckBoxListTileDemoState extends State<CheckBoxListTileDemo> {*/
 /* List<CheckBoxListTileModel> checkBoxListTileModel =
      CheckBoxListTileModel.getUsers();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: new Text(
          'CheckBox ListTile Demo',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: new ListView.builder(
          itemCount: checkBoxListTileModel.length,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
              child: new Container(
                padding: new EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    new CheckboxListTile(
                        activeColor: Colors.pink[300],
                        dense: true,
                        //font change
                        title:  Text(
                          checkBoxListTileModel[index].title,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5),
                        ),
                        value: checkBoxListTileModel[index].isCheck,
                        secondary: Container(
                          height: 50,
                          width: 50,
                          child: Image.asset(
                            checkBoxListTileModel[index].img,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onChanged: (bool? val) {
                          itemChange(val!, index);
                        })
                  ],
                ),
              ),
            );
          }),
    );
  }

  void itemChange(bool val, int index) {
    setState(() {
      checkBoxListTileModel[index].isCheck = val;
    });
  }
}
class CheckBoxListTileModel {
  int? userId;
  String? img;
  String? title;
  bool? isCheck;

  CheckBoxListTileModel({this.userId, this.img, this.title, this.isCheck});

  static List<CheckBoxListTileModel> getUsers() {
    return <CheckBoxListTileModel>[
      CheckBoxListTileModel(
          userId: 1,
          img: 'assets/images/sunrise-symbol_1343440.jpg',
          title: "Android",
          isCheck: true),
      CheckBoxListTileModel(
          userId: 2,
          img: 'assets/images/Screenshot from 2023-04-20 15-46-32.png',
          title: "Flutter",
          isCheck: false),
      CheckBoxListTileModel(
          userId: 3,
          img: 'assets/images/moon.png',
          title: "IOS",
          isCheck: false),
      /*CheckBoxListTileModel(
          userId: 4,
          img: 'assets/images/php_img.png',
          title: "PHP",
          isCheck: false),
      CheckBoxListTileModel(
          userId: 5,
          img: 'assets/images/node_img.png',
          title: "Node",
          isCheck: false),*/
    ];
  }
}
*/