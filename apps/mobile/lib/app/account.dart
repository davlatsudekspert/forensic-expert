import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin/admin_models.dart';
import '../domain/ports/account_ports.dart';
import 'app_info.dart';
import 'providers.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa almashtiriladi.
final accountServiceProvider = Provider<AccountService>(
  (ref) => const UnconfiguredAccountService(),
);

/// Kirgan foydalanuvchining server kirishi (grant + admin). Kirganda bir marta
/// qurilma ma’lumoti ham yuboriladi (platforma, versiya, til, hudud).
final serverAccessProvider = FutureProvider<ServerAccess>((ref) async {
  final auth = ref.watch(authStateProvider);
  final svc = ref.watch(accountServiceProvider);
  if (!auth.signedIn || !svc.isConfigured) return ServerAccess.none;
  final device = PlatformDispatcher.instance.locale;
  unawaited(
    svc.registerDevice(
      platform: kIsWeb
          ? 'other'
          : Platform.isIOS
          ? 'ios'
          : Platform.isAndroid
          ? 'android'
          : 'other',
      version: AppInfo.version,
      locale: device.languageCode,
      region: device.countryCode,
    ),
  );
  return await svc.myAccess() ?? ServerAccess.none;
});

/// Admin panel ma’lumotlari (faqat admin uchun serverdan).
final adminDashboardProvider = FutureProvider.autoDispose<AdminDashboard?>(
  (ref) => ref.watch(accountServiceProvider).dashboard(),
);
