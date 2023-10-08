import 'package:flutter/material.dart';
import 'package:mini_project/supabase_config.dart';

class VerifyUser extends StatefulWidget {
  const VerifyUser({Key? key}) : super(key: key);

  @override
  State<VerifyUser> createState() => _VerifyUserState();
}

class _VerifyUserState extends State<VerifyUser> {
  List<dynamic> parsedData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await supabase.from('signup_details').select().execute();

    if (response.error == null) {
      setState(() {
        parsedData = response.data as List<dynamic>;
      });
    } else {
      print('Failed to fetch data from Supabase');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
      ),
      body: ListView.builder(
        itemCount: parsedData.length,
        itemBuilder: (context, index) {
          final item = parsedData[parsedData.length - 1 - index];
          return Card(
            child: ListTile(
              title: Text('ID: ${item['id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${item['first_name']} ${item['last_name']}'),
                  Text('Password: ${item['password']}'),
                  Text('Department: ${item['department']}'),
                  Text('Username: ${item['username']}'),
                  Text('Phone: ${item['phone']}'),
                  Text('Designation: ${item['designation']}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Warning'),
                                  content: const Text('Do you want to delete user?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Confirm'),
                                      onPressed: () {
                                        // Do something
                                        DeleteData(item['id']);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        // Do something
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text("Delete")),
                      ElevatedButton(
                          onPressed: () {
                            verifyData(
                                context,
                                item['id'],
                                item['username'],
                                item['password'],
                                item['first_name'],
                                item['last_name'],
                                item['designation'],
                                item['department'],
                                item['phone']);
                            print(item['username'] + item['password']);
                          },
                          child: const Text("Verify")),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> DeleteData(dynamic id) async {
    final response =
        await supabase.from('signup_details').delete().eq('id', id).execute();
    if (response.error == null) {
      showVar(context, "User deleted successfully", "Deleted");
      fetchData();
    } else {
      showVar(context, "Failed to delete user", "Failed");
      print("error${response.error}");
    }
  }

  Future<void> verifyData(
      BuildContext context,
      dynamic id,
      String username,
      dynamic password,
      dynamic firstName,
      dynamic lastName,
      dynamic designation,
      dynamic deptartment,
      dynamic phone) async {
//check if user already exists
    final userfound = await supabase //check if user already exists
        .from('users')
        .select()
        .eq('email', username)
        .execute();
    if (userfound.data.isNotEmpty) {
      showVar(context, "User already exists", "Failed");
      return;
    } else {
      final response = await supabase.from('users').insert([
        {
          'email': username,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'designation': designation,
          'department': deptartment,
          'phone': phone,
        }
      ]).execute();
      if (response.error == null) {
        final response = await supabase
            .from('signup_details')
            .delete()
            .eq('id', id)
            .execute();
        print(id);
        showVar(context, "User created successfully", "Created");
        if (response.error == null) {
          print("user deleted after verification");
        }
        fetchData();
      } else {
        showVar(context, "Failed to create user", "Failed");
        print("error${response.error}");
      }
    }
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
              child: const Text('OK'),
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
