import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacyPolicyModal extends ConsumerWidget {
  final bool isTermsOfService;

  const PrivacyPolicyModal({
    super.key,
    required this.isTermsOfService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.center,
              colors: [Color(0xFFF8BADC), Color.fromARGB(255, 250, 240, 245)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isTermsOfService
                          ? 'Terms of Service'
                          : 'Kozi Rwanda Apps Privacy Policy',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white54),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (!isTermsOfService) ...[
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
                        iconColor: const Color(0xFFEA60A7),
                      ),
                      _buildPolicySection(
                        title: 'Information Confidentiality:',
                        content:
                            'User data is securely stored and protected. No personal details are shared or disclosed without user consent.',
                        iconColor: const Color(0xFFEA60A7),
                      ),
                      _buildPolicySection(
                        title: 'Hiring Process:',
                        content:
                            'Employers browse verified workers or request matches. Background checks ensure quality and trust in hiring.',
                        iconColor: const Color(0xFFEA60A7),
                        // bgColor: Colors.white.withOpacity(0.6),
                      ),
                      _buildPolicySection(
                        title: 'Working Conditions:',
                        content:
                            'Employers ensure fair conditions. Workers must perform professionally. Misconduct may lead to account suspension.',
                        iconColor: const Color(0xFFEA60A7),
                        // bgColor: Colors.white.withOpacity(0.6),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPolicySection({
    required String title,
    required String content,
    required Color iconColor,
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
            decoration: BoxDecoration(
              color: iconColor,
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
