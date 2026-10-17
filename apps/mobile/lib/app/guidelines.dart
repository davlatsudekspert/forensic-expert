import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/guidelines/guideline_models.dart';

/// Ilovaga qo‘shilgan mustaqil yo‘riqnoma kartalari (ochiq kontent).
const guidelinesAsset = 'assets/content/guidelines/guidelines_v1.json';

final guidelineBundleLoaderProvider = Provider<Future<String> Function()>(
  (ref) =>
      () => rootBundle.loadString(guidelinesAsset),
);

final guidelinesProvider = FutureProvider<GuidelineBundle>((ref) async {
  try {
    final text = await ref.watch(guidelineBundleLoaderProvider)();
    return GuidelineBundle.fromJson(
      (jsonDecode(text) as Map).cast<String, Object?>(),
    );
  } on Object {
    // Buzilgan yoki yo‘q paket — bo‘sh bo‘lim (soxta kontent yo‘q).
    return GuidelineBundle.empty;
  }
});
