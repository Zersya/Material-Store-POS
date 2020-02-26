import 'package:flutter/material.dart';
import 'package:harco_app/helper/routerHelper.dart';
import 'package:harco_app/widgets/cur_transaction.dart';

class ListTransactionScreen extends StatelessWidget {
  const ListTransactionScreen({Key key, @required this.params})
      : super(key: key);
  final RouteListTransaction params;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Kas'),
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: CurTransaction(
          title: 'Transaksi',
          scrollController: params.scrollController,
          bloc: params.reportBloc,
          onUpdate: () {},
          onDelete: (transaction) {
            showDialogConfrmDelete(context, transaction).then((val) {
              if (val != null && val) {
                Navigator.of(context).pop();
              }
            });
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
          title: Text('Konfirmasi Hapus'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Ya',
              ),
              onPressed: () {
                params.reportBloc.deleteTransaction(transaction).then((_) {
                  Navigator.of(context).pop(true);
                });
              },
            ),
            FlatButton(
              child: Text('Tidak'),
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
