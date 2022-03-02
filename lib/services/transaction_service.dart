import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/services/customer_base_service.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;

class TransactionService extends CustomerBaseService {
  final FirebaseFirestore firestore;

  TransactionService(this.firestore) : super(firestore);

  Future<MyResponse> createTransaction(
      prefTrans.Transaction transaction) async {
    try {
      transaction.id = firestore.collection('transactions').doc().id;

      await firestore
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toMap())
          .catchError((err) {
        throw Exception(err);
      });

      return MyResponse(ResponseState.SUCCESS, transaction,
          message: 'Success add transaction', code: 'SUCCESS_ADD_TRANS');
    } on SocketException {
      return MyResponse(ResponseState.ERROR, null, message: 'Network Error');
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
              isGreaterThan: new DateTime(now.year, now.month, now.day, 00, 00)
                  .millisecondsSinceEpoch)
          .snapshots();

      return MyResponse<Stream<QuerySnapshot>>(ResponseState.SUCCESS, snapshot,
          message: null);
    } on SocketException {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Network Error');
    } on Exception {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Terjadi kesalahan');
    }
  }

  Future<MyResponse> fetchTransactionAll() async {
    try {
      Stream<QuerySnapshot> snapshot = firestore
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .snapshots();

      return MyResponse<Stream<QuerySnapshot>>(ResponseState.SUCCESS, snapshot,
          message: null);
    } on SocketException {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Network Error');
    } on Exception {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Terjadi kesalahan');
    }
  }

  Future<MyResponse> deleteTransaction(prefTrans.Transaction trx) async {
    try {
      final id = trx.id;

      firestore.collection('transactions').doc(id).delete();
      firestore.collection('customers').doc(trx.customer.id).update({
        'deposit': FieldValue.increment(trx.deposit - trx.customer.deposit)
      });
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.SUCCESS, null,
          message: 'Sukses menghapus barang');
    } on SocketException {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Network Error');
    } on Exception {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Terjadi kesalahan');
    }
  }
}
