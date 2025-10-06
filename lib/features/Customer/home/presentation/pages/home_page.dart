import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/services/api_service.dart';
import '../../../sub_services/presentation/pages/sub_services_page.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../model/category_model.dart';
import '../widgets/App drawer.dart';
import '../widgets/home_header.dart';
import '../widgets/job_card.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Category>> _categoriesFuture;
  final TextEditingController _helpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = ApiService.fetchCategories();
  }

  @override
  void dispose() {
    _helpController.dispose();
    super.dispose();
  }

  void _retryFetchCategories() => setState(() {
    _categoriesFuture = ApiService.fetchCategories();
  });

  void _navigateToSubServices() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubServices(categoryKey: 'general')),
    );
  }

  Widget _buildCategoryLayout(List<Category> categories) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppConstants.largePadding,
          left: AppConstants.defaultPadding,
          right: AppConstants.defaultPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (categories.length >= 2)
              Row(
                children: [
                  Expanded(
                    child: JobCard(
                      title: categories[0].title,
                      imagePath: categories[0].imageUrl.isNotEmpty
                          ? categories[0].imageUrl
                          : AppConstants.logoPath,
                      height: 160,
                      onTap: _navigateToSubServices,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: JobCard(
                      title: categories[1].title,
                      imagePath: categories[1].imageUrl.isNotEmpty
                          ? categories[1].imageUrl
                          : AppConstants.logoPath,
                      height: 160,
                      onTap: _navigateToSubServices,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            if (categories.length >= 3)
              JobCard(
                title: categories[2].title,
                imagePath: categories[2].imageUrl.isNotEmpty
                    ? categories[2].imageUrl
                    : AppConstants.logoPath,
                height: 200,
              ),

            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xE325B0F0),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Don’t know what type of work or services you need',
                    textAlign: TextAlign.center,
                  ),
                  // const SizedBox(height: 5),
                  TextButton(
                    onPressed: () {
                      
                    },
                    child: const Text(
                      'Click here',
                      style: TextStyle(
                        color: Color(0xE325B0F0),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            if (categories.length >= 5)
              Row(
                children: [
                  JobCardWhite(
                    title: categories[3].title,
                    imagePath: categories[3].imageUrl.isNotEmpty
                        ? categories[3].imageUrl
                        : AppConstants.logoPath,
                    height: 160,
                    width: 220,
                    onTap: _navigateToSubServices,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: JobCardWhite(
                      title: categories[4].title,
                      imagePath: categories[4].imageUrl.isNotEmpty
                          ? categories[4].imageUrl
                          : AppConstants.logoPath,
                      height: 160,
                      onTap: _navigateToSubServices,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }





  Widget _buildCategoryFutureBuilder() {
    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
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
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _retryFetchCategories,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No categories found'),
              ],
            ),
          );
        }
        return _buildCategoryLayout(snapshot.data!);
      },
    );
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
        drawer: const AppDrawer(),
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
                        child: _buildCategoryFutureBuilder(),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width - 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search location...",
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: Color(0xFFADD8E6),
                              ),
                              suffixIcon: Icon(
                                Icons.more_horiz,
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
        bottomNavigationBar: CustomBottomNavBar(controller: _helpController),
      ),
    );
  }
}
