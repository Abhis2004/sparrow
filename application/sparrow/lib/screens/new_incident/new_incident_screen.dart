import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../app/colors.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../services/location_weather_service.dart';
import '../home/home_service.dart';
import '../home/model/home_model.dart';
import '../incidents/incidents_provider.dart';
import '../timeline/timeline_model.dart';
import '../timeline/timeline_provider.dart';

class NewIncidentScreen extends ConsumerStatefulWidget {
  const NewIncidentScreen({super.key});

  @override
  ConsumerState<NewIncidentScreen> createState() => _NewIncidentScreenState();
}

class _NewIncidentScreenState extends ConsumerState<NewIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController(text: '');
  final _summaryController = TextEditingController();

  // Speech-to-text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;
  String _voiceLocaleId = 'hi_IN'; // Voice language independent of app language

  // Location & Weather state
  bool _isLoadingLocation = true;
  bool _hasLocationPermission = false;
  String? _locationPermissionError;

  String _fetchedLocation = 'Sector 62, Noida';
  double _latitude = 28.6272;
  double _longitude = 77.3635;
  String _fetchedWeather = 'Clear, 34°C, slight humidity';

  String _station = 'Sector 18, Noida';
  String _district = 'Gautam Budh Nagar';
  String _state = 'Uttar Pradesh';

  // Officer info
  AssignedOfficer _officer = const AssignedOfficer(
    id: 'off_104',
    badgeNumber: 'UP-GBN-8821',
    name: 'Rahul Sharma',
    designation: 'Sub Inspector',
    station: 'Sector 18, Noida',
    phone: '+91-9454403812',
  );

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    _loadOfficerProfileStation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndFetchLocation();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _loadOfficerProfileStation() async {
    try {
      final officerProfile = await ref.read(homeServiceProvider).fetchOfficerProfile();
      if (mounted) {
        setState(() {
          if (officerProfile.station.isNotEmpty) _station = officerProfile.station;
          if (officerProfile.district.isNotEmpty) _district = officerProfile.district;
          if (officerProfile.state.isNotEmpty) _state = officerProfile.state;

          _officer = AssignedOfficer(
            id: 'off_104',
            badgeNumber: 'UP-GBN-8821',
            name: officerProfile.name.isNotEmpty ? officerProfile.name : 'Officer',
            designation: officerProfile.designation.isNotEmpty ? officerProfile.designation : 'Police Officer',
            station: _station,
            phone: '+91-9454403812',
          );
        });
      }
    } catch (_) {}
  }

  void _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onError: (val) => setState(() => _isListening = false),
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
      );
      if (mounted) {
        setState(() {
          _speechAvailable = available;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _speechAvailable = false;
        });
      }
    }
  }

  Future<void> _checkAndFetchLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationPermissionError = null;
    });

    try {
      final currentLang = ref.read(languageProvider);
      final isHindi = currentLang == AppLanguage.hindi;

      final locData = await LocationWeatherService.fetchLocationAndWeather(isHindi: isHindi);
      if (!mounted) return;
      setState(() {
        _fetchedLocation = locData.location;
        _latitude = locData.latitude;
        _longitude = locData.longitude;
        _fetchedWeather = locData.weather;
        _hasLocationPermission = true;
        _isLoadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasLocationPermission = false;
        _locationPermissionError = e.toString().replaceAll('Exception: ', '');
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    await LocationWeatherService.requestLocationPermission();
    await _checkAndFetchLocation();
  }

  void _showEditJurisdictionDialog() {
    final loc = AppLocalizations.of(context);
    final dialogFormKey = GlobalKey<FormState>();
    final stationCtrl = TextEditingController(text: _station);
    final districtCtrl = TextEditingController(text: _district);
    final stateCtrl = TextEditingController(text: _state);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  loc.text('edit_jurisdiction'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: stationCtrl,
                  decoration: InputDecoration(
                    labelText: '${loc.text('police_station')} *',
                    prefixIcon: const Icon(Icons.local_police_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return loc.text('enter_station');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: districtCtrl,
                  decoration: InputDecoration(
                    labelText: '${loc.text('district')} *',
                    prefixIcon: const Icon(Icons.map_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return loc.text('enter_district');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: stateCtrl,
                  decoration: InputDecoration(
                    labelText: '${loc.text('state')} *',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return loc.text('enter_state');
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(loc.text('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (!dialogFormKey.currentState!.validate()) return;
                setState(() {
                  _station = stationCtrl.text.trim();
                  _district = districtCtrl.text.trim();
                  _state = stateCtrl.text.trim();
                });
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(loc.text('save')),
            ),
          ],
        );
      },
    );
  }

  void _toggleListening() async {
    if (!_speechAvailable) {
      _initSpeech();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition initializing. Please try again in a moment.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      final initialText = _summaryController.text.trim();

      setState(() => _isListening = true);
      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(localeId: _voiceLocaleId),
        onResult: (result) {
          final recognized = result.recognizedWords;
          if (recognized.isNotEmpty) {
            final newText = initialText.isEmpty
                ? recognized
                : '$initialText $recognized';
            setState(() {
              _summaryController.text = newText;
              _summaryController.selection = TextSelection.fromPosition(
                TextPosition(offset: newText.length),
              );
            });
          }
        },
      );
    }
  }

  void _submitForm() async {
    if (!_hasLocationPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is mandatory to start an incident report.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    final loc = AppLocalizations.of(context);

    setState(() {
      _isSaving = true;
    });

    final now = DateTime.now();
    final timeStr = _formatTime(now);
    final dateStr = _formatDate(now);
    final newId = 'inc_${now.millisecondsSinceEpoch.toString().substring(7)}';
    final summaryText = _summaryController.text.trim();
    final categoryText = _categoryController.text.trim().isEmpty
        ? loc.text('general_crime')
        : _categoryController.text.trim();
    IncidentCategory catEnum;
    final lowerCat = categoryText.toLowerCase();
    if (lowerCat.contains('theft') || lowerCat.contains('चोरी')) {
      catEnum = IncidentCategory.theft;
    } else if (lowerCat.contains('vehicle') || lowerCat.contains('वाहन')) {
      catEnum = IncidentCategory.vehicle;
    } else if (lowerCat.contains('assault') || lowerCat.contains('हमला')) {
      catEnum = IncidentCategory.assault;
    } else {
      catEnum = IncidentCategory.general;
    }

    // 1. Create root Incident for list view
    final newIncident = Incident(
      id: newId,
      incidentName: _nameController.text.trim(),
      location: _fetchedLocation,
      startedAt: timeStr,
      startedDate: dateStr,
      status: IncidentStatus.active, // Active by default
      category: catEnum,
      rawStatus: 'active',
      rawCategory: categoryText,
      observationCount: 0,
      victimCount: 0,
      witnessCount: 0,
      suspectCount: 0,
    );

    // 2. Create IncidentOverview
    final overview = IncidentOverview(
      id: newId,
      incidentName: _nameController.text.trim(),
      location: _fetchedLocation,
      gps: GpsLocation(latitude: _latitude, longitude: _longitude),
      startedAt: timeStr,
      startedDate: dateStr,
      completedAt: '', // blank at start
      completedDate: '', // blank at start
      status: IncidentStatus.active,
      category: catEnum,
      rawStatus: 'active',
      rawCategory: categoryText,
      weather: _fetchedWeather,
      station: _station,
      district: _district,
      state: _state,
      summary: summaryText,
      observationCount: 0,
      victimCount: 0,
      witnessCount: 0,
      suspectCount: 0,
    );

    // 3. Initial Timeline Event with event_type: "case_brief"
    final initialTimelineEvent = TimelineEvent(
      timelineId: 'tl_001',
      timestamp: now.toIso8601String(),
      eventType: 'case_brief',
      personId: _officer.id,
      referenceId: '',
      evidenceIds: const [],
      gps: GpsLocation(latitude: _latitude, longitude: _longitude),
    );

    // 4. Create full TimelineDetails
    final timelineDetails = TimelineDetails(
      incident: overview,
      officer: _officer,
      victims: const [],
      witnesses: const [],
      suspects: const [],
      officerObservations: const [],
      evidence: const [],
      timeline: [initialTimelineEvent],
    );

    // Save to providers and Isar DB
    await ref.read(timelineMapNotifierProvider.notifier).saveTimelineDetails(newId, timelineDetails);
    await ref.read(allIncidentsProvider.notifier).addIncident(newIncident);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text('${loc.text('incident_logged_success')} ("${newIncident.incidentName}")'),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate to the newly created incident's timeline
    context.push('/timeline/${newIncident.id}');
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(loc.text('new_incident')),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.assignment_add,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.text('initial_incident_report'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.text('log_essential_details'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mandatory Location Permission Alert Banner if not granted
            if (!_hasLocationPermission) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.gpp_bad_rounded, color: AppColors.error, size: 24),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Location Access Mandatory',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (_isLoadingLocation)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _locationPermissionError ??
                          'Police officers are required to enable location services and grant location permissions to log new incident reports.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _requestLocationPermission,
                        icon: const Icon(Icons.my_location, size: 18),
                        label: const Text('Enable & Grant Location Permission'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Incident Name Field (Police Add This)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: loc.text('incident_title_type').replaceAll(' *', ''),
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: loc.text('incident_title_hint'),
                prefixIcon: const Icon(Icons.description_outlined),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return loc.text('enter_incident_title');
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Category Field (Police Type This)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: loc.text('category'),
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                hintText: loc.text('category_hint'),
                prefixIcon: const Icon(Icons.category_outlined),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return loc.text('enter_category');
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'theft_crime',
                  'assault_crime',
                  'vehicle_crime',
                  'cyber_crime',
                  'fraud_crime',
                  'general_crime',
                ].map((catKey) {
                  final localizedLabel = loc.text(catKey);
                  final isSelected =
                      _categoryController.text.trim().toLowerCase() == localizedLabel.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(localizedLabel, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _categoryController.text = localizedLabel;
                          });
                        }
                      },
                      selectedColor: colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // Automatically Fetched Location & GPS Card
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: loc.text('location'),
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _hasLocationPermission
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _fetchedLocation,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                loc.text('auto_fetched'),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'GPS: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    onPressed: _checkAndFetchLocation,
                    tooltip: 'Refresh Location & Weather',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Weather & Jurisdiction Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              loc.text('weather').toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const Text(
                              ' *',
                              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.orange),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _fetchedWeather,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 38,
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _showEditJurisdictionDialog,
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                loc.text('jurisdiction').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const Text(
                                ' *',
                                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.edit_outlined,
                                size: 12,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_station, $_district',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Incident Summary Field + Speech-to-Text Mic Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: loc.text('brief_summary_remarks'),
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (_isListening)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.mic, size: 12, color: AppColors.error),
                              SizedBox(width: 4),
                              Text(
                                'Listening...',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('हिंदी', style: TextStyle(fontSize: 11)),
                            selected: _voiceLocaleId == 'hi_IN',
                            onSelected: (selected) {
                              if (selected) setState(() => _voiceLocaleId = 'hi_IN');
                            },
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            selectedColor: colorScheme.primary,
                            labelStyle: TextStyle(
                              color: _voiceLocaleId == 'hi_IN' ? Colors.white : colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 2),
                          ChoiceChip(
                            label: const Text('English', style: TextStyle(fontSize: 11)),
                            selected: _voiceLocaleId == 'en_IN',
                            onSelected: (selected) {
                              if (selected) setState(() => _voiceLocaleId = 'en_IN');
                            },
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            selectedColor: colorScheme.primary,
                            labelStyle: TextStyle(
                              color: _voiceLocaleId == 'en_IN' ? Colors.white : colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _summaryController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: loc.text('summary_field_hint'),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: _isListening
                        ? AppColors.error
                        : colorScheme.primary.withValues(alpha: 0.12),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: _isListening ? Colors.white : colorScheme.primary,
                        size: 20,
                      ),
                      onPressed: _toggleListening,
                      tooltip: _isListening ? 'Stop Recording' : 'Voice Record Brief',
                    ),
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return loc.text('enter_summary');
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        loc.text('create_and_open_file'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}