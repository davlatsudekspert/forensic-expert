import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/knowledge/method_short_name.dart';

/// Qisqa usul nomi faqat to‘liq nomning o‘zidan olinadi (yangi fakt yo‘q).
void main() {
  test('boshidagi va oxiridagi qisqartma', () {
    expect(
      methodShortName('Gaz xromatografiyasi — mass-spektrometriya (GC-MS)'),
      'GC-MS',
    );
    expect(
      methodShortName(
        'LC-MS/MS (suyuqlik xromatografiyasi — tandem mass-spektrometriya)',
      ),
      'LC-MS/MS',
    );
    expect(
      methodShortName(
        'GC-FID (alanga-ionlanish detektorli gaz xromatografiyasi)',
      ),
      'GC-FID',
    );
    expect(methodShortName('Газовая хроматография (ГХ-МС)'), 'ГХ-МС');
    expect(
      methodShortName('UV-Vis spectrophotometry'),
      'UV-Vis spectrophotometry',
    );
  });

  test('qisqartma yo‘q — to‘liq nom o‘zgarmaydi', () {
    expect(
      methodShortName('Bug‘ fazali gaz xromatografiyasi'),
      'Bug‘ fazali gaz xromatografiyasi',
    );
    expect(
      methodShortName('Yupqa qatlamli xromatografiya (yupqa qatlam)'),
      'Yupqa qatlamli xromatografiya (yupqa qatlam)',
    );
    expect(methodShortName('Gaz (GC)'), 'GC');
  });
}
