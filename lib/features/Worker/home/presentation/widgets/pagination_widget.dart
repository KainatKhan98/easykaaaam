import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Function(int)? onPageSelected;
  final bool isLoading;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    this.onPrevious,
    this.onNext,
    this.onPageSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate visible page numbers
    final visiblePages = _getVisiblePages();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Arrow
          _buildArrowButton(
            icon: Icons.chevron_left,
            onPressed: currentPage > 1 && !isLoading ? onPrevious : null,
          ),
          
          const SizedBox(width: 12),
          
          // Page Numbers
          ...visiblePages.map((page) => _buildPageNumber(page)),
          
          const SizedBox(width: 12),
          
          // Next Arrow
          _buildArrowButton(
            icon: Icons.chevron_right,
            onPressed: currentPage < totalPages && !isLoading ? onNext : null,
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: onPressed != null ? Colors.grey.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: onPressed != null ? Colors.grey.shade300 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: onPressed != null ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumber(int page) {
    final isActive = page == currentPage;
    final isClickable = !isLoading && page != currentPage;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isClickable ? () => onPageSelected?.call(page) : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF8DD4FD) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: isActive ? null : Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              page.toString(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<int> _getVisiblePages() {
    const int maxVisiblePages = 7;
    List<int> pages = [];
    
    if (totalPages <= maxVisiblePages) {
      // Show all pages if total is less than max visible
      pages = List.generate(totalPages, (index) => index + 1);
    } else {
      // Show pages around current page
      int start = (currentPage - 3).clamp(1, totalPages - maxVisiblePages + 1);
      int end = (start + maxVisiblePages - 1).clamp(maxVisiblePages, totalPages);
      
      pages = List.generate(end - start + 1, (index) => start + index);
    }
    
    return pages;
  }
}
