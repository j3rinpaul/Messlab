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
      for (var item in data) {
        updatedAt2 = item['updated_at'];
        String updatedAt = formatDateTime(updatedAt2!);
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

  Future<void> deleteAnnouncement(String date) async {
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
              subtitle: Text("Updated At: $updatedAt"),
              title: Text('Announcement: $announcement'),
              trailing: IconButton(
                onPressed: () {
                  deleteAnnouncement(updatedAt2!);
                  print("delete announcement");
                },
                icon: const Icon(Icons.delete),
              ),
            );
          },
        ),
      ),
    );
  }
}
