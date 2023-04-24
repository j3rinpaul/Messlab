/*import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:mini_project/screens/Pointsscreen/screen_points.dart';

class AppBar extends StatelessWidget implements PreferredSizeWidget{
  const AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      ti
         Row(
             
               children: [
                 CircleAvatar (
                   radius: 35,
                   backgroundImage: AssetImage('assets/images/profilepic.png'),
                 ),
                 SizedBox(width: 20),
                 Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: const [
                     Text('Name',
                     style: TextStyle(fontSize: 18),),
                     SizedBox(height: 7,),
                     Text('Designation',
                     style: TextStyle(fontSize: 18),),
                     SizedBox(height: 7,),
                     Text('Role',
                     style: TextStyle(fontSize: 18),)
                   ],
                 ),
                 SizedBox(width: 50),
                 Expanded(
                   child: Column(
                     //mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       SizedBox(height: 28,),
                       Image.asset('assets/images/bill.png',
                       fit: BoxFit.cover,
                       height: 50, // set the desired height
                       width: 50,),
                       TextButton(onPressed: (){
                         Navigator.push(
                         context,
                           MaterialPageRoute(builder: (context) => ScreenPoints()),
                         );
                       }, 
                       child: Text('Bill',style: TextStyle(color: Colors.white),))
                     ],
                   ),
                 )
               ],
             )
    
    ) ;
  }
}*/