import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:minimal_weather_app/models/weather_model.dart';
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
  String getWeatherAnimation(String? mainCondition){
    if(mainCondition == null){
      return "assets/sun_animation.json";
    }

    switch(mainCondition.toLowerCase()){
      case "clouds":
      case "mist":
      case "smoke":
      case "haze":
      case "dust":
      case "fog": return "assets/weather_mist_animation.json";
      case "rain":
      case "drizzle":
      case "shower rain":
      case "thunderstorm": return "assets/storm_animation.json";
      case "clear": return "assets/sun_animation.json";
      default:return "assets/sun_animation.json";

    }
  }

  //init state
  @override
  void initState() {
    super.initState();
    //fetch weather on startup
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 80,),
            const Icon(Icons.location_on,size: 40,color: Colors.white,),
            const SizedBox(height: 10,),
            //city name
            Text(_weather?.cityName ?? "loading city..",style: const TextStyle(fontSize: 20,color: Colors.white),),
            const SizedBox(height: 50,),
            //animation
            Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
            const SizedBox(height: 150,),
            // temp
            Text("${_weather?.temperature.round()}°",style: const TextStyle(fontSize: 50,fontWeight: FontWeight.bold,color: Colors.white),),

          ],
        ),
      ),
    );
  }
}
