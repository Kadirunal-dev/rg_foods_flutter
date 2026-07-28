import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AramaSayfasi extends StatefulWidget {
  const AramaSayfasi({super.key});

  @override
  State<AramaSayfasi> createState() => _AramaSayfasiState();
}

class _AramaSayfasiState extends State<AramaSayfasi> {
  // 1. Değişkenlerimizi tanımlıyoruz
  List<Map<String, dynamic>> _tumUrunler =
      []; // Firebase'den gelen orijinal liste
  List<Map<String, dynamic>> _filtrelenmisUrunler =
      []; // Ekranda gösterilecek olan filtrelenmiş liste
  bool _isLoading = true;

  // Arama çubuğunu kontrol etmek için controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firebaseUrunleriGetir();
  }

  // 2. Firebase'den ürünleri çeken fonksiyon
  Future<void> _firebaseUrunleriGetir() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc('products_01')
          .collection('isim')
          .get();

      final List<Map<String, dynamic>> urunler = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _tumUrunler = urunler;
        _filtrelenmisUrunler =
            urunler; // İlk başta filtrelenmiş liste, tüm ürünlere eşit olsun
        _isLoading = false;
      });
    } catch (e) {
      print("Arama verisi çekilirken hata: $e");
    }
  }

  // 3. Arama yapan ve listeyi filtreleyen fonksiyon
  void _aramaYap(String arananKelime) {
    List<Map<String, dynamic>> sonuclar = [];

    if (arananKelime.isEmpty) {
      // Eğer arama çubuğu boşsa, tüm ürünleri geri göster
      sonuclar = _tumUrunler;
    } else {
      // Küçük/büyük harf duyarlılığını ortadan kaldırmak için iki tarafı da toLowerCase() yapıyoruz
      sonuclar = _tumUrunler.where((urun) {
        final urunAdi = urun['isim'].toString().toLowerCase();
        return urunAdi.contains(arananKelime.toLowerCase());
      }).toList();
    }

    // Ekranı yeni filtrelenmiş listeyle güncelle
    setState(() {
      _filtrelenmisUrunler = sonuclar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Ara')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.black12,
              child: Column(
                children: [
                  // --- ARAMA ÇUBUĞU (SEARCH BAR) ---
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _aramaYap(
                        value,
                      ), // Kullanıcı her harf yazdığında tetiklenir
                      decoration: InputDecoration(
                        hintText: 'Ürün adı ara...',
                        prefixIcon: const Icon(Icons.search),
                        // Arama çubuğunda yazı varsa sağ tarafa temizleme (X) butonu koyalım
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear(); // Yazıyı sil
                                  _aramaYap(''); // Listeyi sıfırla
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),

                  // --- ÜRÜN LİSTESİ ---
                  Expanded(
                    child: _filtrelenmisUrunler.isEmpty
                        ? const Center(
                            child: Text('Aradığınız ürün bulunamadı.'),
                          )
                        : ListView.builder(
                            itemCount: _filtrelenmisUrunler.length,
                            itemBuilder: (context, index) {
                              final urun = _filtrelenmisUrunler[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.shopping_bag,
                                  color: Colors.blue,
                                ),
                                title: Text(urun['isim'] ?? 'İsimsiz'),
                                subtitle: Text('${urun['fiyat'] ?? 0} TL'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
