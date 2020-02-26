import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:harco_app/models/cash.dart';
import 'package:harco_app/utils/commonFunc.dart';
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

  void _submitCash(Cash cash) {
    prefixEnum.CashEnum subjectCash = _cashBloc.subjectCash.value;
    if (subjectCash == null) {
      Navigator.of(context).pop();
      showSnackBar('Silahkan pilih kas keluar atau kas masuk');
      return;
    }

    if (_formKey.currentState.validate()) {
      Cash _cash = Cash(
        _controllerDesc.text,
        _controllerAmount.numberValue,
        subjectCash.toString(),
        _cashBloc.subjectUser.value,
        DateTime.now().millisecondsSinceEpoch,
        id: cash?.id ?? null,
      );

      _cashBloc.setCash(_cash);
      _resetField();
      Navigator.of(context).pop();
    }
  }

  void _resetField() {
    _controllerDesc.clear();
    _controllerAmount.text = '0';
    _cashBloc.subjectCash.sink.add(null);
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
    _cashBloc.fetchCashAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Kas'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialogForm(context);
        },
      ),
      body: StreamBuilder<List<Cash>>(
        stream: _cashBloc.listCashStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Cash> cashes = snapshot.data;

            if (cashes.isEmpty) {
              return Center(
                child: Text(
                  'Tidak ada kas',
                  style: Theme.of(context).textTheme.headline,
                ),
              );
            }

            return ListView.separated(
              itemCount: cashes.length,
              separatorBuilder: (context, index) {
                return Divider(
                  height: 8,
                  color: Theme.of(context).colorScheme.surface,
                );
              },
              itemBuilder: (context, index) {
                DateTime dt =
                    DateTime.fromMillisecondsSinceEpoch(cashes[index].createdAt)
                        .toLocal();
                String date =
                    '${dt.day} ${numberToStrMonth(dt.month)} ${dt.year}';
                String dateTime = '${dt.hour}:${dt.minute}';
                String category =
                    cashes[index].mode == 'CashEnum.IN' ? 'Masuk' : 'Keluar';
                return ListTile(
                  contentPadding: EdgeInsets.only(left: 16, right: 16.0),
                  leading: Card(
                    elevation: 4,
                    child: Container(
                      height: 60,
                      width: 60,
                      color: category == 'Keluar'
                          ? Theme.of(context).colorScheme.primaryVariant
                          : Theme.of(context).colorScheme.secondaryVariant,
                      child: Center(
                        child: Text(
                          category,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    cashes[index].description,
                  ),
                  subtitle: Text(fmf
                      .copyWith(amount: cashes[index].amount.toDouble())
                      .output
                      .symbolOnLeft),
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
                            .body2
                            .copyWith(color: Colors.black54),
                      )
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text('Menu'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                title: Text('Perbaharui'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  showDialogForm(context, cash: cashes[index])
                                      .then((val) {
                                    if (val == null || !val) {
                                      _resetField();
                                    }
                                  });
                                },
                              ),
                              Divider(
                                color: Colors.black87,
                              ),
                              ListTile(
                                title: Text('Hapus'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  showDialogConfrmDelete(
                                      context, cashes[index]);
                                },
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future showDialogConfrmDelete(BuildContext context, cash) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Ya',
              ),
              onPressed: () {
                _cashBloc.deleteCash(cash).then((_) {
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
    );
  }

  Future showDialogForm(BuildContext context, {Cash cash}) {
    if (cash != null) {
      prefixEnum.CashEnum cashEnum = cash.mode == 'CashEnum.IN'
          ? prefixEnum.CashEnum.IN
          : prefixEnum.CashEnum.OUT;
      _cashBloc.subjectCash.add(cashEnum);
      _controllerAmount.text = cash.amount.toInt().toString();
      _controllerDesc.text = cash.description;
    }
    return showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: SizedBox(
            height: 300,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                                        selected: snapshot.data ==
                                            prefixEnum.CashEnum.OUT,
                                        labelStyle: TextStyle(
                                            color: snapshot.data ==
                                                    prefixEnum.CashEnum.OUT
                                                ? Colors.white
                                                : Colors.black87),
                                        selectedColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                                        selected: snapshot.data ==
                                            prefixEnum.CashEnum.IN,
                                        selectedColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        labelStyle: TextStyle(
                                            color: snapshot.data ==
                                                    prefixEnum.CashEnum.IN
                                                ? Colors.white
                                                : Colors.black87),
                                        onSelected: (val) {
                                          _cashBloc.subjectCash.sink
                                              .add(prefixEnum.CashEnum.IN);
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
                                FocusScope.of(context)
                                    .requestFocus(_nodeAmount);
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
                                _submitCash(cash);
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: FlatButton(
                      color: Theme.of(context).colorScheme.primary,
                      child: Text(
                        cash != null ? 'Perbaharui' : 'Tambahkan',
                        style: Theme.of(context).textTheme.button,
                      ),
                      onPressed: () {
                        _submitCash(cash);
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                ),
                StreamBuilder<prefixEnum.ViewState>(
                    stream: _cashBloc.stateStream,
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
          ),
        );
      },
    );
  }
}
