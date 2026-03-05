import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth_service.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_florist, 
                    size: 80, color: Colors.green),
                const SizedBox(height: 16),
                Text('BuyBarter',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Local produce, bought or bartered.',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: () => ref.read(authServiceProvider).signInWithGoogle(context),
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => ref.read(authServiceProvider).continueAsGuest(context),
                  child: const Text('Browse as guest'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}