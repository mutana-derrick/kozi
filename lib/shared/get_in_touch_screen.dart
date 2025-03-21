import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetInTouchScreen extends ConsumerWidget {
  const GetInTouchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC), // Light pink background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Get in touch',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How can we help you?',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Reach out to us any time you need help and our talented team will gladly assist you.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),

              // Contact options
              ContactOptionTile(
                icon: FaIcon(FontAwesomeIcons.phone,
                    color: Colors.white, size: 20),
                backgroundColor: const Color(0xFFFF5252),
                title: 'Call us',
                onTap: () {
                  // Call functionality
                },
              ),

              ContactOptionTile(
                icon: FaIcon(FontAwesomeIcons.envelope,
                    color: Colors.white, size: 20),
                backgroundColor: const Color(0xFF4CAF50),
                title: 'Email us',
                onTap: () {
                  // Email functionality
                },
              ),

              ContactOptionTile(
                icon: FaIcon(FontAwesomeIcons.globe,
                    color: Colors.white, size: 20),
                backgroundColor: const Color(0xFF29B6F6),
                title: 'Visit our website',
                onTap: () {
                  // Website navigation
                },
              ),

              ContactOptionTile(
                icon: FaIcon(FontAwesomeIcons.instagram,
                    color: Colors.white, size: 20),
                backgroundColor: const Color(0xFFCA8035),
                title: 'Follow us on Instagram',
                onTap: () {
                  // Instagram functionality
                },
              ),

              ContactOptionTile(
                icon: FaIcon(FontAwesomeIcons.facebook,
                    color: Colors.white, size: 20),
                backgroundColor: const Color(0xFF3F51B5),
                title: 'Follow us on Facebook',
                onTap: () {
                  // Facebook functionality
                },
              ),

              ContactOptionTile(
                icon: FaIcon(FontAwesomeIcons.linkedin,
                    color: Colors.white, size: 20),
                backgroundColor: const Color(0xFF0277BD),
                title: 'Follow us on LinkedIn',
                onTap: () {
                  // LinkedIn functionality
                },
              ),

              const SizedBox(height: 40),

              // Linked accounts section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Linked accounts',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    // decoration: BoxDecoration(
                    //   color: Colors.white.withOpacity(0.7),
                    //   borderRadius: BorderRadius.circular(20),
                    // ),
                    child: const Row(
                      children: [
                        Text(
                          'Facebook, Google',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Divider(height: 1, color: Colors.black12),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactOptionTile extends StatelessWidget {
  final Widget icon;
  final Color backgroundColor;
  final String title;
  final VoidCallback onTap;

  const ContactOptionTile({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: icon),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
