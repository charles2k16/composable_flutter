import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ─── Dark Card ────────────────────────────────────────────────────────────────

class DarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  final Color? accentColor;

  const DarkCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor;
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent != null
            ? Color.alphaBlend(accent.withOpacity(0.12), AppTheme.bg800)
            : AppTheme.bg800,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? accent?.withOpacity(0.32) ?? AppTheme.border,
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool mono;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontFamily: mono ? 'monospace' : null,
                  fontSize: mono ? 11 : null,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }
}

// ─── GHS Formatter ────────────────────────────────────────────────────────────

String fmtGHS(double amount) {
  return 'GHS ${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

// ─── Date Formatter ───────────────────────────────────────────────────────────

String fmtDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final local = d.toLocal();
  return '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}';
}

String fmtTime(DateTime d) {
  final local = d.toLocal();
  final hour = local.hour;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';
  final hour12 = hour % 12 == 0 ? 12 : hour % 12;
  return '${hour12.toString().padLeft(2, '0')}:$minute $period';
}
