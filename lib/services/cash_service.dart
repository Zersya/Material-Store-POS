import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/models/cash.dart';

class CashService {
  final Firestore firestore;

  CashService(this.firestore);

  Future<MyResponse> setCash(Cash cash) async {
    try {
      if (cash.id == null) {
        cash.id = firestore.collection('cashes').document().documentID;
      }
      await firestore
          .collection('cashes')
          .document(cash.id)
          .setData(cash.toMap())
          .catchError((err) {
        throw Exception(err);
      });

      return MyResponse(ResponseState.SUCCESS, cash,
          message: 'Berhasil menambah kas');
    } on SocketException {
      return MyResponse(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception catch (err) {
      return MyResponse(ResponseState.ERROR, null, message: err.toString());
    }
  }

  Future<MyResponse> fetchCashToday() async {
    try {
      DateTime now = DateTime.now();

      Stream<QuerySnapshot> snapshot = firestore
          .collection('cashes')
          .where('createdAt',
              isGreaterThan: new DateTime(now.year, now.month, now.day, 6, 30)
                  .millisecondsSinceEpoch)
          .snapshots();

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

  Future<MyResponse> fetchCashAll() async {
    try {
      Stream<QuerySnapshot> snapshot =
          firestore.collection('cashes').snapshots();

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

  Future<MyResponse> deleteCash(String id) async {
    try {
      firestore.collection('cashes').document(id).delete();
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.SUCCESS, null,
          message: 'Sukses menghapus kas');
    } on SocketException {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Terjadi kesalahan');
    }
  }
}
