import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/theme.dart';
import '../core/l10n/fe_localizations_delegate.dart';
import '../core/l10n/generated/app_localizations.dart';
import '../core/settings/app_settings.dart';
import '../core/settings/settings_controller.dart';
import '../domain/ports/backend_ports.dart';
import 'class_groups.dart';
import 'plan.dart';
import 'providers.dart';
import 'referral.dart';
import 'router.dart';
import 'routes.dart';
import 'update_gate.dart';

class ForensicExpertApp extends ConsumerWidget {
  const ForensicExpertApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      settingsControllerProvider.select((s) => s.locale),
    );
    final themeMode = ref.watch(
      settingsControllerProvider.select((s) => s.themeMode),
    );
    final contrast = ref.watch(
      settingsControllerProvider.select((s) => s.contrast),
    );
    final newUz = ref.watch(
      settingsControllerProvider.select((s) => s.newUzAlphabet),
    );
    final textScale = ref.watch(
      settingsControllerProvider.select((s) => s.textScale),
    );
    final router = ref.watch(routerProvider);
    // Taklif kodi kuzatuvchisi doim faol: foydalanuvchi kirgach kutilayotgan
    // kodni serverga bir marta yuboradi (qaror serverda).
    ref.listen(pendingReferralProvider, (_, _) {});
    // Do‘kon oqimi doim tinglanadi: kutilayotgan xaridlar ishga tushishda
    // keladi va serverda tekshiriladi.
    ref.listen(proFlowProvider, (_, _) {});
    // Huquq ilova ochilishidayoq yuklanadi va tirik turadi (qulf/ochiq holati
    // birinchi bosishda ham to‘g‘ri bo‘lishi uchun).
    ref.listen(entitlementsProvider, (_, _) {});
    // Guruh taklifi (QR): kirish oynasi boshqa sahifaga olib ketgan bo‘lsa
    // ham, kirgach qo‘shilish sahifasi qayta ochiladi (taklif yo‘qolmaydi).
    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (!next.signedIn || (prev?.signedIn ?? false)) return;
      final inv = ref.read(pendingGroupInviteProvider.notifier).takeAutoOpen();
      if (inv == null) return;
      final here = router.routerDelegate.currentConfiguration.uri.path;
      if (here == Routes.groupJoin) return;
      router.push<void>(
        Routes.groupJoinWith(inv.code, assignmentId: inv.assignmentId),
      );
    });

    // Kontrast: `system` — MaterialApp OS sozlamasiga ko‘ra highContrast
    // mavzusini o‘zi tanlaydi; `high`/`standard` — foydalanuvchi majburlaydi.
    final forceHigh = contrast == ContrastPreference.high;
    final forceStandard = contrast == ContrastPreference.standard;
    final light = forceHigh
        ? FeThemeBuilder.lightHighContrast()
        : FeThemeBuilder.light();
    final dark = forceHigh
        ? FeThemeBuilder.darkHighContrast()
        : FeThemeBuilder.dark();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: router,
      // Router tepasida: eski versiya bloklanganda deep link ham aylanib o‘tolmaydi.
      // Shrift o‘lchami: telefon sozlamasi × ilova sozlamasi (Profil).
      builder: (context, child) {
        final gate = UpdateGateHost(child: child ?? const SizedBox.shrink());
        if (textScale == 1.0) return gate;
        final mq = MediaQuery.of(context);
        final base = mq.textScaler.scale(1);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear((base * textScale).clamp(1.0, 2.6)),
          ),
          child: gate,
        );
      },
      locale: locale,
      supportedLocales: SupportedLanguages.locales,
      localizationsDelegates: FeLocalizationsDelegate.all(newUz: newUz),
      localeResolutionCallback: (device, supported) {
        if (device != null) {
          for (final s in supported) {
            if (s.languageCode == device.languageCode) return s;
          }
        }
        return supported.first;
      },
      theme: light,
      darkTheme: dark,
      highContrastTheme: forceStandard
          ? light
          : FeThemeBuilder.lightHighContrast(),
      highContrastDarkTheme: forceStandard
          ? dark
          : FeThemeBuilder.darkHighContrast(),
      themeMode: themeMode,
    );
  }
}
