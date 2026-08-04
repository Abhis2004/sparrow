import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/colors.dart';
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
                // Header Badge / Icon
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
                        'OFFICER IDENTIFICATION',
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
                const SizedBox(height: 16),

                Text(
                  widget.isMandatory ? 'Setup Officer Profile' : 'Edit Officer Profile',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isMandatory
                      ? 'Please complete all required fields to proceed into the application.'
                      : 'Update your official profile details.',
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
                  controller: _nameController,
                  label: 'Full Name *',
                  hint: 'e.g. Rahul Sharma',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _designationController,
                  label: 'Designation *',
                  hint: 'e.g. Sub Inspector',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _stationController,
                  label: 'Police Station *',
                  hint: 'e.g. Sector 18, Noida',
                  icon: Icons.local_police_outlined,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _districtController,
                  label: 'District *',
                  hint: 'e.g. Gautam Budh Nagar',
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _stateController,
                  label: 'State *',
                  hint: 'e.g. Uttar Pradesh',
                  icon: Icons.map_outlined,
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
                    child: const Text(
                      'Save & Continue',
                      style: TextStyle(
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
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}
