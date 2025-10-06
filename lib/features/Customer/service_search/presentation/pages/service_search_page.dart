
import 'package:flutter/material.dart';

import '../../../home/presentation/widgets/home_header.dart';

class ServiceSearchPage extends StatefulWidget {
  const ServiceSearchPage({super.key});

  @override
  State<ServiceSearchPage> createState() => _ServiceSearchPageState();
}

class _ServiceSearchPageState extends State<ServiceSearchPage> {
  final TextEditingController _helpController = TextEditingController();

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 3),
              Center(
                child: Image.asset(
                  "assets/logo/easykaam.png",
                  fit: BoxFit.contain,
                  height: 85,
                  width: 259,
                ),
              ),

              Expanded(
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage("assets/services/subservices/map 2.png"),
                            fit: BoxFit.cover,

                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),

                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 1,
                                  children: const [
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 0,
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width - 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Searching Nearby Electrician",
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
