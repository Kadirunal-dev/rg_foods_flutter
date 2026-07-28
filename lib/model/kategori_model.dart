class KategoriModel {
  final String id;
  final String isim;
  final String resim;

  KategoriModel({required this.id, required this.isim, required this.resim});

  // Firebase'den gelen Map verisini uygulamamıza uygun nesneye dönüştürür
  factory KategoriModel.fromFirestore(String docId, Map<String, dynamic> json) {
    return KategoriModel(
      id: docId,
      isim: json['isim'] ?? 'İsimsiz Kategori', // Null kontrolü
      resim: json['resim'] ?? '', // Null kontrolü
    );
  }
}
