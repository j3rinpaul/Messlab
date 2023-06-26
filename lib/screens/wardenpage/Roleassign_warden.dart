import 'package:flutter/material.dart';
import 'package:mini_project/supabase_config.dart';

class RoleAssign extends StatefulWidget {
  const RoleAssign({Key? key}) : super(key: key);

  @override
  State<RoleAssign> createState() => _RoleAssignState();
}

class _RoleAssignState extends State<RoleAssign> {
  List<dynamic> parsedData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await supabase.from('users').select().execute();

    if (response.error == null) {
      setState(() {
        parsedData = response.data as List<dynamic>;
      });
    } else {
      print('Failed to fetch data from Supabase');
    }
  }

  Future<void> deletePerson(dynamic id) async {
    final response =
        await supabase.from('users').delete().eq('u_id', id).execute();
    if (response.error == null) {
      setState(() {
        parsedData.removeWhere((item) => item['u_id'] == id);
      });
      showVar(context, "User deleted successfully", "Deleted");
    } else {
      showVar(context, "Failed to delete user", "Failed");
      print("error" + response.error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Role Assign'),
      ),
      body: ListView.builder(
        itemCount: parsedData.length,
        itemBuilder: (context, index) {
          final item = parsedData[parsedData.length - 1 - index];
          print(item.toString());
          return Card(
            child: ListTile(
              title: Text('Name: ${item['first_name']} ${item['last_name']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Department: ${item['department']}'),
                  Text('Designation: ${item['designation']}'),
                  Text('Role: ${item['role']}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Warning'),
                                content: Text('Do you want to delete user?'),
                                actions: [
                                  TextButton(
                                    child: Text('Confirm'),
                                    onPressed: () {
                                      deletePerson(item['u_id']);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text("Delete"),
                      ),
                      TextButton(
                        onPressed: () {
                          showChangePasswordDialog(item['u_id']);
                        },
                        child: Text("Change Password"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showRoleSelectionDialog(item['u_id'], item['role']);
                        },
                        child: Text("Role Assign"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> verifyData(
    BuildContext context,
    String username,
    dynamic password,
    dynamic first_name,
    dynamic last_name,
    dynamic designation,
    dynamic department,
    dynamic phone,
    String role,
  ) async {
    final response = await supabase.from('users').insert([
      {
        'email': username,
        'password': password,
        'first_name': first_name,
        'last_name': last_name,
        'designation': designation,
        'department': department,
        'phone': phone,
        'role': role,
      }
    ]).execute();
    if (response.error == null) {
      showVar(context, "User created successfully", "Created");
    } else {
      showVar(context, "Failed to create user", "Failed");
      print("error" + response.error.toString());
    }
  }

  Future<void> showVar(BuildContext ctx, String? content, String? head) {
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showChangePasswordDialog(dynamic id) async {
    String newPassword = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: TextField(
            onChanged: (value) {
              newPassword = value;
            },
            decoration: InputDecoration(
              labelText: 'New Password',
            ),
          ),
          actions: [
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                await changePassword(id, newPassword);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> changePassword(dynamic id, String newPassword) async {
    final response = await supabase
        .from('users')
        .update({'password': newPassword})
        .eq('u_id', id)
        .execute();

    if (response.error == null) {
      showVar(context, "Password changed successfully", "Success");
    } else {
      showVar(context, "Failed to change password", "Failed");
      print("error" + response.error.toString());
    }
  }

  Future<void> showRoleSelectionDialog(dynamic id, String currentRole) async {
    String? selectedRole = currentRole;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Assign Role'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedRole,
                    onChanged: (String? value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'manager',
                        child: Text('Manager'),
                      ),
                      DropdownMenuItem(
                        value: 'user',
                        child: Text('User'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Confirm'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await assignRole(id, selectedRole);
                  },
                ),
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> assignRole(dynamic id, String? role) async {
    if (role != null) {
      final response = await supabase
          .from('users')
          .update({'role': role})
          .eq('u_id', id)
          .execute();

      if (response.error == null) {
        final userIndex = parsedData.indexWhere((item) => item['u_id'] == id);
        if (userIndex != -1) {
          setState(() {
            parsedData[userIndex]['role'] = role;
          });
        }
        showVar(context, "Role assigned successfully", "Success");
      } else {
        showVar(context, "Failed to assign role", "Failed");
        print("error" + response.error.toString());
      }
    }
  }
}

