import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/customer_base_helper.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/models/customer.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/unit.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;
import 'package:harco_app/services/item_service.dart';
import 'package:harco_app/services/transaction_service.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:rxdart/rxdart.dart';

class FormTransactionBloc extends CustomerBaseHelper {
  ItemService _itemService = GetIt.I<ItemService>();
  TransactionService _transactionService = GetIt.I<TransactionService>();

  BehaviorSubject<String> subjectUnitValue;
  BehaviorSubject<List<Unit>> _subjectListUnit;
  BehaviorSubject<List<Item>> _subjectListItem;
  BehaviorSubject<List<Item>> subjectCart;
  BehaviorSubject<bool> subjectIsNewItem;
  BehaviorSubject<bool> subjectIsNewCustomer;

  List<Item> items = List();
  List<Item> cart = List();

  FormTransactionBloc() {
    subjectUnitValue = BehaviorSubject<String>();
    _subjectListUnit = BehaviorSubject<List<Unit>>();
    _subjectListItem = BehaviorSubject<List<Item>>();
    subjectCart = BehaviorSubject<List<Item>>();
    subjectIsNewItem = BehaviorSubject<bool>();
    subjectIsNewCustomer = BehaviorSubject<bool>();

    subjectIsNewItem.sink.add(true);
    subjectIsNewCustomer.sink.add(true);
  }

  ValueStream<String> get unitStream => subjectUnitValue.stream;
  ValueStream<List<Unit>> get unitListStream => _subjectListUnit.stream;
  ValueStream<List<Item>> get itemListStream => _subjectListItem.stream;
  ValueStream<List<Item>> get cartStream => subjectCart.stream;
  ValueStream<bool> get isNewItemStream => subjectIsNewItem.stream;

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
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response = await _itemService.fetchUnit();

    final listen = response.result.listen((val) {
      List<Unit> units =
          val.documents.map((val) => Unit.fromMap(val.data)).toList();
      this._subjectListUnit.sink.add(units);
      this.subjectResponse.sink.add(response);
      this.subjectState.sink.add(ViewState.IDLE);
    });
    listen.onDone(() => listen.cancel());
  }

  Future fetchItem() async {
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response = await _itemService.fetchItem();

    final listen = response.result.listen((val) {
      items = val.documents.map((val) => Item.fromMap(val.data)).toList();

      this._subjectListItem.sink.add(items);
      this.subjectResponse.sink.add(response);
      this.subjectState.sink.add(ViewState.IDLE);
    });
    listen.onDone(() => listen.cancel());
  }

  Future createItem(Item item) async {
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse response = await _itemService.createItem(item);
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(ViewState.IDLE);
  }

  Future createUnit(Unit unit) async {
    this.subjectState.sink.add(ViewState.LOADING);
    unit.createdBy = this.subjectUser.value;
    MyResponse response = await _itemService.createUnit(unit);
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(ViewState.IDLE);
  }

  Future createTransaction(
      int sumTotal, String customerName, Customer selectedCust) async {
    this.subjectState.sink.add(ViewState.LOADING);

    int sumProfit = 0;
    cart.forEach((item) {
      int priceSell = int.parse(item.priceSell);
      int priceBuy = int.parse(item.priceBuy);

      sumProfit = sumProfit + ((priceSell - priceBuy) * item.pcs);
    });

    Customer customer = selectedCust ??
        Customer(
            name: customerName, deposit: 0, createdBy: this.subjectUser.value);

    prefTrans.Transaction transaction = prefTrans.Transaction(
        customer,
        cart,
        sumProfit,
        sumTotal,
        customer.deposit,
        this.subjectUser.value,
        DateTime.now().millisecondsSinceEpoch);

    if (customer.deposit > 0) {
      customer.deposit -= sumTotal;
      if (customer.deposit < 0) {
        customer.deposit = 0;
      }
      await _transactionService.setCustomer(customer);
    }

    if (subjectIsNewCustomer.value &&
        customerName.isNotEmpty &&
        !this.subjectListCustomer.value.contains(customerName)) {
      await _transactionService.setCustomer(customer);
    }

    transaction.customer = customer;
    MyResponse response =
        await _transactionService.createTransaction(transaction);

    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(ViewState.IDLE);
    clearCart();
  }

  void dispose() {
    _subjectListUnit.close();
    _subjectListItem.close();

    subjectUnitValue.close();
    subjectCart.close();
    subjectIsNewItem.close();
    subjectIsNewCustomer.close();
  }
}
