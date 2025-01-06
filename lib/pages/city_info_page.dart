import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import '../services/weather_service.dart';

class CityInfoPage extends StatefulWidget {
  final String cityName;

  const CityInfoPage({super.key, required this.cityName});

  @override
  _CityInfoPageState createState() => _CityInfoPageState();
}

class _CityInfoPageState extends State<CityInfoPage> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final weatherData = await _weatherService.getWeather(widget.cityName);
      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load weather data: $e';
        _isLoading = false;
      });
    }
  }

  IconData _getWeatherIcon(int condition) {
    if (condition < 300) {
      return WeatherIcons.thunderstorm;
    } else if (condition < 400) {
      return WeatherIcons.showers;
    } else if (condition < 600) {
      return WeatherIcons.rain;
    } else if (condition < 700) {
      return WeatherIcons.snow;
    } else if (condition < 800) {
      return WeatherIcons.fog;
    } else if (condition == 800) {
      return WeatherIcons.day_sunny;
    } else if (condition <= 804) {
      return WeatherIcons.cloudy;
    } else {
      return WeatherIcons.na;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('City Info'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _errorMessage != null
                ? Text(_errorMessage!)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Weather in ${widget.cityName}',
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '${_weatherData!['main']['temp']}°C',
                        style: TextStyle(fontSize: 48),
                      ),
                      SizedBox(height: 20),
                      Text(
                        _weatherData!['weather'][0]['description'],
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 20),
                      Icon(
                        _getWeatherIcon(_weatherData!['weather'][0]['id']),
                        size: 48,
                      ),
                    ],
                  ),
      ),
    );
  }
}