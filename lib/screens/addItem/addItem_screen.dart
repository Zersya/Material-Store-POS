import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/unit.dart';
import 'package:harco_app/screens/addItem/addItem_bloc.dart';
import 'package:harco_app/utils/enum.dart' as prefixEnum;

class AddItemScreen extends StatefulWidget {
  AddItemScreen({Key key}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
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

  TextEditingController _controllerUnit = TextEditingController();

  FocusNode _nodeName = FocusNode();
  FocusNode _nodePriceBuy = FocusNode();
  FocusNode _nodePriceSell = FocusNode();
  FocusNode _nodeUnit = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  AddItemBloc _addItemBloc = AddItemBloc();

  @override
  void initState() {
    super.initState();
    _addItemBloc.responseStream.listen((response) {
      if (response.message != null) {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        );
      }
    });

    _addItemBloc.fetchUnit();
  }

  _buildShowSnackBar(BuildContext context, String msg) {
    return _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  void _submitBarang() async {
    String priceBuy = _controllerPriceBuy.numberValue.toInt().toString();
    String priceSell = _controllerPriceSell.numberValue.toInt().toString();

    if (_addItemBloc.unitStream.value == null) {
      _buildShowSnackBar(context, 'Silahkan pilih satuan barang');
    } else if (priceSell == '0' || priceBuy == '0') {
      _buildShowSnackBar(context, 'Bilangan tidak boleh nol');
    } else {
      Item item = Item(
        _controllerName.text.toLowerCase(),
        priceBuy,
        priceSell,
        _addItemBloc.unitStream.value,
        _addItemBloc.subjectUser.value,
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      await _addItemBloc.createItem(item);
      _resetField();
    }
  }

  void _resetField() {
    _controllerName.clear();
    _controllerPriceBuy.text = '0';
    _controllerPriceSell.text = '0';
  }

  @override
  void dispose() {
    super.dispose();
    _addItemBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Tambah barang'),
      ),
      bottomNavigationBar: SafeArea(
        child: RaisedButton(
          child: Text('Tambahkan'),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _submitBarang();
            }
          },
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
                      TextFormField(
                        controller: _controllerName,
                        focusNode: _nodeName,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Nama barang',
                        ),
                        onFieldSubmitted: (val) {
                          FocusScope.of(context).requestFocus(_nodePriceBuy);
                        },
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Nama barang tidak boleh kosong';
                          }
                          return null;
                        },
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
                          FocusScope.of(context).requestFocus(_nodeUnit);
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
                        addItemBloc: _addItemBloc,
                        nodeUnit: _nodeUnit,
                        controllerUnit: _controllerUnit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<prefixEnum.FormState>(
              stream: _addItemBloc.stateStream,
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
}

class DropdownUnit extends StatelessWidget {
  const DropdownUnit(
      {Key key,
      @required AddItemBloc addItemBloc,
      @required FocusNode nodeUnit,
      @required this.controllerUnit})
      : _addItemBloc = addItemBloc,
        _nodeUnit = nodeUnit,
        super(key: key);

  final AddItemBloc _addItemBloc;
  final FocusNode _nodeUnit;
  final TextEditingController controllerUnit;

  Future dialogCreateUnit(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah satuan'),
        content: TextField(
          controller: controllerUnit,
          decoration: InputDecoration(labelText: 'contoh : kg'),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Batal'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('Tambah'),
            onPressed: () {
              Unit unit = Unit(
                controllerUnit.text.toLowerCase(),
                DateTime.now().millisecondsSinceEpoch.toString(),
              );
              _addItemBloc.createUnit(unit);
              _addItemBloc.subjectUnitValue.sink.add(unit.name);
              controllerUnit.text = '';

              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        StreamBuilder<List<Unit>>(
            stream: _addItemBloc.unitListStream,
            initialData: List(),
            builder: (context, snapshot_1) {
              if (snapshot_1.hasData) {
                List<Unit> units = snapshot_1.data;

                return Expanded(
                  flex: 7,
                  child: StreamBuilder<String>(
                      stream: _addItemBloc.unitStream,
                      initialData: null,
                      builder: (context, snapshot_2) {
                        return DropdownButton(
                          focusNode: _nodeUnit,
                          value: snapshot_2.data,
                          isExpanded: true,
                          hint: Text('Pilih satuan'),
                          onChanged: (val) {
                            _addItemBloc.subjectUnitValue.sink.add(val);
                          },
                          items: units
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit.name,
                                  child: Text(unit.name),
                                ),
                              )
                              .toList(),
                        );
                      }),
                );
              }
              return Container();
            }),
        SizedBox(
          width: 16.0,
        ),
        Expanded(
          child: Material(
            shape: Border.all(color: Theme.of(context).colorScheme.surface),
            elevation: 2,
            child: InkWell(
              child: Container(
                  padding: EdgeInsets.all(4.0), child: Icon(Icons.add)),
              onTap: () {
                dialogCreateUnit(context);
              },
            ),
          ),
        )
      ],
    );
  }
}
