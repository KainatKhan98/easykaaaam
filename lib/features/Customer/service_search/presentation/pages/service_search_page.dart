import 'package:flutter/material.dart';
import '../../../AcceptRequest/presentation/pages/Accept_Request.dart';
import '../../../home/presentation/widgets/home_header.dart';


class ServiceSearchPage extends StatefulWidget {
  final String? jobId; // Optional job ID to view applicants
  
  const ServiceSearchPage({super.key, this.jobId});

  @override
  State<ServiceSearchPage> createState() => _ServiceSearchPageState();
}

class _ServiceSearchPageState extends State<ServiceSearchPage> {
  final TextEditingController _helpController = TextEditingController();
  int _countdown = 3;

  @override
  void initState() {
    super.initState();

    print('🎯 ServiceSearchPage: Starting 3-second timer...');
    print('🎯 ServiceSearchPage: jobId value: ${widget.jobId}');
    
    // Start countdown timer
    _startCountdown();
    
    Future.delayed(const Duration(seconds: 3), () {
      print('🎯 ServiceSearchPage: 3 seconds elapsed, checking for valid jobId...');
      print('🎯 ServiceSearchPage: Widget mounted: $mounted');
      print('🎯 ServiceSearchPage: Context valid: ${context.mounted}');
      
      if (mounted && context.mounted) {
        // Only navigate to AcceptRequestScreen if we have a valid jobId
        if (widget.jobId != null && widget.jobId!.isNotEmpty && widget.jobId != 'default-job-id') {
          try {
            print('🎯 ServiceSearchPage: Valid jobId found, navigating to AcceptRequestScreen with jobId: ${widget.jobId}');
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AcceptRequestScreen(
                  jobId: widget.jobId!,
                ),
              ),
            );
            print('🎯 ServiceSearchPage: Navigation completed successfully');
          } catch (e) {
            print('🎯 ServiceSearchPage: Navigation failed with error: $e');
          }
        } else {
          print('🎯 ServiceSearchPage: No valid jobId available, staying on ServiceSearchPage');
          print('🎯 ServiceSearchPage: jobId value: ${widget.jobId}');
          print('🎯 ServiceSearchPage: Waiting for workers to apply for the job...');
        }
      } else {
        print('🎯 ServiceSearchPage: Widget not mounted or context invalid, skipping navigation');
        print('🎯 ServiceSearchPage: mounted: $mounted, context.mounted: ${context.mounted}');
      }
    });
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdown--;
        });
        if (_countdown > 0) {
          _startCountdown();
        }
      }
    });
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
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Finding Nearby Electricians...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                (widget.jobId != null && widget.jobId!.isNotEmpty && widget.jobId != 'default-job-id')
                                    ? "Redirecting to view applicants in $_countdown seconds..."
                                    : "Waiting for workers to apply for your job...",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: (widget.jobId != null && widget.jobId!.isNotEmpty && widget.jobId != 'default-job-id') ? () {
                                  print('🎯 ServiceSearchPage: Manual navigation triggered with valid jobId: ${widget.jobId}');
                                  try {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AcceptRequestScreen(
                                          jobId: widget.jobId!,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    print('🎯 ServiceSearchPage: Manual navigation failed: $e');
                                  }
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: (widget.jobId != null && widget.jobId!.isNotEmpty && widget.jobId != 'default-job-id') 
                                      ? Colors.white 
                                      : Colors.grey,
                                  foregroundColor: (widget.jobId != null && widget.jobId!.isNotEmpty && widget.jobId != 'default-job-id')
                                      ? const Color(0xFF8DD4FD)
                                      : Colors.grey.shade400,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                child: Text(
                                  (widget.jobId != null && widget.jobId!.isNotEmpty && widget.jobId != 'default-job-id')
                                      ? "View Applicants Now"
                                      : "Waiting for Applicants...",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
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
                              hintText: "Searching Nearby Electrician...",
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black54,
                                    ),
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
