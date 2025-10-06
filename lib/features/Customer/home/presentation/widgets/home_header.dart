import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../core/services/api_service.dart';
import '../../../../../core/state/image_profile_state.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final userId = await ApiService.getUserId();
      final token = await ApiService.getJwtToken();

      if (userId != null && token != null) {
        final imageUrl = await ApiService.getProfileImage(userId, token);
        if (imageUrl != null && imageUrl.isNotEmpty) {
          ProfileState.setImageUrl(
            '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}',
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading profile image: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final userId = await ApiService.getUserId();
    if (userId == null) {
      _showSnackBar('User not authenticated', isError: true);
      return;
    }

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image == null) return;

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final result = await ApiService.uploadProfilePicture(userId, image.path);

      if (result['success'] == true) {
        _showSnackBar('Profile picture updated successfully');
        final newUrl = result['data']?['imageUrl'] as String?;
        if (newUrl != null && newUrl.isNotEmpty) {
          ProfileState.setImageUrl(
            '$newUrl?t=${DateTime.now().millisecondsSinceEpoch}',
          );
        } else {
          await _loadProfileImage();
        }
      } else {
        _showSnackBar(result['message'] ?? 'Failed to upload image', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error uploading image: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const SizedBox(width: 15),
              _LanguageToggle(),
            ],
          ),
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipOval(
                child: ValueListenableBuilder<String?>(
                  valueListenable: ProfileState.profileImageUrl,
                  builder: (context, profileImageUrl, _) {
                    if (isLoading) {
                      return const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      );
                    }

                    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
                      return CachedNetworkImage(
                        imageUrl: profileImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    }

                    return const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 24,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageToggle extends StatefulWidget {
  @override
  State<_LanguageToggle> createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<_LanguageToggle> {
  bool isEnglishSelected = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isEnglishSelected = !isEnglishSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 30,
        width: 75,
        decoration: BoxDecoration(
          color: const Color(0xFFAFE1FE),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              right: isEnglishSelected ? 2.0 : 47.0,
              top: 2.0,
              child: Container(
                height: 26,
                width: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 7,
              child: AnimatedOpacity(
                opacity: isEnglishSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const Text(
                  "Eng",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff0F0F0F),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
