import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsPage({Key? key, required this.onThemeChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"), // Titre de la barre d'application
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            // Commutateur pour activer/désactiver le mode sombre
            SwitchListTile(
              title: const Text("Mode Sombre"), // Texte du commutateur
              value: Theme.of(context).brightness ==
                  Brightness.dark, // Vérifie si le mode sombre est activé
              onChanged: (bool value) {
                onThemeChanged(value
                    ? ThemeMode.dark
                    : ThemeMode
                        .light); // Change le mode en fonction de la sélection
              },
            ),
          ],
        ),
      ),
    );
  }
}
