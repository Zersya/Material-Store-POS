import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/routerHelper.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;
import 'package:harco_app/screens/home/home_bloc.dart';
import 'package:harco_app/utils/commonFunc.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController scrollController = ScrollController();
  HomeBloc _homeBloc = HomeBloc();

  @override
  void initState() {
    super.initState();
    _homeBloc.fetchTransactionToday();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 120,
                    color: Theme.of(context).colorScheme.primaryVariant,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CardTop(
                      homeBloc: _homeBloc,
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  direction: Axis.horizontal,
                  spacing: 16.0,
                  children: <Widget>[
                    FeatureItem(
                      icon: FontAwesomeIcons.boxes,
                      name: 'Barang',
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouterHelper.kRouteListItem);
                      },
                    ),
                    FeatureItem(
                      icon: FontAwesomeIcons.exchangeAlt,
                      name: 'Transaksi',
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouterHelper.kRouteAddTransaction);
                      },
                    ),
                    FeatureItem(
                      icon: FontAwesomeIcons.list,
                      name: 'Data Transaksi',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              CurTransaction(
                scrollController: scrollController,
                homeBloc: _homeBloc,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CurTransaction extends StatelessWidget {
  const CurTransaction(
      {Key key, @required this.scrollController, @required this.homeBloc})
      : super(key: key);

  final ScrollController scrollController;

  final HomeBloc homeBloc;

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
              'Transaksi Hari Ini',
              style: Theme.of(context).textTheme.title,
            ),
            Divider(
              height: 32,
              color: Colors.black,
            ),
            StreamBuilder<List<prefTrans.Transaction>>(
                stream: homeBloc.transStream,
                initialData: List(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<prefTrans.Transaction> transactions = snapshot.data;

                    if (transactions.isEmpty) {
                      return Center(
                        child: Text('Tidak ada transaksi hari ini'),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) {
                        return Container(
                          height: 2,
                          color: Theme.of(context).colorScheme.surface,
                        );
                      },
                      itemBuilder: (context, index) {
                        DateTime dt = DateTime.fromMillisecondsSinceEpoch(
                                transactions[index].createdAt)
                            .toLocal();
                        String dateTime = '${dt.hour}:${dt.minute}';
                        return ListTile(
                          title: Text(transactions[index].name),
                          subtitle: Text(fmf
                              .copyWith(
                                  amount: transactions[index].total.toDouble())
                              .output
                              .symbolOnLeft),
                          trailing: Text(dateTime),
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

class CardTop extends StatelessWidget {
  const CardTop({Key key, @required this.homeBloc}) : super(key: key);

  final HomeBloc homeBloc;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32),
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 100.0,
          children: <Widget>[
            Text(
              'Pendapatan ${numberToStrDay(DateTime.now().weekday)}',
              style: Theme.of(context).textTheme.subtitle,
            ),
            StreamBuilder<int>(
              stream: homeBloc.profitTodayStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return RichText(
                    text: TextSpan(
                        text: 'Rp.',
                        style: Theme.of(context).textTheme.overline,
                        children: [
                          TextSpan(
                              text: fmf
                                  .copyWith(amount: snapshot.data.toDouble())
                                  .output
                                  .nonSymbol,
                              style: Theme.of(context).textTheme.title)
                        ]),
                  );
                }
                return Container();
              },
            )
          ],
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  const FeatureItem(
      {Key key, @required this.name, @required this.icon, @required this.onTap})
      : super(key: key);

  final String name;
  final IconData icon;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon),
                SizedBox(height: 8.0),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
