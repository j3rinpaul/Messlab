import 'package:flutter/material.dart';

class ScreenReview extends StatefulWidget {
  const ScreenReview({super.key});

  @override
  State<ScreenReview> createState() => _ScreenReviewState();
}

class _ScreenReviewState extends State<ScreenReview> {
  TextEditingController _reviewCont = TextEditingController();

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
          width: 425,
          height: 180,
          child: Column(
            children: [
              Center(
                  child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        "Announcements",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))),
              Column(
                children: [Text("No Announcements Today")],
              )
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: SizedBox(
            width: 425,
            height: 150,
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
                              onPressed: () {
                                print(_reviewCont.text);
                                _showDialog(context);
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
}

/*
  announcements are saved into the db and fetched and displayed through valuenotifier

 */