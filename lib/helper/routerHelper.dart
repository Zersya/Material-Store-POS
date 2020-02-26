import 'package:flutter/material.dart';
import 'package:harco_app/screens/form_item/form_item_screen.dart';
import 'package:harco_app/screens/form_transaction/form_transaction_screen.dart';
import 'package:harco_app/screens/auth/login/login_screen.dart';
import 'package:harco_app/screens/cash/cash_screen.dart';
import 'package:harco_app/screens/customers/customer_screen.dart';
import 'package:harco_app/screens/home/home_screen.dart';
import 'package:harco_app/screens/list_item/list_item_screen.dart';
import 'package:harco_app/screens/transaction_report/transaction_report_bloc.dart';
import 'package:harco_app/screens/transaction_report/transaction_report_screen.dart';
import 'package:harco_app/screens/transaction_report/widgets/list_cash_screen.dart';
import 'package:harco_app/screens/transaction_report/widgets/list_transaction_screen.dart';

class RouterHelper {
  static const kRouteLogin = '/login';
  static const kRouteHome = '/home';
  static const kRouteCustomer = '/home/customer';
  static const kRouteListItem = '/home/item';
  static const kRouteFormItem = '/home/item/form';
  static const kRouteFormTransaction = '/home/trasaction';
  static const kRouteTransactionReport = '/home/transactionReport';
  static const kRouteCash = '/home/cash';
  static const kRouteListCash = '/home/transactionReport/cash';
  static const kRouteListTransaction = '/home/transactionReport/transactions';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    print(settings.name);
    switch (settings.name) {
      case kRouteLogin:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case kRouteHome:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case kRouteCustomer:
        return MaterialPageRoute(builder: (_) => CustomerScreen());
      case kRouteListItem:
        return MaterialPageRoute(builder: (_) => ListItemScreen());
      case kRouteFormItem:
        return MaterialPageRoute(builder: (_) => FormItemScreen());
      case kRouteFormTransaction:
        return MaterialPageRoute(builder: (_) => FormTransactionScreen());
      case kRouteTransactionReport:
        return MaterialPageRoute(builder: (_) => TransactionReportScreen());
      case kRouteCash:
        return MaterialPageRoute(builder: (_) => CashScreen());
      case kRouteListCash:
        return MaterialPageRoute(
          builder: (_) => ListCashScreen(
            cashs: settings.arguments,
          ),
        );

      case kRouteListTransaction:
        return MaterialPageRoute(
          builder: (_) => ListTransactionScreen(
            params: settings.arguments,
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => HomeScreen());
    }
  }
}

class RouteListTransaction{
  final ScrollController scrollController;
  final TransactionReportBloc reportBloc;

  RouteListTransaction(this.scrollController, this.reportBloc);
}
