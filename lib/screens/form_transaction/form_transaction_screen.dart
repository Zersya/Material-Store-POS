import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:harco_app/models/customer.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/screens/form_transaction/form_transaction_bloc.dart';
import 'package:harco_app/utils/commonFunc.dart';
import 'package:harco_app/utils/enum.dart' as prefixEnum;
import 'package:harco_app/widgets/drop_down_unit.dart';

import 'widgets/cart_item.dart';

class FormTransactionScreen extends StatefulWidget {
  FormTransactionScreen({Key key}) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<FormTransactionScreen> {
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

  TextEditingController _controllerPieces = TextEditingController();
  TextEditingController _controllerUnit = TextEditingController();

  FocusNode _nodeCustomerName = FocusNode();
  FocusNode _nodeName = FocusNode();
  FocusNode _nodePriceBuy = FocusNode();
  FocusNode _nodePriceSell = FocusNode();
  FocusNode _nodePieces = FocusNode();

  FocusNode _nodeUnit = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  FormTransactionBloc _addTransactionBloc = FormTransactionBloc();

  Item _suggestion;
  Customer _selectedCustomer;

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
    String pcs = _controllerPieces.text;

    Item newItem;

    if (!isNew) {
      newItem = Item(
        _controllerName.text.toLowerCase(),
        priceBuy,
        priceSell,
        _addTransactionBloc.unitStream.value,
        _addTransactionBloc.subjectUser.value,
        createdAt: _suggestion.createdAt,
        pcs: double.tryParse(pcs),
        id: _suggestion.id,
      );
    } else {
      newItem = Item(
        _controllerName.text.toLowerCase(),
        priceBuy,
        priceSell,
        _addTransactionBloc.unitStream.value,
        _addTransactionBloc.subjectUser.value,
        pcs: double.tryParse(pcs),
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      _addTransactionBloc.createItem(newItem);
    }

    newItem.pcs = double.tryParse(pcs);
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
    _controllerPieces.clear();

    _addTransactionBloc.subjectIsNewItem.sink.add(true);
  }

  void _setSuggestionCustomer(Customer customer) {
    _selectedCustomer = customer;
    _controllerCustomerName.text = customer.name;
    _addTransactionBloc.subjectIsNewCustomer.sink.add(false);
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
          title: Text('Confirmation Cancel Order?'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('No'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('Yes'),
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
        double sum = 0;
        cart.forEach(
            (item) => sum = sum + (int.parse(item.priceSell) * item.pcs));

        return AlertDialog(
          title: Text('Summary'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () async {
                String customerName = _controllerCustomerName.text;
                _controllerCustomerName.text = '';
                Navigator.of(context).pop();
                await _addTransactionBloc.createTransaction(
                    sum, customerName, _selectedCustomer);
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
                    'Buyer: ${_controllerCustomerName.text.isNotEmpty ? _controllerCustomerName.text : '-'}',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  Divider(
                    height: 4,
                    color: Colors.transparent,
                  ),
                  if (_selectedCustomer != null &&
                      _selectedCustomer.deposit > 0)
                    Text(
                      'Balance: ${currencyFormatter.format(_selectedCustomer.deposit)}',
                      style: Theme.of(context).textTheme.subtitle2,
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
                        subtitle: Text(
                          currencyFormatter.format(
                            amount,
                          ),
                        ),
                        trailing:
                            Text('${cart[index].pcs} ${cart[index].unit}'),
                      );
                    },
                  ),
                  Divider(height: 16, color: Colors.black54),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            currencyFormatter.format(sum.toDouble()),
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                      if (_selectedCustomer != null &&
                          _selectedCustomer.deposit > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text('Balance Remained: '),
                            Divider(height: 8, color: Colors.transparent),
                            Text(
                              currencyFormatter.format(
                                  _selectedCustomer.deposit - sum.toDouble()),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        )
                    ],
                  ),
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
    if (this.mounted) {
      _addTransactionBloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Transaction'),
        actions: <Widget>[
          TextButton(
            child: Text('Inspect', style: Theme.of(context).textTheme.button),
            onPressed: () {
              if (_addTransactionBloc.cart.isEmpty) {
                _buildShowSnackBar(context, 'Please add goods');
                return;
              }
              dialogSummary(context);
            },
          )
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.button,
                ),
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
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).colorScheme.primary,
                        ),
                        child: Text(isNew ? 'Add New' : 'Add',
                            style: Theme.of(context).textTheme.button),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState.validate()) {
                            if (_controllerName.text.isEmpty) {
                              _buildShowSnackBar(
                                  context, 'Goods name can\'t be empty');
                            } else if (_controllerPriceBuy.text == '0' ||
                                _controllerPriceSell.text == '0' ||
                                _controllerPieces.text == '0') {
                              _buildShowSnackBar(context, 'Value can\'t be 0');
                            } else if (_addTransactionBloc.unitStream.value ==
                                    null ||
                                _addTransactionBloc.unitStream.value.isEmpty) {
                              _buildShowSnackBar(context, 'Please select unit');
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
                      fieldNameCustomer(context),
                      SizedBox(
                        height: 16.0,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(child: fieldItemName(context)),
                          SizedBox(
                            width: 16.0,
                          ),
                          Material(
                            shape: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryVariant),
                            elevation: 2,
                            child: InkWell(
                              child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.clear)),
                              onTap: () {
                                _controllerName.clear();
                                _controllerPriceBuy.text = '0';
                                _controllerPriceSell.text = '0';
                                _controllerPieces.clear();
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      TextFormField(
                        controller: _controllerPriceBuy,
                        focusNode: _nodePriceBuy,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Buy Price',
                        ),
                        onFieldSubmitted: (val) {
                          FocusScope.of(context).requestFocus(_nodePriceSell);
                        },
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Buy Price can\'t be empty';
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
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Sell Price',
                        ),
                        onFieldSubmitted: (val) {
                          FocusScope.of(context).requestFocus(_nodePieces);
                        },
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Seel Price can\'t be empty';
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
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter(RegExp("[0-9,.]"),
                              allow: true),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                        ),
                        onFieldSubmitted: (val) {
                          FocusScope.of(context).requestFocus(_nodeUnit);
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState.validate()) {
                            if (_controllerName.text.isEmpty) {
                              _buildShowSnackBar(
                                  context, 'Goods name can\'t be empty');
                            } else if (_controllerPriceBuy.text == '0' ||
                                _controllerPriceSell.text == '0' ||
                                _controllerPieces.text == '0') {
                              _buildShowSnackBar(context, 'Value can\'t be 0');
                            } else if (_addTransactionBloc.unitStream.value ==
                                    null ||
                                _addTransactionBloc.unitStream.value.isEmpty) {
                              _buildShowSnackBar(context, 'Please select unit');
                            } else {
                              _submitItem2Cart();
                            }
                          }
                        },
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Quantity can\'t be empty';
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
                          'Cart',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      CartItem(addTransactionBloc: _addTransactionBloc)
                    ],
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<prefixEnum.ViewState>(
              stream: _addTransactionBloc.stateStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == prefixEnum.ViewState.LOADING)
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

  TypeAheadField<Customer> fieldNameCustomer(BuildContext context) {
    return TypeAheadField(
      hideOnEmpty: true,
      textFieldConfiguration: TextFieldConfiguration(
          controller: _controllerCustomerName,
          focusNode: _nodeCustomerName,
          textInputAction: TextInputAction.next,
          autofocus: false,
          decoration: InputDecoration(
            labelText: 'Customer Name',
          ),
          onChanged: (val) {
            if (val.isEmpty) {
              _addTransactionBloc.subjectIsNewCustomer.sink.add(true);
            }
          },
          onSubmitted: (val) {
            FocusScope.of(context).requestFocus(_nodeName);
          }),
      suggestionsCallback: (pattern) {
        return _addTransactionBloc.customerListStream.value
            .map((val) => val)
            .where((val) => val.name.contains(pattern))
            .toList();
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: Icon(Icons.person),
          title: Text(suggestion.name),
          subtitle: Text(currencyFormatter.format(suggestion.deposit)),
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
          textInputAction: TextInputAction.next,
          focusNode: _nodeName,
          autofocus: false,
          decoration: InputDecoration(
            labelText: 'Customer Goods',
          ),
          onChanged: (val) {
            if (val.isEmpty) {
              _addTransactionBloc.subjectIsNewItem.sink.add(true);
              _selectedCustomer = null;
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
          subtitle:
              Text(currencyFormatter.format(double.parse(suggestion.priceBuy))),
        );
      },
      onSuggestionSelected: (suggestion) {
        _setSuggestionItem(suggestion);
      },
    );
  }
}
