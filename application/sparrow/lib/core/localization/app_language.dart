import 'package:flutter/material.dart';

enum AppLanguage {
  english(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    locale: Locale('en', 'US'),
  ),
  hindi(
    code: 'hi',
    name: 'Hindi',
    nativeName: 'हिंदी',
    locale: Locale('hi', 'IN'),
  );

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.locale,
  });

  final String code;
  final String name;
  final String nativeName;
  final Locale locale;

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}
