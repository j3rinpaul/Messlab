import 'package:flutter/material.dart';

class ScreenReview extends StatefulWidget {
  const ScreenReview({super.key});

  @override
  State<ScreenReview> createState() => _ScreenReviewState();
}

class _ScreenReviewState extends State<ScreenReview> {
  final TextEditingController _reviewCont = TextEditingController();

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
        child: const SizedBox(
          width: 370,
          height: 180,
          child: Column(
            children: [
              Center(
                  child: Text(
                    "Announcements",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SingleChildScrollView(
                child: Column(
                  children: [
                    Text("No Announcements Today"),
                  ],
                ),
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
                              onPressed: () {
                                print(_reviewCont.text);
                                _showDialog(context);
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