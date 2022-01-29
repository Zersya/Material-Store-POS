import 'package:flutter/material.dart';
import 'package:harco_app/helper/routerHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((val) {
      if (val.containsKey('UID')) {
        Navigator.of(context).pushReplacementNamed(RouterHelper.kRouteHome);
      } else {
        Navigator.of(context).pushReplacementNamed(RouterHelper.kRouteLogin);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Harco',
                style: Theme.of(context).textTheme.headline5,
              ),
              Divider(
                height: 16.0,
                color: Colors.transparent,
              ),
              Center(
                  child: CircularProgressIndicator(
                strokeWidth: 2,
              ))
            ],
          ),
        ),
      ),
    );
  }
}
