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
  final ValueNotifier<List<ExpenseItem>> expenseListNotifier =
      ValueNotifier([]);

  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  DateTime? selectedDate;

  Future<String> getName(String uid) async {
    var resp = await supabase.from('users').select().eq('u_id', uid).execute();
    if (resp.error == null) {
      print(resp.data);
      print("-------------------------------");
      return "${resp.data[0]['first_name']} ${resp.data[0]['last_name']}";
    } else
      return Future.value("No name");
  }

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
      final response = await supabase.from('daily_expense').insert({
        'date': date,
        'amount': amount,
        'remark': remark,
        'u_id': widget.uid,
        'month': curMonth,
        'year': curYear,
      }).execute();

      if (response.error == null) {
        // Expense saved successfully
        final insertedExpense = response.data?.first;
        final newExpense = ExpenseItem(
            date: insertedExpense['date'],
            amount: insertedExpense['amount'],
            remark: insertedExpense['remark'],
            updated_date: insertedExpense['updated_date'],
            u_id: insertedExpense['u_id']);

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

  Future<void> editExpense() async {
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
          updated_date: insertedExpense['updated_date'],
          u_id: insertedExpense['u_id'],
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
    print(response.data);

    if (response.error == null) {
      final data = response.data;
      if (data != null && data.isNotEmpty) {
        final l = data.map((expense) async {
          return ExpenseItem(
              date: expense['date'] as String,
              amount: (expense['amount'] as num).toDouble(),
              remark: expense['remark'] as String,
              updated_date: expense['updated_date'] as String,
              u_id: expense['u_id'] as String,
              name: await getName(expense['u_id']));
        }).toList();
        final list = [];
        for (Future<ExpenseItem> i in l) {
          list.add(await i);
        }
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
                        updated_date: DateTime.now().toString(),
                        u_id: widget.uid!,
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
                  uid: widget.uid!,
                  fetchDate: () => setState(() {
                    print("fetching");
                    fetchExpenses(null, null);
                  }),
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
  final String updated_date;
  final String u_id;
  String? name;

  ExpenseItem(
      {required this.date,
      required this.amount,
      required this.remark,
      required this.updated_date,
      required this.u_id,
      this.name});
}

class ShowList extends StatelessWidget {
  final List<ExpenseItem> expenses;
  final String uid;
  final void Function()? fetchDate;

  ShowList(
      {Key? key,
      required this.expenses,
      required this.uid,
      required this.fetchDate})
      : super(key: key);

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
                DataColumn(label: Text("User")),
                DataColumn(label: Text("Edit")),
                DataColumn(label: Text("Delete"))
              ],
              rows: expenses.map<DataRow>((expense) {
                print(expense.u_id);
                print(uid);
                return DataRow(
                  cells: [
                    DataCell(Text(expense.date)),
                    DataCell(Text(expense.amount.toString())),
                    DataCell(Text(expense.remark)),
                    DataCell(Text(expense.name ?? "")),
                    DataCell(
                      expense.u_id == uid
                          ? IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                TextEditingController controller =
                                    TextEditingController(text: expense.date);
                                TextEditingController amount_controller =
                                    TextEditingController(
                                        text: expense.amount.toString());
                                TextEditingController remark_controller =
                                    TextEditingController(text: expense.remark);
                                DateTime? selectedDate = expense.date.isNotEmpty
                                    ? DateTime.parse(expense.date)
                                    : null;
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Edit Expense'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              DateTime? picked =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(2022),
                                                lastDate: DateTime(2025),
                                              );
                                              if (picked != null) {
                                                selectedDate = picked;
                                                controller.text =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(selectedDate!);
                                              }
                                            },
                                            child: IgnorePointer(
                                              child: TextField(
                                                controller: controller,
                                                decoration:
                                                    const InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                  ),
                                                  labelText: 'Date',
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          TextField(
                                            controller: amount_controller,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                              ),
                                              labelText: 'Amount',
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          TextField(
                                            controller: remark_controller,
                                            maxLines: null,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                              ),
                                              labelText: 'Remark',
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final response = await supabase
                                                .from('daily_expense')
                                                .update({
                                                  'date': controller.text,
                                                  'amount':
                                                      amount_controller.text,
                                                  'remark':
                                                      remark_controller.text,
                                                })
                                                .eq('updated_date',
                                                    expense.updated_date)
                                                .execute();
                                            if (response.error == null) {
                                              print("updated");
                                              fetchDate!();
                                              Navigator.of(context).pop();
                                            } else {
                                              print(response.error);
                                            }
                                          },
                                          child: const Text('Update'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            )
                          : Text(""),
                    ),
                    DataCell(
                      expense.u_id == uid
                          ? IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final response = await supabase
                                    .from('daily_expense')
                                    .delete()
                                    .eq('updated_date', expense.updated_date)
                                    .execute();
                                if (response.error == null) {
                                  print("deleted");
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Deleted"),
                                        content: const Text(
                                            "Expense deleted successfully"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("OK"))
                                        ],
                                      );
                                    },
                                  );
                                  fetchDate!();
                                } else {
                                  print(response.error);
                                }
                              },
                            )
                          : Text(""),
                    ),
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
