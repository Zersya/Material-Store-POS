import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _customerBloc.fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pelanggan'),
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
                child:Text('Data pelanggan kosong'),
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
                  title: Text(snapshot.data[index].name),
                  subtitle: Text(fmf
                      .copyWith(amount: snapshot.data[index].deposit)
                      .output
                      .symbolOnLeft),
                );
              },
            );
          }),
    );
  }
}
