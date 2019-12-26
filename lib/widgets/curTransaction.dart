import 'package:flutter/material.dart';
import 'package:harco_app/helper/transBaseHelper.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;
import 'package:harco_app/utils/commonFunc.dart';

class CurTransaction extends StatelessWidget {
  const CurTransaction(
      {Key key,
      @required this.scrollController,
      @required this.bloc,
      @required this.title})
      : super(key: key);

  final ScrollController scrollController;
  final String title;
  final TransBaseHelper bloc;

  Future dialogSummary(
      BuildContext context, prefTrans.Transaction transaction) {
    return showDialog(
      context: context,
      builder: (context) {
        List<Item> cart = transaction.items;

        return AlertDialog(
          title: Text('Ringkasan'),
          actions: <Widget>[
            FlatButton(
              child: Text('Kembali'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
          content: Container(
            width: 300,
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListView.separated(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cart.length,
                    separatorBuilder: (context, index) {
                      return Divider(height: 1, color: Colors.black87);
                    },
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(cart[index].name),
                        subtitle: Text(fmf
                            .copyWith(
                              amount: transaction.profit.toDouble(),
                            )
                            .output
                            .symbolOnLeft),
                        trailing:
                            Text('${cart[index].pcs} ${cart[index].unit}'),
                      );
                    },
                  ),
                  Divider(height: 3, color: Colors.black87),
                  ListTile(
                    title: Text('Total'),
                    subtitle: Text(fmf
                        .copyWith(amount: transaction.total.toDouble())
                        .output
                        .symbolOnLeft),
                    trailing: RichText(
                      text: TextSpan(
                        text: 'Profit\n',
                        style: Theme.of(context).textTheme.subtitle,
                        children: [
                          TextSpan(
                            style: Theme.of(context).textTheme.caption,
                            text:
                                '${fmf.copyWith(amount: transaction.profit.toDouble()).output.symbolOnLeft}',
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.title,
            ),
            Divider(
              height: 32,
              color: Colors.black,
            ),
            StreamBuilder<List<prefTrans.Transaction>>(
                stream: bloc.transStream,
                initialData: List(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<prefTrans.Transaction> transactions = snapshot.data;

                    if (transactions.isEmpty) {
                      return Center(
                        child: Text('Tidak ada transaksi'),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 8,
                          color: Theme.of(context).colorScheme.surface,
                        );
                      },
                      itemBuilder: (context, index) {
                        DateTime dt = DateTime.fromMillisecondsSinceEpoch(
                                transactions[index].createdAt)
                            .toLocal();
                        String date =
                            '${dt.day} ${numberToStrMonth(dt.month)} ${dt.year}';
                        String dateTime = '${dt.hour}:${dt.minute}';
                        return ListTile(
                          title: Text(transactions[index].name),
                          subtitle: Text(fmf
                              .copyWith(
                                  amount: transactions[index].total.toDouble())
                              .output
                              .symbolOnLeft),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(date, style: Theme.of(context).textTheme.body1,),
                              SizedBox(height: 8.0),
                              Text(dateTime, style: Theme.of(context).textTheme.body2.copyWith(color: Colors.black54),)
                            ],
                          ),
                          onTap: () =>
                              dialogSummary(context, transactions[index]),
                        );
                      },
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
          ],
        ),
      ),
    );
  }
}
