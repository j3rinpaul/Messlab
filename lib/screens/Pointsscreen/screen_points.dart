import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:mini_project/logout.dart';
import 'package:mini_project/screens/homescreen/home_screen.dart';

class ScreenPoints extends StatelessWidget {
  ScreenPoints({super.key});

/*final _pages= [ 
    ScreenHome(),
    ScreenLogout(),
  ];*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          
         // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(height: 30,),
            Container(
              
              height: 100,
              width: 330,
              //width: 600,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[300],
                
              ),
          
              child: Center(
                child: Row(
                  
                 // mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.end,
                  children: [ 
                    SizedBox(width: 30,),
                    //SizedBox(height: 30,),
                    Column(children: [
                      SizedBox(height: 10,),
                      Text('60',style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10,),
                      Text('Points consumed',style: TextStyle(fontWeight: FontWeight.bold),)
                    ],),
                   // Text('60',style: TextStyle(fontSize: 40),),
                    SizedBox(width: 50,),
                    Column(
                      children: [
                        SizedBox(height: 10,),
                        Text('7200',style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold)),
                        SizedBox(height: 10,),
                        Text('Bill owned by you',style: TextStyle(fontWeight: FontWeight.bold),)
                      ],
                    )
                  // Text('Rs.7200',style: TextStyle(fontSize: 40),)
                  ],
                  
                  
                ),
              ),
            ),
            SizedBox(height: 50,),
            Text('Detailed Bill'),
            SizedBox(height: 10,),
            Container(
              height: 350,
              width: 330,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[300]
              ),
              child: Row(children: [
                Container(
                  width: 130,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 149, 183, 212),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Column(
                    children: [
                      
                      Text('Date'),
                      Divider(height: 30,
                      color: Colors.white,),
                      Text('22-04-2023'),
                      Divider(height: 25,
                      color: Colors.white,),
                      Text('23-04-2023'),
                      Divider(height: 25,
                      color: Colors.white,),
                      Text('24-04-2023'),
                      Divider(height: 25,
                      color: Colors.white,),
                    ],
                  ),
                ),
                SizedBox(width: 50,),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                   // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      Text('Consumption'),
                      Divider(height: 22,
                      color: Colors.black,),
                      Image.asset('assets/images/dot.png'),
                      Divider(height: 22,
                      color: Color.fromARGB(255, 255, 255, 255),),
                      Image.asset('assets/images/dot.png'),
                      Divider(height: 22,
                      color: Colors.white,),
                      Image.asset('assets/images/dot.png'),
                      Divider(height: 20,
                      color: Colors.white,)
                    ],
                  ),
                 // ListView.separated(itemBuilder: itemBuilder, separatorBuilder: separatorBuilder, itemCount: itemCount)
                )
              ],),
            )
          ],
        ),
      ),
    );
  }
}