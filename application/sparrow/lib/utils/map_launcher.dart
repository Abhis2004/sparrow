import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  MapLauncher._();

  /// Launches native map app on Android/iOS, or Google Maps in browser for web/desktop.
  static Future<void> openMap({
    required double latitude,
    required double longitude,
    String? title,
  }) async {
    final String query =
        (title != null && title.isNotEmpty) ? title : '$latitude,$longitude';

    final Uri geoUrl = Uri.parse(
      'geo:$latitude,$longitude?q=$latitude,$longitude(${Uri.encodeComponent(query)})',
    );

    final Uri appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?ll=$latitude,$longitude&q=${Uri.encodeComponent(query)}',
    );

    final Uri googleMapsWebUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        if (await canLaunchUrl(geoUrl)) {
          await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
          return;
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        if (await canLaunchUrl(appleMapsUrl)) {
          await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
          return;
        }
      }

      // Universal fallback: launch Google Maps Web
      await launchUrl(googleMapsWebUrl, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(googleMapsWebUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Error launching map: $e');
      }
    }
  }
}

