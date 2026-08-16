import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';
import '../pay/how_to_pay_screen.dart';

class SupportScreen extends StatelessWidget {
  final ClientModel? client;

  const SupportScreen({super.key, this.client});

  static const _whatsappGreen = Color(0xFF25D366);

  Future<void> _call() async {
    final uri = Uri.parse('tel:0547592655');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    final uri = Uri.parse('https://wa.me/233540571511?text=Hello%20Composables%20IT%20Consult%2C%20I%20need%20help%20with%20my%20installment%20account.');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _sms() async {
    final uri = Uri.parse('sms:0540571511?body=Hello%20Composables%20IT%20Consult%2C%20I%20need%20help.');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final device = client?.devices.isNotEmpty == true ? client!.devices.first : null;
    final showPayGuide = device != null && !device.isCompleted;

    const faqItems = [
      (
        q: 'When is my payment due?',
        a: 'Your weekly payment is due based on your start date. Check the Schedule tab for your exact due dates.',
      ),
      (
        q: 'What happens if I miss a payment?',
        a: 'You will receive an SMS reminder after 1 day. After 3 days, a final warning is sent. After 7 days without payment, your device may be remotely locked until the payment is resolved.',
      ),
      (
        q: 'How do I make a payment?',
        a: 'Open How to Pay from Home or the button above. Send your weekly amount to MTN MoMo 0594418292 and include your personal reference code.',
      ),
      (
        q: 'My device is locked. What do I do?',
        a: 'Call or WhatsApp us at 0547592655 immediately to resolve your outstanding payment. Once payment is confirmed, your device will be unlocked remotely within minutes.',
      ),
      (
        q: 'What happens after I finish paying?',
        a: 'Once all payments are complete, we will remove the device management profile and the phone will be fully yours with no restrictions.',
      ),
      (
        q: 'Can I pay off the full balance early?',
        a: 'Yes! Contact us at 0547592655 to arrange early payoff. We will calculate your remaining balance and complete the process for you.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: DarkCard(
                accentColor: AppTheme.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.blue.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('CIT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.blue)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'InstallPay - Device Finance',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your Trusted iPhone Installment Partner',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Accra, Ghana',
                      style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            if (showPayGuide) ...[
              const SizedBox(height: 20),
              const SectionTitle('How to Pay'),
              _PayGuideButton(
                amount: fmtGHS(device.weeklyInstallment),
                onTap: () => HowToPayScreen.open(context, client),
              ),
            ],

            const SizedBox(height: 20),
            const SectionTitle('Contact Us'),

            _ContactButton(
              icon: Icons.call_rounded,
              label: 'Call Us',
              subtitle: '0547592655',
              color: AppTheme.green,
              onTap: _call,
            ),
            const SizedBox(height: 10),
            _ContactButton(
              icon: Icons.chat_rounded,
              label: 'WhatsApp',
              subtitle: 'Chat with us on WhatsApp',
              color: _whatsappGreen,
              onTap: _whatsapp,
            ),
            const SizedBox(height: 10),
            _ContactButton(
              icon: Icons.sms_rounded,
              label: 'Send SMS',
              subtitle: 'Text us your question',
              color: AppTheme.blue,
              onTap: _sms,
            ),

            const SizedBox(height: 24),
            const SectionTitle('Frequently Asked Questions'),

            for (final item in faqItems)
              _FAQItem(q: item.q, a: item.a),

            const SizedBox(height: 16),

            DarkCard(
              accentColor: AppTheme.amber,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 16, color: AppTheme.amber.withOpacity(0.9)),
                      const SizedBox(width: 6),
                      Text(
                        'Office Hours',
                        style: TextStyle(fontSize: 12, color: AppTheme.amber.withOpacity(0.95), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InfoRow(label: 'Monday – Friday', value: '8:00 AM – 6:00 PM'),
                  const Divider(height: 1),
                  InfoRow(label: 'Saturday', value: '9:00 AM – 4:00 PM'),
                  const Divider(height: 1),
                  InfoRow(label: 'Sunday', value: 'Closed'),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PayGuideButton extends StatelessWidget {
  final String amount;
  final VoidCallback onTap;

  const _PayGuideButton({required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.alphaBlend(AppTheme.green.withOpacity(0.14), AppTheme.bg800),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.green.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.green.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.payments_rounded, color: AppTheme.green, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Guide',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.green),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'MoMo number, reference & steps · $amount weekly',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.green.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.alphaBlend(color.withOpacity(0.12), AppTheme.bg800),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.32)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String q;
  final String a;

  const _FAQItem({required this.q, required this.a});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _open = !_open),
        child: DarkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _open ? Icons.remove_rounded : Icons.add_rounded,
                    color: AppTheme.textTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.q,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              if (_open) ...[
                const SizedBox(height: 10),
                Text(widget.a, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
