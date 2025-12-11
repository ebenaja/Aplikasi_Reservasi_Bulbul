import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Simple weather using wttr.in (no API key required)
  // location: city name or lat,lon
  final String baseUrl = 'https://wttr.in';

  /// Returns a Map with keys: 'temp_c' (String), 'condition' (String)
  /// or null on error.
  ///
  /// You can pass either a `location` string (city name) or `lat` and `lon` as coordinates.
  Future<Map<String, String>?> fetchWeather({String? location, double? lat, double? lon}) async {
    try {
      String query;
      if (lat != null && lon != null) {
        // wttr.in supports lat,lon as a location path
        query = '$lat,$lon';
      } else if (location != null && location.isNotEmpty) {
        query = Uri.encodeComponent(location);
      } else {
        // empty -> use IP-based location
        query = '';
      }

      final url = query.isEmpty ? Uri.parse('$baseUrl/?format=j1') : Uri.parse('$baseUrl/$query?format=j1');
      final resp = await http.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        final current = json['current_condition']?[0];
        if (current != null) {
          final tempC = current['temp_C']?.toString() ?? '';
          final condition = (current['weatherDesc'] != null && current['weatherDesc'] is List && current['weatherDesc'].isNotEmpty)
              ? current['weatherDesc'][0]['value']?.toString() ?? ''
              : '';
          return {
            'temp_c': tempC,
            'condition': condition,
          };
        }
      }
    } catch (e) {
      // ignore errors and return null
    }
    return null;
  }
}
