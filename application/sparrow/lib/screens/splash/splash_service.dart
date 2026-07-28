import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashService {
  const SplashService();

  Future<void> initialize(BuildContext context) async {
    // Future initialization goes here.
    // Examples:
    //
    // await Hive.initFlutter();
    // await Firebase.initializeApp();
    // await LocalStorage.init();
    // await AuthService.restoreSession();

    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    context.go('/home');
  }
}