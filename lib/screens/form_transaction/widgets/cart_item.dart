import 'package:flutter/material.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/screens/form_transaction/form_transaction_bloc.dart';

class CartItem extends StatelessWidget {
  const CartItem({
    Key key,
    @required FormTransactionBloc addTransactionBloc,
  })  : _addTransactionBloc = addTransactionBloc,
        super(key: key);

  final FormTransactionBloc _addTransactionBloc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
      stream: _addTransactionBloc.cartStream,
      initialData: [],
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
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                              'Remove ${cart[index].pcs.toString()} ${cart[index].unit.toString()} ?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: Text('Remove'),
                              onPressed: () {
                                _addTransactionBloc.removeFromCart(index);
                                Navigator.pop(context);
                              },
                            )
                          ],
                        );
                      });
                },
              );
            },
          );
        }
        return Container();
      },
    );
  }
}
