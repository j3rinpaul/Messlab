import 'package:flutter/material.dart';
import 'package:mini_project/screens/homescreen/home_screen.dart';
import 'package:mini_project/screens/login.dart';
import 'package:mini_project/screens/managerHome/home_screen.dart';
import 'package:mini_project/screens/wardenpage/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    checkLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Loading..."),
      ),
    );
  }

  Future<void> gotoLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  Future<void> checkLogin() async {
    final sharedprefs =
        await SharedPreferences.getInstance(); 
    final islogged = sharedprefs.getBool(
        'SAVE_KEY'); 
    final roleuse = sharedprefs.getString('role');
    final uid = sharedprefs.getString('uid');
    if (islogged == null || islogged == false) {
      gotoLogin();
    } else if (roleuse == "user") {
      print("user");
      print(uid);

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (ctx1) => ScreenHome(
                u_id: uid,
              )));
    } else if (roleuse == "manager") {
      print("manager--");
      print(uid);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (ctx1) => ManagerHome(
                u_id: uid,
              )));
    }
    else if (roleuse == "warden") {
      print("warden--");
      print(uid);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (ctx1) => wardenPage(
                u_id: uid,
              )));
    }
  }
}
