// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final String selectedLanguage;
  final Function(String) updateLanguage;
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  const SettingsScreen({
    Key? key,
    required this.selectedLanguage,
    required this.updateLanguage,
    required this.themeMode,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _currentLanguage;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.selectedLanguage;
  }

  String _getSettingsTitle(String lang) {
    switch (lang) {
      case 'ar':
        return 'الإعدادات';
      case 'en':
        return 'Settings';
      case 'fr':
        return 'Paramètres';
      case 'ru':
        return 'Настройки';
      case 'de':
        return 'Einstellungen';
      default:
        return 'Settings';
    }
  }

  String _getLanguageTitle(String lang) {
    switch (lang) {
      case 'ar':
        return 'اللغة';
      case 'en':
        return 'Language';
      case 'fr':
        return 'Langue';
      case 'ru':
        return 'Язык';
      case 'de':
        return 'Sprache';
      default:
        return 'Language';
    }
  }

  String _getAppearanceTitle(String lang) {
    switch (lang) {
      case 'ar':
        return 'المظهر';
      case 'en':
        return 'Appearance';
      case 'fr':
        return 'Apparence';
      case 'ru':
        return 'Внешний вид';
      case 'de':
        return 'Erscheinungsbild';
      default:
        return 'Appearance';
    }
  }

  String _getHelpTitle(String lang) {
    switch (lang) {
      case 'ar':
        return 'المساعدة والدعم';
      case 'en':
        return 'Help & Support';
      case 'fr':
        return 'Aide et Support';
      case 'ru':
        return 'Помощь и Поддержка';
      case 'de':
        return 'Hilfe & Support';
      default:
        return 'Help & Support';
    }
  }

  String _getHelpContent(String lang) {
    switch (lang) {
      case 'ar':
        return 'تواصل معنا عبر البريد الإلكتروني: support@khrajni.com';
      case 'en':
        return 'Contact us via email: support@khrajni.com';
      case 'fr':
        return 'Contactez-nous par e-mail : support@khrajni.com';
      case 'ru':
        return 'Свяжитесь с нами по email: support@khrajni.com';
      case 'de':
        return 'Kontaktieren Sie uns per E-Mail: support@khrajni.com';
      default:
        return 'Contact us via email: support@khrajni.com';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(_getSettingsTitle(_currentLanguage)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            _getLanguageTitle(_currentLanguage),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _currentLanguage,
                items: const {
                  'en': 'English',
                  'ar': 'العربية',
                  'fr': 'Français',
                  'ru': 'Русский',
                  'de': 'Deutsch',
                }.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null && newValue != _currentLanguage) {
                    setState(() {
                      _currentLanguage = newValue;
                    });
                    widget.updateLanguage(newValue);
                  }
                },
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getAppearanceTitle(_currentLanguage),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: widget.themeMode == ThemeMode.dark,
            onChanged: (_) => widget.toggleTheme(),
            secondary: Icon(widget.themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode),
          ),
          const SizedBox(height: 16),
          Text(
            _getHelpTitle(_currentLanguage),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _getHelpContent(_currentLanguage),
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
