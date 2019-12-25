import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;
import 'package:harco_app/services/transaction_service.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc extends BaseReponseBloc<ViewState> {
  TransactionService _transactionService = GetIt.I<TransactionService>();

  BehaviorSubject<List<prefTrans.Transaction>> _subjectTransactions;

  List<prefTrans.Transaction> _transactions = List();

  HomeBloc() {
    _subjectTransactions = BehaviorSubject<List<prefTrans.Transaction>>();
  }

  ValueStream<List<prefTrans.Transaction>> get transStream =>
      _subjectTransactions.stream;

  Future fetchTransactionToday() async {
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response =
        await _transactionService.fetchTransactionToday();

    final listen = response.result.listen((val) {
      _transactions = val.documents
          .map((val) => prefTrans.Transaction.fromMap(val.data))
          .toList();
      this._subjectTransactions.sink.add(_transactions);
      this.subjectResponse.sink.add(response);

      this.subjectState.sink.add(ViewState.IDLE);
    });

    listen.onDone(() => listen.cancel());
  }

  void dispose() {
    _subjectTransactions.close();
  }
}
