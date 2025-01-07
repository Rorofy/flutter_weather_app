import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';

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

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('hh:mm a').format(date);
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
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Weather in ${widget.cityName}',
                          style: TextStyle(fontSize: 20),
                        ).padding(bottom: 8),
                        Text(
                          '${_weatherData!['main']['temp']}°C',
                          style: TextStyle(fontSize: 40),
                        ).padding(bottom: 8),
                        Icon(
                          _getWeatherIcon(_weatherData!['weather'][0]['id']),
                          size: 40,
                        ).padding(bottom: 8),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 0.0,
                            crossAxisSpacing: 0.0,
                            childAspectRatio: 2,
                            children: [
                              _buildInfoTile('Feels like', '${_weatherData!['main']['feels_like']}°C'),
                              _buildInfoTile('Humidity', '${_weatherData!['main']['humidity']}%'),
                              _buildInfoTile('Wind speed', '${_weatherData!['wind']['speed']} m/s'),
                              _buildInfoTile('Pressure', '${_weatherData!['main']['pressure']} hPa'),
                              _buildInfoTile('Visibility', '${_weatherData!['visibility']} m'),
                              _buildInfoTile('Sunrise', _formatTime(_weatherData!['sys']['sunrise'])),
                              _buildInfoTile('Sunset', _formatTime(_weatherData!['sys']['sunset'])),
                              _buildInfoTile('Description', _weatherData!['weather'][0]['description']),
                            ],
                          ),
                        ),
                      ],
                    ).padding(all: 8),
                  ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ).padding(bottom: 2),
        Text(
          value,
          style: TextStyle(fontSize: 12),
        ),
      ],
    ).padding(all: 2);
  }
}