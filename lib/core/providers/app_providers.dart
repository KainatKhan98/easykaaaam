import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/Customer/providers/customer_provider.dart';
import '../../features/Worker/providers/worker_provider.dart';
import '../../features/splash/providers/splash_provider.dart';
import '../../features/support/providers/support_provider.dart';

class AppProviders {
  static List<SingleChildWidget> providers = [
    // Feature Providers
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => CustomerProvider()),
    ChangeNotifierProvider(create: (_) => WorkerProvider()),
    ChangeNotifierProvider(create: (_) => SplashProvider()),
    ChangeNotifierProvider(create: (_) => SupportProvider()),
  ];
}
