import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/services/item_service.dart';

GetIt getIt = GetIt.instance;

void locator(Firestore firestore, bool isTest) {
      
  if (isTest) {
    getIt.reset();
  }

  getIt.registerLazySingleton<ItemService>(() => ItemService(firestore));
  
}
