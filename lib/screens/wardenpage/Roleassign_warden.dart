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
   sortData();
  }

  //sort parsedData based on name
  void sortData() {
    parsedData.sort((a, b) {
      final aName = a['first_name'] + a['last_name'];
      final bName = b['first_name'] + b['last_name'];
      return bName.compareTo(aName);
    });
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
      print("error${response.error}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Assign'),
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
                  Text("Username :${item['email']}"),
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
                                title: const Text('Warning'),
                                content: const Text('Do you want to delete user?\nGenerate bill for this mess cycle before you delete.'),
                                actions: [
                                  TextButton(
                                    child: const Text('Confirm'),
                                    onPressed: () {
                                      deletePerson(item['u_id']);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text("Delete"),
                      ),
                      TextButton(
                        onPressed: () {
                          showChangePasswordDialog(item['u_id']);
                        },
                        child: const Text("Change Password"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showRoleSelectionDialog(item['u_id'], item['role']);
                        },
                        child: const Text("Role Assign"),
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
    dynamic firstName,
    dynamic lastName,
    dynamic designation,
    dynamic department,
    dynamic phone,
    String role,
  ) async {
    final response = await supabase.from('users').insert([
      {
        'email': username,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
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
      print("error${response.error}");
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
              child: const Text('OK'),
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
          title: const Text('Change Password'),
          content: TextField(
            onChanged: (value) {
              newPassword = value;
            },
            decoration: const InputDecoration(
              labelText: 'New Password',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                await changePassword(id, newPassword);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
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
      print("error${response.error}");
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
              title: const Text('Assign Role'),
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
                    items: const [
                      DropdownMenuItem(
                        value: 'manager',
                        child: Text('Manager'),
                      ),
                       DropdownMenuItem(
                        value: 'warden',
                        child: Text('warden'),
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
                  child: const Text('Confirm'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await assignRole(id, selectedRole);
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
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
        print("error${response.error}");
      }
    }
  }
}

