import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_food_deneme/model/product_model.dart';
import 'package:rg_food_deneme/model/restaurants_model.dart';
import 'package:rg_food_deneme/model/urun_model.dart';
import 'package:rg_food_deneme/sepet_provider.dart';
import 'package:rg_food_deneme/theme.dart';
import 'package:rg_food_deneme/widget/custom_app_bar.dart';
// import 'package:provider/provider.dart'; // SepetProvider kullanacaksan aktif et

class RestaurantDetay extends StatefulWidget {
  final RestaurantsModel restaurant;
  const RestaurantDetay({super.key, required this.restaurant});

  @override
  State<RestaurantDetay> createState() => _RestaurantDetayState();
}

class _RestaurantDetayState extends State<RestaurantDetay> {
  // Verileri sadece bir kez çekmek için Future nesnesini State içinde saklıyoruz.
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // Sayfa ilk açıldığında Firestore isteğini bir kez başlatıyoruz.
    _productsFuture = _urunleriGetir();
  }

  // Fonksiyon adını mantıksal olarak restoran içindeki ürünleri getirdiği için güncelledik.
  Future<List<ProductModel>> _urunleriGetir() async {
    debugPrint(
      "RestaurantDetay: ${widget.restaurant.name} için '${widget.restaurant.types}' tipindeki ürünler çekiliyor...",
    );
    try {
      if (widget.restaurant.types.isEmpty) {
        debugPrint(
          "RestaurantDetay: ${widget.restaurant.name} için tip bilgisi boş, ürünler çekilemiyor.",
        );
        return [];
      }
      // 1. Doğrudan 'urunler' ana koleksiyonuna gidiyoruz.
      // 2. .where() kullanarak sadece bu restoranın 'type'ı ile eşleşen ürünleri filtreliyoruz.
      //whereIn kullanımı, birden fazla tip için de çalışacak şekilde ayarlandı.ama dikkat et en fazla 10 kategori barındırabilir
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('urunler')
          .where('type', whereIn: widget.restaurant.types)
          .get();

      return snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(doc);
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
        child: CustomAppBar(title: widget.restaurant.name),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture, // State içindeki sabit future'ı kullanıyoruz
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Bir sorun oluştu, lütfen tekrar deneyin."),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              // DÜZELTME: "restoran bulunamadı" yerine "ürün bulunamadı" olarak güncellendi.
              child: Text("Bu restorana ait ürün bulunamadı."),
            );
          }

          List<ProductModel> productsList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: productsList.length,
            itemBuilder: (context, index) {
              final product = productsList[index];
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
                          child: product.imageUrlNet.startsWith('http')
                              ? Image.network(
                                  product.imageUrlNet,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  product.imageUrlNet,
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
                              product.name,
                              style: AppTextStyles.bodymedium20.copyWith(
                                color: AppColors.brandPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${product.price} TL",
                              style: AppTextStyles.bodymedium16.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Teslim Süresi: ${product.ortTeslimat}",
                              style: AppTextStyles.bodymedium14.copyWith(
                                color: AppColors.textSecondary,
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
                                // ÇÖZÜM: 'as dynamic' kullanıp uygulamayı çökertmek yerine,
                                // ProductModel verilerini sepetin beklediği tipe dönüştürüyoruz.
                                // (Eğer sepetin beklediği modelin adı 'Urun' veya 'UrunModel' ise aşağıdaki gibi map etmelisin)
                                final urunNesnesi = UrunModel(
                                  id: product.id,
                                  kategoriId: product.type,
                                  isim: product.name,
                                  resim: product.imageUrlNet,
                                  fiyat: product
                                      .price, // Ya da sepetin beklediği fiyat değişkeni (fiyat/ucret vb.)
                                  // Varsa diğer gerekli alanları da buraya ekleyebilirsin.
                                );

                                // Artık sepetin tanıdığı ve hata vermeyecek güvenli nesneyi ekliyoruz:
                                sepet.sepeteEkle(urunNesnesi);

                                // SnackBar Çakışmasını önlemek için en temiz yöntem:
                                final messenger = ScaffoldMessenger.of(context);
                                messenger.clearSnackBars();

                                messenger.showSnackBar(
                                  SnackBar(
                                    elevation: 3,
                                    padding: const EdgeInsets.all(20),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(
                                      seconds:
                                          2, // 4 saniye kullanıcı için çok uzundur, 2 saniyeye optimize edildi
                                    ),
                                    content: Text(
                                      '${product.name} Sepete Eklendi!',
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
