import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/payment_info_card.dart';
import '../../shared/widgets/widgets.dart';

class HowToPayScreen extends StatelessWidget {
  final ClientModel client;
  final DeviceModel device;

  const HowToPayScreen({
    super.key,
    required this.client,
    required this.device,
  });

  static Future<void> open(BuildContext context, ClientModel? client) {
    final device = client?.devices.isNotEmpty == true ? client!.devices.first : null;
    if (client == null || device == null || device.isCompleted) {
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const _PayUnavailableScreen(),
        ),
      );
    }

    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HowToPayScreen(client: client, device: device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reference = client.reference ?? 'your reference code';

    return Scaffold(
      appBar: AppBar(title: const Text('How to Pay')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaymentInfoCard(client: client, device: device),
            const SizedBox(height: 24),
            const SectionTitle('Steps'),
            _PayStep(
              number: '1',
              title: 'Open Mobile Money',
              subtitle: 'Use MTN MoMo on your phone.',
            ),
            _PayStep(
              number: '2',
              title: 'Send ${fmtGHS(device.weeklyInstallment)}',
              subtitle: 'Transfer to ${PaymentInfoCard.momoNumber}.',
            ),
            _PayStep(
              number: '3',
              title: 'Add your reference',
              subtitle: 'Enter "$reference" in the payment reference or description.',
            ),
            _PayStep(
              number: '4',
              title: 'Keep your receipt',
              subtitle: 'Save the MoMo confirmation in case we need to verify payment.',
            ),
            const SizedBox(height: 8),
            DarkCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.amber.withOpacity(0.9)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Payments are recorded by our team after confirmation. You will receive an SMS and app notification once your payment is logged.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.95), height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _PayStep({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.blue),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayUnavailableScreen extends StatelessWidget {
  const _PayUnavailableScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Pay')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No active installment found. Contact us at 0547592655 for payment help.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
        ),
      ),
    );
  }
}
