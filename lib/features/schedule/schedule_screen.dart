import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';

class ScheduleScreen extends StatelessWidget {
  final ClientModel? client;
  const ScheduleScreen({super.key, this.client});

  @override
  Widget build(BuildContext context) {
    final device = client?.devices.isNotEmpty == true ? client!.devices.first : null;
    final schedule = device?.schedule ?? [];
    final paidCount = schedule.where((s) => s.paid).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Schedule')),
      body: schedule.isEmpty
          ? const Center(child: Text('No schedule available', style: TextStyle(color: AppTheme.textSecondary)))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Progress summary
                        DarkCard(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Weeks Completed', style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                                      Text(
                                        '$paidCount of ${schedule.length}',
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Weeks Remaining', style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                                      Text(
                                        '${schedule.length - paidCount}',
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.amber),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Week dots grid
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: schedule.map((s) => Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    color: s.paid
                                        ? AppTheme.green.withOpacity(0.2)
                                        : AppTheme.bg700,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: s.paid ? AppTheme.green.withOpacity(0.5) : AppTheme.border,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${s.week}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: s.paid ? AppTheme.green : AppTheme.textTertiary,
                                      ),
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Down payment
                        _ScheduleRow(
                          week: 'Down Payment',
                          date: fmtDate(device!.startDate),
                          amount: fmtGHS(device.downPayment),
                          paid: true,
                          isDown: true,
                        ),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: SectionTitle('Weekly Schedule'),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = schedule[index];
                        final isNext = !item.paid && (index == 0 || schedule[index - 1].paid);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ScheduleRow(
                            week: 'Week ${item.week}',
                            date: fmtDate(item.dueDate),
                            amount: fmtGHS(item.amount),
                            paid: item.paid,
                            isNext: isNext,
                          ),
                        );
                      },
                      childCount: schedule.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String week;
  final String date;
  final String amount;
  final bool paid;
  final bool isNext;
  final bool isDown;

  const _ScheduleRow({
    required this.week,
    required this.date,
    required this.amount,
    required this.paid,
    this.isNext = false,
    this.isDown = false,
  });

  @override
  Widget build(BuildContext context) {
    Color accent = paid ? AppTheme.green : isNext ? AppTheme.blue : AppTheme.textTertiary;
    if (isDown) accent = AppTheme.blue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isNext ? AppTheme.blue.withOpacity(0.08) : AppTheme.bg800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNext ? AppTheme.blue.withOpacity(0.3) : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              paid ? Icons.check_circle_rounded : isNext ? Icons.radio_button_unchecked_rounded : Icons.circle_outlined,
              color: accent, size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(week, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: accent)),
                    if (isNext) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('NEXT', style: TextStyle(fontSize: 9, color: AppTheme.blue, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                Text(date, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
              Text(
                paid ? 'Paid' : isNext ? 'Due soon' : 'Pending',
                style: TextStyle(fontSize: 10, color: accent.withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
