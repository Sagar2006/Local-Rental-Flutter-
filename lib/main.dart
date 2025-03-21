import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:localrental_flutter/pages/add_item_page.dart';
import 'package:localrental_flutter/pages/cart_page.dart';
import 'package:localrental_flutter/pages/login_page.dart';
import 'package:localrental_flutter/pages/signup_page.dart';
import 'package:provider/provider.dart';
import 'package:localrental_flutter/providers/auth_provider.dart';
import 'package:localrental_flutter/widgets/auth_wrapper.dart';
import 'package:localrental_flutter/widgets/main_navigation.dart';
import 'firebase_options.dart';
import 'package:localrental_flutter/providers/cart_provider.dart';
import 'package:localrental_flutter/services/cart_service.dart';
// Add these new imports
import 'package:localrental_flutter/pages/edit_item_page.dart';
import 'package:localrental_flutter/models/item_display_model.dart';
import 'package:localrental_flutter/providers/theme_provider.dart';
import 'package:localrental_flutter/pages/settings_page.dart'; // Add this import
import 'package:localrental_flutter/providers/user_provider.dart'; // Add this import

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
        ChangeNotifierProxyProvider<FitnessAuthProvider, CartProvider>(
          create: (_) => CartProvider(CartService()),
          update: (_, auth, previousCart) => auth.isAuthenticated
              ? CartProvider(CartService())
              : CartProvider(CartService()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData, // Use custom theme
            home: const AuthWrapper(),
            routes: {
              '/home': (context) => const MainNavigation(),
              '/login': (context) => const LoginPage(),
              '/signup': (context) => const SignupPage(),
              '/add_item': (context) => const AddItemPage(),
              '/cart': (context) => const CartPage(),
              '/edit_item': (context) {
                final args = ModalRoute.of(context)!.settings.arguments
                    as ItemDisplayModel;
                return EditItemPage(item: args);
              },
              '/settings': (context) =>
                  const SettingsPage(), // Ensure this is recognized
            },
          );
        },
      ),
    );
  }
}
