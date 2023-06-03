import 'package:flutter/material.dart';
import 'package:mini_project/screens/signup.dart';
import '../supabase_config.dart';
import 'homescreen/home_screen.dart';
import 'managerHome/home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = true;
  @override
  Widget build(BuildContext context) {
    EdgeInsets paddings = EdgeInsets.only(
      right: MediaQuery.of(context).size.width * 0.05, // 5% of screen width
      left: MediaQuery.of(context).size.width * 0.05, // 5% of screen width
    );
    return Scaffold(
        body: SafeArea(
      child: Form(
        key: _formKey,
        child: Container(
          padding: paddings,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('mEssLab',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  )),

                  //random comment added
              const Text(
                'Mess Management',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 18.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: _isPasswordVisible,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  hintText: 'Password',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 18.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = _usernameController.text;
                  final password = _passwordController.text;

                  final response = await supabase
                      .from('users')
                      .select()
                      .eq('email', email)
                      .eq('password', password)
                      .execute();
                  if (response.error != null) {
                    // Handle any errors that occurred during the query
                    print('Error: ${response.error}');
                  } else {
                    // Check if the query returned any rows
                    if (response.data.length > 0) {
                      // The email and password are valid, user is authenticated
                      print('Authentication successful');
                      print(response.data);
                      final role = await supabase
                          .from('users')
                          .select('role')
                          .eq('email', email)
                          .eq('password', password)
                          .execute();
                      final roles = role.data[0]['role'];
                      if (roles == "user") {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                          return ScreenHome(u_id: response.data[0]['u_id']);
                        }));
                        print("user");
                      } else if (roles == "manager") {
                        print("manager");
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                          return ManagerHome();
                        }));
                      } else {
                        print("error");
                      }
                    } else {
                      print('Invalid email or password');
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('Wrong Email or Password'),
                            actions: [
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  // Do something
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                      // Show an error message or take appropriate action
                    }
                  }
                },
                child: Text('Sign In'),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(400, 56)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {
                    print("Signup completed");
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return Signup();
                    }));
                  },
                  child: Text("Signup"))
            ],
          ),
        ),
      ),
    ));
  }

 

 
}
