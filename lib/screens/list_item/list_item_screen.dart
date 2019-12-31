import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:harco_app/helper/routerHelper.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/screens/list_item/list_item_bloc.dart';
import 'package:harco_app/utils/commonFunc.dart';

class ListItemScreen extends StatefulWidget {
  ListItemScreen({Key key}) : super(key: key);

  @override
  _ListItemScreenState createState() => _ListItemScreenState();
}

class _ListItemScreenState extends State<ListItemScreen>
    with TickerProviderStateMixin {
  TextEditingController _controllerSearch = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  ScrollDirection _currentDir = ScrollDirection.forward;
  ListItemBloc _listItemBloc = ListItemBloc();

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

 
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_currentDir != _scrollController.position.userScrollDirection) {
        setState(() {
          _isFabVisible = !(_scrollController.position.userScrollDirection ==
              ScrollDirection.reverse);
          _currentDir = _scrollController.position.userScrollDirection;
        });
      }
    });

    _listItemBloc.responseStream.listen((response) {
      if (response.message != null) {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        );
      }
    });
    _listItemBloc.fetchItem();
  }

  Future _dialogDetailItem(BuildContext context, Item item) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail barang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text('Nama barang'),
              subtitle: Text(item.name),
            ),
            Divider(
              height: 4,
              color: Colors.black54,
            ),
            ListTile(
              title: Text('Harga beli'),
              subtitle: Text(fmf
                  .copyWith(amount: double.parse(item.priceBuy))
                  .output
                  .symbolOnLeft),
            ),
            Divider(
              height: 4,
              color: Colors.black54,
            ),
            ListTile(
              title: Text('Harga jual'),
              subtitle: Text(fmf
                  .copyWith(amount: double.parse(item.priceSell))
                  .output
                  .symbolOnLeft),
            ),
            Divider(
              height: 4,
              color: Colors.black54,
            ),
            ListTile(
              title: Text('Satuan barang'),
              subtitle: Text(item.unit),
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Hapus'),
            onPressed: () {
              Navigator.pop(context);
              _listItemBloc.deleteItem(item);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _listItemBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Daftar barang'),),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, RouterHelper.kRouteAddItem);
              },
            )
          : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: ScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controllerSearch,
                onSubmitted: (val) {
                  _listItemBloc.searchItem(val.toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: 'Cari disini..',
                  suffixIcon: Material(
                      color: Colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _listItemBloc.searchItem(
                                _controllerSearch.text.toLowerCase());
                          },
                          child: Icon(Icons.search))),
                ),
              ),
            ),
            StreamBuilder<List<Item>>(
                stream: _listItemBloc.itemListStream,
                initialData: List(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Item> items = snapshot.data;
                    return ListView.separated(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 8,
                          color: Theme.of(context).colorScheme.surface,
                        );
                      },
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(items[index].name),
                          trailing: Text(items[index].unit),
                          onTap: () {
                            _dialogDetailItem(context, items[index]);
                          },
                        );
                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                }),
          ],
        ),
      ),
    );
  }
}
