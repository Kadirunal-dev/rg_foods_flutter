import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_food_deneme/sepet_provider.dart';
import 'package:rg_food_deneme/theme.dart';
import 'package:rg_food_deneme/widget/custom_app_bar.dart';

class SepeteEkle extends StatefulWidget {
  const SepeteEkle({super.key, this.urunId});

  final String? urunId;
  final int adet = 0;
  @override
  State<SepeteEkle> createState() => _SepeteEkleState();
}

class _SepeteEkleState extends State<SepeteEkle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(title: "Sepetim"),
      ),
      body: Consumer<SepetProvider>(
        builder: (context, sepet, child) {
          // 1. Durum: Sepet Boşsa
          if (sepet.sepetListesi.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Sepetiniz Şimdilik Boş Görünüyor.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // 2. Durum: Sepet Doluysa
          return Column(
            children: [
              // Ürünlerin Listelendiği Kısım
              Expanded(
                child: ListView.builder(
                  itemCount: sepet.sepetListesi.length,

                  itemBuilder: (context, index) {
                    final sepetOgesi = sepet.sepetListesi[index];
                    final urun = sepetOgesi.urun;

                    return Card(
                      color: AppColors.brandPrimary,
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
                                    ? Image.network(
                                        urun.resim,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        urun.resim,
                                        fit: BoxFit.cover,
                                      ),
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
                                      color: AppColors.bgColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${urun.fiyat} TL",
                                    style: AppTextStyles.bodymedium16.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    sepet.sepettenAzalt(urun);
                                  },
                                ),
                                Text(
                                  "${sepetOgesi.adet}",
                                  style: AppTextStyles.bodymedium20.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    sepet.sepeteEkle(urun);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Alt Sabit Bar: Toplam Tutar ve Sipariş Butonu
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Toplam Tutar:",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            "${sepet.genelToplam.toStringAsFixed(2)} TL",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          // Siparişi Onaylama İşlemi
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Sipariş başarıyla alındı! Afiyet olsun.",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // İşlem bitince sepeti temizleyip ana sayfaya dönüyoruz
                          sepet.sepetiTemizle();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Sepeti Onayla",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
