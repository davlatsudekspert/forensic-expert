import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';

/// Nima uchun ekran bo‘sh — har biri alohida, halol matn bilan.
enum AvailabilityKind {
  /// Ilmiy bazada bu bo‘lim uchun yozuv yo‘q.
  noData,

  /// Yozuvlar faqat manba va ekspert tekshiruvidan keyin ko‘rsatiladi.
  noReviewedData,

  /// Filtr natijasi bo‘sh.
  filterEmpty,

  /// Onlayn xizmat bu versiyada ulanmagan.
  notConnected,

  /// Onlayn xizmat vaqtincha ishlamayapti.
  serviceUnavailable,
}

/// Bo‘sh holat uchun amal (masalan, «Filtrlarni tozalash»).
typedef AvailabilityAction = ({
  String label,
  IconData icon,
  VoidCallback onTap,
});

/// Tugallangan ko‘rinishdagi bo‘sh holat. Ma’lumot to‘qilmaydi — faqat nima
/// uchun bo‘shligi va foydali keyingi qadam ko‘rsatiladi.
class AvailabilityStateView extends StatelessWidget {
  const AvailabilityStateView({
    super.key,
    required this.kind,
    this.icon,
    this.embedded = false,
    this.actions = const [],
  });

  final AvailabilityKind kind;
  final IconData? icon;

  /// `true` — boshqa skroll ichida (oddiy Column), `false` — mustaqil ekran.
  final bool embedded;
  final List<AvailabilityAction> actions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final (title, body, defaultIcon) = switch (kind) {
      AvailabilityKind.noData => (
        l.availNoDataTitle,
        l.availNoDataBody,
        Icons.inventory_2_outlined,
      ),
      AvailabilityKind.noReviewedData => (
        l.inDevelopmentTitle,
        l.inDevelopmentBody,
        Icons.fact_check_outlined,
      ),
      AvailabilityKind.filterEmpty => (
        l.availFilterTitle,
        l.availFilterBody,
        Icons.filter_alt_off_outlined,
      ),
      AvailabilityKind.notConnected => (
        l.availNotConnectedTitle,
        l.availNotConnectedBody,
        Icons.cloud_off_outlined,
      ),
      AvailabilityKind.serviceUnavailable => (
        l.availServiceTitle,
        l.availServiceBody,
        Icons.portable_wifi_off_outlined,
      ),
    };
    final content = Column(
      key: Key('availability.${kind.name}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(FeSpace.md),
            child: Icon(icon ?? defaultIcon, size: 28, color: c.accent),
          ),
        ),
        const SizedBox(height: FeSpace.md),
        Semantics(
          header: true,
          child: Text(title, style: t.titleMedium, textAlign: TextAlign.center),
        ),
        const SizedBox(height: FeSpace.xs),
        Text(
          body,
          textAlign: TextAlign.center,
          style: t.bodyMedium?.copyWith(color: c.textSecondary),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: FeSpace.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: FeSpace.sm,
            runSpacing: FeSpace.xs,
            children: [
              for (final a in actions)
                OutlinedButton.icon(
                  onPressed: a.onTap,
                  icon: Icon(a.icon, size: 18),
                  label: Text(a.label),
                ),
            ],
          ),
        ],
      ],
    );
    if (embedded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: FeSpace.lg),
        child: content,
      );
    }
    return FeScrollableBody(
      padding: const EdgeInsets.symmetric(vertical: FeSpace.xl),
      child: content,
    );
  }
}
