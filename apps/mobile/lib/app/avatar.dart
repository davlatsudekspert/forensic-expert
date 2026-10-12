import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Profil rasmi faqat qurilmada saqlanadi — serverga yuborilmaydi.
abstract class AvatarStorage {
  Future<Uint8List?> load();
  Future<void> save(Uint8List bytes);
  Future<void> clear();
}

class FileAvatarStorage implements AvatarStorage {
  const FileAvatarStorage();

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/profile_avatar.png');
  }

  @override
  Future<Uint8List?> load() async {
    try {
      final f = await _file();
      return await f.exists() ? await f.readAsBytes() : null;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(Uint8List bytes) async {
    final f = await _file();
    await f.writeAsBytes(bytes, flush: true);
  }

  @override
  Future<void> clear() async {
    try {
      final f = await _file();
      if (await f.exists()) await f.delete();
    } on Object {
      // fayl yo‘q yoki o‘chirib bo‘lmadi — rasm baribir ko‘rsatilmaydi.
    }
  }
}

final avatarStorageProvider = Provider<AvatarStorage>(
  (_) => const FileAvatarStorage(),
);

/// Galereyadan rasm tanlash (kamera ruxsati talab qilinmaydi).
abstract class AvatarPicker {
  Future<Uint8List?> pick();
}

class GalleryAvatarPicker implements AvatarPicker {
  const GalleryAvatarPicker();

  @override
  Future<Uint8List?> pick() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );
    return x?.readAsBytes();
  }
}

final avatarPickerProvider = Provider<AvatarPicker>(
  (_) => const GalleryAvatarPicker(),
);

class AvatarController extends AsyncNotifier<Uint8List?> {
  @override
  Future<Uint8List?> build() => ref.read(avatarStorageProvider).load();

  Future<void> set(Uint8List bytes) async {
    await ref.read(avatarStorageProvider).save(bytes);
    state = AsyncData(bytes);
  }

  Future<void> remove() async {
    await ref.read(avatarStorageProvider).clear();
    state = const AsyncData(null);
  }
}

final avatarProvider = AsyncNotifierProvider<AvatarController, Uint8List?>(
  AvatarController.new,
);
