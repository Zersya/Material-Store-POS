import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/unit.dart';
import 'package:harco_app/models/user.dart';
import 'package:harco_app/services/item_service.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:rxdart/rxdart.dart';

class AddTransactionBloc extends BaseReponseBloc<FormState> {
  ItemService _itemService = GetIt.I<ItemService>();

  BehaviorSubject<String> subjectUnitValue;
  BehaviorSubject<List<Unit>> _subjectListUnit;
  BehaviorSubject<List<Item>> _subjectListItem;
  BehaviorSubject<List<Item>> subjectCart;
  BehaviorSubject<bool> subjectIsNewItem;

  List<Item> items = List();
  List<Item> cart = List();

  AddTransactionBloc() {
    subjectUnitValue = BehaviorSubject<String>();
    _subjectListUnit = BehaviorSubject<List<Unit>>();
    _subjectListItem = BehaviorSubject<List<Item>>();
    subjectCart = BehaviorSubject<List<Item>>();
    subjectIsNewItem = BehaviorSubject<bool>();

    subjectIsNewItem.sink.add(true);
  }

  ValueStream<String> get unitStream => subjectUnitValue.stream;
  ValueStream<List<Unit>> get unitListStream => _subjectListUnit.stream;
  ValueStream<List<Item>> get itemListStream => _subjectListItem.stream;
  ValueStream<List<Item>> get cartStream => subjectCart.stream;
  ValueStream<bool> get isNewItemStream => subjectIsNewItem.stream;

  Future fetchUnit() async {
    this.subjectState.sink.add(FormState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response = await _itemService.fetchUnit();

    final listen = response.result.listen((val) {
      List<Unit> units =
          val.documents.map((val) => Unit.fromMap(val.data)).toList();
      this._subjectListUnit.sink.add(units);
      this.subjectResponse.sink.add(response);
      this.subjectState.sink.add(FormState.IDLE);
    });
    listen.onDone(() => listen.cancel());

  }

  void setCart(Item item) {
    cart.insert(0, item);
    this.subjectCart.sink.add(cart);
  }

  void clearCart() {
    cart.clear();
    this.subjectCart.sink.add(cart);
  }

  Future fetchItem() async {
    this.subjectState.sink.add(FormState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response = await _itemService.fetchItem();

    final listen = response.result.listen((val) {
      items = val.documents.map((val) => Item.fromMap(val.data)).toList();
      this._subjectListItem.sink.add(items);
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
    unit.user = User('mail@mail.com');
    MyResponse response = await _itemService.createUnit(unit);
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(FormState.IDLE);
  }

  void dispose() {
    subjectUnitValue.close();
    _subjectListUnit.close();
    _subjectListItem.close();
    subjectCart.close();
    subjectIsNewItem.close();
  }
}
