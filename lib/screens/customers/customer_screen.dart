import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:harco_app/models/customer.dart';
import 'package:harco_app/screens/customers/customer_bloc.dart';
import 'package:harco_app/utils/commonFunc.dart';

class CustomerScreen extends StatefulWidget {
  CustomerScreen({Key key}) : super(key: key);

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  CustomerBloc _customerBloc = CustomerBloc();
  TextEditingController _controllerName = TextEditingController();
  MoneyMaskedTextController _controllerDeposit = MoneyMaskedTextController(
      thousandSeparator: '.',
      initialValue: 0,
      precision: 0,
      decimalSeparator: '');

  FocusNode _nodeName = FocusNode();
  FocusNode _nodeDepo = FocusNode();

  final _formKey = GlobalKey<FormState>();

  Future dialogCustomer(BuildContext context, Customer customer) {
    if (customer != null) {
      _controllerName.text = customer.name;
      _controllerDeposit.text = customer.deposit.toString();
    }
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(customer != null ? 'Update customer' : 'Add customer'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  focusNode: _nodeName,
                  controller: _controllerName,
                  decoration: InputDecoration(labelText: 'Name'),
                  onFieldSubmitted: (val) {
                    FocusScope.of(context).requestFocus(_nodeDepo);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  focusNode: _nodeDepo,
                  controller: _controllerDeposit,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Deposit'),
                  onFieldSubmitted: (val) {
                    FocusScope.of(context).unfocus();
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Deposit cannot be empty';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                Customer newCustomer = customer != null
                    ? customer
                    : Customer(name: _controllerName.text);

                newCustomer.name = _controllerName.text;
                newCustomer.deposit = _controllerDeposit.numberValue;
                _customerBloc.setCustomer(newCustomer);
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
    ).then((_) {
      _controllerName.text = '';
      _controllerDeposit.text = '0';
    });
  }

  @override
  void initState() {
    super.initState();
    _customerBloc.fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customers'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          dialogCustomer(context, null);
        },
      ),
      body: StreamBuilder<List<Customer>>(
        stream: _customerBloc.customerListStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data.isEmpty) {
            return Center(
              child: Text('Customers is empty'),
            );
          }
          return ListView.separated(
            itemCount: snapshot.data.length,
            separatorBuilder: (context, index) {
              return Divider(
                height: 8,
                color: Theme.of(context).colorScheme.surface,
              );
            },
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  dialogCustomer(context, snapshot.data[index]);
                },
                title: Text(snapshot.data[index].name),
                subtitle: Text(
                  currencyFormatter.format(snapshot.data[index].deposit),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
