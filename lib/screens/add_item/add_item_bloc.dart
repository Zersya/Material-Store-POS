import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/unit.dart';
import 'package:harco_app/models/user.dart';
import 'package:harco_app/services/item_service.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class AddItemBloc extends BaseReponseBloc<FormState> {
  ItemService _itemService = GetIt.I<ItemService>();

  BehaviorSubject<String> subjectUnitValue;
  BehaviorSubject<List<Unit>> subjectListUnit;

  AddItemBloc() {
    subjectUnitValue = BehaviorSubject<String>();
    subjectListUnit = BehaviorSubject<List<Unit>>();
  }

  ValueStream<String> get unitStream => subjectUnitValue.stream;
  ValueStream<List<Unit>> get unitListStream => subjectListUnit.stream;

  Future fetchUnit() async {
    this.subjectState.sink.add(FormState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response = await _itemService.fetchUnit();

    final listen = response.result.listen((val) {
      // this.subjectListUnit.sink.add(val.data);
      List<Unit> units =
          val.documents.map((val) => Unit.fromMap(val.data)).toList();
      this.subjectListUnit.sink.add(units);
      this.subjectResponse.sink.add(response);
      this.subjectState.sink.add(FormState.IDLE);
    });

    listen.onDone(() => listen.cancel());
  }

  Future createItem(Item item) async {
    this.subjectState.sink.add(FormState.LOADING);
    MyResponse response = await _itemService.createItem(item);
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(FormState.IDLE);
  }

  Future createUnit(Unit unit) async {
    this.subjectState.sink.add(FormState.LOADING);
    unit.createdBy = User('mail@mail.com');
    MyResponse response = await _itemService.createUnit(unit);
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(FormState.IDLE);
  }

  void dispose() {
    subjectUnitValue.close();
    subjectListUnit.close();
  }
}
