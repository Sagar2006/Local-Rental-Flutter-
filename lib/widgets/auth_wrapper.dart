import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:localrental_flutter/widgets/main_navigation.dart';
import 'package:localrental_flutter/pages/login_page.dart';
import 'package:localrental_flutter/providers/auth_provider.dart';
import 'package:localrental_flutter/providers/cart_provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessAuthProvider>(
      builder: (context, authProvider, _) {
        return StreamBuilder<User?>(
          stream: authProvider.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<CartProvider>().initializeCartForUser();
              });
              return const MainNavigation();
            }

            return const LoginPage();
          },
        );
      },
    );
  }
}
