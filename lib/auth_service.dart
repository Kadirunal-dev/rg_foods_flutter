import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// todo şifre sıfırlama işlemi
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ! Şifre sıfırlama fonksiyonu - Kullanıcıdan e-posta adresini alır, Firebase'e isteği gönderir ve sonucu kullanıcıya bildirir.

  Future<bool> sendPasswordReset(BuildContext context, String email) async {
    try {
      // 1. Firebase'e isteği gönder
      await _auth.sendPasswordResetEmail(email: email.trim());

      // 2. Başarı durumunda kullanıcıyı bilgilendir
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Şifre sıfırlama bağlantısı $email adresine gönderildi.",
            ),
            backgroundColor: Colors.green,
          ),
        );
        bool durat = true;
        return durat;
      }
    } on FirebaseAuthException catch (e) {
      // 3. Özel hata durumlarını yönet
      String message = "Bir hata oluştu.";
      if (e.code == 'user-not-found') {
        message = "Bu e-posta adresine kayıtlı bir kullanıcı bulunamadı.";
      } else if (e.code == 'invalid-email') {
        message = "Lütfen geçerli bir e-posta adresi giriniz.";
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }
    bool durat = false;
    return durat;
  }
}
