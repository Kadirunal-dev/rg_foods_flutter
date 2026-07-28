import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false; // Checkbox durumu
  final TextEditingController _userController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // Uygulama açılınca veriyi yükle
  }

  // Hafızadaki veriyi getir
  Future<void> _loadUserInfo() async {
    // SharedPreferences kullanarak kaydedilmiş kullanıcı bilgilerini alıyoruz
    SharedPreferences prefs = await SharedPreferences.getInstance();//
    setState(() {
      _userController.text = prefs.getString('username') ?? "";
      _rememberMe = prefs.getBool('remember_me') ?? false;
    });
  }

  // Giriş butonuna basınca veriyi kaydet
  Future<void> _handleLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('username', _userController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.clear(); // Hatırlama istenmiyorsa sil
    }
    // Giriş işlemleri...
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(controller: _userController),
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() => _rememberMe = value!);
              },
            ),
            Text("Beni Hatırla"),
          ],
        ),
        ElevatedButton(onPressed: _handleLogin, child: Text("Giriş Yap")),
      ],
    );
  }
}
