import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harco_app/helper/locator.dart';
import 'package:harco_app/screens/splash/splash_screen.dart';
import 'helper/routerHelper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore firestore = Firestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  runApp(MyApp());

  locator(firestore, auth, false);
}

class MyApp extends StatelessWidget {
  static final ColorScheme colorSchemeLight = ColorScheme.light(
    primary: const Color(0xffe6c76a),
    primaryVariant: const Color(0xfff3c751),
    secondary: const Color(0xffbfce87),
    secondaryVariant: const Color(0xffbfe06c),
    surface: Colors.black45,
    background: Colors.white,
    error: const Color(0xffb00020),
    onPrimary: Colors.white,
    onSecondary: Colors.grey[500],
    onSurface: Colors.grey[500],
    onBackground: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  final TextTheme textTheme = TextTheme(
      headline: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      subhead: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      title: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      subtitle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      body1: TextStyle(fontSize: 14),
      body2: TextStyle(fontSize: 14, color: Colors.grey[300]),
      caption: TextStyle(fontSize: 12, color: Colors.black87),
      overline: TextStyle(fontSize: 12, color: Colors.grey[500]));

  final ThemeData themeData = ThemeData(
      colorScheme: colorSchemeLight,
      primaryColor: colorSchemeLight.primary,
      accentColor: colorSchemeLight.secondary,
      backgroundColor: colorSchemeLight.background,
      buttonTheme: ButtonThemeData(colorScheme: colorSchemeLight),
      dialogTheme: DialogTheme(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Harco POS',
        theme: themeData,
        onGenerateRoute: RouterHelper.generateRoute,
        home: SplashScreen());
  }
}
