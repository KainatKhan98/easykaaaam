import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import '../widgets/Fee_range_button.dart';


class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 40,
                ),
              ),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Call",
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
                        const SizedBox(height: 20),
                        const Text(
                          "Upload image",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: DottedBorder(
                            color: const Color(0xff8DD4FD),
                            strokeWidth: 2,
                            dashPattern: const [6, 3],
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(12),
                            child: Container(
                              height: 186,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 50,
                                  color: Color(0xff8DD4FD),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xff8DD4FD), width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.mic, color: Colors.black),
                              SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: Icon(
                                  Icons.graphic_eq,
                                  color: Color(0xff8DD4FD),
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Address",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8DD4FD),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8DD4FD),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(width: 120, child: Divider(color: Colors.black26, thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text("or", style: TextStyle(color: Colors.black54)),
                            ),
                            SizedBox(width: 120, child: Divider(color: Colors.black26, thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Center(
                          child: Text(
                            "Choose on Map",
                            style: TextStyle(
                              color: Color(0xff70D2FF),
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xff70D2FF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const FeeRangeButton(),
                        const SizedBox(height: 20),

                        Center(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff25B0F0),
                              minimumSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Submit Request",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20, bottom: 20),
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: const BoxDecoration(
                                color: Colors.black12,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow, color: Colors.black87),
                            ),
                          ),
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
