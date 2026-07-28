import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:rg_food_deneme/model/restaurants_model.dart'; // Az önce oluşturduğumuz model
// Bu servis, Firestore'dan restoran verilerini çekmek için kullanılacak.
class RestaurantsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// Firestore'dan restoran verilerini çekmek için bir metot
// Bu metot, Firestore'daki 'restaurants' koleksiyonundan verileri alır ve
// her bir belgeyi RestaurantsModel nesnesine dönüştürür.
// Eğer bir hata oluşursa, boş bir liste döndürür ve hatayı debug konsoluna yazdırır.
  Future<List<RestaurantsModel>> getRestaurants() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('restaurants')
          .get();
      return querySnapshot.docs
          .map((doc) => RestaurantsModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('hata restorantlar yüklenemedi: $e');
      return [];
    }
  }
// Bu metot, Firestore'daki 'restaurants' koleksiyonundan verileri sürekli olarak dinler ve
// her bir belgeyi RestaurantsModel nesnesine dönüştürür.
  Stream<List<RestaurantsModel>> streamRestaurants() {
    return _firestore.collection('restaurants').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RestaurantsModel.fromFirestore(doc))
          .toList();
    });
  }
}
