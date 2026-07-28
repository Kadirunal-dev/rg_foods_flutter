import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantsModel {
  final String id;
  final String name;
  final String imageUrlNet;
  final String phoneNumber;
  final String address;
  final String ortTeslimat;
  final bool isOpen;
  final double rating;
  final String openClose;
  final List<String> types;
  final String restaurantId;
  RestaurantsModel({
    required this.id,
    required this.name,
    required this.imageUrlNet,
    required this.phoneNumber,
    required this.address,
    required this.ortTeslimat,
    required this.isOpen,
    required this.rating,
    required this.openClose,
    required this.types,
    required this.restaurantId,
  });
  //factory yapıcı metodu, Firestore'dan gelen verileri model nesnesine dönüştürmek için kullanılır.
  //DocumentSnapshot, Firestore'daki bir belgeyi temsil eder ve verileri almak için kullanılır.
  //doc.id, Firestore'daki belgenin benzersiz kimliğini temsil eder.
  //data['name'] ?? '', Firestore'daki 'name' alanını alır
  // rating: (data['rating'] as num?)?.toDouble() ?? 0.0, // Firestore'daki 'rating' alanını alır ve double'a dönüştürür.
  // return RestaurantsModel(...), model nesnesini oluşturur ve geri döndürür.
  factory RestaurantsModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<dynamic> typesData =
        data['types'] ?? (data['type'] != null ? [data['type']] : []);
    List<String> typesList = typesData.map((e) => e.toString()).toList();
    return RestaurantsModel(
      types: typesList,
      restaurantId: data['restaurantId'] ?? '',
      id: doc.id,
      name: data['name'] ?? '',
      imageUrlNet: data['imageUrlNet'] ?? '',
      // Firebase'deki listeyi Dart List'e güvenli dönüştürme
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      ortTeslimat: data['ortTeslimat'] ?? '',
      isOpen: data['isOpen'] ?? false,
      openClose: data['openClose'] ?? '',
      // double dönüşümlerinde hata almamak için tedbir
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
