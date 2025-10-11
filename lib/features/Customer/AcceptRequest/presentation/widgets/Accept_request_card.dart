import 'package:flutter/material.dart';

class AcceptRequestCard extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;
  final String rating;
  final String totalJobs;
  final String fee;
  final String time;
  final String distance;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const AcceptRequestCard({
    super.key,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.rating,
    required this.totalJobs,
    required this.fee,
    required this.time,
    required this.distance,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x0D8DD4FD), // ✅ Background color (#8DD4FD0D)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8DD4FD), // ✅ Border color (#8DD4FD)
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ===== Top Info Section =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.startsWith('http') 
                  ? Image.network(
                      imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, size: 35, color: Colors.grey),
                        );
                      },
                    )
                  : Image.asset(
                      imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, size: 35, color: Colors.grey),
                        );
                      },
                    ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      role,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF007ACC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              rating,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        Text(
                          "Jobs: $totalJobs",
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          "Fee: $fee",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(time, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  Text(distance, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ===== Buttons Section =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onDecline,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    "Decline",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8AF19B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    "Accept",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
