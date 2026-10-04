import 'dart:convert';

import 'package:meta/meta.dart';

/// Kontent kanali. Production ilova faqat `production` paketni qabul qiladi.
enum PackChannel { production, development, test }

/// Ilmiy baza versiyasi — CalVer: `YYYY.MM` yoki `YYYY.MM.PATCH`.
@immutable
class PackVersion implements Comparable<PackVersion> {
  const PackVersion(this.year, this.month, [this.patch = 0]);

  factory PackVersion.parse(String s) {
    final m = RegExp(r'^(\d{4})\.(\d{2})(?:\.(\d+))?$').firstMatch(s);
    if (m == null) throw FormatException('Invalid pack version: $s');
    final month = int.parse(m[2]!);
    if (month < 1 || month > 12) throw FormatException('Invalid month: $s');
    return PackVersion(int.parse(m[1]!), month, int.parse(m[3] ?? '0'));
  }

  final int year;
  final int month;
  final int patch;

  @override
  int compareTo(PackVersion other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return patch.compareTo(other.patch);
  }

  bool operator >(PackVersion o) => compareTo(o) > 0;

  @override
  bool operator ==(Object other) =>
      other is PackVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(year, month, patch);

  @override
  String toString() =>
      '$year.${month.toString().padLeft(2, '0')}${patch > 0 ? '.$patch' : ''}';
}

/// Ilova versiyasi (SemVer, faqat major.minor.patch).
@immutable
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);

  factory AppVersion.parse(String s) {
    final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)').firstMatch(s);
    if (m == null) throw FormatException('Invalid app version: $s');
    return AppVersion(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  }

  final int major;
  final int minor;
  final int patch;

  @override
  int compareTo(AppVersion o) {
    if (major != o.major) return major.compareTo(o.major);
    if (minor != o.minor) return minor.compareTo(o.minor);
    return patch.compareTo(o.patch);
  }

  @override
  String toString() => '$major.$minor.$patch';
}

@immutable
class PackFile {
  const PackFile({
    required this.path,
    required this.sha256,
    required this.size,
  });

  final String path;

  /// Kichik harfli hex.
  final String sha256;
  final int size;

  Map<String, Object> toJson() => {
    'path': path,
    'sha256': sha256,
    'size': size,
  };
}

/// `manifest.json` (`docs/00_ARXITEKTURA_REJASI.md`, 24.1).
@immutable
class PackManifest {
  const PackManifest({
    required this.packVersion,
    required this.schemaVersion,
    required this.minAppVersion,
    required this.channel,
    required this.createdAt,
    required this.files,
    required this.keyId,
    this.baseVersion,
    this.critical = false,
  });

  factory PackManifest.fromJson(Map<String, Object?> j) {
    final files = (j['files']! as List<Object?>).cast<Map<String, Object?>>();
    return PackManifest(
      packVersion: PackVersion.parse(j['pack_version']! as String),
      schemaVersion: j['schema_version']! as int,
      minAppVersion: AppVersion.parse(j['min_app_version']! as String),
      channel: PackChannel.values.byName(j['channel']! as String),
      createdAt: DateTime.parse(j['created_at']! as String),
      baseVersion: j['base_version'] == null
          ? null
          : PackVersion.parse(j['base_version']! as String),
      critical: j['critical'] == true,
      keyId: j['key_id']! as String,
      files: [
        for (final f in files)
          PackFile(
            path: f['path']! as String,
            sha256: f['sha256']! as String,
            size: f['size']! as int,
          ),
      ],
    );
  }

  final PackVersion packVersion;
  final int schemaVersion;
  final AppVersion minAppVersion;
  final PackChannel channel;
  final DateTime createdAt;
  final PackVersion? baseVersion;
  final bool critical;
  final String keyId;
  final List<PackFile> files;

  Map<String, Object?> toJson() => {
    'pack_version': packVersion.toString(),
    'schema_version': schemaVersion,
    'min_app_version': minAppVersion.toString(),
    'channel': channel.name,
    'created_at': createdAt.toUtc().toIso8601String(),
    'base_version': baseVersion?.toString(),
    'critical': critical,
    'key_id': keyId,
    'files': [for (final f in files) f.toJson()],
  };

  /// Imzolanadigan aniq baytlar. Imzo **fayldagi baytlar** ustidan
  /// tekshiriladi (qayta seriyalashtirilgan JSON emas) — shuning uchun
  /// verifier `manifestBytes`ni to‘g‘ridan-to‘g‘ri oladi.
  List<int> encode() =>
      utf8.encode(const JsonEncoder.withIndent('  ').convert(toJson()));
}
