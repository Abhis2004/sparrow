/// Utility to format any timestamp (ISO-8601 or 24-hour string) into a clean 12-hour format string (e.g., "10:32 PM")
String formatTo12HourTime(String? input) {
  if (input == null || input.trim().isEmpty) return '';
  final str = input.trim();

  // If it already contains AM or PM, return as is (normalized)
  if (str.toUpperCase().contains('AM') || str.toUpperCase().contains('PM')) {
    return str;
  }

  // Try parsing ISO-8601 DateTime (e.g. "2026-08-03T22:32:00.000Z")
  final parsed = DateTime.tryParse(str);
  if (parsed != null) {
    final local = parsed.toLocal();
    final hour = local.hour == 0 ? 12 : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  // Try parsing "HH:mm" or "HH:mm:ss" 24-hour time string
  try {
    final timeStr = str.contains('T') ? str.split('T').last : str;
    final cleanTime = timeStr.split('+').first.split('Z').first;
    final parts = cleanTime.split(':');
    if (parts.length >= 2) {
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1].split('.').first);
      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    }
  } catch (_) {}

  return str;
}
