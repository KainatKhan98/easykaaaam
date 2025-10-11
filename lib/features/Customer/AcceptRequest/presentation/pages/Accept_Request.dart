import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../../Worker/providers/worker_provider.dart';
import '../../../home/presentation/widgets/App drawer.dart';
import '../../../home/presentation/widgets/home_header.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../providers/customer_provider.dart';

import '../widgets/Accept_request_card.dart';

/// Screen to show applicants for a job that a worker has applied to.
/// This screen is used when a worker applies for a job and wants to see
/// other applicants for the same job.
class AcceptRequestScreen extends StatefulWidget {
  final String jobId;
  
   AcceptRequestScreen({
    super.key,
    required this.jobId,
  })
  {
    print('🎯 AcceptRequestScreen: Constructor called with jobId: $jobId');
  }

  @override
  State<AcceptRequestScreen> createState() => _AcceptRequestScreenState();
}

class _AcceptRequestScreenState extends State<AcceptRequestScreen> {
  final TextEditingController _helpController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _currentJobId = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _currentJobId = widget.jobId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplicantsIfValid();
      _startPeriodicRefresh();
    });
  }

  void _startPeriodicRefresh() {
    // Start periodic refresh every 5 seconds to check for new applicants
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _checkForNewApplicants();
      }
    });
  }

  void _checkForNewApplicants() {
    // Only check if we're still waiting for workers (have default-job-id)
    if (_currentJobId == 'default-job-id' || _currentJobId.isEmpty) {
      debugPrint('🔄 Checking for new applicants...');
      _tryToFindJobId();
    }
  }

  void _tryToFindJobId() {
    // Try to find the jobId by attempting to load applicants with different approaches
    debugPrint('🔍 Attempting to find jobId...');
    
    // Try with a generic approach - some APIs might return the most recent job
    try {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      // Try loading with a special identifier that might work
      customerProvider.loadJobApplicants('latest');
    } catch (e) {
      debugPrint('⚠️ Error trying to find jobId: $e');
    }
  }

  void _manualRefresh() {
    debugPrint('🔄 Manual refresh triggered');
    _loadApplicantsIfValid();
  }

  void _loadApplicantsIfValid() {
    // Only load applicants if we have a valid jobId from worker apply-for-job response
    // This jobId comes from the apply-for-job API response, not from job creation
    if (_currentJobId != 'default-job-id' && _currentJobId.isNotEmpty) {
      // Try CustomerProvider first
      try {
        final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
        customerProvider.loadJobApplicants(_currentJobId);
        debugPrint('🔍 Loading job applicants via CustomerProvider for jobId: $_currentJobId');
      } catch (e) {
        debugPrint('⚠️ CustomerProvider not available, trying WorkerProvider: $e');
        // Fallback to WorkerProvider
        try {
          final workerProvider = Provider.of<WorkerProvider>(context, listen: false);
          workerProvider.getJobApplicants(_currentJobId);
          debugPrint('🔍 Loading job applicants via WorkerProvider for jobId: $_currentJobId');
        } catch (e2) {
          debugPrint('❌ Neither CustomerProvider nor WorkerProvider available: $e2');
        }
      }
    } else {
      debugPrint('⏳ Waiting for valid jobId from apply-for-job response...');
      debugPrint('⏳ Current jobId: $_currentJobId (should come from worker apply-for-job API)');
    }
  }

  void updateJobId(String newJobId) {
    if (newJobId != _currentJobId) {
      setState(() {
        _currentJobId = newJobId;
      });
      
      // Stop periodic refresh if we now have a valid jobId
      if (newJobId != 'default-job-id' && newJobId.isNotEmpty) {
        _refreshTimer?.cancel();
        debugPrint('🛑 Stopped periodic refresh - now have valid jobId: $newJobId');
      }
      
      _loadApplicantsIfValid();
    }
  }


  @override
  void dispose() {
    _refreshTimer?.cancel();
    _helpController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
        bottomNavigationBar: CustomBottomNavBar(controller: _helpController),
        drawer: const AppDrawer(),
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
                    // White main container
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        child: Consumer2<CustomerProvider, WorkerProvider>(
                          builder: (context, customerProvider, workerProvider, child) {
                            // Determine which provider to use based on availability
                            bool useCustomerProvider = true;
                            List<Map<String, dynamic>> applicants = [];
                            bool isLoading = false;
                            String? errorMessage;
                            
                            try {
                              // Try to use CustomerProvider first
                              if (customerProvider.jobApplicants.isNotEmpty || 
                                  customerProvider.isLoadingApplicants || 
                                  customerProvider.applicantsErrorMessage != null) {
                                applicants = customerProvider.jobApplicants;
                                isLoading = customerProvider.isLoadingApplicants;
                                errorMessage = customerProvider.applicantsErrorMessage;
                                useCustomerProvider = true;
                              } else {
                                // Fallback to WorkerProvider
                                applicants = workerProvider.jobApplicants;
                                isLoading = workerProvider.isLoadingApplicants;
                                errorMessage = workerProvider.applicantsErrorMessage;
                                useCustomerProvider = false;
                              }
                            } catch (e) {
                              // If CustomerProvider fails, use WorkerProvider
                              applicants = workerProvider.jobApplicants;
                              isLoading = workerProvider.isLoadingApplicants;
                              errorMessage = workerProvider.applicantsErrorMessage;
                              useCustomerProvider = false;
                            }
                            
                            if (isLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(50.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            
                            if (errorMessage != null) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 64,
                                        color: Colors.red[300],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error loading applicants',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        errorMessage,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red[600],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (useCustomerProvider) {
                                            customerProvider.loadJobApplicants(_currentJobId);
                                          } else {
                                            workerProvider.getJobApplicants(_currentJobId);
                                          }
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            if (applicants.isEmpty) {
                              // Show different message based on jobId validity
                              final isWaitingForWorkers = _currentJobId == 'default-job-id' || _currentJobId.isEmpty;
                              
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(50.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isWaitingForWorkers ? Icons.hourglass_empty : Icons.people_outline,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        isWaitingForWorkers ? 'Waiting for Job Application' : 'No applicants found',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        isWaitingForWorkers 
                                          ? 'Waiting for valid jobId from apply-for-job response. This screen shows other applicants for jobs you have applied to.'
                                          : 'No other applicants found for this job.',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if (isWaitingForWorkers) ...[
                                        const SizedBox(height: 20),
                                        ElevatedButton.icon(
                                          onPressed: _manualRefresh,
                                          icon: const Icon(Icons.refresh, size: 18),
                                          label: const Text('Check for Job Application'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF8DD4FD),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                  const SizedBox(height: 20),
                                  Text(
                                    'Other Applicants (${applicants.length})',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...applicants.map((applicant) {
                                    return AcceptRequestCard(
                                      name: applicant['name'] ?? 'Unknown',
                                      role: applicant['role'] ?? 'Worker',
                                      imageUrl: applicant['profileImage'] ?? 'assets/logo/logo.png',
                                      rating: applicant['rating']?.toString() ?? '0.0',
                                      totalJobs: applicant['totalJobs']?.toString() ?? '0',
                                      fee: applicant['fee']?.toString() ?? '0',
                                      time: applicant['time'] ?? 'N/A',
                                      distance: applicant['distance'] ?? 'N/A',
                                      onAccept: () {
                                        _handleAcceptApplicant(applicant);
                                      },
                                      onDecline: () {
                                        _handleDeclineApplicant(applicant);
                                      },
                                    );
                                  }).toList(),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Search Bar
                    Positioned(
                      top: 0,
                      child: Container(
                        height: 60,
                        width: screenWidth - 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Icon(Icons.handshake_outlined, color: Colors.green[700]),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Match Found",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _handleAcceptApplicant(Map<String, dynamic> applicant) {
    // TODO: Implement accept applicant logic
    debugPrint('Accepting applicant: ${applicant['name']}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accepting ${applicant['name']}...'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _handleDeclineApplicant(Map<String, dynamic> applicant) {
    // TODO: Implement decline applicant logic
    debugPrint('Declining applicant: ${applicant['name']}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Declining ${applicant['name']}...'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
