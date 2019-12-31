import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/models/cash.dart';
import 'package:harco_app/services/cash_service.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';


class CashBloc extends BaseReponseBloc<FormState>{
  CashService _cashService = GetIt.I<CashService>();

  BehaviorSubject<CashEnum> subjectCash;

  CashBloc() {
    subjectCash = BehaviorSubject<CashEnum>();
  }

  ValueStream<CashEnum> get cashEnumStream => subjectCash.stream;

  Future createCash(Cash cash) async {
    this.subjectState.sink.add(FormState.LOADING);
    MyResponse response = await _cashService.createCash(cash);
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(FormState.IDLE);
  }

  @override
  void dispose() {
    super.dispose();
    subjectCash.close();
  }
}