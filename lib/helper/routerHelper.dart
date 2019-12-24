import 'package:flutter/material.dart';
import 'package:harco_app/screens/addItem/addItem_screen.dart';
import 'package:harco_app/screens/addtransaction/addTransaction_screen.dart';
import 'package:harco_app/screens/home/home_screen.dart';
import 'package:harco_app/screens/listItem/listItem_screen.dart';

class RouterHelper {
  static const kRouteHome = '/home';
  static const kRouteListItem = '/home/item';
  static const kRouteAddItem = '/home/item/add';
  static const kRouteAddTransaction = '/home/trasaction';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    print(settings.name);
    switch (settings.name) {
      case kRouteHome:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case kRouteListItem:
        return MaterialPageRoute(builder: (_) => ListItemScreen());
      case kRouteAddItem:
        return MaterialPageRoute(builder: (_) => AddItemScreen());
      case kRouteAddTransaction:
        return MaterialPageRoute(builder: (_) => AddTransactionScreen());
      default:
        return MaterialPageRoute(builder: (_) => HomeScreen());
    }
  }
}
