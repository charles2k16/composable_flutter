import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<ClientNotification> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.blue))
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications yet',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppTheme.blue,
                  backgroundColor: AppTheme.bg800,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      return _NotificationTile(notification: n);
                    },
                  ),
                ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final ClientNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(notification.type);

    return DarkCard(
      padding: const EdgeInsets.all(14),
      borderColor: color.withOpacity(0.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_typeIcon(notification.type), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.typeLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    Text(
                      fmtDate(notification.createdAt),
                      style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (notification.channel.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    notification.channel,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    return switch (type) {
      'PAYMENT_CONFIRMED' || 'COMPLETION' || 'DEVICE_UNLOCKED' => AppTheme.green,
      'PAYMENT_REMINDER' || 'OVERDUE_WARNING' => AppTheme.amber,
      'DEVICE_LOCKED' => AppTheme.red,
      _ => AppTheme.blue,
    };
  }

  IconData _typeIcon(String type) {
    return switch (type) {
      'PAYMENT_CONFIRMED' => Icons.check_circle_rounded,
      'PAYMENT_REMINDER' => Icons.schedule_rounded,
      'DEVICE_LOCKED' => Icons.lock_rounded,
      'DEVICE_UNLOCKED' => Icons.lock_open_rounded,
      'COMPLETION' => Icons.celebration_rounded,
      'ONBOARDING' => Icons.waving_hand_rounded,
      _ => Icons.notifications_rounded,
    };
  }
}
