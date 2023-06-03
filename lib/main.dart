import 'package:flutter/material.dart';
import 'package:mini_project/screens/splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qoyvrrvgzvfmqoptmbtv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFveXZycnZnenZmbXFvcHRtYnR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODMwMzk4NDYsImV4cCI6MTk5ODYxNTg0Nn0.oPxfpyZiVrabR_TL6iBF7OzpkTW2MpPgJSjuY_ksZqU',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.green),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
