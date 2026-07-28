import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String ortTeslimat; // Teslim süresi için
  final String id;
  final String name;
  final String imageUrlNet;
  final int price; // Ürün fiyatı için
  final String type; // Hangi kategoriye/restorana ait olduğunu eşlemek için
  final String restaurantId; // Hangi restoranın ürünü olduğunu eşlemek için

  ProductModel({
    required this.ortTeslimat,
    required this.id,
    required this.name,
    required this.imageUrlNet,
    required this.price,
    required this.type,
    required this.restaurantId,
  });

  // Firestore'dan gelen veriyi ProductModel nesnesine dönüştüren factory metodu
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      ortTeslimat: data['ortTeslimat'] ?? 'Bilinmiyor',
      restaurantId: data['restaurantId'] ?? '',
      id: doc.id,
      // Firestore'daki alan isimlerin (key) ne ise sol tarafa tam olarak onu yazmalısın!
      name: data['isim'] ?? 'İsimsiz Ürün',
      imageUrlNet: data['resim'] ?? '',
      price: data['fiyat'] ?? '0'.toString(),
      type: data['type'] ?? '',
    );
  }
}
