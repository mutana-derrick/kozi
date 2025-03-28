import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class GetInTouchScreen extends ConsumerWidget {
  const GetInTouchScreen({super.key});

  // Helper method to launch URLs
  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString: $e')),
        );
      }
    }
  }

  // Helper method to make phone calls
  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not make phone call: $e')),
        );
      }
    }
  }

  // Helper method to send emails
  Future<void> _sendEmail(BuildContext context, String emailAddress) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send email: $e')),
        );
      }
    }
  }

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
                icon: const FaIcon(FontAwesomeIcons.phone,
                    color: Colors.white, size: 20),
                backgroundColor: const Color(0xFFFF5252),
                title: 'Call us',
                onTap: () => _makePhoneCall(context, '0788719678'),
              ),

              ContactOptionTile(
                icon: const FaIcon(FontAwesomeIcons.envelope,
                    color: Colors.white, size: 20),
                backgroundColor: const Color(0xFF4CAF50),
                title: 'Email us',
                onTap: () => _sendEmail(context, 'info@kozi.rw'),
              ),

              ContactOptionTile(
                icon: const FaIcon(FontAwesomeIcons.globe,
                    color: Colors.white, size: 20),
                backgroundColor: const Color(0xFF29B6F6),
                title: 'Visit our website',
                onTap: () => _launchUrl(context, 'https://www.kozi.rw/'),
              ),
              ContactOptionTile(
                icon: const FaIcon(FontAwesomeIcons.instagram,
                    color: Colors.white, size: 20),
                backgroundColor: const Color(0xFFCA8035),
                title: 'Follow us on Instagram',
                onTap: () =>
                    _launchUrl(context, 'https://www.instagram.com/kozirw/'),
              ),

              ContactOptionTile(
                icon: const FaIcon(FontAwesomeIcons.facebook,
                    color: Colors.white, size: 20),
                backgroundColor: const Color(0xFF3F51B5),
                title: 'Follow us on Facebook',
                onTap: () => _launchUrl(context,
                    'https://www.facebook.com/profile.php?id=61562808873913'),
              ),

              ContactOptionTile(
                icon: const FaIcon(FontAwesomeIcons.linkedin,
                    color: Colors.white, size: 20),
                backgroundColor: const Color(0xFF0277BD),
                title: 'Follow us on LinkedIn',
                onTap: () => _launchUrl(
                    context, 'https://www.linkedin.com/company/kozi-rwanda/'),
              ),

              ContactOptionTile(
                icon: const FaIcon(FontAwesomeIcons.twitter,
                    color: Colors.white, size: 20),
                backgroundColor: const Color(0xFF0277BD),
                title: 'Follow us on Twitter',
                onTap: () => _launchUrl(
                    context, 'https://www.linkedin.com/company/kozi-rwanda/'),
              ),

              const SizedBox(height: 15),
              const SizedBox(height: 30),
              const Divider(height: 1, color: Colors.black12),
            ],
          ),
        ),
      ),
    );
  }
}

// The ContactOptionTile remains the same as in the original code
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
