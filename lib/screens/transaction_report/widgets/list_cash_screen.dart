import 'package:flutter/material.dart';
import 'package:harco_app/models/cash.dart';
import 'package:harco_app/utils/commonFunc.dart';

class ListCashScreen extends StatelessWidget {
  const ListCashScreen({Key key, this.cashs}) : super(key: key);
  final List<Cash> cashs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Kas'),),
      body: SafeArea(
        child: ListView.separated(
          itemCount: cashs.length,
          separatorBuilder: (context, index) {
            return Divider(
              height: 8,
              color: Theme.of(context).colorScheme.surface,
            );
          },
          itemBuilder: (context, index) {
            DateTime dt =
                DateTime.fromMillisecondsSinceEpoch(cashs[index].createdAt)
                    .toLocal();
            String date = '${dt.day} ${numberToStrMonth(dt.month)} ${dt.year}';
            String dateTime = '${dt.hour}:${dt.minute}';

            return ListTile(
              title: Text(
                cashs[index].description,
              ),
              subtitle: Text(fmf
                  .copyWith(amount: cashs[index].amount.toDouble())
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
            );
          },
        ),
      ),
    );
  }
}
