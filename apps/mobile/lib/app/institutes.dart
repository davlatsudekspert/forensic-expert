import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/admin/contract_pdf.dart';
import '../domain/admin/contract_text.dart';
import '../domain/admin/institute_models.dart';
import '../domain/ports/institute_ports.dart';

/// Admin: institutlar va sovg‘a promokodlari. Bootstrap’da Supabase bo‘lsa
/// almashtiriladi; aks holda ulanmagan (admin bo‘limi ko‘rinmaydi).
final adminInstituteServiceProvider = Provider<AdminInstituteService>(
  (ref) => const UnconfiguredAdminInstituteService(),
);

/// Litsenziar rekvizitlari saqlovi (bootstrap’da SharedPreferences).
final licensorProfileStoreProvider = Provider<LicensorProfileStore>(
  (ref) => InMemoryLicensorProfileStore(),
);

final licensorProfileProvider =
    NotifierProvider<LicensorProfileController, LicensorProfile>(
      LicensorProfileController.new,
    );

class LicensorProfileController extends Notifier<LicensorProfile> {
  @override
  LicensorProfile build() => ref.read(licensorProfileStoreProvider).load();

  Future<void> save(LicensorProfile p) async {
    await ref.read(licensorProfileStoreProvider).save(p);
    state = p;
  }
}

final adminInstitutesProvider =
    FutureProvider.autoDispose<List<InstituteSummary>?>((ref) async {
      final r = await ref.watch(adminInstituteServiceProvider).list();
      return r.value;
    });

/// Bitta institut: to‘liq ma’lumot + kodlar. Xato — `null`.
class InstituteBundle {
  const InstituteBundle(this.detail, this.codes);

  final InstituteDetail detail;
  final List<InstituteCode> codes;
}

final adminInstituteProvider = FutureProvider.autoDispose
    .family<InstituteBundle?, String>((ref, id) async {
      final svc = ref.watch(adminInstituteServiceProvider);
      final d = await svc.get(id);
      final c = await svc.codes(id);
      final detail = d.value;
      final codes = c.value;
      if (detail == null || codes == null) return null;
      return InstituteBundle(detail, codes);
    });

/// PDF fayl (ulashish uchun).
class PdfAttachment {
  const PdfAttachment(this.fileName, this.bytes);

  final String fileName;
  final Uint8List bytes;
}

/// PDF’ni tizimning ulashish oynasi orqali yuborish/saqlash ("Fayllarga
/// saqlash" ham shu yerda). Testlarda almashtiriladi.
abstract interface class ContractFileShare {
  Future<void> sharePdfs(List<PdfAttachment> files, {String? subject});
}

class NativeContractFileShare implements ContractFileShare {
  const NativeContractFileShare();

  @override
  Future<void> sharePdfs(List<PdfAttachment> files, {String? subject}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          for (final f in files)
            XFile.fromData(
              f.bytes,
              mimeType: 'application/pdf',
              name: f.fileName,
            ),
        ],
        fileNameOverrides: [for (final f in files) f.fileName],
        subject: subject,
      ),
    );
  }
}

final contractFileShareProvider = Provider<ContractFileShare>(
  (ref) => const NativeContractFileShare(),
);

/// Shartnoma va «Kodlar varag‘i» PDF’larini yaratadi (ilova shriftlari bilan).
class ContractPdfService {
  const ContractPdfService();

  Future<Uint8List> contract(
    InstituteDetail inst,
    LicensorProfile licensor,
  ) async => buildContractPdf(
    buildContractBlocks(ContractData(institute: inst, licensor: licensor)),
    regular: await rootBundle.load(_regular),
    bold: await rootBundle.load(_bold),
    title: _contractTitle,
  );

  Future<Uint8List> codesSheet(
    InstituteDetail inst,
    List<InstituteCode> codes,
  ) async => buildContractPdf(
    buildCodesSheetBlocks(inst, codes),
    regular: await rootBundle.load(_regular),
    bold: await rootBundle.load(_bold),
    title: _sheetTitle,
  );

  static const _contractTitle = 'Litsenziya shartnomasi';
  static const _sheetTitle = 'Kodlar varag‘i';
  static const _regular =
      'assets/fonts/source_serif_4/SourceSerif4-Regular.ttf';
  static const _bold = 'assets/fonts/source_serif_4/SourceSerif4-Bold.ttf';
}

final contractPdfServiceProvider = Provider<ContractPdfService>(
  (ref) => const ContractPdfService(),
);
