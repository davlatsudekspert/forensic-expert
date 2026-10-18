import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/ai/ai_architecture.dart';
import '../../../domain/ai/rag_pipeline.dart';

/// Internetdan olingan javob: amber «tekshirilmagan» yorlig‘i, matn va veb
/// manbalar ro‘yxati. Baza iqtiboslari bilan hech qachon aralashmaydi va
/// «tasdiqlangan» ko‘rinishda emas.
class WebAnswerView extends StatelessWidget {
  const WebAnswerView({super.key, required this.answer});

  final RagAnswer answer;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      key: const Key('ai.web'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeBanner(
          key: const Key('ai.web.label'),
          icon: Icons.public,
          tone: FeBannerTone.warning,
          text: '${l.aiWebLabel}. ${l.aiWebNote}',
        ),
        const SizedBox(height: FeSpace.xs),
        SelectableText(
          answer.text ?? '',
          key: const Key('ai.web.text'),
          style: t.bodyMedium?.copyWith(height: 1.5),
        ),
        if (answer.webSources.isNotEmpty) ...[
          FeSectionHeader(l.aiWebSourcesTitle),
          for (final s in answer.webSources) _WebSourceTile(source: s),
        ],
      ],
    );
  }
}

/// Havola ko‘rsatiladigan domen (grounding yo‘naltirish havolalari
/// `vertexaisearch` domenini beradi — u foydalanuvchiga foydasiz).
String? webSourceDomain(String uri) {
  final host = Uri.tryParse(uri)?.host ?? '';
  if (host.isEmpty || host.contains('vertexaisearch')) return null;
  return host.replaceFirst(RegExp(r'^www\.'), '');
}

class _WebSourceTile extends StatelessWidget {
  const _WebSourceTile({required this.source});

  final WebSource source;

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).aiWebOpenFailed;
    var ok = false;
    try {
      final uri = Uri.tryParse(source.uri);
      if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
        ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } on Object {
      ok = false;
    }
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final domain = webSourceDomain(source.uri);
    return InkWell(
      key: Key('ai.web.source.${source.uri}'),
      onTap: () => _open(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
        child: Row(
          children: [
            Icon(Icons.open_in_new, size: 16, color: c.textSecondary),
            const SizedBox(width: FeSpace.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodyMedium,
                  ),
                  if (domain != null && domain != source.title)
                    Text(
                      domain,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
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
