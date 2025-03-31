import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.center,
            colors: [Color(0xFFF8BADC), Color.fromARGB(255, 250, 240, 245)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Privacy policy',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kozi Rwanda Apps Privacy Policy',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D6B98),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'We value your privacy and protect your data. Any information shared on our platform is securely stored and used solely to connect job providers with skilled workers. Our platform ensures transparency and security in all interactions. By using Kozi Rwanda, you agree to our data practices, which focus on confidentiality and user protection. We do not share personal details with third parties without consent, ensuring a safe hiring experience for all.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPolicySection(
                        title: 'Contracts & Agreements:',
                        content:
                            'All agreements made via Kozi Rwanda are binding, with both parties responsible for respecting their terms fully.',
                      ),
                      _buildPolicySection(
                        title: 'Information Confidentiality:',
                        content:
                            'User data is securely stored and protected. No personal details are shared or disclosed without user consent.',
                      ),
                      _buildPolicySection(
                        title: 'Hiring Process:',
                        content:
                            'Employers browse verified workers or request matches. Background checks ensure quality and trust in hiring.',
                      ),
                      _buildPolicySection(
                        title: 'Working Conditions:',
                        content:
                            'Employers ensure fair conditions. Workers must perform professionally. Misconduct may lead to account suspension.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection({
    required String title,
    required String content,
    Color? bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: bgColor != null ? const EdgeInsets.all(16) : EdgeInsets.zero,
      decoration: bgColor != null
          ? BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 8, right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFEA60A7),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
