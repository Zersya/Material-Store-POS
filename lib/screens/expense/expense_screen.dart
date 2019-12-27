import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:harco_app/models/expense.dart';
import 'package:harco_app/utils/enum.dart' as prefixEnum;
import 'package:harco_app/screens/expense/expense_bloc.dart';

class ExpenseScreen extends StatefulWidget {
  ExpenseScreen({Key key}) : super(key: key);

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  TextEditingController _controllerDesc = TextEditingController();
  MoneyMaskedTextController _controllerAmount = MoneyMaskedTextController(
      thousandSeparator: '.',
      initialValue: 0,
      precision: 0,
      decimalSeparator: '');

  FocusNode _nodeDesc = FocusNode();
  FocusNode _nodeAmount = FocusNode();

  ExpenseBloc _expenseBloc = ExpenseBloc();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _submitExpense() {
    if (_formKey.currentState.validate()) {
      Expense _expense = Expense(
          _controllerDesc.text,
          _controllerAmount.numberValue,
          _expenseBloc.subjectUser.value,
          DateTime.now().millisecondsSinceEpoch);
      _expenseBloc.createExpense(_expense);
      _resetField();
    }
  }

  void _resetField() {
    _controllerDesc.clear();
    _controllerAmount.text = '0';
  }

  @override
  void initState() {
    super.initState();
    _expenseBloc.responseStream.listen((response) {
      if (response.message != null) {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Pengeluaran'),
      ),
      bottomNavigationBar: SafeArea(
        child: RaisedButton(
          child: Text('Tambahkan'),
          onPressed: () {
            _submitExpense();
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
                      TextFormField(
                        controller: _controllerDesc,
                        focusNode: _nodeDesc,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Keterangan pengeluaran',
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
                          labelText: 'Nilai pengeluaran',
                        ),
                        onFieldSubmitted: (val) {
                          _submitExpense();
                          FocusScope.of(context).unfocus();
                        },
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Nilai pengeluaran tidak boleh kosong';
                          } else if (val == '0') {
                            return 'Nilai pengeluaran tidak boleh nol';
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
              stream: _expenseBloc.stateStream,
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
