import 'package:flutter/material.dart';

class HelpCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const HelpCard({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  State<HelpCard> createState() => _HelpCardState();
}

class _HelpCardState extends State<HelpCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isExpanded
          ? const Color(0x268DD4FD) // expanded color
          : const Color(0x0D8DD4FD), // collapsed color
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: widget.onTap, // only trigger external callback
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Only this button toggles expansion
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              // Description + Divider (only if expanded)
              if (widget.subtitle != null && isExpanded) ...[
                const SizedBox(height: 10),
                const Divider(color: Colors.white, thickness: 2),
                const SizedBox(height: 10),
                Text(
                  widget.subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
