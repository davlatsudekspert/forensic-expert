import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/remote/fe_client_headers.dart';
import '../domain/ports/app_version_ports.dart';
import '../features/update/presentation/update_required_page.dart';
import 'app_info.dart';

/// «Majburiy yangilash» (kill-switch) holati.
@immutable
class UpdateGate {
  const UpdateGate({this.required = false, this.androidUrl, this.iosUrl});

  final bool required;
  final String? androidUrl;
  final String? iosUrl;
}

/// Server `app_version_info` xizmati. `null` — Supabase sozlanmagan, funksiya
/// butunlay o‘chiq (bootstrap faqat Supabase bo‘lganda ulaydi).
final appVersionServiceProvider = Provider<AppVersionService?>((ref) => null);

/// Do‘kon havolasini ochish (testlarda almashtiriladi).
typedef StoreLinkLauncher = Future<bool> Function(Uri uri);

final storeLinkLauncherProvider = Provider<StoreLinkLauncher>(
  (ref) =>
      (uri) async => launchUrl(uri, mode: LaunchMode.externalApplication),
);

/// Orqa fonddan qaytganda qayta tekshirish oralig‘i.
const updateRecheckInterval = Duration(minutes: 5);

/// Serverdan oxirgi ko‘rilgan `min_build` qurilmada saqlanadi: bir marta
/// bloklangan eski versiya internetsiz qayta ochilganda ham ochilmaydi.
/// Server min_build’ni pasaytirsa (onlayn tekshiruvda) — blok yechiladi.
abstract interface class UpdateGateStore {
  Future<int?> readMinBuild();
  Future<void> writeMinBuild(int minBuild);
}

class PrefsUpdateGateStore implements UpdateGateStore {
  const PrefsUpdateGateStore();

  static const key = 'fe.update.min_build_seen';

  @override
  Future<int?> readMinBuild() async {
    try {
      return (await SharedPreferences.getInstance()).getInt(key);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> writeMinBuild(int minBuild) async {
    try {
      await (await SharedPreferences.getInstance()).setInt(key, minBuild);
    } on Object {
      // Saqlab bo‘lmasa ham ilova ishlashda davom etadi.
    }
  }
}

/// Xotiradagi saqlagich (testlar va qurilmasiz muhit uchun).
class MemoryUpdateGateStore implements UpdateGateStore {
  MemoryUpdateGateStore([this.value]);

  int? value;

  @override
  Future<int?> readMinBuild() async => value;

  @override
  Future<void> writeMinBuild(int minBuild) async => value = minBuild;
}

final updateGateStoreProvider = Provider<UpdateGateStore>(
  (ref) => const PrefsUpdateGateStore(),
);

/// Vaqtni almashtirish (testlar uchun).
final updateGateClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final updateGateProvider = NotifierProvider<UpdateGateNotifier, UpdateGate>(
  UpdateGateNotifier.new,
);

class UpdateGateNotifier extends Notifier<UpdateGate> {
  DateTime? _lastCheck;
  bool _inFlight = false;

  @override
  UpdateGate build() {
    final signal = UpdateRequiredSignal.instance.required;
    void onSignal() {
      if (signal.value) {
        // Server 426 qaytardi: joriy build eskirgan — qurilmada eslab qolinadi.
        unawaited(
          ref.read(updateGateStoreProvider).writeMinBuild(AppInfo.build + 1),
        );
      }
      if (signal.value && !state.required) {
        state = UpdateGate(
          required: true,
          androidUrl: state.androidUrl,
          iosUrl: state.iosUrl,
        );
      }
    }

    signal.addListener(onSignal);
    ref.onDispose(() => signal.removeListener(onSignal));
    return UpdateGate(required: signal.value);
  }

  /// Fon rejimida tekshiradi; tarmoq/xato/timeout bloklamaydi. [force] false
  /// bo‘lsa, oxirgi tekshiruvdan [updateRecheckInterval] o‘tmaguncha o‘tkazib
  /// yuboriladi. Bloklangan holat ilova qayta ochilguncha saqlanadi.
  Future<void> check({bool force = false}) async {
    final service = ref.read(appVersionServiceProvider);
    if (service == null || _inFlight) return;
    final now = ref.read(updateGateClockProvider)();
    final last = _lastCheck;
    if (!force &&
        last != null &&
        now.difference(last) < updateRecheckInterval) {
      return;
    }
    _lastCheck = now;
    _inFlight = true;
    final store = ref.read(updateGateStoreProvider);
    try {
      // Avval qurilmadagi oxirgi ma’lum min_build (internetsiz ham ishlaydi).
      final seen = await store.readMinBuild();
      if (seen != null && seen > AppInfo.build && !state.required) {
        state = UpdateGate(
          required: true,
          androidUrl: state.androidUrl,
          iosUrl: state.iosUrl,
        );
      }
      final info = await service.fetch();
      if (info == null) return;
      await store.writeMinBuild(info.minBuild);
      if (!info.blocks(AppInfo.build) &&
          seen != null &&
          seen > AppInfo.build &&
          !UpdateRequiredSignal.instance.required.value) {
        // Server blokni bekor qildi (min_build pasaytirildi).
        state = UpdateGate(
          required: false,
          androidUrl: info.androidUrl,
          iosUrl: info.iosUrl,
        );
        return;
      }
      state = UpdateGate(
        required: state.required || info.blocks(AppInfo.build),
        androidUrl: info.androidUrl,
        iosUrl: info.iosUrl,
      );
    } on Object {
      // Hech qachon bloklamaymiz.
    } finally {
      _inFlight = false;
    }
  }
}

/// Play Market havolasi (`applicationId` — android/app/build.gradle bilan bir xil).
Uri defaultPlayStoreUri() => Uri.https(
  'play.google.com',
  '/store/apps/details',
  {'id': AppInfo.applicationId},
);

/// Joriy platforma uchun do‘kon havolasi; yo‘q bo‘lsa `null`.
/// Faqat `https` qabul qilinadi.
Uri? storeUriFor(UpdateGate gate, TargetPlatform platform) {
  Uri? https(String? s) {
    final u = s == null ? null : Uri.tryParse(s);
    return u != null && u.scheme == 'https' && u.host.isNotEmpty ? u : null;
  }

  return switch (platform) {
    TargetPlatform.android => https(gate.androidUrl) ?? defaultPlayStoreUri(),
    TargetPlatform.iOS => https(gate.iosUrl),
    _ => null,
  };
}

/// Ilova ildizida (router tepasida) turadi: ishga tushganda va orqa fondan
/// qaytganda fonda tekshiradi; yangilash kerak bo‘lsa, butun ilova o‘rniga
/// to‘siq sahifa ko‘rsatiladi (deep link ham aylanib o‘tolmaydi).
class UpdateGateHost extends ConsumerStatefulWidget {
  const UpdateGateHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UpdateGateHost> createState() => _UpdateGateHostState();
}

class _UpdateGateHostState extends ConsumerState<UpdateGateHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Birinchi kadrni kechiktirmaydi.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(ref.read(updateGateProvider.notifier).check());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(updateGateProvider.notifier).check());
    }
  }

  @override
  Widget build(BuildContext context) {
    final gate = ref.watch(updateGateProvider);
    if (!gate.required) return widget.child;
    final uri = storeUriFor(gate, defaultTargetPlatform);
    final launch = ref.read(storeLinkLauncherProvider);
    return Stack(
      children: [
        // Ilova holati saqlanadi, lekin ko‘rinmaydi/bosilmaydi/o‘qilmaydi.
        Offstage(child: TickerMode(enabled: false, child: widget.child)),
        Positioned.fill(
          child: UpdateRequiredPage(
            onUpdate: uri == null
                ? null
                : () async {
                    try {
                      await launch(uri);
                    } on Object {
                      // Ochilmasa — sahifa o‘z holicha qoladi.
                    }
                  },
          ),
        ),
      ],
    );
  }
}
