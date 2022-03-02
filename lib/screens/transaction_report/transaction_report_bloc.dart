import "package:collection/collection.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/helper/transBaseHelper.dart';
import 'package:harco_app/models/cash.dart';
import 'package:harco_app/services/cash_service.dart';
import 'package:harco_app/utils/commonFunc.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class TransactionReportBloc extends TransBaseHelper {
  CashService _cashService = GetIt.I<CashService>();

  BehaviorSubject<String> subjectTimeSelect;
  BehaviorSubject<String> subjectTimeStart;
  BehaviorSubject<Map<String, dynamic>> subjectTimeMap;
  BehaviorSubject<String> subjectIncome;
  BehaviorSubject<String> subjectCashOut;
  BehaviorSubject<String> subjectCashIn;

  List<Cash> cashs = List();
  List<Cash> cashsOut = List();
  List<Cash> cashsIn = List();

  TransactionReportBloc() {
    subjectTimeSelect = BehaviorSubject<String>();
    subjectTimeStart = BehaviorSubject<String>();
    subjectTimeMap = BehaviorSubject<Map<String, dynamic>>();
    subjectIncome = BehaviorSubject<String>();
    subjectCashOut = BehaviorSubject<String>();
    subjectCashIn = BehaviorSubject<String>();

    subjectTimeSelect.sink.add('all');
  }

  ValueStream<String> get timeSelectStream => subjectTimeSelect.stream;
  ValueStream<String> get timeStartStream => subjectTimeStart.stream;
  ValueStream<Map<String, dynamic>> get timeMapStream => subjectTimeMap.stream;
  ValueStream<String> get incomeStream => subjectIncome.stream;

  List<Map<String, dynamic>> getProfitDataChart() {
    List<Map<String, dynamic>> list = List();

    Map groupByDay = groupBy(
      transStream.value,
      (trans) {
        DateTime dt = DateTime.fromMillisecondsSinceEpoch(
          trans.createdAt,
        );

        return DateTime(dt.year, dt.month, dt.day);
      },
    );

    groupByDay.forEach((key, val) {
      Map<String, dynamic> map = {
        'value': val.fold(0, (sum, trans) => sum += trans.profit),
        'date': key
      };
      list.add(map);
    });
    return list;
  }

  void insertCash(customDt) {
    cashsOut = this
        .cashs
        .where((val) => customDt != null
            ? val.createdAt >= customDt.millisecondsSinceEpoch
            : true)
        .where((val) => val.mode == CashEnum.OUT.toString())
        .toList();
    double valCashOut = cashsOut.fold(0,
        (accumulator, currentElement) => accumulator + currentElement.amount);

    this.subjectCashOut.sink.add(valCashOut.toString());

    cashsIn = this
        .cashs
        .where((val) => customDt != null
            ? val.createdAt >= customDt.millisecondsSinceEpoch
            : true)
        .where((val) => val.mode == CashEnum.IN.toString())
        .toList();

    double valCashIn = cashsIn.fold(0,
        (accumulator, currentElement) => accumulator + currentElement.amount);

    this.subjectCashIn.sink.add(valCashIn.toString());
  }

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
      case '3 months':
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

    List transactions = this
        .transactions
        .where((val) => val.createdAt >= customDt.millisecondsSinceEpoch)
        .toList();

    double valIncome = transactions.fold(0.0,
        (accumulator, currentElement) => accumulator + currentElement.profit);

    subjectTimeStart.sink.add(
        '${customDt.day} ${numberToStrMonth(customDt.month)} ${customDt.year}');
    this.subjectTransactions.sink.add(transactions);
    this.subjectTimeMap.sink.add({'start': customDt, 'end': dt});
    this.subjectIncome.sink.add(valIncome.toString());

    insertCash(customDt);
  }

  Future fetchCashAll() async {
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response =
        await _cashService.fetchCashAll();

    final listen = response.result.listen((val) {
      cashs = val.docs.map((val) => Cash.fromMap(val.data())).toList();

      this.subjectTransactions.sink.add(transactions);
      this.subjectResponse.sink.add(response);
      insertCash(null);

      this.subjectState.sink.add(ViewState.IDLE);
    });

    listen.onDone(() => listen.cancel());
  }

  Future fetchTransactionAll() async {
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response =
        await transactionService.fetchTransactionAll();

    final listen = response.result.listen((val) {
      transactions = val.docs
          .map((val) => prefTrans.Transaction.fromMap(val.data()))
          .toList();
      double valIncome = 0;
      transactions.forEach((val) => valIncome = valIncome + val.profit);

      this.subjectIncome.sink.add(valIncome.toString());
      this.subjectTransactions.sink.add(transactions);
      this.subjectResponse.sink.add(response);
      this.subjectState.sink.add(ViewState.IDLE);
    });

    listen.onDone(() => listen.cancel());
  }

  Future deleteTransaction(prefTrans.Transaction transaction) async {
    this.subjectState.sink.add(ViewState.LOADING);
    transactions.removeWhere((val) => val.id == transaction.id);
    this.subjectTransactions.sink.add(transactions);
    MyResponse response =
        await transactionService.deleteTransaction(transaction);
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(ViewState.IDLE);
  }

  void dispose() {
    super.dispose();
    subjectTimeSelect.close();
    subjectTimeStart.close();
    subjectTimeMap.close();
    subjectIncome.close();
    subjectCashOut.close();
    subjectCashIn.close();
  }
}
