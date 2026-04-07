import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/navigation.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: ClearDeedApp()));
}

class ClearDeedApp extends ConsumerWidget {
  const ClearDeedApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'ClearDeed',
      theme: AppTheme.lightTheme(),
      debugShowCheckedModeBanner: false,
      home: authState.isAuthenticated ? const NavigationShell() : const LoginScreen(),
    );
  }
}
