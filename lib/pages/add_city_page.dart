import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class AddCityPage extends StatefulWidget {
  const AddCityPage({super.key});

  @override
  _AddCityPageState createState() => _AddCityPageState();
}

class _AddCityPageState extends State<AddCityPage> {
  final TextEditingController _controller = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  String? _errorMessage;

  void _addCity() async {
    final cityName = _controller.text;
    try {
      await _weatherService.getWeather(cityName);
      Navigator.pop(context, cityName);
    } catch (e) {
      setState(() {
        _errorMessage = 'City not found';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add City'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'City Name',
                errorText: _errorMessage,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCity,
              child: Text('Add City'),
            ),
          ],
        ),
      ),
    );
  }
}