import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/models/item.dart';
import 'package:harco_app/models/unit.dart';
import 'package:harco_app/utils/enum.dart';

class ItemService {
  final FirebaseFirestore firestore;

  ItemService(this.firestore);

  Future<MyResponse> createItem(Item item) async {
    try {
      item.id = firestore.collection('items').doc().id;

      await firestore
          .collection('items')
          .doc(item.id)
          .set(item.toMap())
          .catchError((err) {
        throw Exception(err);
      });

      return MyResponse(ResponseState.SUCCESS, item,
          message: 'Berhasil menambah barang');
    } on SocketException {
      return MyResponse(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception catch (err) {
      return MyResponse(ResponseState.ERROR, null, message: err.toString());
    }
  }

  Future<MyResponse> createUnit(Unit unit) async {
    try {
      unit.id = firestore.collection('units').doc().id;

      await firestore
          .collection('units')
          .doc(unit.id)
          .set(unit.toMap())
          .catchError((err) {
        throw Exception(err);
      });

      return MyResponse(ResponseState.SUCCESS, unit,
          message: 'Berhasil menambah satuan');
    } on SocketException {
      return MyResponse(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception catch (err) {
      return MyResponse(ResponseState.ERROR, null, message: err.toString());
    }
  }

  Future<MyResponse> fetchItem() async {
    try {
      Stream<QuerySnapshot> snapshot =
          firestore.collection('items').snapshots();
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.SUCCESS, snapshot,
          message: null);
    } on SocketException {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Terjadi kesalahan');
    }
  }

  Future<MyResponse> deleteItem(String id) async {
    try {
      firestore.collection('items').doc(id).delete();
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.SUCCESS, null,
          message: 'Sukses menghapus barang');
    } on SocketException {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Terjadi kesalahan');
    }
  }

  // Future<MyResponse> searchItem(String value) async {
  //   try {
  //     Stream<QuerySnapshot> snapshot =
  //         firestore.collection('items').where('name', isEqualTo: value).snapshots();
  //     return MyResponse<Stream<QuerySnapshot>>(ResponseState.SUCCESS, snapshot,
  //         message: null);
  //   } on SocketException {
  //     return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
  //         message: 'Kesalahan jaringan');
  //   } on Exception {
  //     return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
  //         message: 'Terjadi kesalahan');
  //   }
  // }

  Future<MyResponse> fetchUnit() async {
    try {
      Stream<QuerySnapshot> snapshot =
          firestore.collection('units').snapshots();
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.SUCCESS, snapshot,
          message: null);
    } on SocketException {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Terjadi kesalahan');
    }
  }
}
