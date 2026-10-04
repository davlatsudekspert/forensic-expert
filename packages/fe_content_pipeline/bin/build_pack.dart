// Kontent paketini yig‘ish:
//   dart run fe_content_pipeline:build_pack \
//     --input content/pilot/bundle.json --out build/content_pack \
//     [--previous <oldingi bundle.json>]
//
// Production kanal uchun maxfiy kalit faqat muhit o‘zgaruvchisidan
// (FE_PACK_SIGNING_SEED_B64, CI secret) olinadi; repozitoriyda kalit yo‘q.
import 'dart:convert';
import 'dart:io';

import 'package:fe_content_pipeline/fe_content_pipeline.dart';
import 'package:fe_content_schema/fe_content_schema.dart';

Future<void> main(List<String> args) async {
  String? arg(String name) {
    final i = args.indexOf(name);
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  final input = arg('--input') ?? 'content/pilot/bundle.json';
  final out = arg('--out') ?? 'build/content_pack';
  final channelArg = arg('--channel');
  // Oldingi chiqarilgan bundle (FE027 review regressiya himoyasi uchun).
  final previousArg = arg('--previous');

  var bundle = BundleCodec.decode(File(input).readAsStringSync());
  if (channelArg != null) {
    bundle = bundle.withChannel(BundleChannel.values.byName(channelArg));
  }
  final seedB64 = Platform.environment['FE_PACK_SIGNING_SEED_B64'];
  try {
    final pack = await const PackBuilder().build(
      bundle: bundle,
      outDir: Directory(out),
      builtAt: DateTime.now().toUtc(),
      signingSeed: seedB64 == null ? null : base64Decode(seedB64),
      previous: previousArg == null
          ? null
          : BundleCodec.decode(File(previousArg).readAsStringSync()).content,
    );
    stdout.writeln(
      'OK ${pack.manifest.packVersion} channel=${pack.manifest.channel.name} '
      'key=${pack.keyId} warnings=${pack.report.issues.length} → $out',
    );
  } on PipelineValidationError catch (e) {
    stderr.writeln(e);
    final codes = <String, int>{};
    for (final i in e.report.errors) {
      codes[i.code] = (codes[i.code] ?? 0) + 1;
    }
    stderr.writeln('Summary: $codes');
    exitCode = 2;
  }
}
