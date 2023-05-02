import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final List<String> items = [
  'Morning',
  'Afternoon',
  'Night',
];

class CheckboxList extends StatefulWidget {
  final DateTime? date;
  const CheckboxList({super.key, required this.date});

  @override
  _CheckboxListState createState() => _CheckboxListState();
}

class _CheckboxListState extends State<CheckboxList> {
  final List<bool> isCheckedList = List.filled(items.length, false);
  final List<Color> _checkBoxc = List.filled(items.length, Colors.red);
  List<IconData> _icons = [Icons.sunny_snowing, Icons.sunny, Icons.cloud];
  bool _formCheck = false;
  bool _submitCheck = false;

  @override
  Widget build(BuildContext context) {
    if (DateTime.now().hour == 0) {
      _submitCheck = false;
      _formCheck = false;
    }
    if (DateTime.now().day != widget.date!.day) {
      //checking whether the dates are same if same then disabling
      _submitCheck = false; //else another date then enabling
      _formCheck = false;
      isCheckedList.fillRange(0, isCheckedList.length, false);
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(7),
          child: SizedBox(
            height: 250,
            width: 500,
            child: ListView.separated(
              padding: EdgeInsets.all(10),
              itemCount: items.length,
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      child: Icon(_icons[index]),
                    ),
                    subtitle: Container(
                      color: _checkBoxc[index],
                    ),
                    title: CheckboxListTile(
                      title: Text(items[index]),
                      value: isCheckedList[index],
                      onChanged: (bool? value) {
                        setState(() {
                          if (_formCheck /*|| DateTime.now().hour >= 12*/) {
                            return null;
                          } else {
                            isCheckedList[index] = value!;
                            print(isCheckedList[index].toString() +
                                index.toString());
                            print(_formCheck);
                            print(DateTime.now().day);
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formCheck /*|| DateTime.now().hour >= 12 ||*/ ||
                _submitCheck) {
              return null;
            } else {
              //submitform code here
              setState(() {
                _formCheck = true;
                _submitCheck = true;
                print(isCheckedList);
                print('Date is ${widget.date!.day}');
                if (DateTime.now().day == widget.date!.day) {
                  String dayOfWeek = DateFormat('EEEE').format(widget.date!);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Timetable Submitted'),
                        content: Text(
                            'Timetable submitted successfully for ${dayOfWeek}'),
                        actions: [
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              // Do something
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  String dayOfWeek = DateFormat('EEEE').format(widget.date!);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content:
                            Text('You can\'t submit meals of ${dayOfWeek}'),
                        actions: [
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              // Do something
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              });
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

/*
the value array is passed into this class as a params
using index of the array we decide whether checked or not

 */

//here we get the result we need to send it to the db
//connect to the db 
//send the data along with the username to the db which is obtained from the shared preferences
//after certain day hour the submit button shouldn't work
//once this is submitted it cannot be resubmitted







/*
this code will help to do so
bool _checkboxChecked = false;
bool _formSubmitted = false;

CheckboxListTile( // for checkbutton 
  title: Text('Checkbox'),
  value: _checkboxChecked,
  onChanged: (bool value) {
    if (_checkboxChecked || DateTime.now().hour >= 12) {
      // Checkbox already checked or past 12 pm
      return null;
    } else {
      // Check the checkbox and set flag to true
      setState(() {
        _checkboxChecked = value;
      });
    }
  },
);

RaisedButton( for elevated button
  child: Text('Submit'),
  onPressed: () {
    if (_formSubmitted || DateTime.now().hour >= 12 || !_checkboxChecked) {
      // Form already submitted, past 12 pm, or checkbox not checked
      return null;
    } else {
      // Submit form and set flag to true
      submitForm();
      _formSubmitted = true;
    }
  },
);

// Reset checkbox and form flags at midnight
if (DateTime.now().hour == 0) {
  _checkboxChecked = false;
  _formSubmitted = false;
}


 */
