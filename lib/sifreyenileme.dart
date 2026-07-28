import 'package:flutter/material.dart';
import 'package:rg_food_deneme/auth_service.dart';
import 'package:rg_food_deneme/theme.dart';
import 'package:rg_food_deneme/widget/custom_app_bar.dart';

class Sifreyenileme extends StatefulWidget {
  const Sifreyenileme({super.key});

  @override
  State<Sifreyenileme> createState() => _SifreyenilemeState();
}

class _SifreyenilemeState extends State<Sifreyenileme> {
  final FocusNode _UserFocusNode = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  bool _isfocused = false;

  @override
  void initState() {
    super.initState();
    _UserFocusNode.addListener(() {
      setState(() {
        _isfocused = _UserFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _UserFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(title: "Şifre Yenileme"),
      ),
      body: Container(
        padding: const EdgeInsets.only(bottom: 150, left: 20, right: 20),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Focus(
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
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: [AutofillHints.email],
                  decoration: InputDecoration(
                    helperText: "Lütfen kayıtlı e-posta adresinizi giriniz.",
                    helperStyle: AppTextStyles.bodymedium14.copyWith(
                      color: AppColors.textPrimary,
                    ),
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
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                bool success = await AuthService().sendPasswordReset(
                  context,
                  _emailController.text,
                );
                if (success) {
                  await Future.delayed(Duration(seconds: 1));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColors.brandPrimary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "GÖNDER",
                style: AppTextStyles.bodymedium16.copyWith(
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
