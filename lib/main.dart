// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout/data/activityRemoteDataSource.dart';
import 'package:scout/data/activityRepositoryImpl.dart';
import 'package:scout/domain/repositories/activityRepository%20.dart';
import 'package:scout/presentation/activityProvider%20.dart';
import 'package:scout/presentation/admin_activity_provider.dart';
import 'package:scout/presentation/auth_provider.dart';
import 'package:scout/presentation/screen/admin_dashboard_screen.dart';
import 'package:scout/presentation/screen/homePage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scout/presentation/screen/login_screen.dart.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 1. Provide ActivityRemoteDataSource first, as it's the most basic dependency
        Provider<ActivityRemoteDataSource>(
          create: (_) => ActivityRemoteDataSource(),
        ),
        // 2. Provide ActivityRepository, which depends on ActivityRemoteDataSource
        // Using ProxyProvider to get the instance of ActivityRemoteDataSource
        ProxyProvider<ActivityRemoteDataSource, ActivityRepository>(
          update: (context, remoteDataSource, previousRepository) =>
              ActivityRepositoryImpl(remoteDataSource),
        ),
        // 3. Provide AdminActivityProvider, which depends on ActivityRepository
        ChangeNotifierProxyProvider<ActivityRepository, AdminActivityProvider>(
          create: (context) => AdminActivityProvider(
            repository: context.read<ActivityRepository>(),
          ),
          update: (context, repository, previousAdminActivityProvider) =>
              AdminActivityProvider(repository: repository),
        ),
        // 4. Provide ActivityProvider, which also depends on ActivityRepository
        ChangeNotifierProxyProvider<ActivityRepository, ActivityProvider>(
          create: (context) =>
              ActivityProvider(context.read<ActivityRepository>())
                ..fetchActivities(), // Fetch activities on app start
          update: (context, repository, previousActivityProvider) =>
              ActivityProvider(repository),
        ),
        // Other independent providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => LocalizationProvider()..loadLocale(),
        ),
      ],
      child: const ScoutsApp(), // The main application widget
    ),
  );
}

class ScoutsApp extends StatelessWidget {
  const ScoutsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocalizationProvider>().locale;

    return MaterialApp(
      title: Provider.of<LocalizationProvider>(context).translate('pageTitle'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: GoogleFonts.nunito()
            .fontFamily, // Assuming Inter font is available or bundled
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          elevation: 0,
        ),
      ),
      locale: locale,
      supportedLocales: const [Locale('en', ''), Locale('ar', '')],
      // CORRECTED: Added GlobalMaterialLocalizations.delegate and GlobalCupertinoLocalizations.delegate
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations
            .delegate, // Add this if you use Cupertino widgets
      ],
      home: const HomePage(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (auth.isAuthenticated) {
          return const AdminDashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
