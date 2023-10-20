import 'package:flutter/material.dart';

import '../service/weather_service.dart';

class SearchCityPage extends StatefulWidget {
  final WeatherService weatherService;

  const SearchCityPage({super.key,required this.weatherService});


  @override
  _SearchCityPageState createState() => _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  String? _searchTerm;
  WeatherService get _weatherService => widget.weatherService;

  // Liste mit Suchergebnissen (hier nur beispielhaft)
  List<String> _searchResults = [];
  _updateSearchResults(String query) {
    // Simuliere die Ergebnisse, hier können Sie eine echte API verwenden
    _searchResults = ['Berlin', 'Hamburg', 'München', 'Köln'].where((city) => city.toLowerCase().contains(query.toLowerCase())).toList();

    // Fügen Sie den aktuellen Standort an den Anfang der Liste hinzu
    _searchResults.insert(0, 'Aktueller Standort');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.grey[900],
      appBar: AppBar(backgroundColor: Colors.grey[900],
        title: TextField(
          onChanged: (value) {
            setState(() {
              _searchTerm = value;
              _updateSearchResults(value);
            });
          },
          decoration: const InputDecoration(hintText: 'Stadt suchen...',),
        ),
      ),
      body: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_searchResults[index]),
            onTap: () {
              if (_searchResults[index] == 'Aktueller Standort') {
                _weatherService.getCurrentCity().then((city) {
                  Navigator.pop(context, city);
                });
              } else {
                Navigator.pop(context, _searchResults[index]);
              }
            },
          );
        },
      ),
    );
  }

}
