import 'package:flutter/material.dart';
import 'package:mini_project/screens/homescreen/home_screen.dart';
import 'package:mini_project/screens/login.dart';
import 'package:mini_project/screens/managerHome/home_screen.dart';
import 'package:mini_project/screens/wardenpage/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();

    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (BuildContext context, Widget? child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Image.asset("assets/images/messlab.png"),
            );
          },
        ),
      ),
    );
  }

  Future<void> gotoLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    final sharedprefs = await SharedPreferences.getInstance();
    final isLogged = sharedprefs.getBool('SAVE_KEY');
    final roleUser = sharedprefs.getString('role');
    final uid = sharedprefs.getString('uid');

    if (isLogged == null || isLogged == false) {
      gotoLogin();
    } else if (roleUser == "user") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx1) => ScreenHome(u_id: uid),
        ),
      );
    } else if (roleUser == "manager") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx1) => ManagerHome(u_id: uid),
        ),
      );
    } else if (roleUser == "warden") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx1) => wardenPage(u_id: uid),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
