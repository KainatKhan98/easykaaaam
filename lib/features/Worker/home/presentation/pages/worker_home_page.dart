import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Customer/home/presentation/widgets/home_header.dart';
import '../../../Request/Presentation/pages/Apply_request.dart';
import '../../../providers/worker_provider.dart';
import '../widgets/Get_available_job_card.dart';
import '../widgets/worker_app_drawer.dart';
import '../widgets/worker_gradient_container.dart';
import '../widgets/worker_content_container.dart';
import '../widgets/worker_search_bar.dart';
import '../widgets/worker_loading_widget.dart';
import '../widgets/worker_error_widget.dart';
import '../widgets/worker_empty_widget.dart';

class WorkerHomePage extends StatefulWidget {
  const WorkerHomePage({super.key});

  @override
  State<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends State<WorkerHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workerProvider = Provider.of<WorkerProvider>(context, listen: false);
      workerProvider.loadAvailableJobs();
    });
  }

  void _refreshJobs() {
    final workerProvider = Provider.of<WorkerProvider>(context, listen: false);
    workerProvider.refreshJobs();
  }

  void _handleJobTap(BuildContext context, Map<String, dynamic> job) {
    // Show job details dialog or navigate to job details page
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            job["title"] ?? job["jobTitle"] ?? "Job Details",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (job["description"] != null) ...[
                const Text(
                  "Description:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job["description"],
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job["address"] ?? "No address",
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    "${job["time"]?.toString() ?? "0"} mins away",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.straighten, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    "${job["distanceKm"]?.toString() ?? job["distance"]?.toString() ?? "0"} km away",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (job["fee"] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text(
                      "Fee: ${job["fee"]}",
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement job application logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Job application feature coming soon!"),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Apply",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }





  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        return WorkerGradientContainer(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            drawer: const WorkerAppDrawer(),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50, child: HomeHeader()),
                  const SizedBox(height: 5),
                  Center(
                    child: Image.asset(
                      "assets/logo/logo.png",
                      fit: BoxFit.contain,
                      height: 145,
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
                          child: WorkerContentContainer(
                            child: _buildJobList(workerProvider),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          child: WorkerSearchBar(
                            onTap: () {
                              // Handle search functionality
                            },
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
      },
    );
  }

  Widget _buildJobList(WorkerProvider workerProvider) {
    if (workerProvider.isLoadingJobs) {
      return const WorkerLoadingWidget();
    }

    if (workerProvider.errorMessage != null) {
      return WorkerErrorWidget(
        message: workerProvider.errorMessage!,
        onRetry: _refreshJobs,
      );
    }

    if (workerProvider.availableJobs.isEmpty) {
      return WorkerEmptyWidget(
        onRetry: _refreshJobs,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _refreshJobs();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: workerProvider.availableJobs.length,
        itemBuilder: (context, index) {
          final job = workerProvider.availableJobs[index];
          return AvailableJobCard(
            name: job["title"] ?? job["jobTitle"] ?? "Job Title",
            address: job["address"] ?? "No address",
            rating: (job["rating"] ?? 0).toDouble(),
            totalJobs: job["totalJobs"] ?? 0,
            distance: "${job["distanceKm"]?.toString() ?? job["distance"]?.toString() ?? "0"} km",
            time: "${job["time"]?.toString() ?? "0"} mins",
            profileImageUrl: job["profileImageUrl"] ?? job["customerProfileImage"],
            jobData: job,
          );
        },
      ),
    );
  }
}
