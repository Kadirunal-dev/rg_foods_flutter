import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_food_deneme/sepet_provider.dart';
import 'package:rg_food_deneme/sepete_ekle.dart';
import 'package:rg_food_deneme/theme.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final bool leading;
  final bool otoActions;
  final List<Widget>? actions;
  // todo Bu widget, uygulamanın farklı bölümlerinde kullanılabilecek özelleştirilebilir bir AppBar sağlar. title ve actions parametreleri ile başlık ve sağdaki ikonlar dinamik olarak belirlenebilir.
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading = false,
    this.otoActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Consumer<SepetProvider>(
          builder: (context, sepet, child) {
            return Padding(
              padding: EdgeInsets.all(9.0),
              child: Badge(
                largeSize: 20,
                backgroundColor: Colors.white,
                textColor: AppColors.brandPrimary,

                // Sepette ürün yoksa Badge'i gizle (isLabelVisible)
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

      automaticallyImplyLeading: leading,
      automaticallyImplyActions: otoActions,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Image.asset(
              'assets/images/sefffaf_logo.png',
              height: 55, // Yükseklik belirtmek taşmaları önler
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 26,
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
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_ios_new_outlined),
        color: Colors.white,
      ),
      elevation: 10,
      shadowColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
    );
  }

  @override
  // ignore: override_on_non_overriding_member
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}




    