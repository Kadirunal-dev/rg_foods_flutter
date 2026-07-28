import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rg_food_deneme/home_page.dart';
import 'package:rg_food_deneme/sifreyenileme.dart';
import 'package:rg_food_deneme/theme.dart';
import 'package:rg_food_deneme/kayitol.dart';

class KullaniciGiris extends StatefulWidget {
  const KullaniciGiris({super.key});

  @override
  State<KullaniciGiris> createState() => _KullaniciGirisState();
}

class _KullaniciGirisState extends State<KullaniciGiris> {
  List<bool> isSelected = [false];
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // ignore: non_constant_identifier_names
  final FocusNode _UserFocusNode = FocusNode();
  // ignore: non_constant_identifier_names
  final FocusNode _PasswordFocusNode = FocusNode();
  bool _isfocused = false;
  bool _isfocused2 = false;
  bool _isAccepted = false;

  // Reklamın kapatılıp kapatılmadığını takip eden bayrak
  //**************e posta onaylamak için burayı aç */
  // Future<bool> loginUser() async {
  //   try {
  //     UserCredential userCredential = await FirebaseAuth.instance
  //         .signInWithEmailAndPassword(
  //           email: _emailController.text.trim(),
  //           password: _passwordController.text.trim(),
  //         );

  //     // Kullanıcı güncel verilerini çek (onay durumunu tazelemek için)
  //     await userCredential.user?.reload();
  //     User? user = FirebaseAuth.instance.currentUser;

  //     if (user != null && user.emailVerified) {
  //       return true; // Giriş başarılı ve e-posta onaylı
  //     } else {
  //       // E-posta onaylı değilse çıkış yaptır ki yetkisiz işlem yapmasın
  //       await FirebaseAuth.instance.signOut();

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Lütfen e-posta adresinizi onaylayın.")),
  //       );
  //     }
  //     return false; // Giriş başarısız (e-posta onaylı değil)
  //   } catch (e) {
  //     debugPrint("Hata: $e");
  //     return false;
  //   }
  // }

  // eposta onaysız gitmesi için burayı aç
  Future<bool> loginUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      return true; // Bilgiler doğruysa direkt giriş başarılı
    } catch (e) {
      debugPrint("Hata: $e");
      return false; // Bilgiler yanlışsa veya bir hata oluşursa giriş başarısız
    }
  }

  @override
  void initState() {
    super.initState();
    _UserFocusNode.addListener(() {
      setState(() {
        _isfocused = _UserFocusNode.hasFocus;
      });
    });
    _PasswordFocusNode.addListener(() {
      setState(() {
        _isfocused2 = _PasswordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _UserFocusNode.dispose();
    _PasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(bottom: 5),
              child: Image.asset(
                'assets/images/sefffaf_logo.png',
                alignment: AlignmentGeometry.center,
                height: 55, // Yükseklik belirtmek taşmaları önler
              ),
            ),

            Padding(
              padding: EdgeInsetsGeometry.only(top: 5),
              child: Text(
                "RKFOODS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        automaticallyImplyLeading: false,
        automaticallyImplyActions: false,
        elevation: 10,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),

        backgroundColor: AppColors.brandPrimary,
        toolbarHeight: 55,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
        child: Center(
          child: Container(
            width: 361,
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  "KULLANICI GİRİŞİ",
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 35),
                // E-posta veya kullanıcı adı alanı
                Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      _isfocused = hasFocus;
                    });
                  },

                  child: TextFormField(
                    focusNode: _UserFocusNode,
                    style: AppTextStyles.bodymedium16.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    controller: _emailController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                      } else if (!RegExp(
                        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
                      ).hasMatch(value)) {
                        return 'Geçerli bir email adresi giriniz';
                      }
                      return null;
                    },

                    keyboardType: TextInputType.emailAddress,
                    autofillHints: [AutofillHints.email],

                    decoration: InputDecoration(
                      labelStyle: AppTextStyles.bodymedium16.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      labelText: "Kullanıcı Adı veya E-posta",
                      hintText: "example@gmail.com",
                      hintStyle: AppTextStyles.bodyregular16.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: _isfocused
                            ? AppColors.brandPrimary
                            : AppColors.textSecondary,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
                // Parola alanı
                Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      _isfocused2 = hasFocus;
                    });
                  },

                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                      } else if (value.length < 6) {
                        return 'Parola en az 6 karakter olmalıdır';
                      }
                      return null;
                    },
                    enableInteractiveSelection: false,
                    enableSuggestions: false,
                    autocorrect: false,
                    obscureText: !isSelected[0],
                    focusNode: _PasswordFocusNode,
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    style: AppTextStyles.bodymedium16.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    autofillHints: [AutofillHints.password],
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          isSelected[0]
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            isSelected[0] = !isSelected[0];
                          });
                        },
                      ),
                      labelStyle: AppTextStyles.bodymedium16.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      hintText: "Parola",
                      hintStyle: AppTextStyles.bodyregular16.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      labelText: "Parola",
                      prefixIcon: Icon(
                        Icons.lock_person,
                        color: _isfocused2
                            ? AppColors.brandPrimary
                            : AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 15),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      margin: EdgeInsets.only(right: 8, left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 30,
                      width: 20,
                      child: Checkbox(
                        value: _isAccepted,
                        onChanged: (bool? value) {
                          setState(() {
                            _isAccepted = value ?? false;
                          });
                        },
                        activeColor: AppColors.brandPrimary,
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Text(
                      "Beni Hatırla",
                      style: AppTextStyles.bodyregular16.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 90),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Sifreyenileme(),
                          ),
                        );
                        // Şifremi Unuttum işlevi
                      },
                      child: Text(
                        "Şifremi Unuttum",
                        style: AppTextStyles.bodyregular16.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 35),
                ElevatedButton(
                  onPressed: () async {
                    bool isSuccess = await loginUser();
                    if (isSuccess) {
                      if (_isAccepted == false) {
                        _emailController.clear();
                      }

                      // Giriş başarılı, ana sayfaya yönlendir

                      _passwordController.clear();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      // Giriş başarısız, hata mesajı göstermek isteyebilirsiniz
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Giriş başarısız oldu."),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Giriş Yap",
                    style: AppTextStyles.bodymedium16.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 35),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Kayitol()),
                    );
                    // Kayıt olma işlevi
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: AppColors.brandPrimary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "KAYIT OL",
                    style: AppTextStyles.bodymedium16.copyWith(
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
