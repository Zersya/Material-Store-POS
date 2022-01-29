import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:harco_app/firebase_options.dart';
import 'package:harco_app/helper/locator.dart';
import 'package:harco_app/screens/splash/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'helper/routerHelper.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseAuth auth = FirebaseAuth.instance;

  locator(firestore, auth, false);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final ColorScheme colorSchemeLight = ColorScheme.light(
    primary: const Color(0xff3d8ab8),
    primaryVariant: const Color(0xff849fbb),
    secondary: const Color(0xff005f97),
    secondaryVariant: const Color(0xff004c79),
    surface: Colors.black45,
    background: Color(0xffe9f4fa),
    error: const Color(0xffb00020),
    onPrimary: Colors.white,
    onSecondary: Colors.grey[500],
    onSurface: Colors.grey[500],
    onBackground: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  static final TextTheme textTheme = TextTheme(
    headline5: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    subtitle1: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    headline6: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    subtitle2: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    bodyText2: TextStyle(fontSize: 14),
    bodyText1: TextStyle(fontSize: 14, color: Colors.grey[300]),
    caption: TextStyle(fontSize: 12, color: Colors.black87),
    overline: TextStyle(fontSize: 12, color: Colors.grey[500]),
    button: TextStyle(color: Colors.white),
  );

  final ThemeData themeData = ThemeData(
      colorScheme: colorSchemeLight,
      primaryColor: colorSchemeLight.primary,
      textTheme: textTheme,
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
      home: SplashScreen(),
    );
  }
}
