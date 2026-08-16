import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import 'widgets.dart';

class PaymentHistoryCard extends StatelessWidget {
  final PaymentModel payment;
  final int weekNumber;

  const PaymentHistoryCard({
    super.key,
    required this.payment,
    required this.weekNumber,
  });

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$weekNumber',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.green),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.note ?? 'Week $weekNumber payment',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Paid',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.green,
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fmtDate(payment.recordedAt),
                  style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary, height: 1.2),
                ),
                Text(
                  fmtTime(payment.recordedAt),
                  style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary, height: 1.2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmtGHS(payment.amount),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.green),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  payment.methodLabel,
                  style: const TextStyle(fontSize: 10, color: AppTheme.blue, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
