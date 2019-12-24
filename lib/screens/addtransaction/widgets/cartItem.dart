import 'package:flutter/material.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/screens/addtransaction/addTransaction_bloc.dart';

class CartItem extends StatelessWidget {
  const CartItem({
    Key key,
    @required AddTransactionBloc addTransactionBloc,
  })  : _addTransactionBloc = addTransactionBloc,
        super(key: key);

  final AddTransactionBloc _addTransactionBloc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
      stream: _addTransactionBloc.cartStream,
      initialData: List(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Item> cart = snapshot.data;
          return ListView.separated(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: cart.length,
            separatorBuilder: (context, index) {
              return Divider(height: 1, color: Colors.black87);
            },
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(cart[index].name),
                leading: Icon(Icons.shopping_cart),
                trailing: Text(
                    '${cart[index].pcs.toString()} ${cart[index].unit.toString()}'),
              );
            },
          );
        }
        return Container();
      },
    );
  }
}