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
import '../widgets/pagination_widget.dart';

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
      final workerProvider = Provider.of<WorkerProvider>(
        context,
        listen: false,
      );
      workerProvider.loadAvailableJobs();
    });
  }

  void _refreshJobs() {
    final workerProvider = Provider.of<WorkerProvider>(context, listen: false);
    workerProvider.refreshJobs();
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
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: _buildJobList(workerProvider),
                                  ),

                                  // Pagination Widget inside the same white container
                                  if (workerProvider.availableJobs.isNotEmpty &&
                                      !workerProvider.isLoadingJobs)
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: PaginationWidget(
                                        currentPage: workerProvider.currentPage,
                                        totalPages: workerProvider.totalPages,
                                        totalItems: workerProvider.totalItems,
                                        itemsPerPage: workerProvider.pageSize,
                                        isLoading: workerProvider.isLoadingMore,
                                        onPrevious: workerProvider.goToPreviousPage,
                                        onNext: workerProvider.goToNextPage,
                                        onPageSelected: workerProvider.goToPage,
                                      ),
                                    ),
                                ],
                              ),
                            ),
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
      return WorkerEmptyWidget(onRetry: _refreshJobs);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: workerProvider.availableJobs.length,
      itemBuilder: (context, index) {
        final job = workerProvider.availableJobs[index];
        return AvailableJobCard(
          name: job["title"] ?? job["jobTitle"] ?? "Job Title",
          address: job["address"] ?? "No address",
          rating: (job["rating"] ?? 0).toDouble(),
          totalJobs: job["totalJobs"] ?? 0,
          distance:
              "${job["distanceKm"]?.toString() ?? job["distance"]?.toString() ?? "0"} km",
          time: "${job["time"]?.toString() ?? "0"} mins",
          profileImageUrl:
              job["profileImageUrl"] ?? job["customerProfileImage"],
          jobData: job,
        );
      },
    );
  }
}
