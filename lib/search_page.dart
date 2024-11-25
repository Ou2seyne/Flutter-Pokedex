import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'pokemon_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;

  // Fonction pour rechercher un Pokémon par nom
  void _searchPokemon(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions =
            []; // Si la recherche est vide, réinitialiser les suggestions
      });
      return;
    }

    setState(() {
      _isLoading = true; // Lancer le chargement
    });

    try {
      String url = "https://pokebuildapi.fr/api/v1/pokemon?name=$query";
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = convert.jsonDecode(response.body);
        var results = data as List;

        // Filtrer les résultats pour correspondre à la recherche
        var filteredResults = results
            .where((pokemon) => pokemon['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .take(10) // Limiter à 10 suggestions
            .toList();

        List<Map<String, dynamic>> suggestions = [];
        for (var pokemon in filteredResults) {
          suggestions.add({
            'name': pokemon['name'],
            'imageUrl': pokemon['image'],
            'id': pokemon['id'],
          });
        }

        setState(() {
          _suggestions = suggestions; // Mettre à jour les suggestions
        });
      } else {
        throw Exception('Échec du chargement des suggestions de Pokémon');
      }
    } catch (e) {
      print('Erreur de requête: $e');
      setState(() {
        _suggestions = []; // Réinitialiser les suggestions en cas d'erreur
      });
    } finally {
      setState(() {
        _isLoading = false; // Terminer le chargement
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Recherche de Pokémon'), // Titre de la barre d'application
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Champ de texte pour la recherche
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText:
                    'Rechercher un Pokémon', // Libellé du champ de recherche
                border: OutlineInputBorder(),
              ),
              onChanged:
                  _searchPokemon, // Appeler la fonction de recherche quand l'entrée change
            ),
            const SizedBox(height: 10),
            // Afficher un indicateur de chargement ou les résultats de la recherche
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _suggestions.isEmpty
                        ? const Center(
                            child: Text(
                                'Aucune suggestion trouvée')) // Message lorsque aucune suggestion n'est trouvée
                        : ListView.builder(
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(_suggestions[index]['name']),
                                trailing: Image.network(
                                  _suggestions[index]['imageUrl'],
                                  width: 50,
                                  height: 50,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PokemonDetailPage(
                                          pokemonId: _suggestions[index]['id']),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
