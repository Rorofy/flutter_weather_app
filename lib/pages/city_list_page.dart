import 'package:flutter/material.dart';
import 'city_info_page.dart';
import 'add_city_page.dart';
import '../services/weather_service.dart';
import 'package:weather_icons/weather_icons.dart';

class CityListPage extends StatefulWidget {
  const CityListPage({super.key});

  @override
  _CityListPageState createState() => _CityListPageState();
}

class _CityListPageState extends State<CityListPage> {
  final List<String> _cities = [];
  final WeatherService _weatherService = WeatherService();

  void _addCity(String cityName) {
    setState(() {
      _cities.add(cityName);
    });
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
        title: Text('City List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final cityName = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCityPage()),
              );
              if (cityName != null) {
                _addCity(cityName);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _cities.isEmpty
                ? Center(
                    child: Text('No cities added yet.'),
                  )
                : ListView.builder(
                    itemCount: _cities.length,
                    itemBuilder: (context, index) {
                      final cityName = _cities[index];
                      return FutureBuilder(
                        future: _weatherService.getWeather(cityName),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return ListTile(
                              title: Text(cityName),
                              subtitle: Text('Loading...'),
                            );
                          } else if (snapshot.hasError) {
                            return ListTile(
                              title: Text(cityName),
                              subtitle: Text('Error loading weather'),
                            );
                          } else {
                            final weatherData = snapshot.data as Map<String, dynamic>;
                            return ListTile(
                              title: Text(cityName),
                              subtitle: Text('${weatherData['main']['temp']}°C'),
                              trailing: Icon(_getWeatherIcon(weatherData['weather'][0]['id'])),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CityInfoPage(cityName: cityName),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                final cityName = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCityPage()),
                );
                if (cityName != null) {
                  _addCity(cityName);
                }
              },
              child: Text('Add City'),
            ),
          ),
        ],
      ),
    );
  }
}