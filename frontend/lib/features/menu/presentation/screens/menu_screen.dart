import 'package:flutter/material.dart';

import '../../../../shared/data/mock_drinks.dart';
import '../../../../shared/widgets/drink_card.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Robot Barista")),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),

        itemCount: mockDrinks.length,

        itemBuilder: (context, index) {
          final drink = mockDrinks[index];

          return DrinkCard(drink: drink);
        },
      ),
    );
  }
}
