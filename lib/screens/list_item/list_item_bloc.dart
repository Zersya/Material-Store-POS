import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/services/item_service.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class ListItemBloc extends BaseReponseBloc<ViewState> {
  ItemService _itemService = GetIt.I<ItemService>();

  BehaviorSubject<List<Item>> subjectListItem;

  List<Item> items = List();

  ListItemBloc() {
    subjectListItem = BehaviorSubject<List<Item>>();
  }

  ValueStream<List<Item>> get itemListStream => subjectListItem.stream;

  Future deleteItem(Item item) async {
    this.subjectState.sink.add(ViewState.LOADING);
    items.removeWhere((val) => val.id == item.id);
    this.subjectListItem.sink.add(items);
    MyResponse response = await _itemService.deleteItem(item.id);
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(ViewState.IDLE);
  }

  Future fetchItem() async {
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response = await _itemService.fetchItem();

    final listen = response.result.listen((val) {
      items = val.docs.map((val) => Item.fromMap(val.data())).toList();
      this.subjectListItem.sink.add(items);
      this.subjectResponse.sink.add(response);

      this.subjectState.sink.add(ViewState.IDLE);
    });

    listen.onDone(() => listen.cancel());
  }

  Future searchItem(String value) async {
    this.subjectState.sink.add(ViewState.LOADING);
    // MyResponse<Stream<QuerySnapshot>> response = await _itemService.searchItem(value);

    List<Item> items = value.isEmpty
        ? this.items
        : this
            .subjectListItem
            .value
            .where((item) => item.name.contains(value))
            .toList();

    this.subjectListItem.sink.add(items);
    this.subjectState.sink.add(ViewState.IDLE);
  }

  void dispose() {
    subjectListItem.close();
  }
}
