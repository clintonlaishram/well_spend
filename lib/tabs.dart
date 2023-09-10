import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:well_spend/pages/add.dart';
import 'package:well_spend/pages/expenses.dart';
import 'package:well_spend/pages/reports.dart';
import 'package:well_spend/pages/settings.dart';
import 'package:well_spend/types/widgets.dart';


class TabsController extends StatefulWidget{
  const TabsController({super.key});

  @override
  State<TabsController> createState() => _TabsControllerState();

}

class _TabsControllerState extends State<TabsController>{

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    }

  static const List<WidgetWithTitle> _pages = [
    Expenses(),
    Reports(),
    Add(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context){
     return Scaffold(
          body: _pages[_selectedIndex],
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          bottomNavigationBar: SafeArea(
            child: Container(
              height: 65,
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: BottomNavigationBar(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.payments_outlined, size: 30,),
                    label: 'Expenses',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart, size: 30),
                    label: 'Report',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.add, size: 39,),
                    label: 'Add',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.gear_solid, size: 30,),
                    label: 'Setting',
                  ),
                ],
                currentIndex: _selectedIndex,
                type: BottomNavigationBarType.fixed,
                showUnselectedLabels: true,
                selectedItemColor: CupertinoColors.activeBlue,
                unselectedItemColor: CupertinoColors.inactiveGray,
                selectedFontSize: 12,
                unselectedFontSize: 10,
                onTap: _onItemTapped,
              ),
            ),
          ),
      );
  }

}