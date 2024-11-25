import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PokemonDetailPage extends StatefulWidget {
  final int pokemonId;

  const PokemonDetailPage({Key? key, required this.pokemonId})
      : super(key: key);

  @override
  _PokemonDetailPageState createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic> _pokemonDetails = {};
  String _pokemonDescription = "Chargement..."; // "Loading..." en français
  String _pokemonName = "Chargement..."; // "Loading..." en français

  @override
  void initState() {
    super.initState();
    _fetchPokemonDetails(widget.pokemonId);
  }

  Future<void> _fetchPokemonDetails(int pokemonId) async {
    setState(() {
      _isLoading = true;
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
            "Aucune description disponible en français."; // Traduction de "No description available in French."

        setState(() {
          _pokemonDetails = detailsData;
          _pokemonDescription = flavorText;
          _pokemonName = detailsData['name'];
        });
      } else {
        setState(() {
          _pokemonDescription =
              "Échec du chargement des données Pokémon."; // Traduction de "Failed to load Pokémon data."
        });
      }
    } catch (e) {
      setState(() {
        _pokemonDescription =
            "Erreur de chargement des données. Veuillez réessayer plus tard."; // Traduction de "Error loading data. Please try again later."
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Construire une barre de statistiques avec un changement de couleur en fonction de la valeur
  Widget _buildStatBar(String label, int value) {
    Color statBarColor;

    // Changer la couleur en fonction de la valeur des statistiques
    if (value >= 75) {
      statBarColor = Colors.green;
    } else if (value >= 50) {
      statBarColor = Colors.yellow;
    } else {
      statBarColor = Colors.redAccent;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: statBarColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPokemonDetails() {
    if (_pokemonDetails.isEmpty) {
      return const Center(
          child: Text(
              'Aucune donnée disponible.')); // Traduction de "No data available."
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ajouter de l'espace entre l'app bar et l'image
          const SizedBox(height: 16), // Ajuster l'espace ici

          // Image avec bordure
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple, width: 2),
              ),
              child: Image.network(
                _pokemonDetails['sprite'] ??
                    'https://example.com/default-image.png',
                height: 250,
                width: 250,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nom avec bordure
          Center(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple, width: 1),
              ),
              child: Text(
                "Nom: $_pokemonName",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Center(
            child: Text(
              "Type: ${_pokemonDetails['apiTypes']?.first['name'] ?? 'Inconnu'}", // Traduction de "Unknown"
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Statistiques :", // Traduction de "Stats:"
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          // Barres de statistiques avec bordures
          _buildStatBar("  PV   ", _pokemonDetails['stats']['HP'] ?? 0),
          _buildStatBar(
              "  Attaque   ", _pokemonDetails['stats']['attack'] ?? 0),
          _buildStatBar(
              "  Défense   ", _pokemonDetails['stats']['defense'] ?? 0),
          const SizedBox(height: 16),

          // Description avec fond coloré et centrée
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple, width: 2),
              ),
              child: Center(
                child: Text(
                  _pokemonDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon: $_pokemonName'),
        backgroundColor: Colors
            .deepPurple, // Même style de barre d'applications que dans main.dart
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPokemonDetails(),
    );
  }
}
