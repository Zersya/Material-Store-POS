import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/helper/transBaseHelper.dart';
import 'package:harco_app/models/expense.dart';
import 'package:harco_app/services/expense_service.dart';
import 'package:harco_app/utils/commonFunc.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class TransactionReportBloc extends TransBaseHelper {
  ExpenseService _expenseService = GetIt.I<ExpenseService>();

  BehaviorSubject<String> subjectTimeSelect;
  BehaviorSubject<String> subjectTimeStart;
  BehaviorSubject<Map<String, dynamic>> subjectTimeMap;
  BehaviorSubject<String> subjectIncome;
  BehaviorSubject<String> subjectExpense;

  List<Expense> expenses = List();

  TransactionReportBloc() {
    subjectTimeSelect = BehaviorSubject<String>();
    subjectTimeStart = BehaviorSubject<String>();
    subjectTimeMap = BehaviorSubject<Map<String, dynamic>>();
    subjectIncome = BehaviorSubject<String>();
    subjectExpense = BehaviorSubject<String>();

    subjectTimeSelect.sink.add('semua');
  }

  ValueStream<String> get timeSelectStream => subjectTimeSelect.stream;
  ValueStream<String> get timeStartStream => subjectTimeStart.stream;
  ValueStream<Map<String, dynamic>> get timeMapStream => subjectTimeMap.stream;
  ValueStream<String> get incomeStream => subjectIncome.stream;

  void getDateTime() {
    DateTime dt = DateTime.now();
    DateTime customDt;

    switch (subjectTimeSelect.value) {
      case '1 minggu':
        customDt = DateTime(dt.year, dt.month, dt.day - dt.weekday);
        break;
      case '1 bulan':
        customDt = DateTime(dt.year, dt.month, 1);
        break;
      case '3 bulan':
        customDt = DateTime(dt.year, dt.month - 3, 1);
        break;
      case '1 tahun':
        customDt = DateTime(dt.year - 1, dt.month, 1);
        break;
      case 'semua':
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

    int valIncome = transactions.fold(0,
        (accumulator, currentElement) => accumulator + currentElement.profit);

    List expenses = this
        .expenses
        .where((val) => val.createdAt >= customDt.millisecondsSinceEpoch)
        .toList();

    double valExpense = expenses.fold(0,
        (accumulator, currentElement) => accumulator + currentElement.amount);

    subjectTimeStart.sink.add(
        '${customDt.day} ${numberToStrMonth(customDt.month)} ${customDt.year}');
    this.subjectTransactions.sink.add(transactions);
    this.subjectTimeMap.sink.add({'start': customDt, 'end': dt});
    this.subjectExpense.sink.add(valExpense.toString());
    this.subjectIncome.sink.add(valIncome.toString());
  }

  Future fetchExpenseAll() async {
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response =
        await _expenseService.fetchExpenseAll();

    final listen = response.result.listen((val) {
      expenses = val.documents.map((val) => Expense.fromMap(val.data)).toList();
      double valExpense = expenses.fold(0,
          (accumulator, currentElement) => accumulator + currentElement.amount);

      this.subjectExpense.sink.add(valExpense.toString());
      this.subjectTransactions.sink.add(transactions);
      this.subjectResponse.sink.add(response);
      this.subjectState.sink.add(ViewState.IDLE);
    });

    listen.onDone(() => listen.cancel());
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
    subjectExpense.close();
  }
}
