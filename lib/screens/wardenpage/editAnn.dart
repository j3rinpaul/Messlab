import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../supabase_config.dart';

class EditAnnouncements extends StatefulWidget {
  const EditAnnouncements({super.key});

  @override
  State<EditAnnouncements> createState() => EditAnnouncementsState();
}

String formatDateTime(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  return formatter.format(dateTime);
}

class EditAnnouncementsState extends State<EditAnnouncements> {
  String? updatedAt2;
  Map<String, String> announcementList = {};
  Future<void> getAnnounce() async {
    final response = await supabase
        .from('announcements')
        .select('updated_at , announcemnts')
        .execute();
    if (response.error == null) {
      var data = response.data as List<dynamic>;
      print(data);
      for (var item in data) {
        // updatedAt2 = ;
        String updatedAt = item['updated_at'];
        // formatDateTime(updatedAt2!);
        String announcement = item['announcemnts'];
        setState(() {
          announcementList[updatedAt] = announcement;
        });
      }
      print(announcementList);
      print("Announce");
    } else {
      print(response.error);
    }
  }

  final TextEditingController _announcementCont = TextEditingController();

  void showAddAnnouncementDialog(BuildContext context, String updated_at) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Announcement'),
          content: TextField(
            controller: _announcementCont,
            // onChanged: (value) {
            //   _announcementCont. = value;
            // },
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                print(updated_at);
                final response = await supabase
                    .from('announcements')
                    .update({'announcemnts': _announcementCont.text})
                    .eq('updated_at', updated_at)
                    .execute();

                // insert({
                //   'announcemnts': _announcementCont.text,
                //   "u_id": widget.uid
                // }).execute();

                if (response.error == null) {
                  print("Announcement updated");
                  _announcementCont.clear();
                  getAnnounce();
                } else {
                  print(response.error);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteAnnouncement(String date) async {
    var dialog =
        AlertDialog(title: Text("Delete this announcement ?"), actions: [
      TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel")),
      TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final response = await supabase
                .from('announcements')
                .delete()
                .eq('updated_at', date)
                .execute();
            if (response.error == null) {
              print("deleted");
              setState(() {
                announcementList.remove(date);
              });
            } else {
              print(response.error);
            }
          },
          child: Text("Delete"))
    ]);

    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  @override
  void initState() {
    // TODO: implement initState
    getAnnounce();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Announcements"),
        actions: [
          IconButton(
            onPressed: () {
              getAnnounce();
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemCount: announcementList.length,
          itemBuilder: (BuildContext context, int index) {
            int reverseIndex = announcementList.length - index - 1;
            String updatedAt = announcementList.keys.elementAt(reverseIndex);
            String announcement =
                announcementList.values.elementAt(reverseIndex);
            print(updatedAt);
            print(announcement);

            return ListTile(
              subtitle: Text("Updated At: ${formatDateTime(updatedAt)}"),
              title: Text('Announcement: $announcement'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      _announcementCont.text = announcement;
                      showAddAnnouncementDialog(context, updatedAt);
                      print("edit announcement");
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      deleteAnnouncement(updatedAt);
                      print("delete announcement");
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
