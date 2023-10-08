import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_project/supabase_config.dart';

class MonthlyExp extends StatefulWidget {
  final String? uid;

  const MonthlyExp({Key? key, this.uid}) : super(key: key);

  @override
  _MonthlyExpState createState() => _MonthlyExpState();
}

class _MonthlyExpState extends State<MonthlyExp> {
  final ValueNotifier<List<ExpenseItem>> expenseListNotifier = ValueNotifier([]);

  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      selectedDate = picked;
      dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
    }
  }

  Future<void> addExpense() async {
    final String date = dateController.text;
    final double amount = double.tryParse(amountController.text) ?? 0;
    final String remark = remarkController.text;

    DateTime currentDate = DateTime.now();
    int curMonth = selectedDate!.month;
    int curYear = currentDate.year;

    if (date.isNotEmpty && amount > 0) {
      // Save expense to Supabase
      final response = await supabase.from('daily_expense').insert([
        {
          'date': date,
          'amount': amount,
          'remark': remark,
          'u_id': widget.uid,
          'month': curMonth,
          'year': curYear,
        }
      ]).execute();

      if (response.error == null) {
        // Expense saved successfully
        final insertedExpense = response.data?.first;
        final newExpense = ExpenseItem(
          date: insertedExpense['date'],
          amount: insertedExpense['amount'],
          remark: insertedExpense['remark'],
        );

        expenseListNotifier.value = [...expenseListNotifier.value, newExpense];

        // Clear the text fields after adding an expense
        dateController.clear();
        amountController.clear();
        remarkController.clear();
        selectedDate = null;
      } else {
        // Error occurred while saving the expense
        print('Error: ${response.error?.message}');
      }
    }
  }

  Future<void> fetchExpenses(String? date, int? year) async {
    if (date == null && year == null) {
      date = DateFormat('MM').format(DateTime.now());
    }

    final response = await supabase
        .from('daily_expense')
        .select()
        .eq('month', date)
        .eq(year != null ? 'year' : '', year)
        .execute();

    if (response.error == null) {
      final data = response.data;

      if (data != null && data.isNotEmpty) {
        final list = data.map((expense) => ExpenseItem(
              date: expense['date'] as String,
              amount: (expense['amount'] as num).toDouble(),
              remark: expense['remark'] as String,
            ));

        expenseListNotifier.value = List.from(list);
      }
    } else {
      print('Error: ${response.error?.message}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchExpenses(null, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expenses'),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () => _selectDate(context),
                  child: IgnorePointer(
                    child: TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        labelText: 'Date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    labelText: 'Amount',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: remarkController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    labelText: 'Remark',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final response = await supabase
                        .from('bill_generated')
                        .select()
                        .eq('month', DateFormat('MM').format(DateTime.now()))
                        .execute();
                    final generate = response.data.isNotEmpty
                        ? response.data[0]['generate_bill']
                        : false;
                    print(generate);

                    if (generate) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Bill Not Added'),
                            content: const Text(
                                'The bill has already been generated for this month.'),
                            actions: <Widget>[
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
                      print("bill not added");
                      return;
                    } else {
                      print("bill added");
                      addExpense();
                      ExpenseItem(
                        date: dateController.text,
                        amount: double.parse(amountController.text),
                        remark: remarkController.text,
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
                TextButton(
                  onPressed: _selectMonthAndYear,
                  child: const Text("View Bill"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<ExpenseItem>>(
              valueListenable: expenseListNotifier,
              builder: (context, expenses, _) {
                return ShowList(
                  expenses: expenses,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String? selectedMonth;
  int? selectedYear;

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

  Future<void> _selectMonthAndYear() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Month and Year'),
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
                if (selectedMonth != null && selectedYear != null) {
                  print(
                      'Selected month and year: $selectedMonth $selectedYear');
                }
                fetchExpenses(selectedMonth, selectedYear);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class ExpenseItem {
  final String date;
  final double amount;
  final String remark;

  ExpenseItem({
    required this.date,
    required this.amount,
    required this.remark,
  });
}

class ShowList extends StatelessWidget {
  final List<ExpenseItem> expenses;
  const ShowList({Key? key, required this.expenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          children: [
            DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Remark')),
              ],
              rows: expenses.map<DataRow>((expense) {
                return DataRow(
                  cells: [
                    DataCell(Text(expense.date)),
                    DataCell(Text(expense.amount.toString())),
                    DataCell(Text(expense.remark)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
