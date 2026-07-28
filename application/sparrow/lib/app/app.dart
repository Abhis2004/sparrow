import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class SparrowApp extends StatelessWidget {
  const SparrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SPARROW',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      routerConfig: appRouter,
    );
  }
}