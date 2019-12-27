import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/services/auth_service.dart';
import 'package:harco_app/services/expense_service.dart';
import 'package:harco_app/services/item_service.dart';
import 'package:harco_app/services/transaction_service.dart';

GetIt getIt = GetIt.instance;

void locator(Firestore firestore, FirebaseAuth auth, bool isTest) {
      
  if (isTest) {
    getIt.reset();
  }

  getIt.registerLazySingleton<ItemService>(() => ItemService(firestore));
  getIt.registerLazySingleton<TransactionService>(() => TransactionService(firestore));
  getIt.registerLazySingleton<AuthService>(() => AuthService(firestore, auth));
  getIt.registerLazySingleton<ExpenseService>(() => ExpenseService(firestore));
  
  
}
