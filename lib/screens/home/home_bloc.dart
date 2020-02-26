import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/helper/transBaseHelper.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;
import 'package:harco_app/utils/enum.dart';

class HomeBloc extends TransBaseHelper {
  Future fetchProfitToday() async {
    double sumProfitToday = 0;
    transactions.forEach((val) {
      sumProfitToday = sumProfitToday + val.profit;
      print(val.profit);
    });

    subjectProfitToday.sink.add(sumProfitToday);
  }

  Future fetchTransactionToday() async {
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response =
        await transactionService.fetchTransactionToday();

    final listen = response.result.listen((val) {
      transactions = val.documents
          .map((val) => prefTrans.Transaction.fromMap(val.data))
          .toList();
      transactions = transactions.reversed.toList();
      this.subjectTransactions.sink.add(transactions);
      this.subjectResponse.sink.add(response);

      this.subjectState.sink.add(ViewState.IDLE);
      fetchProfitToday();
    });

    listen.onDone(() => listen.cancel());
  }

  Future deleteTransaction(prefTrans.Transaction transaction) async {
    this.subjectState.sink.add(ViewState.LOADING);
    transactions.removeWhere((val) => val.id == transaction.id);
    this.subjectTransactions.sink.add(transactions);
    MyResponse response = await transactionService.deleteTransaction(transaction.id);
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(ViewState.IDLE);
  }

  void dispose() {
    super.dispose();
  }
}
