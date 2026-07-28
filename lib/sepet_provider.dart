import 'package:flutter/material.dart';
import 'package:rg_food_deneme/model/sepet_model.dart';
import 'package:rg_food_deneme/model/urun_model.dart';

class SepetProvider extends ChangeNotifier {
  // Sepetteki ürünlerin listesi
  final List<SepetModel> _sepetListesi = [];

  List<SepetModel> get sepetListesi => _sepetListesi;
  bool get sepetBosMu => _sepetListesi.isEmpty;
  int get toplamUrunAdedi {
    int toplam = 0;
    for (var item in _sepetListesi) {
      toplam += item.adet;
    }
    return toplam;
  }

  // 1. Sepete Ürün Ekleme Fonksiyonu
  void sepeteEkle(UrunModel yeniUrun) {
    // Ürün sepette zaten var mı kontrol et
    int index = _sepetListesi.indexWhere((item) => item.urun.id == yeniUrun.id);

    if (index != -1) {
      // Ürün zaten varsa adetini 1 artır
      _sepetListesi[index].adet++;
    } else {
      // Ürün ilk defa ekleniyorsa listeye yeni SepetModel olarak ekle
      _sepetListesi.add(SepetModel(urun: yeniUrun));
    }

    // Arayüzün güncellenmesi için haber ver
    notifyListeners();
  }

  // 2. Sepetten Ürün Azaltma/Çıkarma Fonksiyonu
  void sepettenAzalt(UrunModel urun) {
    int index = _sepetListesi.indexWhere((item) => item.urun.id == urun.id);

    if (index != -1) {
      if (_sepetListesi[index].adet > 1) {
        _sepetListesi[index].adet--;
      } else {
        // Adet 1 ise ve azaltılmak isteniyorsa ürünü tamamen sil
        _sepetListesi.removeAt(index);
      }
      notifyListeners();
    }
  }

  // 3. Toplam Sepet Tutarını Hesaplama
  double get genelToplam {
    double toplam = 0;
    for (var item in _sepetListesi) {
      toplam += item.toplamFiyat;
    }
    return toplam;
  }

  // 4. Sepeti Tamamen Temizleme (Sipariş verildikten sonra)
  void sepetiTemizle() {
    _sepetListesi.clear();
    notifyListeners();
  }
}
