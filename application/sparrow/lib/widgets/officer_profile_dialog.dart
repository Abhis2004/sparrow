import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/colors.dart';
import '../core/localization/app_language.dart';
import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../screens/home/home_service.dart';
import '../screens/home/model/home_model.dart';

class OfficerProfileSetupDialog extends ConsumerStatefulWidget {
  const OfficerProfileSetupDialog({
    super.key,
    this.isMandatory = true,
  });

  /// If true, user cannot dismiss the dialog until all mandatory fields are filled.
  final bool isMandatory;

  static Future<void> show(BuildContext context, {bool isMandatory = true}) async {
    return showDialog(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (context) => OfficerProfileSetupDialog(isMandatory: isMandatory),
    );
  }

  @override
  ConsumerState<OfficerProfileSetupDialog> createState() =>
      _OfficerProfileSetupDialogState();
}

class _OfficerProfileSetupDialogState
    extends ConsumerState<OfficerProfileSetupDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _designationController;
  late TextEditingController _stationController;
  late TextEditingController _districtController;
  late TextEditingController _stateController;
  late TextEditingController _badgeNumberController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final currentProfile = ref.read(officerProfileProvider);

    _nameController = TextEditingController(text: currentProfile.name);
    _designationController =
        TextEditingController(text: currentProfile.designation);
    _stationController = TextEditingController(text: currentProfile.station);
    _districtController = TextEditingController(text: currentProfile.district);
    _stateController = TextEditingController(text: currentProfile.state);
    _badgeNumberController =
        TextEditingController(text: currentProfile.badgeNumber.toUpperCase());
    _phoneController = TextEditingController(text: currentProfile.phone);

    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _stationController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _badgeNumberController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _initialLetter {
    final text = _nameController.text.trim();
    return text.isNotEmpty ? text[0].toUpperCase() : 'O';
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newProfile = OfficerProfile(
        name: _nameController.text.trim(),
        designation: _designationController.text.trim(),
        station: _stationController.text.trim(),
        district: _districtController.text.trim(),
        state: _stateController.text.trim(),
        badgeNumber: _badgeNumberController.text.trim().toUpperCase(),
        phone: _phoneController.text.trim(),
        profileImage: null,
      );

      await ref.read(officerProfileProvider.notifier).saveProfile(newProfile);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    final dialogContent = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Header Badge & Language Switch Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            loc.text('officer_identification'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Language Switch Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          ref.read(languageProvider.notifier).toggleLanguage();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.g_translate_rounded,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                loc.language == AppLanguage.english ? 'EN' : 'HI',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  widget.isMandatory
                      ? loc.text('setup_officer_profile')
                      : loc.text('edit_officer_profile'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isMandatory
                      ? loc.text('mandatory_profile_desc')
                      : loc.text('edit_profile_desc'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),

                // Standard Circle Avatar with First Letter of Name
                CircleAvatar(
                  radius: 36,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    _initialLetter,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Form Fields
                _buildTextField(
                  context: context,
                  controller: _nameController,
                  label: loc.text('full_name_required'),
                  hint: loc.text('hint_full_name'),
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  context: context,
                  controller: _designationController,
                  label: loc.text('designation_required'),
                  hint: loc.text('hint_designation'),
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  context: context,
                  controller: _stationController,
                  label: loc.text('police_station_required'),
                  hint: loc.text('hint_police_station'),
                  icon: Icons.local_police_outlined,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  context: context,
                  controller: _districtController,
                  label: loc.text('district_required'),
                  hint: loc.text('hint_district'),
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  context: context,
                  controller: _stateController,
                  label: loc.text('state_required'),
                  hint: loc.text('hint_state'),
                  icon: Icons.map_outlined,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  context: context,
                  controller: _badgeNumberController,
                  label: loc.text('badge_number_required'),
                  hint: loc.text('hint_badge_number'),
                  icon: Icons.numbers_outlined,
                  isRequired: true,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  context: context,
                  controller: _phoneController,
                  label: loc.text('contact_phone_required'),
                  hint: loc.text('hint_phone'),
                  icon: Icons.phone_outlined,
                  isRequired: true,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),

                // Save Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      loc.text('save_and_continue'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.isMandatory) {
      return PopScope(
        canPop: false,
        child: dialogContent,
      );
    }

    return dialogContent;
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    final loc = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      onChanged: textCapitalization == TextCapitalization.characters
          ? (value) {
              final upper = value.toUpperCase();
              if (value != upper) {
                controller.value = controller.value.copyWith(
                  text: upper,
                  selection: TextSelection.collapsed(offset: upper.length),
                );
              }
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return loc.text('field_required_error');
              }
              return null;
            }
          : null,
    );
  }
}
