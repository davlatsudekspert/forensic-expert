import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/user_data.dart';

/// Ko‘rinmas yordamchi: yozuv ochilganda uning ID’sini «yaqinda
/// ko‘rilganlar»ga yozadi. Faqat lokal (SharedPreferences); hech qayerga
/// yuborilmaydi va matn yoki holat ma’lumoti saqlanmaydi.
class ViewRecorder extends ConsumerStatefulWidget {
  const ViewRecorder({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ViewRecorder> createState() => _ViewRecorderState();
}

class _ViewRecorderState extends ConsumerState<ViewRecorder> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.read(userDataProvider.notifier).recordViewed(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
