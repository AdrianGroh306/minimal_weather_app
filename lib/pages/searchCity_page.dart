import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/weather_service.dart';

class SearchCityPage extends StatefulWidget {
  final WeatherService weatherService;

  const SearchCityPage({Key? key, required this.weatherService}) : super(key: key);

  @override
  _SearchCityPageState createState() => _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  String? _searchTerm;
  WeatherService get _weatherService => widget.weatherService;

  final List<Map<String, String>> _allCities = [
    {'city': 'Berlin', 'country': 'Germany', 'flag': '🇩🇪'},
    {'city': 'Paris', 'country': 'France', 'flag': '🇫🇷'},
    {'city': 'London', 'country': 'UK', 'flag': '🇬🇧'},
    {'city': 'Rome', 'country': 'Italy', 'flag': '🇮🇹'},
  ];

  List<Map<String, String>> _searchResults = [];
  List<String> _previouslySelectedCities = [];
  List<String> _enteredCities = [];

  _loadPreviouslySelectedCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> previouslySelected = prefs.getStringList('selectedCities') ?? [];
    setState(() {
      _previouslySelectedCities = previouslySelected;
      _searchResults = _allCities.where((data) => previouslySelected.contains(data['city'])).toList();
    });
  }

  _addCityToSelected(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currentSelected = prefs.getStringList('selectedCities') ?? [];
    if (!currentSelected.contains(city)) {
      currentSelected.add(city);
      await prefs.setStringList('selectedCities', currentSelected);
    }
  }

  _updateSearchResults(String query) {
    if (query.isEmpty) {
      _loadPreviouslySelectedCities();
    } else {
      _searchResults = _allCities
          .where((data) => data['city']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPreviouslySelectedCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: TextField(
          onSubmitted: (value) {
            if (value.isNotEmpty && !_enteredCities.contains(value)) {
              setState(() {
                _enteredCities.add(value);
              });
            }
          },
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _searchTerm = value;
              _updateSearchResults(value);
            });
          },
          decoration: const InputDecoration(
            hintText: 'City search...',
            hintStyle: TextStyle(color: Colors.grey),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _previouslySelectedCities.length,
              itemBuilder: (context, index) {
                final cityData = _allCities.firstWhere(
                        (data) => data['city'] == _previouslySelectedCities[index],
                    orElse: () => {'city': '', 'country': '', 'flag': ''});
                if (cityData['city']!.isEmpty) return const SizedBox.shrink();

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  color: Colors.grey[800],
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Text(cityData['flag']!, style: const TextStyle(fontSize: 24.0)),
                    title: Text(cityData['city']!),
                    subtitle: Text(cityData['country']!),
                    onTap: () {
                      Navigator.pop(context, cityData['city']!);
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _enteredCities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_enteredCities[index]),
                  onTap: () {
                    _addCityToSelected(_enteredCities[index]);
                    Navigator.pop(context, _enteredCities[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
