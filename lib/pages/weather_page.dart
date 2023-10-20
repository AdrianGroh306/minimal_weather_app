import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:minimal_weather_app/models/weather_model.dart';
import 'package:minimal_weather_app/pages/searchCity_page.dart';
import 'package:minimal_weather_app/service/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  //api key
  final _weatherService = WeatherService("82c825395cb3189ccb54a4f12e4b6851");
  Weather? _weather;

  //fetch weather
  _fetchWeather() async {
    //get curent city
    String cityName = await _weatherService.getCurrentCity();

    //get weather for city
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  //weather animation
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) {
      return "assets/sun_animation.json";
    }

    switch (mainCondition.toLowerCase()) {
      case "clouds":
      case "mist":
      case "smoke":
      case "haze":
      case "dust":
      case "fog":
        return "assets/weather_mist_animation.json";
      case "rain":
      case "drizzle":
      case "shower rain":
      case "thunderstorm":
        return "assets/storm_animation.json";
      case "clear":
        return "assets/sun_animation.json";
      default:
        return "assets/sun_animation.json";
    }
  }
  List<Weather> weeklyForecast = [
    // Dummy-Daten für eine Woche
    Weather(temperature: 22, mainCondition: "clear", cityName: ''),
    Weather(temperature: 24, mainCondition: "rain", cityName: ''),
    Weather(temperature: 20, mainCondition: "clouds", cityName: ''),
    Weather(temperature: 23, mainCondition: "clear", cityName: ''),
    Weather(temperature: 25, mainCondition: "rain", cityName: ''),
    Weather(temperature: 22, mainCondition: "clouds", cityName: ''),
    Weather(temperature: 21, mainCondition: "clear", cityName: ''),
  ];


  //init state
  @override
  void initState() {
    super.initState();
    //fetch weather on startup
    _fetchWeather();
  }

  _fetchWeatherForCity(String cityName) async {
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }
  String getDayOfWeek(int index) {
    final DateTime today = DateTime.now();
    final DateTime dayWanted = today.add(Duration(days: index));
    final List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

    return days[dayWanted.weekday - 1];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[900],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(width: 25,),
            //city name
            Expanded(  // add this to make sure the text widget does not overflow
              child: Text(
                _weather?.cityName ?? "loading city..",
                style: const TextStyle(
                    fontSize: 20, color: Colors.white, fontFamily: "Arial"),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final selectedCity = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchCityPage(
                        weatherService: _weatherService,
                      )),
                );
                if (selectedCity != null) {
                  // Wetter für die ausgewählte Stadt abrufen
                  _fetchWeatherForCity(selectedCity);
                }
              },
            )
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),

            //animation
            Lottie.asset(getWeatherAnimation(_weather?.mainCondition),width: 200),
            const SizedBox(
              height: 25,
            ),
            // temp
            Text(
              "${_weather?.temperature.round()}°",
              style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: weeklyForecast.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final dayWeather = weeklyForecast[index];
                  return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.grey[850],
                    child: ListTile(contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 20),
                      leading: const Icon(
                        Icons.wb_sunny, // Ersetzen Sie durch das passende Wetter-Icon basierend auf der Bedingung
                        color: Colors.white,
                      ),
                      title: Text(
                        getDayOfWeek(index), // Diese Funktion gibt den Wochentag zurück
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        "${dayWeather.temperature.round()}°", // Temperatur ohne Dezimalstellen
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
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
