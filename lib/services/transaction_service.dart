import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/services/customer_base_service.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;

class TransactionService extends CustomerBaseService{
  final Firestore firestore;

  TransactionService(this.firestore) : super(firestore);

  Future<MyResponse> createTransaction(
      prefTrans.Transaction transaction) async {
    try {
      transaction.id =
          firestore.collection('transactions').document().documentID;

      await firestore
          .collection('transactions')
          .document(transaction.id)
          .setData(transaction.toMap())
          .catchError((err) {
        throw Exception(err);
      });

      return MyResponse(ResponseState.SUCCESS, transaction,
          message: 'Berhasil menambah transaksi', code: 'SUCCESS_ADD_TRANS');
    } on SocketException {
      return MyResponse(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception catch (err) {
      return MyResponse(ResponseState.ERROR, null, message: err.toString());
    }
  }

  Future<MyResponse> fetchTransactionToday() async {
    try {
      DateTime now = DateTime.now();

      Stream<QuerySnapshot> snapshot = firestore
          .collection('transactions')
          .where('createdAt',
              isGreaterThan:
                  new DateTime(now.year, now.month, now.day, 6, 30)
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

  Future<MyResponse> fetchTransactionAll() async {
    try {
      Stream<QuerySnapshot> snapshot =
          firestore.collection('transactions').snapshots();

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
