import 'package:flutter/material.dart';
import 'package:harco_app/helper/transBaseHelper.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;
import 'package:harco_app/utils/commonFunc.dart';

class CurTransaction extends StatelessWidget {
  const CurTransaction({
    Key key,
    @required this.scrollController,
    @required this.bloc,
    @required this.title,
    @required this.onDelete,
    @required this.onUpdate,
  }) : super(key: key);

  final ScrollController scrollController;
  final String title;
  final TransBaseHelper bloc;
  final Function onDelete;
  final Function onUpdate;

  Future dialogSummary(
      BuildContext context, prefTrans.Transaction transaction) {
    return showDialog(
      context: context,
      builder: (context) {
        List<Item> cart = transaction.items;

        return AlertDialog(
          title: Text('Summary'),
          actions: <Widget>[
            TextButton(
              child: Text('Delete'),
              onPressed: () => onDelete(transaction),
            ),
            // FlatButton(
            //   child: Text('Ubah'),
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            // ),
            TextButton(
              child: Text('Back'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Name : ${transaction.customer.name}'),
                  if (transaction.deposit != 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Paid with Deposit',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                    ),
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
                        subtitle: Text(
                          currencyFormatter.format(
                            transaction.profit.toDouble(),
                          ),
                        ),
                        trailing:
                            Text('${cart[index].pcs} ${cart[index].unit}'),
                      );
                    },
                  ),
                  Divider(height: 3, color: Colors.black87),
                  ListTile(
                    title: Text(
                      'Total',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    subtitle: Text(currencyFormatter.format(transaction.total)),
                    trailing: RichText(
                      text: TextSpan(
                        text: 'Profit\n',
                        style: Theme.of(context).textTheme.subtitle2,
                        children: [
                          TextSpan(
                            style: Theme.of(context).textTheme.bodyText2,
                            text:
                                '${currencyFormatter.format(transaction.profit.toDouble())}',
                          )
                        ],
                      ),
                    ),
                  ),
                  // Text(
                  //   'Pay Deposit : ${currencyFormatter.format(transaction.deposit)}',
                  // ),
                  Text(
                    'Paid : ${currencyFormatter.format((transaction.deposit - transaction.total).abs())}',
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
        child: StreamBuilder<List<prefTrans.Transaction>>(
            stream: bloc.transStream,
            initialData: List(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<prefTrans.Transaction> transactions = snapshot.data;

                if (transactions.isEmpty) {
                  return Center(
                    child: Text('Empty Transaction'),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      direction: Axis.vertical,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: <Widget>[
                        Text(
                          '$title : ${snapshot.data.length}',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Divider(
                          height: 16.0,
                          color: Colors.transparent,
                        ),
                        Text(
                          'Revenue : ${currencyFormatter.format(bloc.omzet)}',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                    Divider(
                      height: 32,
                      color: Colors.black,
                    ),
                    ListView.separated(
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
                          title: Text(
                            transactions[index]
                                .items
                                .map((e) => e.name)
                                .join(', '),
                          ),
                          subtitle: Text(
                            currencyFormatter.format(transactions[index].total),
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(date),
                              SizedBox(height: 8.0),
                              Text(
                                dateTime,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(color: Colors.black54),
                              )
                            ],
                          ),
                          onTap: () =>
                              dialogSummary(context, transactions[index]),
                        );
                      },
                    ),
                  ],
                );
              } else {
                return CircularProgressIndicator();
              }
            }),
      ),
    );
  }
}
