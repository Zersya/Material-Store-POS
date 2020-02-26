import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:harco_app/helper/routerHelper.dart';
import 'package:harco_app/screens/home/home_bloc.dart';
import 'package:harco_app/utils/commonFunc.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/widgets/cur_transaction.dart';

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
  void dispose() {
    super.dispose();
    if (this.mounted) {
      _homeBloc.dispose();
    }
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
                    child: StreamBuilder<ViewState>(
                        stream: _homeBloc.stateStream,
                        initialData: ViewState.LOADING,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData ||
                              snapshot.data == ViewState.LOADING) {
                            return Center(child: CircularProgressIndicator());
                          }
                          return CardTop(
                            homeBloc: _homeBloc,
                          );
                        }),
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
                  alignment: WrapAlignment.center,
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
                            context, RouterHelper.kRouteFormTransaction);
                      },
                    ),
                    FeatureItem(
                      icon: FontAwesomeIcons.wallet,
                      name: 'Kas',
                      onTap: () {
                        Navigator.pushNamed(context, RouterHelper.kRouteCash);
                      },
                    ),
                    FeatureItem(
                      icon: FontAwesomeIcons.list,
                      name: 'Laporan Keuangan',
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouterHelper.kRouteTransactionReport);
                      },
                    ),
                    FeatureItem(
                      icon: Icons.person,
                      name: 'Pelanggan',
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouterHelper.kRouteCustomer);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              StreamBuilder<ViewState>(
                stream: _homeBloc.stateStream,
                initialData: ViewState.LOADING,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == ViewState.LOADING) {
                    return Container(
                        height: 80,
                        child: Center(child: CircularProgressIndicator()));
                  }
                  return CurTransaction(
                    title: 'Transaksi Hari ini',
                    scrollController: scrollController,
                    bloc: _homeBloc,
                    onUpdate: () {},
                    onDelete: (transaction) {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text('Konfirmasi Hapus'),
                            actions: <Widget>[
                              FlatButton(
                                textColor: Colors.grey,
                                child: Text(
                                  'Ya',
                                ),
                                onPressed: () {
                                  _homeBloc
                                      .deleteTransaction(transaction)
                                      .then((_) {
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
                      ).then((val) {
                        if (val != null && val) {
                          Navigator.of(context).pop();
                        }
                      });
                    },
                  );
                },
              )
            ],
          ),
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
      margin: EdgeInsets.symmetric(vertical: 32.0, horizontal: 32),
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 100.0,
          children: <Widget>[
            Text(
              'Profit ${numberToStrDay(DateTime.now().weekday)}',
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
