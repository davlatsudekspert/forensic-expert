import 'package:file_selector/file_selector.dart';

import '../../domain/ports/professional_ports.dart';

/// Tizim fayl tanlagichi (Android SAF / iOS Document Picker). Ruxsat
/// so‘ralmaydi: foydalanuvchi faylni o‘zi tanlaydi.
class SystemCredentialFilePicker implements CredentialFilePicker {
  const SystemCredentialFilePicker();

  static const _group = XTypeGroup(
    label: 'PDF / JPG / PNG',
    extensions: ['pdf', 'jpg', 'jpeg', 'png'],
    mimeTypes: ['application/pdf', 'image/jpeg', 'image/png'],
    uniformTypeIdentifiers: ['com.adobe.pdf', 'public.jpeg', 'public.png'],
  );

  @override
  Future<PickedFile?> pick() async {
    final f = await openFile(acceptedTypeGroups: const [_group]);
    if (f == null) return null;
    return PickedFile(name: f.name, bytes: await f.readAsBytes());
  }
}
