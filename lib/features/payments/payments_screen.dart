import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/payment_history_card.dart';
import '../../shared/widgets/widgets.dart';

class PaymentsScreen extends StatelessWidget {
  final ClientModel? client;
  const PaymentsScreen({super.key, this.client});

  @override
  Widget build(BuildContext context) {
    final device = client?.devices.isNotEmpty == true ? client!.devices.first : null;
    final payments = device?.payments ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: payments.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textTertiary),
                  SizedBox(height: 12),
                  Text('No payments yet', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Summary header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Summary cards
                        Row(
                          children: [
                            Expanded(
                              child: DarkCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total Paid', style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                                    const SizedBox(height: 4),
                                    Text(
                                      fmtGHS(device?.totalPaid ?? 0),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.green),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DarkCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Remaining', style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                                    const SizedBox(height: 4),
                                    Text(
                                      fmtGHS(device?.balance ?? 0),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.amber),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Down payment row
                        DarkCard(
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.blue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.arrow_downward_rounded, color: AppTheme.blue, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Down Payment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    Text(
                                      fmtDate(device?.startDate ?? DateTime.now()),
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                fmtGHS(device?.downPayment ?? 0),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.blue),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: SectionTitle('Weekly Payments'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Payment list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final payment = payments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PaymentHistoryCard(
                            payment: payment,
                            weekNumber: index + 1,
                          ),
                        );
                      },
                      childCount: payments.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
