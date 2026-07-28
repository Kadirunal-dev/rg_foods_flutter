import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:rg_food_deneme/sepet_provider.dart';
import 'firebase_options.dart';
import 'package:rg_food_deneme/theme.dart';
import 'package:rg_food_deneme/kullanici_giris.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SepetProvider())],
      child: rg_food(),
    ),
  );
}

// ignore: camel_case_types
class rg_food extends StatelessWidget {
  const rg_food({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: AppTextStyles.myTheme,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

bool isClosed = false;

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => KullaniciGiris()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.brandPrimary,
        toolbarHeight: 30,
        titleTextStyle: AppTextStyles.titleLarge,
        foregroundColor: AppColors.brandPrimary,
      ),
      body: Container(
        padding: const EdgeInsets.only(bottom: 150.0),
        alignment: Alignment.center,
        child: Center(
          child: Image(
            image: AssetImage("assets/images/gemini2.png"),
            width: 300,
            height: 300,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
