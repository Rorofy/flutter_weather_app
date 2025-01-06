import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CityInfoPage extends StatefulWidget {
  final String cityName;

  const CityInfoPage({super.key, required this.cityName});

  @override
  _CityInfoPageState createState() => _CityInfoPageState();
}

class _CityInfoPageState extends State<CityInfoPage> {
  late WeatherFactory wf;
  Weather? _weather;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    wf = WeatherFactory(dotenv.env['API_KEY']!);
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      Weather weather = await wf.currentWeatherByCityName(widget.cityName);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load weather data: $e';
        _isLoading = false;
      });
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
                        '${_weather!.temperature?.celsius?.toStringAsFixed(1)}°C',
                        style: TextStyle(fontSize: 48),
                      ),
                      SizedBox(height: 20),
                      Text(
                        _weather!.weatherDescription ?? '',
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 20),
                      Icon(
                        Icons.wb_sunny, // You can use different icons based on weather condition
                        size: 48,
                      ),
                    ],
                  ),
      ),
    );
  }
}