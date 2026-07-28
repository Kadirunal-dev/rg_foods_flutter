import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UrunAramaSayfasi extends StatefulWidget {
  const UrunAramaSayfasi({Key? key}) : super(key: key);

  @override
  State<UrunAramaSayfasi> createState() => _UrunAramaSayfasiState();
}

class _UrunAramaSayfasiState extends State<UrunAramaSayfasi> {
  String aramaKelimesi = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ürün & Kategori Ara")),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  // Firestore'da arama yaparken harf duyarlılığını
                  // aşmak için girdiyi küçük harfe çeviriyoruz.
                  aramaKelimesi = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Ürün veya kategori adı girin...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // SONUÇ LİSTESİ
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getSearchStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Ürün bulunamadı."));
                }

                var urunler = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: urunler.length,
                  itemBuilder: (context, index) {
                    var urun = urunler[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(urun['urunIsmi'] ?? ''),
                      subtitle: Text("Kategori: ${urun['kategoriIsmi'] ?? ''}"),
                      trailing: Text("${urun['fiyat']} TL"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Arama Durumuna Göre Sorgu Döndüren Fonksiyon
  Stream<QuerySnapshot> _getSearchStream() {
    if (aramaKelimesi.isEmpty) {
      // Boşsa tüm ürünleri getir (veya popüler olanları)
      return _firestore.collection('urunler').snapshots();
    } else {
      // Arama kelimesi `searchKeywords` dizisinde var mı diye kontrol et
      return _firestore
          .collection('urunler')
          .where('searchKeywords', arrayContains: aramaKelimesi)
          .snapshots();
    }
  }
}
