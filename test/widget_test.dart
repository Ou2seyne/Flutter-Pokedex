import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart'; // Make sure this import is correct
import 'package:myapp/search_page.dart';

void main() {
  testWidgets('Sheare Pokémon Page displays correct content',
      (WidgetTester tester) async {
    // Build the ShearePage widget with sample data
    await tester.pumpWidget(
      MaterialApp(
        home: ShearePage(
          pokemonName: 'Pikachu', // Correctly pass the Pokémon name
          description:
              'Electric-type Pokémon', // Correctly pass the description
          imageUrl:
              'https://pokeapi.co/media/sprites/pokemon/25.png', // Add a sample image URL
        ),
      ),
    );

    // Verify that the Pokémon name is displayed
    expect(find.text('Pikachu'), findsOneWidget);

    // Verify that the description is displayed
    expect(find.text('Electric-type Pokémon'), findsOneWidget);
  });
}
