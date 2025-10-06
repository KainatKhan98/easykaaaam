import 'package:flutter/material.dart';

import '../call/presentation/pages/Call_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final TextEditingController controller;

  const CustomBottomNavBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1))],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFADD8E6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.help_outline, color: Colors.white),
            ),

            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFADD8E6)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'What do you need help with...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CallScreen()),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFADD8E6),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.phone_in_talk,
                  color: Color(0xFFADD8E6),
                  size: 24,
                ),
              ),
            )

        ],
        ),
      ),
    );
  }
}
