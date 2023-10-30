import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mini_project/screens/login.dart';
import 'package:mini_project/supabase_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePass extends StatefulWidget {
  String? id;
  ChangePass({super.key, this.id});

  @override
  State<ChangePass> createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  final _oldpass = TextEditingController();
  final _newpass = TextEditingController();
  final _confirm = TextEditingController();

  void toastBar(String msgs) {
    Fluttertoast.showToast(
        msg: msgs,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 20);
  }

  Future<void> checkPass(String confirm, String newpass, String id) async {
    if (confirm == newpass) {
      final response = await supabase
          .from('users')
          .update({'password': newpass})
          .eq('u_id', id)
          .execute();
      if (response.error == null) {
        print("Password changed successfully");
        toastBar("Password changed successfully");
        final sharedprefs = await SharedPreferences.getInstance();
        await sharedprefs.clear();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx1) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        print("Failed to change password");
        toastBar("Failed to change password");
      }
    } else {
      print("Passwords do not match1");
      toastBar("Passwords do not match");
    }
  }

  Future<void> changePass(
      String oldpass, String newpass, String confirm, String id) async {
    final response = await supabase
        .from('users')
        .select('password')
        .eq('u_id', id)
        .execute();
    if (response.error == null) {
      if (oldpass == response.data[0]['password']) {
        checkPass(newpass, confirm, id);
      } else {
        print("Old password is incorrect");
        toastBar("Old password is incorrect");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _oldpass,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Old Password',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _newpass,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'New Password',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _confirm,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Confirm Password',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                changePass(
                    _oldpass.text, _newpass.text, _confirm.text, widget.id!);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
