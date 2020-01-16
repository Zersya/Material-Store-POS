import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/services/transaction_service.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:rxdart/rxdart.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;

class TransBaseHelper extends BaseReponseBloc<ViewState> {
  TransactionService transactionService = GetIt.I<TransactionService>();

  BehaviorSubject<List<prefTrans.Transaction>> subjectTransactions;
  BehaviorSubject<int> subjectProfitToday;

  List<prefTrans.Transaction> transactions = List();

  TransBaseHelper() {
    subjectTransactions = BehaviorSubject<List<prefTrans.Transaction>>();
    subjectProfitToday = BehaviorSubject<int>();
  }

  ValueStream<List<prefTrans.Transaction>> get transStream =>
      subjectTransactions.stream;

  ValueStream<int> get profitTodayStream => subjectProfitToday.stream;

  double get omzet => transactions.fold(0, (a, b) => a + b.total);

  void dispose() {
    subjectTransactions.close();
    subjectProfitToday.close();
  }
}
