class UrunModel {
  final String id;
  final String isim;
  final int fiyat;
  final String resim;
  final String kategoriId; // Kategoriyi birbirine bağlayan kritik alan

  UrunModel({
    required this.id,
    required this.isim,
    required this.fiyat,
    required this.resim,
    required this.kategoriId,
  });

  factory UrunModel.fromFirestore(String id, Map<String, dynamic> data) {
    return UrunModel(
      id: id, // Dokümanın kendi adı (americano)
      isim: data['isim'] ?? '',
      // Firestore'da fiyat '170' yani sayı (int) olarak girilmiş.
      // Modelinde double bekliyorsa .toDouble() eklemelisin.
      fiyat: (data['fiyat'] != null) ? data['fiyat'] as int : 0,
      kategoriId: data['kategoriId'] ?? '',
      resim: data['resim'] ?? '',
    );
  }
}
