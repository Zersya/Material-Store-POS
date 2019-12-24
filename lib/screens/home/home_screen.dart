import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:harco_app/helper/routerHelper.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController scrollController = ScrollController();
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
                    child: CardTop(),
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
                        Navigator.pushNamed(context, RouterHelper.kRouteAddTransaction);
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
              Container(
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
                        ListView.separated(
                          controller: scrollController,
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 30,
                          separatorBuilder: (context, index) {
                            return Container(
                              height: 2,
                              color: Theme.of(context).colorScheme.surface,
                            );
                          },
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('index $index'),
                            );
                          },
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class CardTop extends StatelessWidget {
  const CardTop({
    Key key,
  }) : super(key: key);

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
          spacing: 120.0,
          children: <Widget>[
            RichText(
              text: TextSpan(
                  text: 'Pendapatan',
                  style: Theme.of(context).textTheme.subtitle,
                  children: [
                    TextSpan(
                        text: ' Senin',
                        style: Theme.of(context).textTheme.title)
                  ]),
            ),
            RichText(
              text: TextSpan(
                  text: 'Rp.',
                  style: Theme.of(context).textTheme.overline,
                  children: [
                    TextSpan(
                        text: '0', style: Theme.of(context).textTheme.title)
                  ]),
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
