import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:localrental_flutter/pages/add_item_page.dart';
import 'package:localrental_flutter/pages/cart_page.dart';
import 'package:localrental_flutter/pages/home.dart';
import 'package:localrental_flutter/pages/login_page.dart';
import 'package:localrental_flutter/pages/signup_page.dart';
import 'package:provider/provider.dart';
import 'package:localrental_flutter/providers/auth_provider.dart';
import 'package:localrental_flutter/widgets/auth_wrapper.dart';
import 'package:localrental_flutter/widgets/main_navigation.dart';
import 'firebase_options.dart';
import 'package:localrental_flutter/providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      // Firebase already initialized, continue
    } else {
      rethrow;
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FitnessAuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins'),
        home: const AuthWrapper(),
        routes: {
          '/home': (context) => const MainNavigation(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/add_item': (context) => const AddItemPage(),
          '/cart': (context) => const CartPage(),
        },
      ),
    );
  }
}
