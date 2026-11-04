import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/promo.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/plan/promo_models.dart';

/// Qurilmalar limiti (3 ta) to‘lgan bo‘lsa — bir marta yumshoq oyna:
/// ro‘yxat va «Chiqarish». Bekor qilinsa ilova ishlashda davom etadi.
class DeviceLimitHost extends ConsumerStatefulWidget {
  const DeviceLimitHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DeviceLimitHost> createState() => _DeviceLimitHostState();
}

class _DeviceLimitHostState extends ConsumerState<DeviceLimitHost> {
  bool _open = false;

  Future<void> _show() async {
    if (_open) return;
    _open = true;
    await showDialog<void>(
      context: context,
      builder: (_) => const DeviceLimitDialog(),
    );
    _open = false;
    if (mounted && ref.read(deviceLimitProvider).full) {
      ref.read(deviceLimitProvider.notifier).dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(deviceLimitProvider, (prev, next) {
      if (next.full && !(prev?.full ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _show();
        });
      }
    });
    return widget.child;
  }
}

class DeviceLimitDialog extends ConsumerStatefulWidget {
  const DeviceLimitDialog({super.key});

  @override
  ConsumerState<DeviceLimitDialog> createState() => _DeviceLimitDialogState();
}

class _DeviceLimitDialogState extends ConsumerState<DeviceLimitDialog> {
  String? _busyHash;
  String? _error;

  Future<void> _remove(DeviceRecord d) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busyHash = d.hash;
      _error = null;
    });
    final ok = await ref
        .read(deviceLimitProvider.notifier)
        .removeAndRetry(d.hash);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _busyHash = null;
      _error = ref.read(deviceLimitProvider).full
          ? l.devLimitStillFull
          : l.devLimitRemoveError;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final st = ref.watch(deviceLimitProvider);
    final t = Theme.of(context).textTheme;
    return AlertDialog(
      key: const Key('devLimit.dialog'),
      title: Text(l.devLimitTitle(st.limit)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.devLimitBody, style: t.bodyMedium),
              const SizedBox(height: 8),
              for (final d in st.devices)
                ListTile(
                  key: Key('devLimit.device.${d.hash}'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.smartphone_outlined),
                  title: Text(d.label ?? l.devLimitUnknown),
                  subtitle: d.lastSeen == null
                      ? null
                      : Text(l.devLimitLastSeen(feDate(context, d.lastSeen!))),
                  trailing: TextButton(
                    key: Key('devLimit.remove.${d.hash}'),
                    onPressed: _busyHash == null ? () => _remove(d) : null,
                    child: _busyHash == d.hash
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l.devLimitRemove),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    key: const Key('devLimit.error'),
                    style: t.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('devLimit.later'),
          onPressed: () {
            ref.read(deviceLimitProvider.notifier).dismiss();
            Navigator.of(context).pop();
          },
          child: Text(l.devLimitLater),
        ),
      ],
    );
  }
}
