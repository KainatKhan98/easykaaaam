import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import '../widgets/Submit_button.dart';
import '../widgets/help_card.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
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
                              "Form",
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
                          color: Colors.grey.withOpacity(0.2),
                          thickness: 1.5,
                          indent: 5,
                          endIndent: 5,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "Booking ID",
                                style: TextStyle(
                                  fontSize: 16,                  // font size
                                  fontWeight: FontWeight.w700,   // bold text
                                  color: Colors.black87,         // text color
                                  letterSpacing: 0.5,            // slight spacing
                                ),
                              ),
                            ),

                            // Search Bar
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(color: const Color(0xFF8DD4FD), width: 1.5),
                                ),
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'EK-001',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "Description",
                                style: TextStyle(
                                  fontSize: 16,                  // font size
                                  fontWeight: FontWeight.w700,   // bold text
                                  color: Colors.black87,         // text color
                                  letterSpacing: 0.5,            // slight spacing
                                ),
                              ),
                            ),

                            // Search Bar
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(color: const Color(0xFF8DD4FD), width: 1.5),
                                ),
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Type here',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                            padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: SubmitButton(
                                  text: "Submit Request",
                                  width: 200,  // custom width
                                  height: 60,  // custom height
                                  onPressed: () {
                                    // handle submit
                                  },
                                ),
                              ),
                            )

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
