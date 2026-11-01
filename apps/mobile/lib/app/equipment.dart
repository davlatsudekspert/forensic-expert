import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/equipment/equipment.dart';

/// «Asbob-uskunalar» paketi (manbali, asli o‘zbekcha).
const equipmentAsset = 'assets/content/equipment/equipment_v1.json';

final equipmentLoaderProvider = Provider<Future<String> Function()>(
  (ref) =>
      () => rootBundle.loadString(equipmentAsset),
);

final equipmentProvider = FutureProvider<EquipmentBundle>((ref) async {
  try {
    final text = await ref.watch(equipmentLoaderProvider)();
    return EquipmentBundle.fromJson(
      (jsonDecode(text) as Map).cast<String, Object?>(),
    );
  } on Object {
    // Buzilgan yoki yo‘q paket — bo‘sh bo‘lim (soxta kontent yo‘q).
    return EquipmentBundle.empty;
  }
});
