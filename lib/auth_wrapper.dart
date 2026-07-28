import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rg_food_deneme/home_page.dart';
import 'package:rg_food_deneme/kullanici_giris.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // todo FirebaseAuth.instance.authStateChanges() stream'i, kullanıcının giriş yapıp yapmadığını dinler. Eğer kullanıcı giriş yapmışsa HomePage'e yönlendirir, aksi halde KullaniciGiris sayfasını gösterir.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Eğer kullanıcı giriş yapmışsa (data varsa) Ana Sayfa'ya gönder
        if (snapshot.hasData) {
          return HomePage();
        }
        // Kullanıcı giriş yapmamışsa Giriş Ekranı'nı göster
        else {
          return KullaniciGiris();
        }
      },
    );
  }
}
