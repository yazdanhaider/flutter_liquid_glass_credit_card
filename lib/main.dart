import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/credit_card_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const LiquidGlassCreditCardApp());
}

class LiquidGlassCreditCardApp extends StatelessWidget {
  const LiquidGlassCreditCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liquid Glass Credit Card',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CreditCardScreen(),
    );
  }
}
