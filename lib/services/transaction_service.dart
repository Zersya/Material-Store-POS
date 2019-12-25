import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;

class TransactionService {
  final Firestore firestore;

  TransactionService(this.firestore);
  
  Future<MyResponse> fetchCustomers() async {
    try {
      Stream<QuerySnapshot> snapshot =
          firestore.collection('customers').snapshots();
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

  Future<MyResponse> createCustomer(String customerName) async {
    try {
      final id = firestore.collection('customers').document().documentID;

      await firestore
          .collection('customers')
          .document(id)
          .setData({'id': id, 'name': customerName}).catchError((err) {
        throw Exception(err);
      });

      return MyResponse(ResponseState.SUCCESS, null,
          message: 'Berhasil menambah customer');
    } on SocketException {
      return MyResponse(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception catch (err) {
      return MyResponse(ResponseState.ERROR, null, message: err.toString());
    }
  }

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
          message: 'Berhasil menambah transaksi');
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
                  new DateTime(now.year, now.month, now.day - 1, 6, 30)
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
