import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dna/dna.dart';

/// «DNK» bo‘limi paketi (manbali, asli o‘zbekcha).
const dnaAsset = 'assets/content/dna/dna_v1.json';

final dnaLoaderProvider = Provider<Future<String> Function()>(
  (ref) =>
      () => rootBundle.loadString(dnaAsset),
);

final dnaProvider = FutureProvider<DnaBundle>((ref) async {
  try {
    final text = await ref.watch(dnaLoaderProvider)();
    return DnaBundle.fromJson(
      (jsonDecode(text) as Map).cast<String, Object?>(),
    );
  } on Object {
    // Paket yo‘q yoki buzilgan — bo‘lim ko‘rsatilmaydi (soxta kontent yo‘q).
    return DnaBundle.empty;
  }
});
