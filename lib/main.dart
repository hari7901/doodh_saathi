import 'package:DoodhSaathi/src/models/cart_model.dart';
import 'package:DoodhSaathi/src/models/cattle_model.dart';
import 'package:DoodhSaathi/src/utils/acitvity_menu_provider.dart';
import 'package:DoodhSaathi/src/utils/activity_provider.dart';
import 'package:DoodhSaathi/src/utils/cattleId.dart';
import 'package:DoodhSaathi/src/utils/cattle_changes_provider.dart';
import 'package:DoodhSaathi/src/utils/marketplace_data_provider.dart';
import 'package:DoodhSaathi/src/views/home/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CattleIdProvider()),
        ChangeNotifierProvider(create: (_) => CattleModel()),
        ChangeNotifierProvider(create: (_) => CowProvider()),
        ChangeNotifierProvider(create: (context) => ActivityProvider()),
        ChangeNotifierProvider(create: (context) => CartModel()),
        ChangeNotifierProvider(create: (context) => MenuOptionsProvider()),
        ChangeNotifierProvider(create: (context) => CattleOptionsProvider()),
      ],
        child: MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DoodhSaathi',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pa',''),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}
