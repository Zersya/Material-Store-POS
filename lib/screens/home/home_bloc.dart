import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/helper/transBaseHelper.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;
import 'package:harco_app/utils/enum.dart';

class HomeBloc extends TransBaseHelper {
  Future fetchProfitToday() async {
    int sumProfitToday = 0;
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
      this.subjectTransactions.sink.add(transactions);
      this.subjectResponse.sink.add(response);

      this.subjectState.sink.add(ViewState.IDLE);
      fetchProfitToday();
    });

    listen.onDone(() => listen.cancel());
  }

  void dispose() {
    super.dispose();
  }
}
