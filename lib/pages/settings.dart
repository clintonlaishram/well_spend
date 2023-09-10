// ignore_for_file: library_private_types_in_public_api


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:well_spend/models/category.dart';
import 'package:well_spend/models/expense.dart';
import 'package:well_spend/pages/report_bug.dart';
import 'package:well_spend/realm.dart';
import 'package:well_spend/utils/destructive_prompt.dart';

import '../pages/categories.dart';
import '../types/widgets.dart';

class Item {
  final String label;
  final bool isDestructive;

  const Item(this.label, this.isDestructive);
}

const items = [
  Item('Categories', false),
  Item('Report a bug', false),
  Item('Erase all data', true),
];

class Settings extends WidgetWithTitle {
  const Settings({super.key}) : super(title: "Settings");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: false,
          toolbarHeight: 70,
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          title: const Padding(
            padding: EdgeInsets.fromLTRB(8, 25, 8, 0),
            child: Text("Settings",
              style: TextStyle(color: Colors.white, 
                fontSize: 36, fontWeight: FontWeight.w700 ),
              )
            ),
          ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromARGB(255, 0, 0, 0),
          padding: const EdgeInsets.only(top: 20),
          transformAlignment: Alignment.center,
          child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 28, 28, 30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CupertinoFormSection.insetGrouped(children: [
                ...List.generate(
                    items.length,
                    (index) => GestureDetector(
                        onTap: () {
                          switch (index) {
                            case 0:
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          const Categories()));
                              break;
                            case 1:
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => const ReportBug()));
                              break;
                            case 2:
                              showAlertDialog(
                                context,
                                () {
                                  realm.write(() {
                                    realm.deleteAll<Expense>();
                                    realm.deleteAll<Category>();
                                  });
                                },
                                "Are you sure?",
                                "This action cannot be undone.",
                                "Erase data",
                              );
                              break;
                          }
                        },
                        child: DecoratedBox(
                          decoration: const BoxDecoration(),
                          child: CupertinoFormRow(
                            prefix: Text(items[index].label,
                                style: TextStyle(
                                    color: items[index].isDestructive
                                        ? const Color.fromARGB(255, 255, 69, 58)
                                        : const Color.fromARGB(255, 255, 255, 255), 
                                        fontSize: 18)),
                            helper: null,
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            child: items[index].isDestructive
                                ? Container()
                                : const Icon(CupertinoIcons.chevron_right),
                          ),
                        )))
              ])),
        ),
      ),
    );
  }
}
