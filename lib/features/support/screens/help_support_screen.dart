import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/url_launcher_helper.dart';
import '../../../shared/widgets/card_container.dart';

/// Help and Support screen.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Options
            ListTileCard(
              leading: const Icon(Icons.email_outlined),
              title: 'Email Support',
              subtitle: 'support@lifeandgym.com',
              onTap: () {
                URLLauncherHelper.launchEmail('support@lifeandgym.com');
              },
            ),

            AppSpacing.vGapSm,

            ListTileCard(
              leading: const Icon(Icons.phone_outlined),
              title: 'Call Us',
              subtitle: '+95 9 123 456 789',
              onTap: () {
                URLLauncherHelper.launchPhone('+959123456789');
              },
            ),

            AppSpacing.vGapSm,

            ListTileCard(
              leading: const Icon(Icons.chat_outlined),
              title: 'Live Chat',
              subtitle: 'Available 9 AM - 5 PM',
              onTap: () {
                URLLauncherHelper.launchURL('https://chat.lifeandgym.com');
              },
            ),

            AppSpacing.vGapLg,

            // FAQ Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            _buildFAQItem(
              context,
              question: 'How do I check in to the gym?',
              answer: 'Tap the QR code on the home screen and scan it at the gym entrance.',
            ),

            _buildFAQItem(
              context,
              question: 'How do I book a class?',
              answer: 'Go to the Classes tab, select a class, and tap "Book Class".',
            ),

            _buildFAQItem(
              context,
              question: 'Can I change my membership plan?',
              answer: 'Yes, go to your Profile and tap on your membership card to view available plans.',
            ),

            _buildFAQItem(
              context,
              question: 'How do I track my workouts?',
              answer: 'Use the Workouts tab to log exercises, sets, and reps. Your progress is automatically saved.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, {required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
