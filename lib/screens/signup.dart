import 'package:flutter/material.dart';

class User {
  String fname;
  String lname;
  String username;
  String password;
  String department;

  User(this.fname, this.lname, this.username, this.password, this.department);
}

class Signup extends StatelessWidget {
  Signup({super.key});

  final _fname = TextEditingController();
  final _lname = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Signup"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _fname,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: "First Name",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _lname,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: "Last Name",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _email,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: "Username",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _password,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: "Password",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _confirmPassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: "Department",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    var namm = new User(_fname.text, _lname.text, _email.text,
                        _password.text, _confirmPassword.text);

                    //using the db endpoint submit the data
                    // print(namm.fname);
                    // print(namm.lname);
                    // print(namm.username);
                    // print(namm.password);
                    // print(namm.department);

                    if (_fname.text == "" ||
                        _lname.text == "" ||
                        _email.text == "" ||
                        _password.text == "" ||
                        _confirmPassword.text == "") {
                      showVar(context, "Please fill all the fields", "Error");
                    } else {
                      showVar(
                          context,
                          "User created successfully wait for validation from the admin",
                          "Success");
                    }
                  },
                  child: Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future showVar(ctx, String? content, String? head) {
    return showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$head'),
          content: Text('$content'),
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
  }
}
