import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_food_deneme/kategori_detay.dart';
import 'package:rg_food_deneme/model/restaurants_model.dart';
import 'package:rg_food_deneme/restaurant.detay.dart';
import 'package:rg_food_deneme/restaurant_card.dart';
import 'package:rg_food_deneme/restaurants_service.dart';
import 'package:rg_food_deneme/sepet_provider.dart';
import 'package:rg_food_deneme/model/kategori_model.dart';
import 'package:rg_food_deneme/kullanici_giris.dart';
import 'package:rg_food_deneme/sepete_ekle.dart';
import 'package:rg_food_deneme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> yenilenenUrunList = [];
  bool isLoading = true;
  final RestaurantsService _restaurantsService = RestaurantsService();
  late Stream<List<RestaurantsModel>>
  _restaurantsStream; // Restaurant kısmını kendi model adına göre düzenleyebilirsin
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  OverlayEntry?
  _overlayEntry; // Arama sonuçlarını göstermek için kullanılacak OverlayEntry değişkeni
  String aramaSorgusu = "";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<KategoriModel>> _kategorilerFuture;
  bool isClosed = false;
  // todo verileri yenileme fonksiyonu, RefreshIndicator'ın onRefresh parametresine atanır ve kullanıcı aşağı çektiğinde çağrılır. Tüm Firebase isteklerini aynı anda başlatır ve hepsi bitene kadar bekler.
  Future<void> _verileriFirebaseYenile() async {
    try {
      debugPrint("Firebase verileri yenileniyor...");
      // Future.wait içindeki tüm Firebase isteklerini AYNI ANDA başlatır
      // ve hepsi bitene kadar RefreshIndicator'ın dönen çemberini kapatmaz.
      await Future.wait([
        FirebaseFirestore.instance.collection('categories').get(),
        FirebaseFirestore.instance.collection('products').get(),
        FirebaseFirestore.instance.collection('kategory_images').get(),
        FirebaseFirestore.instance.collection('urunler').get(),

        // Sepet verilerini yenilemek için provider fonksiyonunu çağırıyoruz
        // Eğer bir State Management (Provider vb.) kullanıyorsan onların refresh fonksiyonları da buraya gelebilir:
        // Provider.of<SepetProvider>(context, listen: false).sepetiGuncelle(),
      ]);

      setState(() {
        debugPrint("Veriler Firebase'den başarıyla yenilendi.");
        // Gelen yeni verileri lokal listelerine aktar ve ekranı çiz
        // Örneğin, kategorileri yenilemek için:
        _kategorilerFuture = kategorileriGetir();
      });
    } catch (e) {
      debugPrint("Genel yenileme hatası: $e");
    }
  }

  // ! Firebase'den kategorileri çekmek için kullanılan fonksiyon, FutureBuilder içinde çağrılır ve sonucu ekrana basar.
  // Tüm kategorileri liste olarak getiren fonksiyon
  Future<List<KategoriModel>> kategorileriGetir() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .get();

      return querySnapshot.docs.map((doc) {
        return KategoriModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint("Veri çekilirken hata oluştu: $e");
      return [];
    }
  }

  // Controller ve onay değişkenini State içinde tanımlamak daha sağlıklıdır.
  final CarouselSliderController _controllerslider = CarouselSliderController();
  bool _exitConfirmed = false;
  int current = 0;
  @override
  void initState() {
    super.initState();
    _kategorilerFuture = kategorileriGetir();
    _verileriFirebaseYenile();
    _focusNode.addListener((_onFocusChanged));
    _restaurantsStream = _restaurantsService.streamRestaurants();

    // Kategorileri çekmek için initState içinde çağırabiliriz, ancak FutureBuilder zaten bunu yapıyor.
    // Eğer kategorileri önceden çekmek istiyorsak, burada bir Future değişkenine atayabiliriz.

    // todo popup zamanlayıcısı, şu an için devre dışı bırakıldı, ileride aktif edilebilir.
    /* Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        _showAdPopup();
      }
    });*/
  }

  // todo uygulamada popup gösterme kodu var ama şu an için devre dışı bırakıldı, ileride aktif edilebilir.
  /* void _showAdPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // Dışarıya tıklayınca da kapanabilsin
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(seconds: 5), () {});
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              //Reklam İçeriği
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // İçerik kadar yer kaplasın
                  children: [
                    //  Temsili Reklam Görseli (Kendi yerel görselini veya NetworkImage koyabilirsin)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://picsum.photos/400/300',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Haftanın Fırsatı! 🚀",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Premium üyeliğe geçişte bugüne özel %40 indirim kazandınız.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Reklamı kapat
                        //  Burada gitmek istediğin sayfaya yönlendirme kodunu yazabilirsin
                      },
                      child: const Text("Fırsatı Yakala"),
                    ),
                  ],
                ),
              ),
              // Kapatma Çarpı Butonu
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      isClosed = true;
      setState(() {
        if (isClosed == true) {
          Future.delayed(const Duration(seconds: 5), () {
            // Reklam kapandıktan sonra ana sayfaya yönlendir
            _showAdPopup();
          });
          // Reklam kapatıldıktan sonra yapılacak işlemler
        }
        //  Kullanıcı reklamı kapattığında bayrağı güncelle
      });
      //Kullanıcı reklamı el ile (çarpıdan, butondan veya dışarı tıklayarak) kapattığında burası çalışır
    });
    //3.// ADIM: 5 saniye sonra otomatik kapatma zamanlayıcısı
  }*/

  Future<bool> showSuccessDialog(BuildContext context) async {
    await showDialog(
      barrierDismissible: false,
      barrierColor: AppColors.textSecondary.withValues(alpha: 0.5),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.brandPrimary,
          title: Text(
            "ÇIKIŞ",
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
          ),
          content: Text(
            "Çıkış İşlemi Yapmak İstediğinize Emin Misiniz?",
            style: AppTextStyles.bodymedium16.copyWith(color: AppColors.white),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _exitConfirmed = true;
                Navigator.of(context).pop();
              },
              child: Text(
                "Evet",
                style: AppTextStyles.bodymedium12.copyWith(
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _exitConfirmed = false;
                Navigator.of(context).pop();
              },
              child: Text(
                "Hayır",
                style: AppTextStyles.bodymedium12.copyWith(
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
    return _exitConfirmed;
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _paneliGoster();
    } else {
      _paneliKapat();
    }
  }

  void _paneliKapat() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _paneliGoster() {
    _paneliKapat(); // Önce varsa eski paneli kapat
    // Flutter'ın çizim (render) işleminin bitmesini bekleyip overlay'i öyle ekliyoruz.
    // Panel görünmeme sorununun ana çözümü budur.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_focusNode.hasFocus) return;
      try {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry!);
      } catch (e) {
        debugPrint("Overlay yerleştirilirken hata oluştu: $e");
      }
    });
  }

  // todo arama motorunda Aşağı doğru açılan o estetik mini panelin tasarımı ve içeriği bu fonksiyon içinde oluşturulur. Arama sorgusuna göre Firebase'den filtrelenmiş ürünler burada listelenir.search paneli
  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;

    return OverlayEntry(
      builder: (context) => Positioned(
        // Genişlik ve konumlandırma hesaplaması
        width: size.width > 24 ? size.width - 24 : 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height > 0 ? 60 : 50),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              // Firestore Dinleyici
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collectionGroup('urunler')
                    .snapshots(),
                builder: (context, snapshot) {
                  // 1. HATA DURUMU KONTROLÜ
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Firebase Hatası: ${snapshot.error}"),
                    );
                  }

                  // 2. YÜKLENME DURUMU
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      ),
                    );
                  }

                  // 3. BOŞ VERİ KONTROLÜ
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Ürün bulunamadı."),
                    );
                  }

                  // 4. İSTEMCİ TARAFLI FİLTRELEME (Arama sorgusuna göre)
                  List<QueryDocumentSnapshot> filtrelenmisUrunler = [];

                  try {
                    filtrelenmisUrunler = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>?;
                      if (data == null) return false;

                      final String urunIsmi = (data['isim'] ?? '')
                          .toString()
                          .toLowerCase();
                      final String kategoriId = (data['kategoriId'] ?? '')
                          .toString()
                          .toLowerCase();

                      if (aramaSorgusu.isEmpty) return false;

                      return urunIsmi.contains(aramaSorgusu) ||
                          kategoriId.contains(aramaSorgusu);
                    }).toList();
                  } catch (filterError) {
                    debugPrint("Filtreleme hatası: $filterError");
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Veri okuma hatası oluştu."),
                    );
                  }

                  // 5. SONUÇ BOŞ İSE
                  if (filtrelenmisUrunler.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Sonuç bulunamadı.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  // 6. SONUÇ LİSTESİ
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    shrinkWrap: true,
                    itemCount: filtrelenmisUrunler.length,
                    itemBuilder: (context, index) {
                      try {
                        final urunData =
                            filtrelenmisUrunler[index].data()
                                as Map<String, dynamic>;

                        return Card(
                          elevation: 8,
                          shadowColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            tileColor: AppColors.bgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            leading: Image.network(
                              urunData['resim'] ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.fastfood),
                            ),
                            title: Text(
                              urunData['isim'] ?? 'İsimsiz',
                              style: AppTextStyles.bodymedium20.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Text(
                              "${urunData['fiyat'] ?? 0} TL",
                              style: AppTextStyles.bodymedium14.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            // TIKLAMA OLAYI: Yönlendirme mantığını temiz tutmak için
                            // aşağıda tanımladığımız özel metoda gönderiyoruz.
                            onTap: () => _onUrunTiklandi(urunData),
                          ),
                        );
                      } catch (itemError) {
                        return const SizedBox.shrink();
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Arama panelinden bir ürüne tıklandığında çalışan yardımcı metod
  Future<void> _onUrunTiklandi(Map<String, dynamic> urunData) async {
    debugPrint("======== ÜRÜN TIKLANDI ========");

    // Adım 1: Arama paneli odağını ve klavyeyi kapat
    _focusNode.unfocus();

    // NOT: Eğer Overlay'inizi ayrı bir metodla (ör. _removeOverlay()) kapatıyorsanız
    // burada onu çağırabilirsiniz. Örneğin:
    // _removeOverlay();

    bool isLoadingShown = false;

    try {
      // Adım 2: Restoran ID doğrulaması
      final String? rId = urunData['restaurantId'] as String?;
      debugPrint("Aranan restaurantId: $rId");

      if (rId == null || rId.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu ürünün restoran bilgisi eksik!')),
          );
        }
        return;
      }

      // Adım 3: İletişim sürerken ekranda geçici Yükleniyor (Dialog) göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
      isLoadingShown = true;

      // Adım 4: Firestore 'restaurants' koleksiyonundan ana restoran dökümanını çek
      DocumentSnapshot restDoc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(rId)
          .get();

      // Adım 5: Yükleniyor Dialog'unu kapat
      if (context.mounted && isLoadingShown) {
        Navigator.of(context).pop();
        isLoadingShown = false;
      }

      // Adım 6: Restoran dökümanı varsa modele çevir ve detay sayfasına yönlendir
      if (restDoc.exists) {
        RestaurantsModel tiklananRestoran = RestaurantsModel.fromFirestore(
          restDoc,
        );

        debugPrint("Yönlendirilen Restoran: ${tiklananRestoran.name}");

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RestaurantDetay(restaurant: tiklananRestoran),
            ),
          );
        }
      } else {
        // Restoran dökümanı silinmiş veya bulunamamışsa hata ver
        debugPrint("HATA: '$rId' dökümanı veritabanında yok!");
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Restoran bulunamadı: $rId")));
        }
      }
    } catch (e, stacktrace) {
      debugPrint("Yönlendirme sırasında hata: $e");
      debugPrint("Hata detayları: $stacktrace");

      // Hata durumunda da yükleniyor ekranını güvenli bir şekilde kapat
      if (context.mounted && isLoadingShown) {
        Navigator.of(context).pop();
        isLoadingShown = false;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İşlem sırasında hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus
            ?.unfocus(); // Ekrana tıklandığında klavyeyi ve paneli kapatır
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Consumer<SepetProvider>(
              builder: (context, sepet, child) {
                return Padding(
                  padding: EdgeInsets.all(9.0),
                  child: Badge(
                    largeSize: 20,
                    backgroundColor: Colors.white,
                    textColor: AppColors.brandPrimary,
                    isLabelVisible: !sepet.sepetBosMu,
                    label: Text(sepet.toplamUrunAdedi.toString()),
                    child: IconButton(
                      icon: Icon(
                        size: 28,
                        sepet.sepetBosMu
                            ? Icons.shopping_cart_outlined
                            : Icons.shopping_cart,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        final currentRoute = ModalRoute.of(context);
                        if (currentRoute?.settings.name == '/sepet') {
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: RouteSettings(name: '/sepet'),
                            builder: (context) => const SepeteEkle(),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Image.asset(
                  'assets/images/sefffaf_logo.png',
                  height: 50, // Yükseklik belirtmek taşmaları önler
                ),
              ),
              // SizedBox(width: 5),
              Padding(
                padding: EdgeInsets.only(top: 7),
                child: Text(
                  "RKFOODS",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.brandPrimary,
          toolbarHeight: 50, // 30 çok dardı, ikonlar sığmayabilir 50 idealdir
          leading: IconButton(
            onPressed: () async {
              bool exit = await showSuccessDialog(context);
              if (exit) {
                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KullaniciGiris(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            color: Colors.white,
          ),
          elevation: 10,
          shadowColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _verileriFirebaseYenile,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: TextField(
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppTextStyles.bodymedium20.fontSize,
                      ),
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: (val) {
                        setState(() {
                          aramaSorgusu = val.trim().toLowerCase();
                        });
                        _overlayEntry
                            ?.markNeedsBuild(); // Arama sorgusu değiştiğinde paneli güncelle
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            style: BorderStyle.solid,
                            color: AppColors.brandPrimary,
                            width: 4,
                          ),

                          borderRadius: BorderRadius.circular(30),
                        ),

                        hintText: 'Ürün Ketgori Veya Marka Ara...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppTextStyles.bodymedium16.fontSize,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.brandPrimary,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.brandPrimary,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    aramaSorgusu = "";
                                  });
                                  _overlayEntry?.markNeedsBuild();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // FIREBASE CAROUSEL SECTION
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('carousel_images')
                        .doc('slider_data')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return const Text("Veri yüklenemedi");
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Veriyi Map olarak alıyoruz
                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      List<dynamic> imagePaths = data['urls'] ?? [];

                      return Column(
                        children: [
                          CarouselSlider(
                            carouselController: _controllerslider,
                            options: CarouselOptions(
                              onPageChanged: (index, reason) {
                                setState(() {
                                  current = index;
                                });
                              },
                              height: 200,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              aspectRatio: 16 / 9,
                              viewportFraction: 0.8,
                            ),
                            // ÖNEMLİ: Artık sabit carouselList değil, Firebase'den gelen imagePaths kullanılıyor
                            items: imagePaths.map((path) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE84C4F),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    path.toString(),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              color: Colors.white,
                                              size: 50,
                                            ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: 25,
                          ), // Slider ile noktalar arası boşluk
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: imagePaths.asMap().entries.map((entry) {
                              return GestureDetector(
                                onTap: () =>
                                    _controllerslider.animateToPage(entry.key),
                                child: Container(
                                  width: current == entry.key
                                      ? 12.0
                                      : 8.0, // Aktif nokta daha geniş olsun
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: current == entry.key
                                        ? AppColors
                                              .brandPrimary // Aktifse bordo
                                        : AppColors.brandPrimary.withValues(
                                            alpha: 0.4,
                                          ),
                                  ), // Değilse soluk bordo
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Kategoriler",
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // 1. FutureBuilder'ı dikey genişliği (yüksekliği) sabit bir SizedBox içine alıyoruz.
                  // 140 piksel; 100px resim kutusu, altındaki boşluk ve yazı için fazlasıyla yeterlidir.
                  SizedBox(
                    height: 140,
                    child: FutureBuilder<List<KategoriModel>>(
                      future: _kategorilerFuture,
                      builder: (context, snapshot) {
                        // Veri yüklenirken loading göstergesi
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Hata veya boş veri kontrolü
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("Kategoriler yüklenemedi."),
                          );
                        }

                        List<KategoriModel> kategoriListesi = snapshot.data!;
                        //
                        return ListView.builder(
                          // shrinkWrap ve physics yatay kaydırmada iç içe kaydırma sorunlarını önler
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: kategoriListesi.length,
                          itemBuilder: (context, index) {
                            final kategori = kategoriListesi[index];

                            // Elemanların yatayda birbirine yapışık olmaması için Padding ekliyoruz
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  splashFactory: InkRipple.splashFactory,
                                  splashColor: AppColors.brandPrimary
                                      .withValues(alpha: 0.3),
                                  enableFeedback: true,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            KategoriDetay(kategori: kategori),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    margin: const EdgeInsets.all(
                                      8,
                                    ), // Resim ile yazı arasına boşluk
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: kategori.resim.startsWith('http')
                                          ? Image.network(
                                              kategori.resim,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              kategori.resim,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ), // Resmi yazıdan biraz uzaklaştırdık
                                Text(
                                  kategori.isim,
                                  style: AppTextStyles.bodymedium14.copyWith(
                                    color: AppColors.brandPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  //popüler restoranlar başlığı ve listesi
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Popüler Restoranlar",
                      style: AppTextStyles.bodymedium20.copyWith(
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                  // Restoranları Firestore'dan çekmek için StreamBuilder kullanıyoruz. Bu sayede veriler anlık olarak güncellenir.
                  StreamBuilder(
                    stream: _restaurantsStream,
                    builder: (context, snapshot) {
                      // Eğer veri yükleniyorsa, kullanıcıya bir yükleniyor göstergesi gösteriyoruz
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Bir hata oluştu!'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('Henüz hiç restoran eklenmemiş.'),
                        );
                      }
                      return Column(
                        children: snapshot.data!
                            .map(
                              (restaurant) =>
                                  RestaurantCard(restaurant: restaurant),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
