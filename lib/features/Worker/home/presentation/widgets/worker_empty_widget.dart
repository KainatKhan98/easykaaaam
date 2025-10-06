import 'package:flutter/material.dart';

class WorkerEmptyWidget extends StatelessWidget {
  final String message;
  final String subtitle;
  final VoidCallback? onRetry;
  final VoidCallback? onDebug;

  const WorkerEmptyWidget({
    super.key,
    this.message = "No jobs available",
    this.subtitle = "Check back later for new opportunities",
    this.onRetry,
    this.onDebug,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.work_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 8),
          Text(subtitle),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onRetry != null)
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text("Refresh"),
                ),
              if (onRetry != null && onDebug != null)
                const SizedBox(width: 16),
              if (onDebug != null)
                ElevatedButton(
                  onPressed: onDebug,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Debug API"),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

