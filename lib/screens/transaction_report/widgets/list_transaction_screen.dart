import 'package:flutter/material.dart';
import 'package:harco_app/helper/routerHelper.dart';
import 'package:harco_app/widgets/cur_transaction.dart';

class ListTransactionScreen extends StatelessWidget {
  ListTransactionScreen({Key key, @required this.params}) : super(key: key);
  final RouteListTransaction params;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('List Transaction'),
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: CurTransaction(
          title: 'Transactions',
          scrollController: params.scrollController,
          bloc: params.reportBloc,
          onUpdate: () {},
          onDelete: (transaction) {
            Navigator.of(context).pop();
            showDialogConfrmDelete(context, transaction);
          },
        ),
      ),
    );
  }

  Future showDialogConfrmDelete(BuildContext context, transaction) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Confirmation Delete'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Yes',
              ),
              onPressed: () {
                params.reportBloc.deleteTransaction(transaction).then((_) {
                  Navigator.of(context).pop(true);
                });
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }
}
