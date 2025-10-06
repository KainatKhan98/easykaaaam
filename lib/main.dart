
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/providers/app_providers.dart';
import 'features/Customer/home/presentation/pages/home_page.dart';
import 'features/Worker/home/presentation/pages/worker_home_page.dart';
import 'features/auth/presentation/pages/otp_page.dart';
import 'features/auth/presentation/pages/registration_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EasyKaam',
        theme: ThemeData(
          textTheme: GoogleFonts.interTextTheme(),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const SplashPage(),
        routes: {
          '/home': (context) =>  HomePage(),
          '/registration': (context) => const RegistrationPage(),
          '/otp': (context) => OtpScreen(phoneNo: '12345'),
          '/worker-home': (context) =>  WorkerHomePage(),
        },
      ),
    );
  }
}
