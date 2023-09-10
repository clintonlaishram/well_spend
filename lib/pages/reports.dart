// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:well_spend/components/charts/monthly_chart.dart';
import 'package:well_spend/components/charts/weekly_chart.dart';
import 'package:well_spend/components/charts/yearly_chart.dart';
import 'package:well_spend/components/expenses_list.dart';

import 'package:well_spend/constants.dart';
import 'package:well_spend/extensions/date_extensions.dart';
import 'package:well_spend/extensions/expenses_extensions.dart';
import 'package:well_spend/extensions/number_extensions.dart';
import 'package:well_spend/models/expense.dart';
import 'package:well_spend/realm.dart';
import 'package:well_spend/types/period.dart';
import 'package:well_spend/utils/picker_utils.dart';
import 'package:realm/realm.dart';

import '../types/widgets.dart';

class Reports extends WidgetWithTitle {
  const Reports({super.key}) : super(title: "Reports");

  @override
  Widget build(BuildContext context) {
    return const ReportsContent();
  }
}

class ReportsContent extends StatefulWidget {
  const ReportsContent({super.key});

  @override
  _ReportsContent createState() => _ReportsContent();
}

class _ReportsContent extends State<ReportsContent> {
  final PageController _controller = PageController(initialPage: 0);
  set _currentPage(int value) {
    setStateValues(value);
  }

  double _spentInPeriod = 0;
  double _avgPerDay = 0;

  StreamSubscription<RealmResultsChanges<Expense>>? _expensesSub;
  var realmExpenses = realm.all<Expense>();
  List<Expense> _expenses = [];

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  int get _numberOfPages {
    switch (periods[_selectedPeriodIndex]) {
      case Period.day:
        return 365; // not used
      case Period.week:
        return 53;
      case Period.month:
        return 12;
      case Period.year:
        return 1;
    }
  }

  int _periodIndex = 1;
  int get _selectedPeriodIndex => _periodIndex;
  set _selectedPeriodIndex(int value) {
    _periodIndex = value;
    setStateValues(0);
    _controller.jumpToPage(0);
  }

  @override
  void initState() {
    super.initState();
    setStateValues(0);
  }

  void setStateValues(int page) {
    var filterResults = realmExpenses
        .toList()
        .filterByPeriod(periods[_selectedPeriodIndex], page);

    var expenses = filterResults[0] as List<Expense>;
    var start = filterResults[1] as DateTime;
    var end = filterResults[2] as DateTime;
    var numOfDays = end.difference(start).inDays;

    setState(() {
      _expenses = expenses;
      _startDate = start;
      _endDate = end;
      _spentInPeriod = expenses.sum();
      _avgPerDay = _spentInPeriod / numOfDays;
    });
  }

  @override
  Widget build(BuildContext context) {
    _expensesSub ??= realmExpenses.changes.listen((changes) {
      setStateValues(_controller.page!.toInt());
    });
    //final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 70,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Padding(
          padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
          child: Text("Reports",
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 36, fontWeight: FontWeight.w700))),
        actions: [
          CupertinoButton(
          padding: const EdgeInsets.fromLTRB(10, 45, 23, 0),
          child: const Icon(CupertinoIcons.calendar),
          onPressed: () => showPicker(
            context,
            CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: _selectedPeriodIndex - 1,
              ),
              magnification: 1,
              squeeze: 1.2,
              useMagnifier: false,
              itemExtent: kItemExtent,
              // This is called when selected item is changed.
              onSelectedItemChanged: (int selectedItem) {
                setState(() {
                  _selectedPeriodIndex = selectedItem + 1;
                });
              },
              children: List<Widget>.generate(periods.length - 1, (int index) {
                return Center(
                  child: Text(periods[index + 1].name),
                );
              }),
            ),
          ),
        ),
      ]),
      body: SafeArea(
        child: Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color.fromARGB(255, 0, 0, 0),
            transformAlignment: Alignment.center,
        child: PageView.builder(
          controller: _controller,
          onPageChanged: (newPage) => _currentPage = newPage,
          itemCount: _numberOfPages,
          reverse: true,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_startDate.shortDate} - ${_endDate.shortDate}",
                            style: const TextStyle(fontSize: 20),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Text(
                                  "Rs. ",
                                  style: TextStyle(
                                    color: CupertinoColors.inactiveGray,
                                  ),
                                ),
                                Text(
                                  _spentInPeriod.removeDecimalZeroFormat(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Avg/day",
                            style: TextStyle(fontSize: 20),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Text(
                                  "Rs. ",
                                  style: TextStyle(
                                    color: CupertinoColors.inactiveGray,
                                  ),
                                ),
                                Text(
                                  _avgPerDay.removeDecimalZeroFormat(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  (() {
                    switch (_selectedPeriodIndex) {
                      case 1:
                        return WeeklyChart(expenses: _expenses.groupWeekly());
                      case 2:
                        return MonthlyChart(
                          expenses: _expenses,
                          startDate: _startDate,
                          endDate: _endDate,
                        );
                      case 3:
                        return YearlyChart(expenses: _expenses);
                      default:
                        return const Text("");
                    }
                  }()),
                  // SizedBox(
                  //     height: height * 0.40,
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: <Widget>[
                  //         SizedBox(
                  //           height: height * 0.001,
                  //         ),
                  //         const Text('Ring Pie Chart', style: TextStyle(fontSize: 20),),
                  //         const Expanded(
                  //           flex: 3,
                  //           child: Row(
                  //             children: [
                  //                 Expanded(flex: 3, child: Placeholder()),
                  //                 Expanded(flex: 4, child: Placeholder()),
                  //                 ]),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                    
                  (() {
                    if (_expenses.isEmpty) {
                      return const Text("No data for selected period!");
                    } else {
                      return Expanded(
                        child: ExpensesList(
                          expenses: _expenses,
                        ),
                      );
                    }
                  }()),
                ],
              ),
            );
          },
        ),
      ),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
