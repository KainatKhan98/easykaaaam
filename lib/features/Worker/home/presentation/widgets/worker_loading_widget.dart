import 'package:flutter/material.dart';

class WorkerLoadingWidget extends StatelessWidget {
  final String message;

  const WorkerLoadingWidget({
    super.key,
    this.message = "Loading available jobs...",
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Loading available jobs..."),
        ],
      ),
    );
  }
}

