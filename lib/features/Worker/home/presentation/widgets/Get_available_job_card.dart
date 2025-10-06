import 'package:flutter/material.dart';

import '../../../Request/Presentation/pages/Apply_request.dart';


class AvailableJobCard extends StatefulWidget {
  final String name;
  final String address;
  final double rating;
  final int totalJobs;
  final String distance;
  final String time;
  final String? profileImageUrl;
  final Map<String, dynamic>? jobData;

  const AvailableJobCard({
    super.key,
    required this.name,
    required this.address,
    required this.rating,
    required this.totalJobs,
    required this.distance,
    required this.time,
    this.profileImageUrl,
    this.jobData,
  });

  @override
  State<AvailableJobCard> createState() => _AvailableJobCardState();
}

class _AvailableJobCardState extends State<AvailableJobCard> {
  bool _isVisible = true; // 👁️ toggle for eye icon

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Container(
        height: screenHeight * (183 / 812),
        decoration: BoxDecoration(
          color: const Color(0x0D8DD4FD), // light transparent blue
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF8DD4FD),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: widget.profileImageUrl != null
                        ? NetworkImage(widget.profileImageUrl!)
                  : null,
                    child: widget.profileImageUrl == null
                        ? Icon(Icons.person,
                        size: 32, color: Colors.blue.shade600)
                  : null,
            ),
                  const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.address,
                      style: const TextStyle(
                            color: Color(0xFF0077B6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                    children: [
                                  const Icon(Icons.star,
                                      size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: Colors.amber.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${widget.totalJobs} jobs",
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  widget.distance,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  widget.time,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 👉 Arrow icon that navigates to ApplyRequestScreen
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApplyRequestScreen(jobData: widget.jobData),
                        ),
                      );
                    },
                    child: Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),

            // 👁️ Eye icon toggle
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isVisible = !_isVisible;
                  });
                },
                child: Icon(
                  _isVisible
                      ? Icons.remove_red_eye_rounded
                      : Icons.visibility_off_rounded,
                  color: const Color(0xFF8DD4FD),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
