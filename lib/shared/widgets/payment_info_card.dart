import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import 'widgets.dart';

class PaymentInfoCard extends StatelessWidget {
  final ClientModel client;
  final DeviceModel device;

  static const momoNumber = '0594418292';

  const PaymentInfoCard({
    super.key,
    required this.client,
    required this.device,
  });

  void _copyToClipboard(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextDue = device.nextDueDate ?? client.nextDueDate;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppTheme.blue.withOpacity(0.18),
            AppTheme.green.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.blue.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.payments_rounded, color: AppTheme.blue, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Details',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Mobile Money weekly payment',
                        style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _copyToClipboard(context, momoNumber, 'MoMo number'),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppTheme.bg900.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.green.withOpacity(0.35)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet_rounded, color: AppTheme.green.withOpacity(0.9), size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'MTN MoMo Number',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        momoNumber,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: AppTheme.green,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.copy_rounded, size: 14, color: AppTheme.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to copy',
                            style: TextStyle(fontSize: 11, color: AppTheme.textTertiary.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                if (client.reference != null && client.reference!.isNotEmpty)
                  PayDetailTile(
                    icon: Icons.tag_rounded,
                    label: 'Your Reference',
                    value: client.reference!,
                    valueColor: AppTheme.blue,
                    mono: true,
                    onCopy: () => _copyToClipboard(context, client.reference!, 'Reference'),
                  ),
                if (client.reference != null && client.reference!.isNotEmpty) const SizedBox(height: 8),
                PayDetailTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Weekly Amount',
                  value: fmtGHS(device.weeklyInstallment),
                  valueColor: AppTheme.blue,
                ),
                if (nextDue != null) ...[
                  const SizedBox(height: 8),
                  PayDetailTile(
                    icon: Icons.schedule_rounded,
                    label: 'Next Payment Due',
                    value: fmtDate(nextDue),
                    valueColor: device.overdue ? AppTheme.red : AppTheme.amber,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Text(
              'Send ${fmtGHS(device.weeklyInstallment)} to the MoMo number above and use your reference. Call 0547592655 if you need help.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.85), height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class PayDetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool mono;
  final VoidCallback? onCopy;

  const PayDetailTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.mono = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppTheme.bg800.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: valueColor.withOpacity(0.85)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: mono ? 13 : 14,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                    fontFamily: mono ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            Icon(Icons.copy_rounded, size: 16, color: AppTheme.textTertiary.withOpacity(0.6)),
        ],
      ),
    );

    if (onCopy == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCopy,
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }
}
