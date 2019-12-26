import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/helper/transBaseHelper.dart';
import 'package:harco_app/utils/commonFunc.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class TransactionReportBloc extends TransBaseHelper {
  BehaviorSubject<String> subjectTimeSelect;
  BehaviorSubject<String> subjectTimeStart;
  BehaviorSubject<Map<String, dynamic>> subjectTimeMap;
  BehaviorSubject<String> subjectIncome;

  TransactionReportBloc() {
    subjectTimeSelect = BehaviorSubject<String>();
    subjectTimeStart = BehaviorSubject<String>();
    subjectTimeMap = BehaviorSubject<Map<String, dynamic>>();
    subjectIncome = BehaviorSubject<String>();
  }

  ValueStream<String> get timeSelectStream => subjectTimeSelect.stream;
  ValueStream<String> get timeStartStream => subjectTimeStart.stream;
  ValueStream<Map<String, dynamic>> get timeMapStream => subjectTimeMap.stream;
  ValueStream<String> get incomeStream => subjectIncome.stream;

  void getDateTime() {
    DateTime dt = DateTime.now();
    DateTime customDt;

    switch (subjectTimeSelect.value) {
      case '1 week':
        customDt = DateTime(dt.year, dt.month, dt.day - dt.weekday);
        break;
      case '1 month':
        customDt = DateTime(dt.year, dt.month, 1);
        break;
      case '3 month':
        customDt = DateTime(dt.year, dt.month - 3, 1);
        break;
      case '1 year':
        customDt = DateTime(dt.year - 1, dt.month, 1);
        break;
      case 'all':
        customDt = DateTime(2019);
        break;
      default:
        customDt = DateTime(dt.year, dt.month, dt.day - dt.weekday);
        break;
    }
    subjectTimeStart.sink.add(
        '${customDt.day} ${numberToStrMonth(customDt.month)} ${customDt.year}');

    List transactions = this
        .transactions
        .where((val) => val.createdAt >= customDt.millisecondsSinceEpoch)
        .toList();

    int valIncome = 0;
    transactions.forEach((val) => valIncome = valIncome + val.profit);

    this.subjectTransactions.sink.add(transactions);
    this.subjectTimeMap.sink.add({'start': customDt, 'end': dt});
    this.subjectIncome.sink.add(valIncome.toString());
  }

  Future fetchTransactionAll() async {
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response =
        await transactionService.fetchTransactionAll();

    final listen = response.result.listen((val) {
      transactions = val.documents
          .map((val) => prefTrans.Transaction.fromMap(val.data))
          .toList();
      int valIncome = 0;
      transactions.forEach((val) => valIncome = valIncome + val.profit);

      this.subjectIncome.sink.add(valIncome.toString());
      this.subjectTransactions.sink.add(transactions);
      this.subjectResponse.sink.add(response);
      this.subjectState.sink.add(ViewState.IDLE);
    });

    listen.onDone(() => listen.cancel());
  }

  void dispose() {
    super.dispose();
    subjectTimeSelect.close();
    subjectTimeStart.close();
    subjectTimeMap.close();
    subjectIncome.close();
  }
}
