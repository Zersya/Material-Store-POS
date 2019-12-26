import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/unit.dart';
import 'package:harco_app/models/user.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;
import 'package:harco_app/services/item_service.dart';
import 'package:harco_app/services/transaction_service.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:rxdart/rxdart.dart';

class AddTransactionBloc extends BaseReponseBloc<FormState> {
  ItemService _itemService = GetIt.I<ItemService>();
  TransactionService _transactionService = GetIt.I<TransactionService>();

  BehaviorSubject<String> subjectUnitValue;
  BehaviorSubject<List<Unit>> _subjectListUnit;
  BehaviorSubject<List<Item>> _subjectListItem;
  BehaviorSubject<List<String>> _subjectListCustomer;
  BehaviorSubject<List<Item>> subjectCart;
  BehaviorSubject<bool> subjectIsNewItem;

  List<Item> items = List();
  List<Item> cart = List();
  List<String> customers = List();

  AddTransactionBloc() {
    subjectUnitValue = BehaviorSubject<String>();
    _subjectListUnit = BehaviorSubject<List<Unit>>();
    _subjectListItem = BehaviorSubject<List<Item>>();
    subjectCart = BehaviorSubject<List<Item>>();
    subjectIsNewItem = BehaviorSubject<bool>();
    _subjectListCustomer = BehaviorSubject<List<String>>();

    subjectIsNewItem.sink.add(true);
  }

  ValueStream<String> get unitStream => subjectUnitValue.stream;
  ValueStream<List<Unit>> get unitListStream => _subjectListUnit.stream;
  ValueStream<List<Item>> get itemListStream => _subjectListItem.stream;
  ValueStream<List<Item>> get cartStream => subjectCart.stream;
  ValueStream<bool> get isNewItemStream => subjectIsNewItem.stream;
  ValueStream<List<String>> get customerListStream =>
      _subjectListCustomer.stream;

  void insert2Cart(Item item) {
    cart.insert(0, item);
    this.subjectCart.sink.add(cart);
  }

  void removeFromCart(int index) {
    cart.removeAt(index);
    this.subjectCart.sink.add(cart);
  }

  void clearCart() {
    cart.clear();
    this.subjectCart.sink.add(cart);
  }

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

  Future fetchCustomers() async {
    this.subjectState.sink.add(FormState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response =
        await _transactionService.fetchCustomers();

    final listen = response.result.listen((list) {
      customers = List<String>.from(
          list.documents.map((val) => val.data['name']).toList());
      // customers = list.documents.map((val) => val.data).toList();

      this._subjectListCustomer.sink.add(customers);
      this.subjectResponse.sink.add(response);
      this.subjectState.sink.add(FormState.IDLE);
    });
    listen.onDone(() => listen.cancel());
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

  Future createTransaction(int sumTotal, String customerName) async {
    this.subjectState.sink.add(FormState.LOADING);

    int sumProfit = 0;
    cart.forEach((item) {
      int priceSell = int.parse(item.priceSell);
      int priceBuy = int.parse(item.priceBuy);

      sumProfit = sumProfit + ((priceSell - priceBuy) * item.pcs);
    });

    prefTrans.Transaction transaction = prefTrans.Transaction(
        customerName,
        cart,
        sumProfit,
        sumTotal,
        User('mail@mail.com'),
        DateTime.now().millisecondsSinceEpoch);

    MyResponse response;
    if (customerName != '-') {
      MyResponse response =
          await _transactionService.createCustomer(customerName);
      this.subjectResponse.sink.add(response);
    }
    response = await _transactionService.createTransaction(transaction);

    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(FormState.IDLE);
    clearCart();
  }

  void dispose() {
    _subjectListUnit.close();
    _subjectListItem.close();
    _subjectListCustomer.close();

    subjectUnitValue.close();
    subjectCart.close();
    subjectIsNewItem.close();
  }
}
