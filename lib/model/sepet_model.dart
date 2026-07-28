import 'package:flutter/material.dart';
// Kendi projenin yoluna göre UrunModel'ini import etmeyi unutma:
// import 'package:rguniverse/models/urun_model.dart';

class SepetModel {
  final dynamic urun; // Burayı kendi 'UrunModel' sınıfınla değiştir
  int adet;

  SepetModel({required this.urun, this.adet = 1});

  int get toplamFiyat => (urun.fiyat * adet);
}

class SepetProvider extends ChangeNotifier {
  final List<SepetModel> _sepetListesi = [];

  List<SepetModel> get sepetListesi => _sepetListesi;

  void sepeteEkle(dynamic yeniUrun) {
    int index = _sepetListesi.indexWhere((item) => item.urun.id == yeniUrun.id);

    if (index != -1) {
      _sepetListesi[index].adet++;
    } else {
      _sepetListesi.add(SepetModel(urun: yeniUrun));
    }

    // Değişikliği tüm arayüze haber veriyoruz
    notifyListeners();
  }

  void sepettenAzalt(dynamic urun) {
    int index = _sepetListesi.indexWhere((item) => item.urun.id == urun.id);

    if (index != -1) {
      if (_sepetListesi[index].adet > 1) {
        _sepetListesi[index].adet--;
      } else {
        _sepetListesi.removeAt(index);
      }
      notifyListeners();
    }
  }

  int get genelToplam {
    int toplam = 0;
    for (var item in _sepetListesi) {
      toplam += item.toplamFiyat;
    }
    return toplam;
  }
}
