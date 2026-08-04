import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import 'app_language.dart';

const String _languagePrefKey = 'sparrow_language_code';

final languageProvider =
    NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedCode = prefs.getString(_languagePrefKey);
    if (savedCode != null) {
      return AppLanguage.fromCode(savedCode);
    }
    return AppLanguage.english;
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_languagePrefKey, language.code);
  }

  Future<void> toggleLanguage() async {
    final nextLang = state == AppLanguage.english
        ? AppLanguage.hindi
        : AppLanguage.english;
    await setLanguage(nextLang);
  }
}
