import 'package:flutter/material.dart';

import '../../supabase_config.dart';

class EditProfile extends StatefulWidget {
  String? id;
  EditProfile({super.key, this.id});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _fname = TextEditingController();
  final _lname = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _designation = TextEditingController();
  final _phonenumber = TextEditingController();
  String? _selectedOption;

  final RegExp emailPattern =
      RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  final RegExp phoneNumberPattern = RegExp(r'^\+?[0-9]{8,15}$');
  final RegExp passwordPattern = RegExp(r'^.{6,}$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
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
                        DropdownMenuItem(
                          value: 'Office',
                          child: Text('Office'),
                        ),
                      ],
                      underline: Container(), // Remove the default underline
                      icon: const Icon(
                          Icons.arrow_drop_down), // Customize the dropdown icon
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
                  final fname = _fname.text.trim();
                  String lname = _lname.text.trim();
                  final email = _email.text.trim();
                  final designation = _designation.text.trim();
                  final phonenumber = _phonenumber.text.trim();

                  if (fname.isEmpty ||
                      email.isEmpty ||
                      _selectedOption == null ||
                      designation.isEmpty ||
                      phonenumber.isEmpty) {
                    showVar(
                        context, "Please fill all the fields", "Error", () {});
                  } else if (!emailPattern.hasMatch(email)) {
                    showVar(context, "Invalid email address", "Error", () {});
                  } else if (!phoneNumberPattern.hasMatch(phonenumber)) {
                    showVar(context, "Invalid phone number", "Error", () {});
                  }else if(lname == null){
                    setState(() {
                      lname = " ";
                    });
                  } 
                  else {
                    final response = await supabase
                        .from('users')
                        .update({
                          'first_name': fname,
                          'last_name': lname,
                          'email': email,
                          'department': _selectedOption!,
                          'designation': designation,
                          'phone': phonenumber,
                        })
                        .eq("u_id", widget.id!)
                        .execute();

                    if (response.error != null) {
                      showVar(
                          context, "Profile updation failed", "Error", () {});
                      print(response.error!.message);
                    } else {
                      showVar(
                        context,
                        "Profile updated successfully",
                        "Success",
                        () {
                          _fname.clear();
                          _lname.clear();
                          _email.clear();
                          _password.clear();
                          _designation.clear();
                          _phonenumber.clear();
                          setState(() {
                            _selectedOption = null;
                          });
                          Navigator.pop(context);
                        },
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
