import 'package:easykaaaam/features/Worker/Customer_search/Presentation/pages/Customer_Search.dart';
import 'package:easykaaaam/features/Customer/AcceptRequest/presentation/pages/Accept_Request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../home/presentation/pages/worker_home_page.dart';
import '../../../providers/worker_provider.dart';



class ApplyRequestScreen extends StatefulWidget {
  final int? preselectedServiceKey;
  final Map<String, dynamic>? jobData;

  const ApplyRequestScreen({super.key, this.preselectedServiceKey, this.jobData});

  @override
  State<ApplyRequestScreen> createState() => _ApplyRequestScreenState();
}

class _ApplyRequestScreenState extends State<ApplyRequestScreen> {
  @override
  void initState() {
    super.initState();
    // Clear any previous apply job message when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workerProvider = Provider.of<WorkerProvider>(context, listen: false);
      workerProvider.clearApplyJobMessage();
    });
  }

  Future<void> _applyForJob() async {
    if (widget.jobData == null) {
      _showErrorSnackBar('Job data not available');
      return;
    }

    debugPrint('📋 Job data: ${widget.jobData}');

    final workerProvider = Provider.of<WorkerProvider>(context, listen: false);

    final jobId = widget.jobData!['id']?.toString() ??
        widget.jobData!['jobId']?.toString();

    debugPrint('🆔 Extracted jobId: $jobId');

    if (jobId == null) {
      _showErrorSnackBar('Job ID not found in job data');
      return;
    }

    debugPrint('🚀 Applying for job...');
    final result = await workerProvider.applyForJob(jobId: jobId);

    if (result['success'] == true) {
      _showSuccessSnackBar('Successfully applied for job!');
      
      // Get the jobId from the response or stored value
      final appliedJobId = result['jobId'] ?? workerProvider.lastAppliedJobId ?? jobId;
      
      debugPrint('🎯 Job applied successfully with jobId: $appliedJobId');
      debugPrint('🎯 Navigating to AcceptRequestScreen with jobId: $appliedJobId');

      // Navigate to AcceptRequestScreen with the jobId from apply-for-job response
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          debugPrint('🎯 Worker: Navigating to AcceptRequestScreen with jobId: $appliedJobId');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => AcceptRequestScreen(jobId: appliedJobId),
            ),
            (route) => false, // Remove all previous routes
          );
        }
      });
    } else {
      _showErrorSnackBar(result['message'] ?? 'Failed to apply for job');
    }
  }


  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Worker Request ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                                color: Colors.black,
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 20),


                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0x0D8DD4FD),
                            border: Border.all(color: Colors.blue.shade100, width: 1.2),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Header
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.blue.shade100,
                                    backgroundImage: widget.jobData?["profileImageUrl"] != null
                                        ? NetworkImage(widget.jobData!["profileImageUrl"])
                                        : null,
                                    child: widget.jobData?["profileImageUrl"] == null
                                        ? const Icon(Icons.person, size: 32, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.jobData?["title"] ?? "Job Title",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.jobData?["address"] ?? "No address",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF0077B6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(height: 1, color: Color(0xFFE0E0E0)),
                              const SizedBox(height: 12),

                              // Stats Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${widget.jobData?["rating"]?.toString() ?? "0.0"}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Rating",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        "${widget.jobData?["totalJobs"]?.toString() ?? "0"}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Total Jobs",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        "${widget.jobData?["distanceKm"]?.toString() ?? "0"}Km",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Distance",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        "${widget.jobData?["time"]?.toString() ?? "0"} mins",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Time",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 25),

                              // Upload Media Section
                              Container(
                                height: 186,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[200],
                                  border: Border.all(
                                    color: const Color(0x8025B0F0), // #25B0F080 (50% opacity blue)
                                    width: 1.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.image, color: Colors.grey, size: 50),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Audio Section
                              Container(
                                constraints: const BoxConstraints(minHeight: 60, maxHeight: 120),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xff8DD4FD),
                                    width: 1.5,
                                  ),
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
                                    Icon(Icons.mic, color: Colors.black, size: 24),
                                    SizedBox(width: 10),

                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Address Section
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white, // 🩶 White background
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xff8DD4FD), // Border color
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xff25B0F0), // Blue accent icon
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        "Enter your address",
                                        style: TextStyle(
                                          color: Colors.grey, // Softer text color for hint style
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),


                              const SizedBox(height: 20),

                              // Submit Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0x0D9D9D9C),
                                        minimumSize: const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        "Close",
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: workerProvider.isApplyingForJob ? null : _applyForJob,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: workerProvider.isApplyingForJob 
                                            ? Colors.grey 
                                            : const Color(0x767BD47A),
                                        minimumSize: const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: workerProvider.isApplyingForJob
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              "Accept",
                                              style: TextStyle(fontSize: 16, color: Colors.white),
                                            ),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
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
      },
    );
  }




}
