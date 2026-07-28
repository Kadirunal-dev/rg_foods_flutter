import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rg_food_deneme/model/kategori_model.dart';

class FirebaseServis {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tüm kategorileri liste olarak getiren fonksiyon
  Future<List<KategoriModel>> kategorileriGetir() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .get();

      return querySnapshot.docs.map((doc) {
        return KategoriModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      debugPrint("Veri çekilirken hata oluştu: $e");
      return [];
    }
  }
}
