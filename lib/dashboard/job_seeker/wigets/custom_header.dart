import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;

  const CustomHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.only(right: 18),
            // decoration: const BoxDecoration(
            //   color: Colors.white,
            //   shape: BoxShape.circle,
            // ),
            child: const Icon(
              Icons.settings,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
