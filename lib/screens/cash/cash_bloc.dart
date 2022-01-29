import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/models/cash.dart';
import 'package:harco_app/services/cash_service.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class CashBloc extends BaseReponseBloc<ViewState> {
  CashService _cashService = GetIt.I<CashService>();

  BehaviorSubject<CashEnum> subjectCash;
  BehaviorSubject<List<Cash>> subjectListCash;

  CashBloc() {
    subjectCash = BehaviorSubject<CashEnum>();
    subjectListCash = BehaviorSubject<List<Cash>>();
  }

  ValueStream<CashEnum> get cashEnumStream => subjectCash.stream;
  ValueStream<List<Cash>> get listCashStream => subjectListCash.stream;

  Future setCash(Cash cash) async {
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse response = await _cashService.setCash(cash);
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(ViewState.IDLE);
  }

  Future fetchCashAll() async {
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response =
        await _cashService.fetchCashAll();

    final listen = response.result.listen((val) {
      List<Cash> cashes =
          val.docs.map((val) => Cash.fromMap(val.data())).toList();

      this.subjectListCash.sink.add(cashes);
      this.subjectResponse.sink.add(response);
      this.subjectState.sink.add(ViewState.IDLE);
    });

    listen.onDone(() => listen.cancel());
  }

  Future deleteCash(Cash cash) async {
    this.subjectState.sink.add(ViewState.LOADING);
    List<Cash> cashes = subjectListCash.value;
    cashes.removeWhere((val) => val.id == cash.id);
    this.subjectListCash.sink.add(cashes);
    MyResponse response = await _cashService.deleteCash(cash.id);
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(ViewState.IDLE);
  }

  @override
  void dispose() {
    super.dispose();
    subjectCash.close();
    subjectListCash.close();
  }
}
