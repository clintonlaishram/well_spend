// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:well_spend/components/expenses_list.dart';
import 'package:well_spend/extensions/number_extensions.dart';
import 'package:well_spend/extensions/expenses_extensions.dart';
import 'package:well_spend/constants.dart';
import 'package:well_spend/models/expense.dart';
import 'package:well_spend/realm.dart';
import 'package:well_spend/types/period.dart';
import 'package:well_spend/types/widgets.dart';
import 'package:well_spend/utils/picker_utils.dart';
import 'package:realm/realm.dart';

class Expenses extends WidgetWithTitle {
  const Expenses({super.key}) : super(title: "Expenses");

  @override
  Widget build(BuildContext context) {
    return const ExpensesContent();
  }
}

class ExpensesContent extends StatefulWidget {
  const ExpensesContent({super.key});

  @override
  _ExpensesContent createState() => _ExpensesContent();
}

class _ExpensesContent extends State<ExpensesContent> {
  int _selectedPeriodIndex = 1;
  Period get _selectedPeriod => periods[_selectedPeriodIndex];

  var realmExpenses = realm.all<Expense>();
  StreamSubscription<RealmResultsChanges<Expense>>? _expensesSub;
  List<Expense> _expenses = [];

  double get _total => _expenses.map((expense) => expense.amount).sum;

  @override
  void initState() {
    super.initState();
    _expenses = realmExpenses.toList().filterByPeriod(_selectedPeriod, 0)[0];
  }

  @override
  Future<void> dispose() async {
    await _expensesSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _expensesSub ??= realmExpenses.changes.listen((changes) {
      setState(() {
        _expenses =
            changes.results.toList().filterByPeriod(_selectedPeriod, 0)[0];
      });
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        centerTitle: false,
          toolbarHeight: 70,
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          title: const Padding(
            padding: EdgeInsets.fromLTRB(8, 25, 8, 0),
            child: Text("Expenses",
              style: TextStyle(color: Colors.white, 
                fontSize: 36, fontWeight: FontWeight.w700 ),
              )
            ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Total for: ", style: TextStyle(fontSize: 20),),
                CupertinoButton(
                  onPressed: () => showPicker(
                    context,
                    CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                          initialItem: _selectedPeriodIndex),
                      magnification: 1,
                      squeeze: 1.2,
                      useMagnifier: false,
                      itemExtent: kItemExtent,
                      // This is called when selected item is changed.
                      onSelectedItemChanged: (int selectedItem) {
                        setState(() {
                          _selectedPeriodIndex = selectedItem;
                          _expenses = realmExpenses.toList().filterByPeriod(
                              periods[_selectedPeriodIndex], 0)[0];
                        });
                      },
                      children:
                          List<Widget>.generate(periods.length, (int index) {
                        return Center(
                          child: Text(getPeriodDisplayName(periods[index]), 
                          style: const TextStyle(fontSize: 24),),
                        );
                      }),
                    ),
                  ),
                  child: Text(getPeriodDisplayName(_selectedPeriod), 
                    style: const TextStyle(fontSize: 20),),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 2, 0),
                  child: const Text("₹",
                      style: TextStyle(
                        fontSize: 26,
                        color: CupertinoColors.inactiveGray,
                      )),
                ),
                Text(_total.removeDecimalZeroFormat(),
                    style: const TextStyle(
                      fontSize: 50,
                    )),
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                child: ExpensesList(expenses: _expenses),
              ),
            )
          ],
        ),
      ),
    );
  }
}
