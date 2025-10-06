import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import '../widgets/help_card.dart';
import 'form.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  final TextEditingController _addressController = TextEditingController(
    text: "412, st 7, sector 3, Islamabad",
  );

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8DD4FD), Color(0xFF547F97)],
          stops: [0.01, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              // Dropdown Arrow
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              // Main Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Help Centre",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                                color: Colors.black,
                              ),
                            ),
                            Icon(
                              Icons.more_vert,
                              size: 28,
                              color: Color(0xff25B0F0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          color: Colors.grey.withOpacity(0.2), // light grey with transparency
                          thickness: 1.5,                      // line thickness
                          indent: 5,                           // space from left
                          endIndent: 5,                        // space from right
                        ),
                        Column(
                          children: [
                            // Search Bar
                            Padding(
                              padding: const EdgeInsets.only(top:10.0),
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  // color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(color: Color(0xff25B0F0)),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: 'search for help',
                                          hintStyle: TextStyle(color: Colors.grey),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.search, color: Colors.blue),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Card: Direct call booking
                            HelpCard(
                              title: "Direct call booking?",
                              subtitle: "Not sure what kind of service you need? No worries just click here and we’ll guide you!",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const FormScreen()), // replace FormScreen with your screen
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            // Card: Job Quality Issue
                            HelpCard(
                              title: "Job Quality Issue",
                              subtitle: "To register, fill the form and submit your documents.",
                            ),
                            const SizedBox(height: 10),
                            // Card: Booking Confusion
                            HelpCard(
                              title: "Booking Confusion",
                              subtitle: "To register, fill the form and submit your documents.",
                            ),
                            const SizedBox(height: 10),
                            // Card: Rework Request
                            HelpCard(
                              title: "Rework Request",
                              subtitle: "To register, fill the form and submit your documents.",
                            ),
                          ],
                        )
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