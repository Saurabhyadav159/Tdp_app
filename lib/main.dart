import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poster/startup/presentation/onboarding.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/colors.dart';
import 'core/network/local_storage.dart';
import 'core/shared_components.dart';
import 'features/auth/data/auth.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/dashboard/presentation/dashboard.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: SharedColors.primary),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const _Home(),
        '/dashboard': (context) => const Dashboard(),
      },
    );
  }
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  String? authToken;

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      await [
        Permission.storage,
        Permission.photos,
        if (await Permission.manageExternalStorage.isRestricted)
          Permission.manageExternalStorage,
      ].request();
    }
  }

  Future<void> checkAuthStatus() async {
    authToken = await getToken();
    FlutterNativeSplash.remove();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (authToken != null && authToken!.isNotEmpty) {
      return const Dashboard();
    }

    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Placeholder();
        }

        SharedPreferences preferences = snapshot.data!;
        String? status = preferences.getString("status");

        return MultiProvider(
          providers: [
            Provider(create: (context) => Auth(preferences)),
            Provider(create: (context) => preferences),
          ],
          builder: (context, child) {
            if (status == null) {
              return SharedComponents.scaffolded(const OnboardingPage());
            }
            if (status == AuthState.loggedOut.name) {
              return SharedComponents.scaffolded(const AuthScreen());
            }
            return const Dashboard();
          },
        );
      },
    );
  }
}