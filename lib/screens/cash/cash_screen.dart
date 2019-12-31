import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:harco_app/models/cash.dart';
import 'package:harco_app/utils/enum.dart' as prefixEnum;
import 'package:harco_app/screens/cash/cash_bloc.dart';

class CashScreen extends StatefulWidget {
  CashScreen({Key key}) : super(key: key);

  @override
  _CashScreenState createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  TextEditingController _controllerDesc = TextEditingController();
  MoneyMaskedTextController _controllerAmount = MoneyMaskedTextController(
      thousandSeparator: '.',
      initialValue: 0,
      precision: 0,
      decimalSeparator: '');

  FocusNode _nodeDesc = FocusNode();
  FocusNode _nodeAmount = FocusNode();

  CashBloc _cashBloc = CashBloc();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _submitCash() {
    prefixEnum.CashEnum subjectCash = _cashBloc.subjectCash.value;
    if (subjectCash == null) {
      showSnackBar('Silahkan pilih kas keluar atau kas masuk');

      return;
    }
    
    if (_formKey.currentState.validate()) {
      Cash _cash = Cash(_controllerDesc.text, _controllerAmount.numberValue, subjectCash.toString(),
          _cashBloc.subjectUser.value, DateTime.now().millisecondsSinceEpoch);
      _cashBloc.createCash(_cash);
      _resetField();
    }
  }

  void _resetField() {
    _controllerDesc.clear();
    _controllerAmount.text = '0';
  }

  void showSnackBar(message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cashBloc.responseStream.listen((response) {
      if (response.message != null) {
        showSnackBar(response.message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Kas'),
      ),
      bottomNavigationBar: SafeArea(
        child: RaisedButton(
          child: Text('Tambahkan'),
          onPressed: () {
            _submitCash();
            FocusScope.of(context).unfocus();
          },
        ),
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      StreamBuilder<prefixEnum.CashEnum>(
                          stream: _cashBloc.cashEnumStream,
                          initialData: null,
                          builder: (context, snapshot) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ChoiceChip(
                                  label: Text('Kas Keluar'),
                                  selected: snapshot.data == prefixEnum.CashEnum.OUT,
                                  onSelected: (val) {
                                    _cashBloc.subjectCash.sink
                                        .add(prefixEnum.CashEnum.OUT);
                                  },
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                ChoiceChip(
                                  label: Text('Kas Masuk'),
                                  selected: snapshot.data == prefixEnum.CashEnum.IN,
                                  onSelected: (val) {
                                    _cashBloc.subjectCash.sink.add(prefixEnum.CashEnum.IN);
                                  },
                                ),
                              ],
                            );
                          }),
                      TextFormField(
                        controller: _controllerDesc,
                        focusNode: _nodeDesc,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Keterangan kas',
                        ),
                        onFieldSubmitted: (val) {
                          FocusScope.of(context).requestFocus(_nodeAmount);
                        },
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Keterangan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      TextFormField(
                        controller: _controllerAmount,
                        focusNode: _nodeAmount,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Nilai kas',
                        ),
                        onFieldSubmitted: (val) {
                          _submitCash();
                          FocusScope.of(context).unfocus();
                        },
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Nilai kas tidak boleh kosong';
                          } else if (val == '0') {
                            return 'Nilai kas tidak boleh nol';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<prefixEnum.FormState>(
              stream: _cashBloc.stateStream,
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
