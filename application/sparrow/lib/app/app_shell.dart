import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/home/home_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/officer_profile_dialog.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOfficerDetails();
    });
  }

  void _checkOfficerDetails() {
    if (_dialogShown) return;
    final officer = ref.read(officerProfileProvider);
    if (!officer.isComplete) {
      _dialogShown = true;
      OfficerProfileSetupDialog.show(context, isMandatory: true).then((_) {
        _dialogShown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(officerProfileProvider, (previous, next) {
      if (!next.isComplete && !_dialogShown) {
        _dialogShown = true;
        OfficerProfileSetupDialog.show(context, isMandatory: true).then((_) {
          _dialogShown = false;
        });
      }
    });

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavBar(
        navigationShell: widget.navigationShell,
      ),
    );
  }
}