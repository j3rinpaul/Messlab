import 'package:flutter/material.dart';

import '../../supabase_config.dart';

class ScreenReview extends StatefulWidget {
  final String? uid;
  const ScreenReview({super.key, this.uid});

  @override
  State<ScreenReview> createState() => _ScreenReviewState();
}

class _ScreenReviewState extends State<ScreenReview> {
  final TextEditingController _reviewCont = TextEditingController();

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
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child:  SizedBox(
          width: 370,
          height: 180,
          child: Column(
            children: [
              Center(
                  child: Text(
                    "Announcements",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              Expanded(
                  child: ListView.builder(
                    itemCount: announcementList.length,
                    itemBuilder: (context, index) {
                      final adjustedIndex = index + 1;
                      final announcement = announcementList[index];
                      return ListTile(
                        title: Text("$adjustedIndex"),
                        trailing: Text(announcement),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: SizedBox(
            width: 370,
            height: 150,
            child: Column(
              children: [
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(5), child: Text("Reviews"))),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10, left: 10, top: 15),
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
                              icon: const Icon(Icons.send)),
                          hintText: "Review",
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                      ),
                    ),
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
          title: const Text('Review'),
          content: const Text("Review successfully submitted"),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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