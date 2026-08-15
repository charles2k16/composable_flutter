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
    final nextUpcomingIndex = schedule.indexWhere((s) => s.resolvedStatus == 'active');

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
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: schedule.asMap().entries.map((entry) {
                                  final s = entry.value;
                                  final color = _weekDotColor(s, entry.key == nextUpcomingIndex);
                                  return Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: color.withOpacity(0.5)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${s.week}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
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
                        final isNext = index == nextUpcomingIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ScheduleRow(
                            week: 'Week ${item.week}',
                            date: fmtDate(item.dueDate),
                            amount: fmtGHS(item.amount),
                            paid: item.paid,
                            status: item.resolvedStatus,
                            amountPaid: item.amountPaid,
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

  Color _weekDotColor(ScheduleItem item, bool isNext) {
    if (item.paid) return AppTheme.green;
    if (item.isOverdue) return AppTheme.red;
    if (item.isPartial) return AppTheme.amber;
    if (isNext) return AppTheme.blue;
    return AppTheme.textTertiary;
  }
}

class _ScheduleRow extends StatelessWidget {
  final String week;
  final String date;
  final String amount;
  final bool paid;
  final String? status;
  final double? amountPaid;
  final bool isNext;
  final bool isDown;

  const _ScheduleRow({
    required this.week,
    required this.date,
    required this.amount,
    required this.paid,
    this.status,
    this.amountPaid,
    this.isNext = false,
    this.isDown = false,
  });

  @override
  Widget build(BuildContext context) {
    Color accent = AppTheme.textTertiary;
    if (isDown) {
      accent = AppTheme.blue;
    } else if (paid) {
      accent = AppTheme.green;
    } else if (status == 'overdue') {
      accent = AppTheme.red;
    } else if (status == 'partial') {
      accent = AppTheme.amber;
    } else if (isNext) {
      accent = AppTheme.blue;
    }

    final statusLabel = paid
        ? 'Paid'
        : status == 'overdue'
            ? 'Overdue'
            : status == 'partial'
                ? 'Partial'
                : isNext
                    ? 'Due soon'
                    : 'Pending';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isNext || status == 'overdue')
            ? accent.withOpacity(0.08)
            : AppTheme.bg800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isNext || status == 'overdue' || status == 'partial')
              ? accent.withOpacity(0.3)
              : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              paid
                  ? Icons.check_circle_rounded
                  : status == 'overdue'
                      ? Icons.warning_rounded
                      : status == 'partial'
                          ? Icons.pie_chart_rounded
                          : isNext
                              ? Icons.radio_button_unchecked_rounded
                              : Icons.circle_outlined,
              color: accent,
              size: 20,
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
                    if (status == 'overdue') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('OVERDUE', style: TextStyle(fontSize: 9, color: AppTheme.red, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                Text(date, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                if (status == 'partial' && amountPaid != null && amountPaid! > 0)
                  Text(
                    'Paid ${fmtGHS(amountPaid!)} of $amount',
                    style: TextStyle(fontSize: 10, color: accent.withOpacity(0.8)),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
              Text(
                statusLabel,
                style: TextStyle(fontSize: 10, color: accent.withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
