import 'package:flutter/material.dart';
import '../../../../Worker/EarnWithEasyKaam/Presentation/Pages/Earnscreen.dart';
import '../../../../Worker/home/presentation/pages/worker_home_page.dart';
import '../../../../support/presentation/pages/Customer_support_screen.dart';
import '../../../AcceptRequest/presentation/pages/Accept_Request.dart'; // 👈 Import Accept Request screen
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
      debugPrint('❌ Error loading profile image: $e');
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
          // 🧑 Profile Header
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
                          ? const Icon(Icons.person,
                          size: 40, color: Colors.grey)
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
                  title:
                  const Text('Help', style: TextStyle(color: Colors.black)),
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
                      MaterialPageRoute(
                          builder: (_) => const CustomerSupportScreen()),
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
                  title:
                  const Text('Jobs', style: TextStyle(color: Colors.black)),
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
                  title: const Text('Settings',
                      style: TextStyle(color: Colors.black)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: iconColor),
                  title: const Text('Logout',
                      style: TextStyle(color: Colors.black)),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 🔘 Worker Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _checkRegistrationStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25B0F0),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Worker",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  /// ✅ Checks registration and navigates directly.
  Future<void> _checkRegistrationStatus() async {
    try {
      debugPrint("🔍 Checking worker registration status...");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
        const Center(child: CircularProgressIndicator(color: Colors.blue)),
      );

      final isRegistered = await ApiService.checkWorkerRegistration();

      if (mounted) Navigator.of(context).pop();

      if (!mounted) return;

      if (isRegistered) {
        debugPrint("✅ Worker already registered — navigating to WorkerHomePage");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WorkerHomePage()),
        );
      } else {
        debugPrint("⚠️ Not registered — navigating to EarnScreen");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EarnScreen()),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      debugPrint('❌ Error checking registration status: $e');
    }
  }
}
