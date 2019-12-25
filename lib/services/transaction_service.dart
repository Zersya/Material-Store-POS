import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/models/transaction.dart' as prefTrans;

class TransactionService {
  final Firestore firestore;

  TransactionService(this.firestore);

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
}
