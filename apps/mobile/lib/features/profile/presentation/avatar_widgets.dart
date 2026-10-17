import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/avatar.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';

/// Profil rasmi tanlash oqimi: bottom sheet → galereya → moslash → saqlash.
Future<void> showAvatarActions(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final has = ref.read(avatarProvider).value != null;
  final action = await showModalBottomSheet<String>(
    useRootNavigator: true,
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const Key('avatar.choose'),
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l.avatarChoose),
            onTap: () => Navigator.of(ctx).pop('choose'),
          ),
          if (has) ...[
            ListTile(
              key: const Key('avatar.view'),
              leading: const Icon(Icons.zoom_out_map),
              title: Text(l.avatarView),
              onTap: () => Navigator.of(ctx).pop('view'),
            ),
            ListTile(
              key: const Key('avatar.remove'),
              leading: const Icon(Icons.delete_outline),
              title: Text(l.avatarRemove),
              onTap: () => Navigator.of(ctx).pop('remove'),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FeSpace.md,
              FeSpace.xs,
              FeSpace.md,
              FeSpace.md,
            ),
            child: Text(
              l.avatarDeviceOnly,
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted || action == null) return;
  switch (action) {
    case 'remove':
      await ref.read(avatarProvider.notifier).remove();
    case 'view':
      final bytes = ref.read(avatarProvider).value;
      if (bytes != null) await showAvatarViewer(context, bytes);
    case 'choose':
      Uint8List? picked;
      try {
        picked = await ref.read(avatarPickerProvider).pick();
      } on Object {
        if (context.mounted) _error(context, l.avatarError);
        return;
      }
      if (picked == null || !context.mounted) return;
      final cropped = await Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(builder: (_) => AvatarCropScreen(source: picked!)),
      );
      if (cropped != null) {
        await ref.read(avatarProvider.notifier).set(cropped);
      }
  }
}

void _error(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

Future<void> showAvatarViewer(BuildContext context, Uint8List bytes) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => GestureDetector(
      key: const Key('avatar.viewer'),
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(ctx).pop(),
      child: Center(
        child: InteractiveViewer(
          child: ClipOval(child: Image.memory(bytes, fit: BoxFit.contain)),
        ),
      ),
    ),
  );
}

/// Kvadrat ichida surish/yaqinlashtirish; saqlanganda 512×512 PNG qaytadi.
class AvatarCropScreen extends StatefulWidget {
  const AvatarCropScreen({super.key, required this.source});

  final Uint8List source;

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  final _boundary = GlobalKey();
  bool _busy = false;

  Future<void> _save(double side) async {
    setState(() => _busy = true);
    try {
      final b =
          _boundary.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final img = await b.toImage(pixelRatio: 512 / side);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      if (!mounted) return;
      Navigator.of(context).pop(data!.buffer.asUint8List());
    } on Object {
      if (mounted) {
        setState(() => _busy = false);
        _error(context, AppLocalizations.of(context).avatarError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final side = (width - FeSpace.lg * 2).clamp(200.0, 420.0);
    return Scaffold(
      appBar: AppBar(title: Text(l.avatarCropTitle)),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: SizedBox(
                width: side,
                height: side,
                child: Stack(
                  children: [
                    RepaintBoundary(
                      key: _boundary,
                      child: ClipRect(
                        child: InteractiveViewer(
                          key: const Key('avatar.crop'),
                          minScale: 1,
                          maxScale: 6,
                          child: Image.memory(
                            widget.source,
                            width: side,
                            height: side,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: CustomPaint(
                        size: Size.square(side),
                        painter: const _CircleMask(Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: FeSpace.md),
            Text(
              l.avatarCropHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(FeSpace.md),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('avatar.cancel'),
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(l.avatarCancel),
                    ),
                  ),
                  const SizedBox(width: FeSpace.sm),
                  Expanded(
                    child: FilledButton(
                      key: const Key('avatar.save'),
                      onPressed: _busy ? null : () => _save(side),
                      child: Text(l.avatarSave),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleMask extends CustomPainter {
  const _CircleMask(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addOval(Offset.zero & size)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CircleMask old) => old.color != color;
}
