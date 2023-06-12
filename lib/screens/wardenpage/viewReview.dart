import 'package:flutter/material.dart';
import 'package:mini_project/supabase_config.dart';

class viewReview extends StatefulWidget {
  const viewReview({super.key});

  @override
  State<viewReview> createState() => _viewReviewState();
}

class _viewReviewState extends State<viewReview> {
  @override
  void initState() {
    super.initState();
    fetchReview();
  }

  List<String> reviews = [];
  Future<void> fetchReview() async {
    //fetch review from database
    final response = await supabase.from('reviews').select('review').execute();
    if (response.error == null) {
      print("No reviews today");
      print(response.data);
      setState(() {
        reviews = (response.data as List<dynamic>)
            .map((item) => item['review'].toString())
            .toList();
      });
    } else {
      print(response.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Reviews"),
        ),
        body: ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
          final adjustedIndex = index + 1;
            return ListTile(
              title: Text("$adjustedIndex"),
              trailing: Text(reviews[index]),
            );
          },
        ));
  }
}
