import 'package:flutter/material.dart';
import 'package:mini_project/screens/home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final _formKey = GlobalKey<FormState>();
  final _usernameController=TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top:130.0,left: 10.0,right: 10.0),
        //const EdgeInsets.only(left:200.0),
        child: SafeArea(child: Form(
          key: _formKey,
          child: Expanded(
            child: Column(
              children: [const 
                Text('mEssLab',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                )),
               const  Text('Mess Management',
                style:TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ) ,),
                SizedBox(height: 30,),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 18.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(40.0),),
                    ),
                    validator: (value) {
                      if(value==null ||value.isEmpty){
                        return 'value is empty';
                      }else{
                        return null;
                      }
                    },
                  ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 18.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(40.0),),
                    ),
                    validator: (value) {
                      if(value==null ||value.isEmpty){
                        return 'value is empty';
                      }else{
                        return null;
                      }
                    },
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(onPressed: (){
                    _formKey.currentState!.validate();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return ScreenHome();
                    }));
                  }, child: Text('Sign In'),
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(400, 56)),
                    shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
                ),
              ),
                  ),)
              ],
            ),
          ),
        ),
        
        
        ),
      )
    );
  }
}
