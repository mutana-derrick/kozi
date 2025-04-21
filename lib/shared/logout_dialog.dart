import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';

class CustomLogoutDialog extends ConsumerWidget {
  final VoidCallback? onCancel;

  const CustomLogoutDialog({
    super.key,
    this.onCancel,
  });

  /// Shows the logout confirmation dialog
  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomLogoutDialog(
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context, ref),
    );
  }

  Widget _buildDialogContent(BuildContext context, WidgetRef ref) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Log Out',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  if (onCancel != null) onCancel!();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFEE5A9E),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () async {
                  // Perform logout using auth provider
                  await ref.read(authProvider.notifier).logout();
                  
                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                    // Navigate to login screen
                    context.go('/seekerlogin');
                  }
                },
                child: const Text(
                  'Ok',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFEE5A9E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}