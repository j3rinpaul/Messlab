import 'package:flutter/material.dart';
import 'package:mini_project/screens/wardenpage/editAnn.dart';
import 'package:mini_project/screens/wardenpage/viewReview.dart';
import 'package:mini_project/supabase_config.dart';

class ScreenReview extends StatefulWidget {
  String? uid;
  ScreenReview({super.key, this.uid});

  @override
  State<ScreenReview> createState() => _ScreenReviewState();
}

class _ScreenReviewState extends State<ScreenReview> {
  TextEditingController _reviewCont = TextEditingController();

  List<String> announcementList = [];
  Future<void> getAnnounce() async {
    final response =
        await supabase.from('announcements').select('announcemnts').execute();
    if (response.error == null) {
      setState(() {
        announcementList = (response.data as List<dynamic>)
            .map((item) => item['announcemnts'].toString())
            .toList();
      });
      print(announcementList);
      print(response.data);
      print("Announce");
    } else {
      print(response.error);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAnnounce();
  }

  @override
  void dispose() {
    _reviewCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.87,
            height: MediaQuery.of(context).size.height * 0.25,
            child: Column(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Announcements",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            getAnnounce();
                          },
                          icon: Icon(
                            Icons.refresh,
                            size: 15,
                          ))
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: announcementList.length,
                    itemBuilder: (context, index) {
                      int reverse_index = announcementList.length - index - 1;
                      final adjustedIndex = index + 1;
                      final announcement = announcementList[reverse_index];
                      return ListTile(
                        title: Text("$adjustedIndex"),
                        trailing: Text(announcement),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          showAddAnnouncementDialog(context);
                        },
                        icon: Icon(
                          Icons.add,
                          size: 20,
                        )),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (ctx) {
                            return EditAnnouncements();
                          }));
                        },
                        icon: Icon(Icons.edit, size: 20))
                  ],
                ),
              ],
            )),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.87,
            height: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              children: [
                Center(
                    child: Padding(
                        padding: EdgeInsets.all(5), child: Text("Reviews"))),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10, left: 10, top: 15),
                      child: TextField(
                        controller: _reviewCont,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () async {
                                final response = await supabase
                                    .from('reviews')
                                    .insert({
                                  'review': _reviewCont.text,
                                  "u_id": widget.uid
                                }).execute();
                                print(_reviewCont.text);
                                if (response.error == null) {
                                  _showDialog(context);
                                } else {
                                  print(response.error);
                                }
                                _reviewCont.clear();
                              },
                              icon: Icon(Icons.send)),
                          hintText: "Review",
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          print("View");
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (ctx) {
                            return viewReview();
                          }));
                        },
                        child: Text("view"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  void _showDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Review'),
          content: Text("Review successfully submitted"),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  TextEditingController _announcementCont = TextEditingController();
  String newAnnouncement = "";
  void showAddAnnouncementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Announcement'),
          content: TextField(
            controller: _announcementCont,
            onChanged: (value) {
              newAnnouncement = value;
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final response = await supabase.from('announcements').insert({
                  'announcemnts': _announcementCont.text,
                  "u_id": widget.uid
                }).execute();

                if (response.error == null) {
                  print("Announcement added");
                  _announcementCont.clear();
                  getAnnounce();
                } else {
                  print(response.error);
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}


/*
  announcements are saved into the db and fetched and displayed through valuenotifier

 */