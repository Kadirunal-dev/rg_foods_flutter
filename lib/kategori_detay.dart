import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rg_food_deneme/model/kategori_model.dart';
import 'package:rg_food_deneme/sepet_provider.dart';
import 'package:rg_food_deneme/theme.dart';
import 'package:provider/provider.dart';
import 'package:rg_food_deneme/model/urun_model.dart';
import 'package:rg_food_deneme/widget/custom_app_bar.dart';

class KategoriDetay extends StatefulWidget {
  final KategoriModel kategori;
  const KategoriDetay({super.key, required this.kategori});

  @override
  State<KategoriDetay> createState() => _KategoriDetayState();
}

class _KategoriDetayState extends State<KategoriDetay> {
  // Verileri sadece bir kez çekmek için Future nesnesini State içinde saklıyoruz.
  late Future<List<UrunModel>> _urunlerFuture;

  @override
  void initState() {
    super.initState();
    // Sayfa ilk açıldığında Firestore isteğini bir kez başlatıyoruz.
    _urunlerFuture = _urunleriGetir();
  }

  Future<List<UrunModel>> _urunleriGetir() async {
    debugPrint(
      "KategoriDetay: ${widget.kategori.id} için ürünler çekiliyor...",
    );
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc('products_01')
          .collection(widget.kategori.id)
          .get();

      return snapshot.docs.map((doc) {
        return UrunModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      debugPrint("Ürünler çekilirken hata: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(title: widget.kategori.isim),
      ),
      body: FutureBuilder<List<UrunModel>>(
        future: _urunlerFuture, // State içindeki sabit future'ı kullanıyoruz
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Bu kategoriye ait ürün bulunamadı."),
            );
          }

          List<UrunModel> urunListesi = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: urunListesi.length,
            itemBuilder: (context, index) {
              final urun = urunListesi[index];

              return Card(
                color: Colors.white,
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      // 1. Ürün Resmi
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: urun.resim.startsWith('http')
                              ? Image.network(urun.resim, fit: BoxFit.cover)
                              : Image.asset(urun.resim, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 2. Ürün Bilgileri
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              urun.isim,
                              style: AppTextStyles.bodymedium20.copyWith(
                                color: AppColors.brandPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${urun.fiyat} TL",
                              style: AppTextStyles.bodymedium16.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. Sipariş/Sepet Butonu Bölümü
                      Consumer<SepetProvider>(
                        builder: (context, sepet, child) {
                          return IconButton(
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              color: Color(0xFFE89951),
                            ),
                            onPressed: () {
                              try {
                                sepet.sepeteEkle(urun);

                                // SnackBar Çakışmasını önlemek için en temiz yöntem:
                                final messenger = ScaffoldMessenger.of(context);
                                messenger.clearSnackBars();

                                messenger.showSnackBar(
                                  SnackBar(
                                    elevation: 3,
                                    padding: EdgeInsets.all(20),
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(
                                      seconds: 4,
                                    ), // 1 saniye sonra otomatik kapanır
                                    content: Text(
                                      '${urun.isim} Sepete Eklendi!',
                                      style: AppTextStyles.bodymedium16
                                          .copyWith(color: Colors.white),
                                    ),
                                    backgroundColor: AppColors.textPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                debugPrint("Sepete ekleme esnasında hata: $e");
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
