import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../pages/login_page.dart';
import 'main_navigation.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FitnessAuthProvider>(context);

    // Listen to authentication state changes
    return FutureBuilder(
      future: authProvider.autoLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check authentication status
        if (authProvider.isAuthenticated) {
          // User is authenticated
          final cartProvider =
              Provider.of<CartProvider>(context, listen: false);

          // Initialize cart for the authenticated user
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cartProvider.initializeCartForUser(authProvider.user!.uid);
          });

          return const MainNavigation();
        } else {
          // User is not authenticated
          return const LoginPage();
        }
      },
    );
  }
}
