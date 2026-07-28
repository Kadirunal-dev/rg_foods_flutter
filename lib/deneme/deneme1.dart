import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UrunAramaSayfasi extends StatefulWidget {
  const UrunAramaSayfasi({Key? key}) : super(key: key);

  @override
  State<UrunAramaSayfasi> createState() => _UrunAramaSayfasiState();
}

class _UrunAramaSayfasiState extends State<UrunAramaSayfasi> {
  String aramaSorgusu = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ürün & Kategori Ara"),
        backgroundColor: Colors.orange, // Uygulama temanıza uygun renk
      ),
      body: Column(
        children: [
          // SEARCH BAR (ARAMA ÇUBUĞU)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  // Arama yaparken büyük/küçük harf sorununu çözmek için küçük harfe çeviriyoruz
                  aramaSorgusu = value.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: "Ürün ismi veya kategori kodu girin...",
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // ÜRÜN LİSTESİ (STREAMBUILDER)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Tüm kategorilerin altındaki ürünleri çekebilmek için 'collectionGroup' kullanıyoruz
              stream: FirebaseFirestore.instance
                  .collection('urunler')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Veritabanında ürün bulunamadı."),
                  );
                }

                // Firebase'den gelen dökümanları kullanıcının arama sorgusuna göre süzüyoruz
                var filtrelenmisUrunler = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;

                  // Firebase'deki alan isimleriniz: 'isim' ve 'kategoriId'
                  String urunIsmi = (data['isim'] ?? '')
                      .toString()
                      .toLowerCase();
                  String kategoriId = (data['kategoriId'] ?? '')
                      .toString()
                      .toLowerCase();

                  // Kullanıcı arama çubuğuna bir şey yazdıysa hem isimde hem kategoriId'de aratıyoruz
                  return urunIsmi.contains(aramaSorgusu) ||
                      kategoriId.contains(aramaSorgusu);
                }).toList();

                if (filtrelenmisUrunler.isEmpty) {
                  return const Center(
                    child: Text("Aranan kriterlere uygun ürün bulunamadı."),
                  );
                }

                // Listeleme Sıralaması
                return ListView.builder(
                  itemCount: filtrelenmisUrunler.length,
                  itemBuilder: (context, index) {
                    var urunData =
                        filtrelenmisUrunler[index].data()
                            as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading:
                            urunData['resim'] != null &&
                                urunData['resim'].toString().isNotEmpty
                            ? Image.network(
                                urunData['resim'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.fastfood),
                              )
                            : const Icon(Icons.fastfood),
                        title: Text(
                          urunData['isim'] ?? 'İsimsiz Ürün',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Kategori: ${urunData['kategoriId'] ?? '-'}",
                        ),
                        trailing: Text(
                          "${urunData['fiyat'] ?? 0} TL",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
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
}
