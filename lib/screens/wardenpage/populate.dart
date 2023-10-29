import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_project/supabase_config.dart';

class PopulateDb extends StatefulWidget {
  const PopulateDb({super.key});

  @override
  State<PopulateDb> createState() => _PopulateDbState();
}

class _PopulateDbState extends State<PopulateDb> {
  bool isLoading = false;

  String month = DateFormat('MM').format(DateTime.now());
  String year = DateFormat('yy').format(DateTime.now());

//make markings for all the users for a month
  Future<void> makeMarkings(String month, String year) async {
    setState(() {
      isLoading = true;
    });
    final response = await supabase.from('users').select().execute();
    final valid = await supabase
        .from('food_marked')
        .select("created")
        .eq("month", month)
        .eq("year", year)
        .execute();
    print("Valis" + valid.data.toString());

    DateTime now = DateTime(int.parse(year), int.parse(month), 1);
    DateTime month_end = DateTime(int.parse(year), int.parse(month) + 1, 0);

    if (valid.data.isEmpty) {
      for (DateTime time = now;
          time.isBefore(month_end.add(const Duration(days: 1)));
          time = time.add(const Duration(days: 1))) {
        String date = time.toLocal().toString().split(' ')[0];
        for (var item in response.data) {
          final userId = item['u_id'];
          final insertResponse = await supabase.from('food_marking').insert([
            {
              'u_id': userId,
              'mark_date': date,
              'morning': true,
              'noon': true,
              'evening': true,
            }
          ]).execute();

          if (insertResponse.error != null) {
            // Handle error
            throw insertResponse.error!;
          }
          print('Insert operation completed successfully!');
        }
      }
      final dataEntry = await supabase
          .from("food_marked") //inserting into food_marked table
          .insert([
        {
          'month': month,
          'year': year,
          'created': true,
        }
      ]).execute();
      if (dataEntry.error != null) {
        // Handle error
        throw dataEntry.error!;
      }
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool switchValue = false;

  List<String> months = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
  ];
  List<int> years =
      List<int>.generate(10, (index) => DateTime.now().year - 5 + index);

  String? selectedMonth;
  int? selectedYear;

  Future<void> _selectMonthAndYear() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Month  and Year '),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedMonth,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMonth = newValue;
                  });
                },
                items: months.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Month',
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: selectedYear,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedYear = newValue;
                  });
                },
                items: years.map((int year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Year',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  selectedMonth = null;
                  selectedYear = null;
                });
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Perform actions with selectedMonth and selectedYear
                if (selectedMonth != null && selectedYear != null) {
                  print(
                      'Selected month and year: $selectedMonth $selectedYear');
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Populate DB"),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _selectMonthAndYear,
                  child: const Text('Select Month and Year'),
                ),
                const SizedBox(height: 10),
                Text("Date selected: $selectedMonth $selectedYear"),
                ElevatedButton(
                  onPressed: () {
                    if (selectedMonth != null && selectedYear != null) {
                    
                      makeMarkings(selectedMonth!, selectedYear.toString());
                    }else{
                      showSnackBar("Please select a month and year");
                    }
                  },
                  child: const Text('Populate DB'),
                ),
                const SizedBox(height: 10),
                if (isLoading) const CircularProgressIndicator(),
              ],
            ),
          ],
        ));
  }
}
