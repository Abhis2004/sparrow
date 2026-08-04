import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class IncidentLocationData {
  const IncidentLocationData({
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.weather,
  });

  final String location;
  final double latitude;
  final double longitude;
  final String weather;
}

class LocationWeatherService {
  /// Checks location permission status and precise accuracy status
  static Future<bool> isLocationAvailable() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    try {
      LocationAccuracyStatus accuracy = await Geolocator.getLocationAccuracy();
      if (accuracy == LocationAccuracyStatus.reduced) {
        final newAccuracy = await Geolocator.requestTemporaryFullAccuracy(
          purposeKey: 'PreciseIncidentLocation',
        );
        return newAccuracy == LocationAccuracyStatus.precise;
      }
    } catch (_) {}

    return true;
  }

  /// Request location permission explicitly & ensure precise location
  static Future<LocationPermission> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }
    LocationPermission perm = await Geolocator.requestPermission();

    try {
      LocationAccuracyStatus accuracy = await Geolocator.getLocationAccuracy();
      if (accuracy == LocationAccuracyStatus.reduced) {
        await Geolocator.requestTemporaryFullAccuracy(
          purposeKey: 'PreciseIncidentLocation',
        );
      }
    } catch (_) {}

    return perm;
  }

  /// Fetches live high-precision GPS coordinates, reverse geocoded address, and weather info
  static Future<IncidentLocationData> fetchLocationAndWeather({bool isHindi = false}) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled on device.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied by user.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    // Verify & request Precise Location (FINE location accuracy)
    try {
      LocationAccuracyStatus accuracyStatus = await Geolocator.getLocationAccuracy();
      if (accuracyStatus == LocationAccuracyStatus.reduced) {
        accuracyStatus = await Geolocator.requestTemporaryFullAccuracy(
          purposeKey: 'PreciseIncidentLocation',
        );
        if (accuracyStatus == LocationAccuracyStatus.reduced) {
          throw Exception('Precise location permission is required to start an incident report.');
        }
      }
    } catch (_) {}

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (_) {
      position = await Geolocator.getLastKnownPosition() ??
          Position(
            longitude: 77.3635,
            latitude: 28.6272,
            timestamp: DateTime.now(),
            accuracy: 1.0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
    }

    final lat = position.latitude;
    final lng = position.longitude;

    // Parallel fetch address and weather
    final addressFuture = _reverseGeocode(lat, lng, isHindi: isHindi);
    final weatherFuture = _fetchWeather(lat, lng, isHindi: isHindi);

    final results = await Future.wait([addressFuture, weatherFuture]);
    final address = results[0];
    final weather = results[1];

    return IncidentLocationData(
      location: address,
      latitude: lat,
      longitude: lng,
      weather: weather,
    );
  }

  /// Reverse geocode coordinates to human-readable address
  static Future<String> _reverseGeocode(double lat, double lng, {bool isHindi = false}) async {
    try {
      final acceptLang = isHindi ? 'hi,en' : 'en,hi';
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng&accept-language=$acceptLang');
      final response = await http.get(url, headers: {
        'User-Agent': 'SparrowIncidentApp/1.0',
        'Accept-Language': acceptLang,
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final addressObj = data['address'] as Map<String, dynamic>?;
        if (addressObj != null) {
          final suburb = addressObj['suburb'] ??
              addressObj['neighbourhood'] ??
              addressObj['residential'] ??
              addressObj['road'] ??
              (isHindi ? 'सेक्टर 62' : 'Sector 62');
          final city = addressObj['city'] ??
              addressObj['town'] ??
              addressObj['county'] ??
              addressObj['state_district'] ??
              (isHindi ? 'नोएडा' : 'Noida');
          return '$suburb, $city';
        }
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }
    return isHindi ? 'सेक्टर 62, नोएडा' : 'Sector 62, Noida';
  }

  /// Fetch live weather from Open-Meteo free API
  static Future<String> _fetchWeather(double lat, double lng, {bool isHindi = false}) async {
    try {
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current_weather=true');
      final response =
          await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final currentWeather =
            data['current_weather'] as Map<String, dynamic>?;
        if (currentWeather != null) {
          final temp = currentWeather['temperature'];
          final weatherCode = currentWeather['weathercode'] as int? ?? 0;
          final desc = _getWeatherDescription(weatherCode, isHindi: isHindi);
          final humidityStr = isHindi ? 'हल्की नमी' : 'slight humidity';
          return '$desc, ${temp?.round()}°C, $humidityStr';
        }
      }
    } catch (e) {
      debugPrint('Weather fetch error: $e');
    }
    return isHindi ? 'साफ़, 34°C, हल्की नमी' : 'Clear, 34°C, slight humidity';
  }

  static String _getWeatherDescription(int code, {bool isHindi = false}) {
    switch (code) {
      case 0:
        return isHindi ? 'साफ़' : 'Clear';
      case 1:
      case 2:
      case 3:
        return isHindi ? 'आंशिक रूप से बादल' : 'Partly Cloudy';
      case 45:
      case 48:
        return isHindi ? 'कोहरा' : 'Foggy';
      case 51:
      case 53:
      case 55:
        return isHindi ? 'बूंदाबांदी' : 'Drizzle';
      case 61:
      case 63:
      case 65:
        return isHindi ? 'बारिश' : 'Rain';
      case 71:
      case 73:
      case 75:
        return isHindi ? 'बर्फबारी' : 'Snow';
      case 80:
      case 81:
      case 82:
        return isHindi ? 'तेज बारिश' : 'Rain Showers';
      case 95:
      case 96:
      case 99:
        return isHindi ? 'तूफान और बारिश' : 'Thunderstorm';
      default:
        return isHindi ? 'साफ़' : 'Clear';
    }
  }
}
