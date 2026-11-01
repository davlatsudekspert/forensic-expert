import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../tools/tool_strings.dart';

/// Saqlangan id’lar (★ tanlanganlar, ko‘rilganlar) → ko‘rinadigan nom va
/// ochish amali. Paketda yo‘q (o‘chirilgan) yozuv tashlab ketiladi.
List<(String, VoidCallback)> resolveSavedItems(
  BuildContext context,
  WidgetRef ref,
  Iterable<String> ids,
) {
  final l = AppLocalizations.of(context);
  final lang = Localizations.localeOf(context).languageCode;
  final library = ref.watch(libraryRepositoryProvider);
  final knowledge = ref.watch(knowledgeRepositoryProvider);
  final evidence = ref.watch(evidenceDataProvider);

  String? nameOf(String id) {
    final tool = ToolsCatalog.byId(id);
    if (tool != null) return l.toolName(tool);
    final k = knowledge.byId(id);
    if (k != null) return k.name.resolve(lang);
    final entry = library.byId(id);
    if (entry != null) return entry.name.resolve(lang);
    final r = evidence.researchById(id);
    if (r != null) {
      return r.title.length > 60 ? '${r.title.substring(0, 57)}…' : r.title;
    }
    return null;
  }

  void openId(String id) {
    if (ToolsCatalog.byId(id) != null) {
      context.push(Routes.homeTool(id));
    } else if (knowledge.byId(id) != null) {
      context.push(Routes.knowledgeEntry(id));
    } else if (evidence.researchById(id) != null) {
      context.push(Routes.researchEntry(id));
    } else {
      context.push(Routes.homeSubstance(id));
    }
  }

  return [
    for (final id in ids)
      if (nameOf(id) case final n?) (n, () => openId(id)),
  ];
}
