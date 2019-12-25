import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/user.dart';
import 'package:harco_app/screens/addtransaction/addTransaction_bloc.dart';
import 'package:harco_app/utils/commonFunc.dart';
import 'package:harco_app/utils/enum.dart' as prefixEnum;
import 'package:harco_app/widgets/dropDownUnit.dart';

import 'widgets/cartItem.dart';

class AddTransactionScreen extends StatefulWidget {
  AddTransactionScreen({Key key}) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TextEditingController _controllerCustomerName = TextEditingController();
  TextEditingController _controllerName = TextEditingController();

  MoneyMaskedTextController _controllerPriceBuy = MoneyMaskedTextController(
      thousandSeparator: '.',
      initialValue: 0,
      precision: 0,
      decimalSeparator: '');
  MoneyMaskedTextController _controllerPriceSell = MoneyMaskedTextController(
      thousandSeparator: '.',
      initialValue: 0,
      precision: 0,
      decimalSeparator: '');
  MoneyMaskedTextController _controllerPieces = MoneyMaskedTextController(
      thousandSeparator: '.',
      initialValue: 0,
      precision: 0,
      decimalSeparator: '');

  TextEditingController _controllerUnit = TextEditingController();

  FocusNode _nodeCustomerName = FocusNode();
  FocusNode _nodeName = FocusNode();
  FocusNode _nodePriceBuy = FocusNode();
  FocusNode _nodePriceSell = FocusNode();
  FocusNode _nodePieces = FocusNode();

  FocusNode _nodeUnit = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  AddTransactionBloc _addTransactionBloc = AddTransactionBloc();

  Item _suggestion;

  @override
  void initState() {
    super.initState();
    _addTransactionBloc.responseStream.listen((response) {
      if (response.message != null) {
        
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Theme.of(context).colorScheme.surface,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
    _addTransactionBloc.fetchCustomers();
    _addTransactionBloc.fetchItem();
    _addTransactionBloc.fetchUnit();
  }

  void _submitItem2Cart() {
    bool isNew = _addTransactionBloc.isNewItemStream.value;

    String priceBuy = _controllerPriceBuy.numberValue.toInt().toString();
    String priceSell = _controllerPriceSell.numberValue.toInt().toString();
    String pcs = _controllerPieces.numberValue.toInt().toString();

    Item newItem;

    if (!isNew) {
      newItem = Item(
        _controllerName.text.toLowerCase(),
        priceBuy,
        priceSell,
        _addTransactionBloc.unitStream.value,
        User('mail@mail.com'),
        createdAt: _suggestion.createdAt,
        pcs: int.parse(pcs),
        id: _suggestion.id,
      );
    } else {
      newItem = Item(
        _controllerName.text.toLowerCase(),
        priceBuy,
        priceSell,
        _addTransactionBloc.unitStream.value,
        User('mail@mail.com'),
        pcs: int.parse(pcs),
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      _addTransactionBloc.createItem(newItem);
    }

    newItem.pcs = int.parse(pcs);
    _addTransactionBloc.insert2Cart(newItem);
    _resetField();
  }

  void _cancelCart() {
    _addTransactionBloc.clearCart();
    _resetField();
  }

  void _resetField() {
    _controllerName.clear();
    _controllerPriceBuy.text = '0';
    _controllerPriceSell.text = '0';
    _controllerPieces.text = '0';

    _addTransactionBloc.subjectIsNewItem.sink.add(true);
  }

  void _setSuggestionCustomer(String name){
    _controllerCustomerName.text = name;
  }

  void _setSuggestionItem(Item suggestion) {
    _controllerName.text = suggestion.name;
    _controllerPriceBuy.text = suggestion.priceBuy;
    _controllerPriceSell.text = suggestion.priceSell;
    _addTransactionBloc.subjectUnitValue.sink.add(suggestion.unit);
    _addTransactionBloc.subjectIsNewItem.sink.add(false);
    _suggestion = suggestion;
  }

  _buildShowSnackBar(BuildContext context, String msg) {
    return _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  _dialogCancel(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Kamu ingin membatalkan pesanan ?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Tidak'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Iya'),
              onPressed: () {
                _cancelCart();
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Future dialogSummary(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        List<Item> cart = _addTransactionBloc.cart;
        int sum = 0;
        cart.forEach(
            (item) => sum = sum + (int.parse(item.priceSell) * item.pcs));

        return AlertDialog(
          title: Text('Ringkasan'),
          actions: <Widget>[
            FlatButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.pop(context);
                _addTransactionBloc.createTransaction(
                    sum, _controllerCustomerName.text);
              },
            ),
          ],
          content: Container(
            width: 300,
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Pembeli: ${_controllerCustomerName.text}',
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  Divider(
                    height: 16,
                    color: Colors.black87,
                  ),
                  ListView.separated(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cart.length,
                    separatorBuilder: (context, index) {
                      return Divider(height: 1, color: Colors.black87);
                    },
                    itemBuilder: (context, index) {
                      double amount =
                          double.parse(cart[index].priceSell) * cart[index].pcs;

                      return ListTile(
                        title: Text(cart[index].name),
                        subtitle: Text(fmf
                            .copyWith(
                              amount: amount,
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
                        .copyWith(amount: sum.toDouble())
                        .output
                        .symbolOnLeft),
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
  void dispose() {
    super.dispose();
    _addTransactionBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Transaksi'),
        actions: <Widget>[
          FlatButton(
            child: Text('Periksa'),
            onPressed: () {
              if (_addTransactionBloc.cart.isEmpty) {
                _buildShowSnackBar(context, 'Silahkan tambahkan barang');
                return;
              }
              dialogSummary(context);
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62.0),
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.black),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: fieldNameCustomer(context),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                color: Theme.of(context).colorScheme.primary,
                child: Text('Batalkan'),
                onPressed: () {
                  if (_addTransactionBloc.cartStream.value == null) {
                    return;
                  } else if (_addTransactionBloc.cartStream.value.length > 0) {
                    _dialogCancel(context);
                  }
                },
              ),
            ),
            SizedBox(
              width: 2,
            ),
            Expanded(
              child: StreamBuilder<bool>(
                  stream: _addTransactionBloc.isNewItemStream,
                  initialData: true,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      bool isNew = snapshot.data;
                      return FlatButton(
                        color: Theme.of(context).colorScheme.primary,
                        child: Text(isNew ? 'Tambah baru' : 'Tambahkan'),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            if (_controllerName.text.isEmpty) {
                              _buildShowSnackBar(
                                  context, 'Nama barang tidak boleh kosong');
                            } else if (_controllerPriceBuy.text == '0' ||
                                _controllerPriceSell.text == '0' ||
                                _controllerPieces.text == '0') {
                              _buildShowSnackBar(
                                  context, 'Bilangan tidak boleh nol');
                            } else if (_addTransactionBloc.unitStream.value ==
                                    null ||
                                _addTransactionBloc.unitStream.value.isEmpty) {
                              _buildShowSnackBar(
                                  context, 'Silahkan pilih satuan');
                            } else {
                              _submitItem2Cart();
                            }
                          }
                        },
                      );
                    }
                    return Container();
                  }),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      fieldItemName(context),
                      SizedBox(
                        height: 16.0,
                      ),
                      TextFormField(
                        controller: _controllerPriceBuy,
                        focusNode: _nodePriceBuy,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Harga beli',
                        ),
                        onFieldSubmitted: (val) {
                          FocusScope.of(context).requestFocus(_nodePriceSell);
                        },
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Harga beli tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      TextFormField(
                        controller: _controllerPriceSell,
                        focusNode: _nodePriceSell,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Harga jual',
                        ),
                        onFieldSubmitted: (val) {
                          FocusScope.of(context).requestFocus(_nodePieces);
                        },
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Harga jual tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      DropdownUnit(
                        addTransactionBloc: _addTransactionBloc,
                        nodeUnit: _nodeUnit,
                        controllerUnit: _controllerUnit,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      TextFormField(
                        controller: _controllerPieces,
                        focusNode: _nodePieces,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Jumlah satuan',
                        ),
                        onFieldSubmitted: (val) {
                          FocusScope.of(context).requestFocus(_nodeUnit);
                        },
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Harga jual tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      Divider(
                        height: 32,
                        color: Colors.transparent,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Keranjang',
                          style: Theme.of(context).textTheme.headline,
                        ),
                      ),
                      CartItem(addTransactionBloc: _addTransactionBloc)
                    ],
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<prefixEnum.FormState>(
              stream: _addTransactionBloc.stateStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == prefixEnum.FormState.LOADING)
                    return Center(
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black54,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                }
                return Container();
              })
        ],
      ),
    );
  }

  TypeAheadField<String> fieldNameCustomer(BuildContext context) {
    return TypeAheadField(
      hideOnEmpty: true,
      textFieldConfiguration: TextFieldConfiguration(
          controller: _controllerCustomerName,
          focusNode: _nodeCustomerName,
          autofocus: false,
          decoration: InputDecoration(
            labelText: 'Nama Pembeli',
          ),
          onChanged: (val) {
            // if (val.isEmpty) {
            //   _addTransactionBloc.subjectIsNewItem.sink.add(true);
            // }
          },
          onSubmitted: (val) {
            FocusScope.of(context).requestFocus(_nodeName);
          }),
      suggestionsCallback: (pattern) {
        return _addTransactionBloc.customerListStream.value
            .where((val) => val.contains(pattern))
            .toList();
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: Icon(Icons.person),
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (suggestion) {
        _setSuggestionCustomer(suggestion);
      },
    );
  }

  TypeAheadField<Item> fieldItemName(BuildContext context) {
    return TypeAheadField(
      hideOnEmpty: true,
      textFieldConfiguration: TextFieldConfiguration(
          controller: _controllerName,
          focusNode: _nodeName,
          autofocus: false,
          decoration: InputDecoration(
            labelText: 'Nama barang',
          ),
          onChanged: (val) {
            if (val.isEmpty) {
              _addTransactionBloc.subjectIsNewItem.sink.add(true);
            }
          },
          onSubmitted: (val) {
            FocusScope.of(context).requestFocus(_nodePriceBuy);
          }),
      suggestionsCallback: (pattern) {
        return _addTransactionBloc.itemListStream.value
            .where((val) => val.name.contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: Icon(Icons.shopping_cart),
          title: Text(suggestion.name),
          subtitle: Text(fmf
              .copyWith(amount: double.parse(suggestion.priceBuy))
              .output
              .symbolOnLeft),
        );
      },
      onSuggestionSelected: (suggestion) {
        _setSuggestionItem(suggestion);
      },
    );
  }
}
