import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class JobCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.width = 160,
    this.height = 160,
    this.onTap,
  });

  Widget _buildImage() {
    return imagePath.startsWith('http')
        ? CachedNetworkImage(
      imageUrl: imagePath,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade300,
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade300,
      ),
    )
        : Image.asset(imagePath, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8DD4FD), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(child: _buildImage()),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFF547F97).withOpacity(0.8),
                        const Color(0xFF8DD4FD).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JobCardWhite extends StatelessWidget {
  final String title;
  final String imagePath;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const JobCardWhite({
    super.key,
    required this.title,
    required this.imagePath,
    this.width = 160,
    this.height = 160,
    this.onTap,
  });

  Widget _buildImage() {
    return imagePath.startsWith('http')
        ? CachedNetworkImage(
      imageUrl: imagePath,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade300,
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade300,
      ),
    )
        : Image.asset(imagePath, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8DD4FD), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Stack(
                  children: [
                    _buildImage(),
                    Container(color: Colors.black.withOpacity(0.3)),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.white70,
                          offset: Offset(0, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
