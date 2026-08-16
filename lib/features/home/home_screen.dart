import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/models/models.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/payment_history_card.dart';
import '../../shared/widgets/widgets.dart';
import '../pay/how_to_pay_screen.dart';
import '../payments/payments_screen.dart';
import '../schedule/schedule_screen.dart';
import '../support/support_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  ClientModel? _client;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final client = await AuthService.getProfile();
    if (mounted) setState(() { _client = client; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardTab(client: _client, loading: _loading, onRefresh: _loadProfile),
      PaymentsScreen(client: _client),
      ScheduleScreen(client: _client),
      SupportScreen(client: _client),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long_rounded), label: 'Payments'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today_rounded), label: 'Schedule'),
            BottomNavigationBarItem(icon: Icon(Icons.headset_mic_outlined), activeIcon: Icon(Icons.headset_mic_rounded), label: 'Support'),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final ClientModel? client;
  final bool loading;
  final VoidCallback onRefresh;

  const _DashboardTab({this.client, required this.loading, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final device = client?.devices.isNotEmpty == true ? client!.devices.first : null;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        color: AppTheme.blue,
        backgroundColor: AppTheme.bg800,
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${client?.name.split(' ').first ?? ''}! 👋',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Text('Your installment overview', style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 22),
                  color: AppTheme.textTertiary,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  color: AppTheme.textTertiary,
                  onPressed: () async {
                    await AuthService.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
                    }
                  },
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (loading) ...[
                    const Center(child: CircularProgressIndicator(color: AppTheme.blue)),
                  ] else if (device == null) ...[
                    DarkCard(
                      child: Column(
                        children: [
                          const Icon(Icons.phone_iphone_rounded, size: 48, color: AppTheme.textTertiary),
                          const SizedBox(height: 12),
                          const Text('No device found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          const Text('Contact us to get started', style: TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ] else ...[

                    // Status banner
                    if (device.isLocked)
                      _StatusBanner(
                        color: AppTheme.amber,
                        icon: Icons.lock_rounded,
                        title: 'Device Locked',
                        subtitle: 'Your device is locked. Call 0540571511 to resolve.',
                      )
                    else if (device.overdue)
                      _StatusBanner(
                        color: AppTheme.red,
                        icon: Icons.warning_rounded,
                        title: 'Payment Overdue',
                        subtitle: 'You have a missed payment. Please pay to avoid device lock.',
                      )
                    else if (device.isCompleted)
                      _StatusBanner(
                        color: AppTheme.green,
                        icon: Icons.check_circle_rounded,
                        title: 'Fully Paid! 🎉',
                        subtitle: 'Congratulations! Your device is yours. Contact us to remove management.',
                      ),

                    if (device.isLocked || device.overdue || device.isCompleted)
                      const SizedBox(height: 16),

                    // Big progress card
                    _ProgressCard(device: device),

                    if (!device.isCompleted) ...[
                      const SizedBox(height: 16),
                      _PayNowBanner(client: client!, device: device),
                    ],

                    const SizedBox(height: 16),

                    // Financial breakdown
                    DarkCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle('Financial Summary'),
                          InfoRow(label: 'Selling Price', value: fmtGHS(device.sellingPrice)),
                          const Divider(height: 1),
                          InfoRow(label: 'Down Payment', value: fmtGHS(device.downPayment), valueColor: AppTheme.blue),
                          const Divider(height: 1),
                          InfoRow(label: 'Total Paid', value: fmtGHS(device.totalPaid), valueColor: AppTheme.green),
                          const Divider(height: 1),
                          InfoRow(
                            label: 'Balance Remaining',
                            value: device.isCompleted ? 'PAID IN FULL ✓' : fmtGHS(device.balance),
                            valueColor: device.isCompleted ? AppTheme.green : AppTheme.amber,
                          ),
                          const Divider(height: 1),
                          InfoRow(label: 'Weekly Installment', value: fmtGHS(device.weeklyInstallment), valueColor: AppTheme.blue),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Device info
                    DarkCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle('Device'),
                          InfoRow(label: 'Model', value: device.model),
                          const Divider(height: 1),
                          InfoRow(label: 'Variant', value: device.variant ?? '—'),
                          const Divider(height: 1),
                          InfoRow(label: 'Serial Number', value: device.serialNumber, mono: true),
                          const Divider(height: 1),
                          InfoRow(label: 'Start Date', value: fmtDate(device.startDate)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Recent payments
                    if (device.payments.isNotEmpty) ...[
                      const SectionTitle('Recent Payments'),
                      ...device.payments.take(3).toList().asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PaymentHistoryCard(
                            payment: e.value,
                            weekNumber: e.key + 1,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final DeviceModel device;
  const _ProgressCard({required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: device.isCompleted
              ? [AppTheme.green.withOpacity(0.3), AppTheme.green.withOpacity(0.1)]
              : device.overdue
                  ? [AppTheme.red.withOpacity(0.3), AppTheme.red.withOpacity(0.1)]
                  : [AppTheme.blue.withOpacity(0.3), AppTheme.blue.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: device.isCompleted
              ? AppTheme.green.withOpacity(0.3)
              : device.overdue
                  ? AppTheme.red.withOpacity(0.3)
                  : AppTheme.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.model, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    StatusBadge(
                      label: device.isCompleted ? 'Completed' : device.overdue ? 'Overdue' : device.isLocked ? 'Locked' : 'Active',
                      color: device.isCompleted ? AppTheme.green : device.overdue ? AppTheme.red : device.isLocked ? AppTheme.amber : AppTheme.blue,
                    ),
                  ],
                ),
              ),
              CircularPercentIndicator(
                radius: 40,
                lineWidth: 6,
                percent: device.pct / 100,
                center: Text('${device.pct}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                progressColor: device.isCompleted ? AppTheme.green : device.overdue ? AppTheme.red : AppTheme.blue,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(label: 'Paid', value: fmtGHS(device.totalPaid), color: AppTheme.green),
              _Stat(label: 'Remaining', value: device.isCompleted ? 'DONE ✓' : fmtGHS(device.balance), color: AppTheme.amber),
              _Stat(label: 'Weeks Left', value: device.isCompleted ? '0' : '${device.weeksLeft}', color: AppTheme.blue),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const _StatusBanner({required this.color, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
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

class _PayNowBanner extends StatelessWidget {
  final ClientModel client;
  final DeviceModel device;

  const _PayNowBanner({required this.client, required this.device});

  @override
  Widget build(BuildContext context) {
    final nextDue = device.nextDueDate ?? client.nextDueDate;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => HowToPayScreen.open(context, client),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.green.withOpacity(0.14),
                AppTheme.blue.withOpacity(0.1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.green.withOpacity(0.28)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payments_rounded, color: AppTheme.green, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Pay',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${fmtGHS(device.weeklyInstallment)} weekly via MoMo',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    if (nextDue != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Due ${fmtDate(nextDue)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: device.overdue ? AppTheme.red : AppTheme.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.green.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
