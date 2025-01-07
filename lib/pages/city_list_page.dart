import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:styled_widget/styled_widget.dart';
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
  bool _isLoadingLocation = true;
  String? _currentLocationCity;

  @override
  void initState() {
    super.initState();
    _loadCities();
    _addCurrentLocationCity();
  }

  Future<void> _loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? cities = prefs.getStringList('cities');
    if (cities != null) {
      setState(() {
        _cities.addAll(cities);
      });
    }
  }

  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('cities', _cities);
  }

  Future<void> _addCurrentLocationCity() async {
    try {
      Position position = await _determinePosition();
      final weatherData = await _weatherService.getWeatherByCoordinates(position.latitude, position.longitude);
      final cityName = weatherData['name'];
      if (!_cities.contains(cityName)) {
        setState(() {
          _cities.add(cityName);
          _currentLocationCity = cityName;
          _isLoadingLocation = false;
        });
        _saveCities();
      } else {
        setState(() {
          _currentLocationCity = cityName;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _addCity(String cityName) {
    if (!_cities.contains(cityName)) {
      setState(() {
        _cities.add(cityName);
      });
      _saveCities();
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
        title: Text('Weather App'),
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
            child: _isLoadingLocation
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _cities.isEmpty
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
                                  subtitle: Text(
                                    '${weatherData['main']['temp']}°C${cityName == _currentLocationCity ? ' (Current Location)' : ''}',
                                  ),
                                  trailing: Icon(_getWeatherIcon(weatherData['weather'][0]['id'])),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CityInfoPage(cityName: cityName),
                                      ),
                                    );
                                  },
                                ).padding(all: 8).decorated(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ).padding(vertical: 4);
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ).padding(all: 16).backgroundColor(Colors.white),
    );
  }
}