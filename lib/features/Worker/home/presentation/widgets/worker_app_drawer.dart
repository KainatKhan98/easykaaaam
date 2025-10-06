import 'package:flutter/material.dart';
import 'dart:async';


import '../../../../../core/services/api_service.dart';
import '../../../../Customer/home/presentation/pages/home_page.dart';

class WorkerAppDrawer extends StatefulWidget {
  const WorkerAppDrawer({super.key});

  @override
  State<WorkerAppDrawer> createState() => _WorkerAppDrawerState();
}

class _WorkerAppDrawerState extends State<WorkerAppDrawer> {
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
                          "John Doe",
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
                              "4.8",
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

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: iconColor),
                  title: const Text('Wallet', style: TextStyle(color: Colors.black)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.security, color: iconColor),
                  title: const Text('Safety', style: TextStyle(color: Colors.black)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_bag, color: iconColor),
                  title: const Text('Orders', style: TextStyle(color: Colors.black)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.work, color: iconColor),
                  title: const Text('Rework', style: TextStyle(color: Colors.black)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: iconColor),
                  title: const Text('Settings', style: TextStyle(color: Colors.black)),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25B0F0).withOpacity(0.78),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                },
                child: const Text(
                  'Customer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
