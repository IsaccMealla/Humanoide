import 'package:flutter/material.dart';

import '../../../menu/presentation/screens/menu_screen.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../robot/presentation/screens/robot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const MenuScreen(),
    const OrdersScreen(),
    const RobotScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(icon: Icon(Icons.coffee), label: "Menu"),

          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: "Pedidos",
          ),

          NavigationDestination(icon: Icon(Icons.smart_toy), label: "Robot"),
        ],
      ),
    );
  }
}
