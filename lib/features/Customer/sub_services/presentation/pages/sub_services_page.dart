
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/services/api_service.dart';
import '../../../home/presentation/widgets/App drawer.dart';
import '../../../home/presentation/widgets/home_header.dart';
import '../../../post_a_job/Presentation/pages/post_a_job.dart';
import '../../../service_search/presentation/pages/service_search_page.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../widgets/sub_services_card.dart';

class SubServices extends StatefulWidget {
  final String categoryKey;
  
  const SubServices({super.key, required this.categoryKey});

  @override
  State<SubServices> createState() => _SubServicesState();
}

class _SubServicesState extends State<SubServices> {
  final TextEditingController _helpController = TextEditingController();
  late Future<List<SubCategory>> _subCategoriesFuture;
  
  final Map<String, int> _subCategoryToServiceKey = {
    'Plumber': 1,
    'Plumbing': 1,
    'Pipe Repair': 1,
    'Leak Repair': 1,
    'Drain Cleaning': 1,
    'Toilet Repair': 1,
    'Faucet Repair': 1,
    'Water Heater': 1,
    'Bathroom Plumbing': 1,
    'Kitchen Plumbing': 1,
    
    'Electrician': 2,
    'Electrical': 2,
    'Wiring': 2,
    'Electrical Repair': 2,
    'Light Installation': 2,
    'Outlet Repair': 2,
    'Circuit Breaker': 2,
    'Electrical Panel': 2,
    'Ceiling Fan': 2,
    'Electrical Safety': 2,
    
    'Sweeper': 3,
    'Cleaning': 3,
    'House Cleaning': 3,
    'Office Cleaning': 3,
    'Deep Cleaning': 3,
    'Carpet Cleaning': 3,
    'Window Cleaning': 3,
    'Floor Cleaning': 3,
    'Kitchen Cleaning': 3,
    'Bathroom Cleaning': 3,
    
    'Carpenter': 4,
    'Carpentry': 4,
    'Wood Work': 4,
    'Furniture Repair': 4,
    'Cabinet Making': 4,
    'Door Repair': 4,
    'Window Repair': 4,
    'Flooring': 4,
    'Trim Work': 4,
    'Custom Furniture': 4,
    
    'Painter': 5,
    'Painting': 5,
    'Interior Painting': 5,
    'Exterior Painting': 5,
    'Wall Painting': 5,
    'Ceiling Painting': 5,
    'Touch Up': 5,
    'Color Consultation': 5,
    'Primer Application': 5,
    'Stain Work': 5,
    
    'HVAC': 6,
    'Air Conditioning': 6,
    'Heating': 6,
    'AC Repair': 6,
    'AC Installation': 6,
    'Duct Cleaning': 6,
    'Thermostat': 6,
    'Ventilation': 6,
    
    'Appliance Repair': 7,
    'Refrigerator': 7,
    'Washing Machine': 7,
    'Dryer': 7,
    'Dishwasher': 7,
    'Oven': 7,
    'Microwave': 7,
    'Air Conditioner': 7,
    
    // 'Landscaping': 8,
    // 'Gardening': 8,
    // 'Lawn Care': 8,
    // 'Tree Trimming': 8,
    // 'Fence Repair': 8,
    // 'Outdoor Maintenance': 8,
    //
    // 'Security': 9,
    // 'Locksmith': 9,
    // 'Lock Repair': 9,
    // 'Security System': 9,
    // 'Camera Installation': 9,
    //
    // 'Maintenance': 10,
    // 'General Repair': 10,
    // 'Handyman': 10,
    // 'Home Repair': 10,
    // 'Property Maintenance': 10,
    //
    // 'IT Support': 11,
    // 'Computer Repair': 11,
    // 'Network Setup': 11,
    // 'Software Installation': 11,
    // 'Tech Support': 11,
    //
    'Other': 99,
    'Miscellaneous': 99,
    'Custom Service': 99,
  };

  @override
  void initState() {
    super.initState();
    _subCategoriesFuture = ApiService.fetchAllSubCategories(widget.categoryKey);
  }

  @override
  void dispose() {
    _helpController.dispose();
    super.dispose();
  }

  void _retryFetch() {
    setState(() {
      _subCategoriesFuture = ApiService.fetchAllSubCategories(widget.categoryKey);
    });
  }

  void _navigateToSearch(String subCategoryName) {
    int? serviceKey = _subCategoryToServiceKey[subCategoryName];
    
    if (serviceKey == null) {
      final lowerName = subCategoryName.toLowerCase();
      
      for (final entry in _subCategoryToServiceKey.entries) {
        if (lowerName.contains(entry.key.toLowerCase()) || 
            entry.key.toLowerCase().contains(lowerName)) {
          serviceKey = entry.value;
          break;
        }
      }
    }
    
    serviceKey ??= 99;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostJobScreen(
          preselectedServiceKey: serviceKey,
        ),
      ),
    );
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
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.defaultPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),

                            FutureBuilder<List<SubCategory>>(
                              future: _subCategoriesFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                        childAspectRatio: 1,
                                      ),
                                      itemCount: 6,
                                      itemBuilder: (context, index) {
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey.shade300,
                                          highlightColor: Colors.grey.shade100,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                                        const SizedBox(height: 16),
                                        Text("Error: ${snapshot.error}"),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _retryFetch,
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                                        SizedBox(height: 16),
                                        Text("No subcategories found"),
                                      ],
                                    ),
                                  );
                                }

                                final subCategories = snapshot.data!;

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: subCategories.length,
                                  itemBuilder: (context, index) {
                                    final subCategory = subCategories[index];
                                    return SubServicesCard(
                                      title: subCategory.name,
                                      width: 160,
                                      height: 160,
                                      imagePath: subCategory.imageUrl?.isNotEmpty == true
                                          ? subCategory.imageUrl!
                                          : AppConstants.defaultServiceImage,
                                      onTap: () => _navigateToSearch(subCategory.name),
                                    );
                                  },
                                );
                              },
                            )

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
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "What do you need",
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                              suffixIcon: Icon(
                                Icons.search,
                                color: Colors.black54,
                              ),
                            ),
                          ),
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
}
