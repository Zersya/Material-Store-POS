import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/models/cash.dart';

class CashService {
  final FirebaseFirestore firestore;

  CashService(this.firestore);

  Future<MyResponse> setCash(Cash cash) async {
    try {
      if (cash.id == null) {
        cash.id = firestore.collection('cashes').doc().id;
      }
      await firestore
          .collection('cashes')
          .doc(cash.id)
          .set(cash.toMap())
          .catchError((err) {
        throw Exception(err);
      });

      return MyResponse(ResponseState.SUCCESS, cash,
          message: 'Success added cash');
    } on SocketException {
      return MyResponse(ResponseState.ERROR, null,
          message: 'Network Error');
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
          message: 'Network Error');
    } on Exception {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Unknown Error');
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
          message: 'Network Error');
    } on Exception {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Unknown Error');
    }
  }

  Future<MyResponse> deleteCash(String id) async {
    try {
      firestore.collection('cashes').doc(id).delete();
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.SUCCESS, null,
          message: 'Success deleted cash');
    } on SocketException {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Network Error');
    } on Exception {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Unknown Error');
    }
  }
}
