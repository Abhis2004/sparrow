import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/app_localizations.dart';
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
  DateTime? _lastBackPressTime;

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

    final loc = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // If an inner modal/page can pop, pop it first
        if (Navigator.of(context).canPop()) {
          context.pop();
          return;
        }

        // If currently on another tab besides Home (branch 0), navigate to Home tab first
        if (widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
          return;
        }

        // Double press back to exit within 2 seconds
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.text('press_back_again_to_exit')),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: BottomNavBar(
          navigationShell: widget.navigationShell,
        ),
      ),
    );
  }
}