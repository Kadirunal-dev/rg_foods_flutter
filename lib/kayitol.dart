import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rg_food_deneme/kullanici_giris.dart';
import 'package:rg_food_deneme/theme.dart';
import 'package:rg_food_deneme/widget/custom_app_bar.dart';

class Kayitol extends StatefulWidget {
  const Kayitol({super.key});

  @override
  State<Kayitol> createState() => _KayitolState();
}

final TextEditingController _nameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final FocusNode _nameFocusNode = FocusNode();
final FocusNode _userFocusNode = FocusNode();
final FocusNode _passwordFocusNode = FocusNode();
bool _isfocused = false;
bool _isfocused2 = false;
bool _isfocused3 = false;

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.brandPrimary,
        title: Text(
          "BAŞARILI",
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
        ),
        content: Text(
          "Kayıt işlemi başarıyla tamamlandı!",
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
              Navigator.of(context).pop(); // Pop-up'ı kapatır
            },
            child: Text(
              "Tamam",
              style: AppTextStyles.bodymedium12.copyWith(
                color: AppColors.brandPrimary,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<bool> registerUser() async {
  try {
    // UserCredential userCredential =
    await FirebaseAuth.instance
    //firebase sunucularına eposta ve parola bilgilerini gönderir ve kullanıcı oluşturur
    .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    // await userCredential.user?.sendEmailVerification();
    // debugPrint("Kullanıcıya mail gitti: ${userCredential.user?.email}");
    return true;
    // Kayıt başarılı! Yönlendirme yapabilirsin.
  } catch (e) {
    return false;
  }
}

class _KayitolState extends State<Kayitol> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(title: "Kayıt Ol"),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 70),
        child: Center(
          child: Container(
            width: 361,
            height: 438,
            alignment: Alignment.center,

            child: Column(
              children: [
                Text(
                  "KAYIT OL",
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 35),
                // Ad soyad alanı
                Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      _isfocused = hasFocus;
                    });
                  },
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen ad soyad giriniz';
                      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                        return 'Ad soyad sadece harf ve boşluk içerebilir';
                      }
                      return null;
                    },
                    focusNode: _nameFocusNode,
                    style: AppTextStyles.bodymedium16.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    autofillHints: [AutofillHints.name],

                    decoration: _customInputDecoration(
                      'Ad Soyad',
                      Icons.person_rounded,
                      _isfocused,
                      'Kadir Ünal',
                    ),
                  ),
                ),

                SizedBox(height: 20),
                // Email alanı
                Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      _isfocused2 = hasFocus;
                    });
                  },

                  child: TextFormField(
                    focusNode: _userFocusNode,
                    controller: _emailController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen email giriniz';
                      } else if (!RegExp(
                        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
                      ).hasMatch(value)) {
                        return 'Geçerli bir email adresi giriniz';
                      }
                      return null;
                    },

                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodymedium16.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    autofillHints: [AutofillHints.email],
                    decoration: _customInputDecoration(
                      'Email',
                      Icons.email_outlined,
                      _isfocused2,
                      'email@example.com',
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      _isfocused3 = hasFocus;
                    });
                  },
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen parola giriniz';
                      } else if (value.length < 6) {
                        return 'Parola en az 6 karakter olmalıdır';
                      } else if (value.contains(' ')) {
                        return 'Parola boşluk içeremez';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: true,
                    focusNode: _passwordFocusNode,
                    style: AppTextStyles.bodymedium16.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    autofillHints: [AutofillHints.password],

                    decoration: _customInputDecoration(
                      'Parola',
                      Icons.lock_outline_rounded,
                      _isfocused3,
                      '*******',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    bool isSuccess = await registerUser();
                    if (isSuccess) {
                      _emailController.clear();
                      _passwordController.clear();
                      _nameController.clear();
                      // Kayıt başarılı, giriş sayfasına yönlendir
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KullaniciGiris(),
                          ),
                        );
                        showSuccessDialog(context);
                      } else {
                        // Kayıt başarısız, hata mesajı göstermek isteyebilirsiniz
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Kayıt başarısız oldu."),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      }
                      // Giriş yapma işlevi
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
                    "KAYIT OL",
                    style: AppTextStyles.bodymedium16.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => KullaniciGiris()),
                    );
                  },
                  child: Text(
                    "Hesabınız Var mı ?",
                    style: AppTextStyles.bodyregular16.copyWith(
                      color: AppColors.textSecondary,
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

  InputDecoration? _customInputDecoration(
    String s,
    IconData icon,
    bool state,
    String h,
  ) {
    return InputDecoration(
      labelStyle: AppTextStyles.bodymedium16.copyWith(
        color: AppColors.textSecondary,
      ),
      labelText: s,
      hintText: h,
      hintStyle: AppTextStyles.bodyregular16.copyWith(
        color: AppColors.textTertiary,
      ),
      prefixIcon: Icon(
        icon,
        color: state ? AppColors.brandPrimary : AppColors.textSecondary,
      ),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
