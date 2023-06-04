import 'package:flutter/material.dart';
import 'package:mini_project/supabase_config.dart';

class User {
  String fname;
  String lname;
  String username;
  String password;
  String department;

  User(this.fname, this.lname, this.username, this.password, this.department);
}

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _fname = TextEditingController();
  final _lname = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _designation = TextEditingController();
  final _phonenumber = TextEditingController();
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Signup"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
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
                const SizedBox(
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
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _email,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: "Email",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: "Password",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text("Department:"),
                        ),
                      ),
                      DropdownButton<String>(
                        padding: const EdgeInsets.only(right: 20),
                        value: _selectedOption,
                        hint: const Text('Select Option'),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedOption = newValue;
                          });
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'CSE',
                            child: Text('CSE'),
                          ),
                          DropdownMenuItem(
                            value: 'ME',
                            child: Text('ME'),
                          ),
                          DropdownMenuItem(
                            value: 'ECE',
                            child: Text('ECE'),
                          ),
                          DropdownMenuItem(
                            value: 'EEE',
                            child: Text('EEE'),
                          ),
                          DropdownMenuItem(
                            value: 'IT',
                            child: Text('IT'),
                          ),
                        ],
                        underline: Container(), // Remove the default underline
                        icon: const Icon(Icons
                            .arrow_drop_down), // Customize the dropdown icon
                        iconSize: 24,
                        elevation: 12,
                        style: const TextStyle(color: Colors.black),
                        isExpanded: false,
                        dropdownColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _designation,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: "Designation",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _phonenumber,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: "Phone Number",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_fname.text == "" ||
                        _lname.text == "" ||
                        _email.text == "" ||
                        _password.text == "" ||
                        _selectedOption == "" ||
                        _designation.text == "" ||
                        _phonenumber.text == "") {
                      showVar(context, "Please fill all the fields", "Error",
                          () {});
                    } else {
                      final response =
                          await supabase.from('signup_details').insert({
                        'first_name': _fname.text,
                        'last_name': _lname.text,
                        'username': _email.text,
                        'password': _password.text,
                        'department': _selectedOption,
                        'designation': _designation.text,
                        'phone': _phonenumber.text,
                      }).execute();
                      print(response.status);
                      if (response.error != null) {
                        showVar(
                            context, "Failed to create user", "Error", () {});
                      } else {
                        showVar(
                          context,
                          "User created successfully. Wait for validation from the admin",
                          "Success",
                          () {
                            setState(() {
                              _fname.text = "";
                              _lname.text = "";
                              _email.text = "";
                              _password.text = "";
                              _designation.text = "";
                              _phonenumber.text = "";
                              _selectedOption = null;
                            });
                            Navigator.pop(context);
                          },

                          //refresh page after submit
                          //route to sign in page -- loading animations
                        );
                      }
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showVar(
      BuildContext ctx, String content, String head, Function? callback) async {
    await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(head),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (callback != null) {
                  callback();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
