import 'package:flutter/material.dart';
import '../../../../Worker/EarnWithEasyKaam/Presentation/Pages/Earnscreen.dart';
import '../../../../Worker/home/presentation/pages/worker_home_page.dart';
import '../../../../support/presentation/pages/Customer_support_screen.dart';
import '../pages/home_page.dart';
import '../../../../../core/services/api_service.dart';
import 'dart:async';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Future<String?>? _profileImageFuture;

  @override
  void initState() {
    super.initState();
    _profileImageFuture = _loadProfileImage();
  }

  Future<String?> _loadProfileImage() async {
    try {
      final userId = await ApiService.getUserId();
      final token = await ApiService.getJwtToken();

      if (userId != null && token != null) {
        final imageUrl = await ApiService.getProfileImage(userId, token);
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
        }
      }
    } catch (e) {
      debugPrint('Error loading profile image: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const iconColor = Color(0xFF8DD4FD);

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 🧑‍🦱 Profile Header (same as Worker Drawer)
          FutureBuilder<String?>(
            future: _profileImageFuture,
            builder: (context, snapshot) {
              final imageUrl = snapshot.data ?? "";

              return DrawerHeader(
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.person, size: 40, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Jane Smith",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 4),
                            Text(
                              "4.9",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // 📋 Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline, color: iconColor),
                  title: const Text('Help', style: TextStyle(color: Colors.black)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.contact_phone, color: iconColor),
                  title: const Text('Customer Support',
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomerSupportScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.monetization_on, color: iconColor),
                  title: const Text('Earn with EasyKaam',
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EarnScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.work_outline, color: iconColor),
                  title: const Text('Jobs', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings, color: iconColor),
                  title: const Text('Settings', style: TextStyle(color: Colors.black)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: iconColor),
                  title: const Text('Logout', style: TextStyle(color: Colors.black)),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 🔘 Bottom Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _checkRegistrationStatus, // 👈 directly call the async method
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25B0F0),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "worker",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

            ),
          ),
        ],
      ),
    );
  }
  Future<void> _checkRegistrationStatus() async {
    try {
      debugPrint("🔍 Checking if user is already registered as worker...");

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );

      // API call
      final isRegistered = await ApiService.checkWorkerRegistration();

      if (mounted) Navigator.of(context).pop(); // close loading

      if (mounted) {
        if (isRegistered) {
          _showRegistrationStatusDialog(
            title: "Already Registered!",
            message: "You are already registered as a worker. Redirecting to your dashboard...",
            isSuccess: true,
            onConfirm: () {
              Navigator.of(context).pushReplacementNamed('/worker-home');
            },
          );
        } else {
          _showRegistrationStatusDialog(
            title: "Not Registered",
            message: "You are not registered as a worker yet. Please fill out the registration form above to get started!",
            isSuccess: false,
            onConfirm: () {},
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      debugPrint('Error checking registration status: $e');

      if (mounted) {
        _showRegistrationStatusDialog(
          title: "Error",
          message: "Could not check your registration status. Please try again or contact support.",
          isSuccess: false,
          onConfirm: () {},
        );
      }
    }
  }

  void _showRegistrationStatusDialog({
    required String title,
    required String message,
    required bool isSuccess,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info,
              color: isSuccess ? Colors.green : Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.blue,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(
              isSuccess ? "Go to Dashboard" : "Got it",
              style: TextStyle(
                color: isSuccess ? Colors.green : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
