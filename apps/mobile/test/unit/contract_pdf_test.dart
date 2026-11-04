// Shartnoma PDF: matn tasdiqlangan shablonga aynan mos, faqat institut
// ma’lumotlari to‘ldiriladi; litsenziar rekvizitlari kodda yo‘q; PDF bo‘sh emas.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/admin/contract_pdf.dart';
import 'package:forensic_expert/domain/admin/contract_text.dart';
import 'package:forensic_expert/domain/admin/institute_models.dart';

const _regular = 'assets/fonts/source_serif_4/SourceSerif4-Regular.ttf';
const _bold = 'assets/fonts/source_serif_4/SourceSerif4-Bold.ttf';

final _inst = InstituteDetail(
  id: 'i1',
  name: 'Andijon davlat tibbiyot instituti',
  address: 'Andijon sh., Atabekov ko‘chasi 1',
  stir: '201234567',
  bank: 'Test Bank',
  account: '20208000900000000001',
  mfo: '00014',
  director: 'Valiyev Ali Karimovich',
  phone: '+998 90 123 45 67',
  contractNo: '17/2026',
  contractDate: DateTime(2026, 11, 4),
  seats: 3,
  months: 12,
  pricePerSeat: 25000,
  termStart: DateTime(2026, 11, 10),
  termEnd: DateTime(2027, 11, 10),
);

String _all(List<ContractBlock> blocks) => blocks
    .expand((b) => [b.text, b.text2, for (final r in b.rows) ...r])
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('shartnoma matni', () {
    final blank = buildContractBlocks(
      const ContractData(
        institute: InstituteDetail(id: 'x', name: ''),
      ),
    );

    test('1–10 bandlar to‘liq; [qavs] va bo‘sh chiziqlar qoladi', () {
      final text = _all(blank);
      for (final n in [
        '1.1.',
        '1.7.',
        '2.4.',
        '3.3.',
        '4.6.',
        '5.2.',
        '6.7.',
        '7.3.',
        '8.5.',
        '9.1.',
        '10.2.',
      ]) {
        expect(text, contains('\n$n '), reason: n);
      }
      expect(text, contains('11. TOMONLARNING REKVIZITLARI VA IMZOLARI'));
      expect(text, contains('Abduraxmonov Yo‘ldashali Toshtemirovich'));
      expect(text, contains('[ro‘yxat to‘ldiriladi]'));
      expect(text, contains('[kelishiladi]'));
      expect(text, contains('_' * 16));
      expect(text, contains('1-ILOVA'));
    });

    test('institut ma’lumoti to‘ldiriladi', () {
      final text = _all(buildContractBlocks(ContractData(institute: _inst)));
      for (final v in [
        'LITSENZIYA SHARTNOMASI № 17/2026',
        '«4» noyabr 2026-yil',
        'nomi: Andijon davlat tibbiyot instituti',
        'rahbari Valiyev Ali Karimovich (F.I.O.)',
        'O‘rinlar soni: 3 ta.',
        'kodlar topshirilgan sanadan boshlab 12 oy [yoki',
        'Litsenziya narxi 900 000 (so‘z bilan:',
        'narxi (25 000 so‘m/oy) × o‘rinlar soni (3) × oylar soni (12)',
        'STIR: 201234567',
        'Hisob raqam: 20208000900000000001',
        'MFO: 00014',
        'Tel.: +998 90 123 45 67',
        'Rahbar F.I.O.: Valiyev Ali Karimovich',
        'boshlanishi: «10» noyabr 2026-yil; tugashi: «10» noyabr 2027-yil',
      ]) {
        expect(text, contains(v), reason: v);
      }
    });

    test('1-ilova jadvalida faqat tartib raqami (3 qator + sarlavha)', () {
      final blocks = buildContractBlocks(ContractData(institute: _inst));
      final table = blocks.lastWhere((b) => b.kind == ContractBlockKind.table);
      expect(table.rows.length, 1 + 3);
      expect(table.rows[1].first, '1');
      expect(table.rows.last[1], '3');
    });

    test(
      'litsenziar rekvizitlari: bo‘sh bo‘lsa chiziq, kiritilsa qo‘yiladi',
      () {
        final empty = _all(buildContractBlocks(ContractData(institute: _inst)));
        expect(
          empty,
          contains('Manzil: ____________________\nTel.: ____________________'),
        );
        expect(empty, contains('JShShIR: ____________________'));
        expect(
          empty,
          contains('Shaxsni tasdiqlovchi hujjat: ____________________'),
        );

        final filled = _all(
          buildContractBlocks(
            ContractData(
              institute: _inst,
              licensor: const LicensorProfile(
                address: 'TEST-MANZIL',
                phone: 'TEST-TEL',
                bank: 'TEST-BANK',
                mfo: 'TEST-MFO',
                account: 'TEST-HISOB',
                transitAccount: 'TEST-TRANZIT',
              ),
            ),
          ),
        );
        for (final v in [
          'Manzil: TEST-MANZIL',
          'Tel.: TEST-TEL',
          'Bank: TEST-BANK, MFO TEST-MFO',
          'Qabul qiluvchi hisobi: TEST-HISOB',
          'tranzit hisobi: TEST-TRANZIT',
        ]) {
          expect(filled, contains(v), reason: v);
        }
        // JShShIR va hujjat har doim bo‘sh maydon.
        expect(filled, contains('JShShIR: ____________________'));
        expect(
          filled,
          contains('Shaxsni tasdiqlovchi hujjat: ____________________'),
        );
      },
    );

    test('kodlar shartnomada yo‘q; «Kodlar varag‘i»da bor', () {
      const codes = [
        InstituteCode(n: 1, code: 'ZXCV123456', revoked: false),
        InstituteCode(n: 2, code: 'QWER654321', revoked: false),
      ];
      final contract = _all(
        buildContractBlocks(ContractData(institute: _inst)),
      );
      expect(contract, isNot(contains('ZXCV123456')));
      final sheet = _all(buildCodesSheetBlocks(_inst, codes));
      expect(sheet, contains('ZXCV123456'));
      expect(sheet, contains('QWER654321'));
      expect(sheet, contains('Faqat vakilga yopiq kanal orqali yuboriladi'));
    });

    test('repo kodida litsenziar rekvizitlari yo‘q', () {
      // Shartnoma shabloniga bank/hisob/telefon/manzil yozilmagan.
      final src = File('lib/domain/admin/contract_text.dart')
          .readAsStringSync();
      for (final secret in [
        'Kapitalbank',
        '01158',
        '22618',
        '23120',
        '99 011',
        'Navoi',
      ]) {
        expect(src.contains(secret), isFalse, reason: secret);
      }
    });
  });

  group('PDF', () {
    test('shartnoma PDF bo‘sh emas va %PDF bilan boshlanadi', () async {
      final bytes = await buildContractPdf(
        buildContractBlocks(ContractData(institute: _inst)),
        regular: await rootBundle.load(_regular),
        bold: await rootBundle.load(_bold),
      );
      expect(bytes.length, greaterThan(5000));
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('kodlar varag‘i PDF', () async {
      final bytes = await buildContractPdf(
        buildCodesSheetBlocks(_inst, [
          for (var i = 1; i <= 40; i++)
            InstituteCode(
              n: i,
              code: 'CODE${i.toString().padLeft(6, '0')}',
              revoked: false,
            ),
        ]),
        regular: await rootBundle.load(_regular),
        bold: await rootBundle.load(_bold),
      );
      expect(bytes.length, greaterThan(1500));
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('shartnoma matnidagi barcha belgilar shriftda bor', () async {
      final text =
          _all(buildContractBlocks(ContractData(institute: _inst))) +
          _all(buildCodesSheetBlocks(_inst, const []));
      for (final path in [_regular, _bold]) {
        final missing = missingGlyphs(text, await rootBundle.load(path));
        expect(
          missing.map(String.fromCharCode).toList(),
          isEmpty,
          reason: path,
        );
      }
    });
  });
}
