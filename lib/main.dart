import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_page.dart';
import 'search_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = (prefs.getString('themeMode') == 'dark')
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'themeMode', themeMode == ThemeMode.dark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.redAccent,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red.shade900,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red.shade900,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.red.shade900,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.black,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade900,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
      ),
      themeMode: _themeMode,
      home: MyHomePage(
        themeMode: _themeMode,
        onThemeChanged: (newThemeMode) {
          setState(() {
            _themeMode = newThemeMode;
            _saveThemeMode(newThemeMode);
          });
        },
      ),
      routes: {
        '/settings': (context) => SettingsPage(onThemeChanged: (newThemeMode) {
              setState(() {
                _themeMode = newThemeMode;
                _saveThemeMode(newThemeMode);
              });
            }),
        '/search': (context) => const SearchPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const MyHomePage({
    Key? key,
    required this.themeMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int pokemonId = 1;
  bool isFetchingData = false;
  Map<String, dynamic> pokemonData = {};
  String pokemonDescription = "Chargement...";

  @override
  void initState() {
    super.initState();
    _fetchPokemonDetails();
  }

  Future<void> _fetchPokemonDetails() async {
    setState(() {
      isFetchingData = true;
    });

    try {
      final detailsResponse = await http
          .get(Uri.parse("https://pokebuildapi.fr/api/v1/pokemon/$pokemonId"));
      final descriptionResponse = await http.get(
          Uri.parse("https://pokeapi.co/api/v2/pokemon-species/$pokemonId"));

      if (detailsResponse.statusCode == 200 &&
          descriptionResponse.statusCode == 200) {
        final detailsData = convert.jsonDecode(detailsResponse.body);
        final descriptionData = convert.jsonDecode(descriptionResponse.body);

        final flavorText = descriptionData['flavor_text_entries']?.firstWhere(
              (entry) => entry['language']['name'] == 'fr',
              orElse: () => null,
            )?['flavor_text'] ??
            "Aucune description disponible en français.";

        setState(() {
          pokemonData = detailsData;
          pokemonDescription = flavorText;
        });
      }
    } catch (e) {
      setState(() {
        pokemonDescription = "Échec du chargement des données.";
      });
    } finally {
      setState(() {
        isFetchingData = false;
      });
    }
  }

  Widget _buildStatBar(String label, int value) {
    Color statBarColor;

    if (value >= 75) {
      statBarColor = Colors.green;
    } else if (value >= 50) {
      statBarColor = Colors.yellow;
    } else {
      statBarColor = Colors.redAccent;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 8,
              decoration: BoxDecoration(
                color: statBarColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LinearProgressIndicator(
                  value: value / 100,
                  color: statBarColor,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPokemonDetails() {
    if (pokemonData.isEmpty) {
      return const Center(child: Text('Aucune donnée disponible.'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  pokemonData['sprite'] ?? '',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Nom: ${pokemonData['name']}",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(
              "Type: ${pokemonData['apiTypes']?.first['name'] ?? 'Inconnu'}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildStatBar("HP   ", pokemonData['stats']['HP']),
            _buildStatBar("Attaque   ", pokemonData['stats']['attack']),
            _buildStatBar("Défense   ", pokemonData['stats']['defense']),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  pokemonDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: widget.themeMode == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedNavigationButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  pokemonId = (pokemonId > 1) ? pokemonId - 1 : pokemonId;
                  _fetchPokemonDetails();
                });
              },
              child: const Text('Précédent'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  pokemonId = pokemonId + 1;
                  _fetchPokemonDetails();
                });
              },
              child: const Text('Suivant'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          isFetchingData
              ? const Center(child: CircularProgressIndicator())
              : _buildPokemonDetails(),
          _buildFixedNavigationButtons(),
        ],
      ),
    );
  }
}
