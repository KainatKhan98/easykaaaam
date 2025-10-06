import 'package:flutter/material.dart';

class WorkerErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDebug;

  const WorkerErrorWidget({
    super.key,
    this.message = "Error loading jobs",
    this.onRetry,
    this.onDebug,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 8),
          const Text("Check back later for new opportunities"),
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

