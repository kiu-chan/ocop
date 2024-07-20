import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en');

  void _changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizationsDelegate(),
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('vi', ''),
      ],
      home: MyHomePage(onLanguageChange: _changeLanguage),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Function(String) onLanguageChange;

  MyHomePage({required this.onLanguageChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('hello')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).translate('hello'),
            ),
            ElevatedButton(
              onPressed: () {
                // Toggle between English and Vietnamese
                final newLanguageCode = Localizations.localeOf(context).languageCode == 'en' ? 'vi' : 'en';
                onLanguageChange(newLanguageCode);
              },
              child: Text(AppLocalizations.of(context).translate('changeLanguage')),
            ),
          ],
        ),
      ),
    );
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'hello': 'Hello',
      'changeLanguage': 'Change Language',
    },
    'vi': {
      'hello': 'Xin chào',
      'changeLanguage': 'Thay đổi ngôn ngữ',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
