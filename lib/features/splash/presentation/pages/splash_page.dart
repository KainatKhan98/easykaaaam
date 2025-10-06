
import 'package:flutter/material.dart';


import '../../../../core/services/api_service.dart';
import '../../../auth/presentation/pages/registration_page.dart';
import '../../../Customer/home/presentation/pages/home_page.dart';
import '../../../Worker/home/presentation/pages/worker_home_page.dart';
import '../widgets/splash_logo.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isCheckingLogin = true;
  String _statusMessage = "Loading...";

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    try {
      setState(() {
        _statusMessage = "Checking login status...";
      });

      // Wait a bit for splash effect
      await Future.delayed(const Duration(seconds: 1));

      // Check if user can auto-login
      final canAutoLogin = await ApiService.canAutoLogin();
      
      if (mounted) {
        if (canAutoLogin) {
          setState(() {
            _statusMessage = "Welcome back!";
          });
          
          await Future.delayed(const Duration(seconds: 1));
          
          // Check user role to determine which home to navigate to
          final userRole = await ApiService.getUserRole();
          final isWorker = await ApiService.checkWorkerRegistration();
          
          if (mounted) {
            if (isWorker) {
              // User is already registered as a worker, navigate to worker home
              debugPrint("✅ User is already registered as worker, navigating to worker home");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  WorkerHomePage()),
              );
            } else {
              // User is a customer, navigate to customer home
              debugPrint("✅ User is a customer, navigating to customer home");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            }
          }
        } else {
          setState(() {
            _statusMessage = "Please login to continue";
          });
          
          await Future.delayed(const Duration(seconds: 1));
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RegistrationPage()),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking auto-login: $e');
      if (mounted) {
        setState(() {
          _statusMessage = "Please login to continue";
        });
        
        await Future.delayed(const Duration(seconds: 1));
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegistrationPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            const SplashLogo(),
            const SizedBox(height: 30),
            // Status message
            Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            // Loading indicator
            if (_isCheckingLogin)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
