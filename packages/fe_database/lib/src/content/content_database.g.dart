// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_database.dart';

// ignore_for_file: type=lint
class ContentMeta extends Table with TableInfo<ContentMeta, ContentMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ContentMeta(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _metaKeyMeta = const VerificationMeta(
    'metaKey',
  );
  late final GeneratedColumn<String> metaKey = GeneratedColumn<String>(
    'meta_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _metaValueMeta = const VerificationMeta(
    'metaValue',
  );
  late final GeneratedColumn<String> metaValue = GeneratedColumn<String>(
    'meta_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [metaKey, metaValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('meta_key')) {
      context.handle(
        _metaKeyMeta,
        metaKey.isAcceptableOrUnknown(data['meta_key']!, _metaKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_metaKeyMeta);
    }
    if (data.containsKey('meta_value')) {
      context.handle(
        _metaValueMeta,
        metaValue.isAcceptableOrUnknown(data['meta_value']!, _metaValueMeta),
      );
    } else if (isInserting) {
      context.missing(_metaValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {metaKey};
  @override
  ContentMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentMetaData(
      metaKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_key'],
      )!,
      metaValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_value'],
      )!,
    );
  }

  @override
  ContentMeta createAlias(String alias) {
    return ContentMeta(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get dontWriteConstraints => true;
}

class ContentMetaData extends DataClass implements Insertable<ContentMetaData> {
  final String metaKey;
  final String metaValue;
  const ContentMetaData({required this.metaKey, required this.metaValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meta_key'] = Variable<String>(metaKey);
    map['meta_value'] = Variable<String>(metaValue);
    return map;
  }

  ContentMetaCompanion toCompanion(bool nullToAbsent) {
    return ContentMetaCompanion(
      metaKey: Value(metaKey),
      metaValue: Value(metaValue),
    );
  }

  factory ContentMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentMetaData(
      metaKey: serializer.fromJson<String>(json['meta_key']),
      metaValue: serializer.fromJson<String>(json['meta_value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'meta_key': serializer.toJson<String>(metaKey),
      'meta_value': serializer.toJson<String>(metaValue),
    };
  }

  ContentMetaData copyWith({String? metaKey, String? metaValue}) =>
      ContentMetaData(
        metaKey: metaKey ?? this.metaKey,
        metaValue: metaValue ?? this.metaValue,
      );
  ContentMetaData copyWithCompanion(ContentMetaCompanion data) {
    return ContentMetaData(
      metaKey: data.metaKey.present ? data.metaKey.value : this.metaKey,
      metaValue: data.metaValue.present ? data.metaValue.value : this.metaValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentMetaData(')
          ..write('metaKey: $metaKey, ')
          ..write('metaValue: $metaValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(metaKey, metaValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentMetaData &&
          other.metaKey == this.metaKey &&
          other.metaValue == this.metaValue);
}

class ContentMetaCompanion extends UpdateCompanion<ContentMetaData> {
  final Value<String> metaKey;
  final Value<String> metaValue;
  const ContentMetaCompanion({
    this.metaKey = const Value.absent(),
    this.metaValue = const Value.absent(),
  });
  ContentMetaCompanion.insert({
    required String metaKey,
    required String metaValue,
  }) : metaKey = Value(metaKey),
       metaValue = Value(metaValue);
  static Insertable<ContentMetaData> custom({
    Expression<String>? metaKey,
    Expression<String>? metaValue,
  }) {
    return RawValuesInsertable({
      if (metaKey != null) 'meta_key': metaKey,
      if (metaValue != null) 'meta_value': metaValue,
    });
  }

  ContentMetaCompanion copyWith({
    Value<String>? metaKey,
    Value<String>? metaValue,
  }) {
    return ContentMetaCompanion(
      metaKey: metaKey ?? this.metaKey,
      metaValue: metaValue ?? this.metaValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (metaKey.present) {
      map['meta_key'] = Variable<String>(metaKey.value);
    }
    if (metaValue.present) {
      map['meta_value'] = Variable<String>(metaValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentMetaCompanion(')
          ..write('metaKey: $metaKey, ')
          ..write('metaValue: $metaValue')
          ..write(')'))
        .toString();
  }
}

class Sources extends Table with TableInfo<Sources, Source> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Sources(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _authorsJsonMeta = const VerificationMeta(
    'authorsJson',
  );
  late final GeneratedColumn<String> authorsJson = GeneratedColumn<String>(
    'authors_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'[]\'',
    defaultValue: const CustomExpression('\'[]\''),
  );
  static const VerificationMeta _organizationMeta = const VerificationMeta(
    'organization',
  );
  late final GeneratedColumn<String> organization = GeneratedColumn<String>(
    'organization',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _journalMeta = const VerificationMeta(
    'journal',
  );
  late final GeneratedColumn<String> journal = GeneratedColumn<String>(
    'journal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _publicationYearMeta = const VerificationMeta(
    'publicationYear',
  );
  late final GeneratedColumn<int> publicationYear = GeneratedColumn<int>(
    'publication_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _editionMeta = const VerificationMeta(
    'edition',
  );
  late final GeneratedColumn<String> edition = GeneratedColumn<String>(
    'edition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _doiMeta = const VerificationMeta('doi');
  late final GeneratedColumn<String> doi = GeneratedColumn<String>(
    'doi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _pmidMeta = const VerificationMeta('pmid');
  late final GeneratedColumn<String> pmid = GeneratedColumn<String>(
    'pmid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _officialUrlMeta = const VerificationMeta(
    'officialUrl',
  );
  late final GeneratedColumn<String> officialUrl = GeneratedColumn<String>(
    'official_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _accessedDateMeta = const VerificationMeta(
    'accessedDate',
  );
  late final GeneratedColumn<String> accessedDate = GeneratedColumn<String>(
    'accessed_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  late final GeneratedColumn<int> tier = GeneratedColumn<int>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (tier IN (1, 2, 3))',
  );
  static const VerificationMeta _evidenceLevelMeta = const VerificationMeta(
    'evidenceLevel',
  );
  late final GeneratedColumn<String> evidenceLevel = GeneratedColumn<String>(
    'evidence_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (evidence_level IN (\'A\', \'B\', \'C\', \'D\', \'E\'))',
  );
  static const VerificationMeta _licenseModeMeta = const VerificationMeta(
    'licenseMode',
  );
  late final GeneratedColumn<String> licenseMode = GeneratedColumn<String>(
    'license_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _licenseAgreementIdMeta =
      const VerificationMeta('licenseAgreementId');
  late final GeneratedColumn<String> licenseAgreementId =
      GeneratedColumn<String>(
        'license_agreement_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _identifierVerifiedMeta =
      const VerificationMeta('identifierVerified');
  late final GeneratedColumn<int> identifierVerified = GeneratedColumn<int>(
    'identifier_verified',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  late final GeneratedColumn<String> lastReviewedAt = GeneratedColumn<String>(
    'last_reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _isTestDataMeta = const VerificationMeta(
    'isTestData',
  );
  late final GeneratedColumn<int> isTestData = GeneratedColumn<int>(
    'is_test_data',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    sourceType,
    title,
    authorsJson,
    organization,
    journal,
    publicationYear,
    edition,
    doi,
    pmid,
    officialUrl,
    accessedDate,
    tier,
    evidenceLevel,
    licenseMode,
    licenseAgreementId,
    identifierVerified,
    reviewStatus,
    lastReviewedAt,
    version,
    isTestData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<Source> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('authors_json')) {
      context.handle(
        _authorsJsonMeta,
        authorsJson.isAcceptableOrUnknown(
          data['authors_json']!,
          _authorsJsonMeta,
        ),
      );
    }
    if (data.containsKey('organization')) {
      context.handle(
        _organizationMeta,
        organization.isAcceptableOrUnknown(
          data['organization']!,
          _organizationMeta,
        ),
      );
    }
    if (data.containsKey('journal')) {
      context.handle(
        _journalMeta,
        journal.isAcceptableOrUnknown(data['journal']!, _journalMeta),
      );
    }
    if (data.containsKey('publication_year')) {
      context.handle(
        _publicationYearMeta,
        publicationYear.isAcceptableOrUnknown(
          data['publication_year']!,
          _publicationYearMeta,
        ),
      );
    }
    if (data.containsKey('edition')) {
      context.handle(
        _editionMeta,
        edition.isAcceptableOrUnknown(data['edition']!, _editionMeta),
      );
    }
    if (data.containsKey('doi')) {
      context.handle(
        _doiMeta,
        doi.isAcceptableOrUnknown(data['doi']!, _doiMeta),
      );
    }
    if (data.containsKey('pmid')) {
      context.handle(
        _pmidMeta,
        pmid.isAcceptableOrUnknown(data['pmid']!, _pmidMeta),
      );
    }
    if (data.containsKey('official_url')) {
      context.handle(
        _officialUrlMeta,
        officialUrl.isAcceptableOrUnknown(
          data['official_url']!,
          _officialUrlMeta,
        ),
      );
    }
    if (data.containsKey('accessed_date')) {
      context.handle(
        _accessedDateMeta,
        accessedDate.isAcceptableOrUnknown(
          data['accessed_date']!,
          _accessedDateMeta,
        ),
      );
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('evidence_level')) {
      context.handle(
        _evidenceLevelMeta,
        evidenceLevel.isAcceptableOrUnknown(
          data['evidence_level']!,
          _evidenceLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_evidenceLevelMeta);
    }
    if (data.containsKey('license_mode')) {
      context.handle(
        _licenseModeMeta,
        licenseMode.isAcceptableOrUnknown(
          data['license_mode']!,
          _licenseModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_licenseModeMeta);
    }
    if (data.containsKey('license_agreement_id')) {
      context.handle(
        _licenseAgreementIdMeta,
        licenseAgreementId.isAcceptableOrUnknown(
          data['license_agreement_id']!,
          _licenseAgreementIdMeta,
        ),
      );
    }
    if (data.containsKey('identifier_verified')) {
      context.handle(
        _identifierVerifiedMeta,
        identifierVerified.isAcceptableOrUnknown(
          data['identifier_verified']!,
          _identifierVerifiedMeta,
        ),
      );
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewStatusMeta);
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_test_data')) {
      context.handle(
        _isTestDataMeta,
        isTestData.isAcceptableOrUnknown(
          data['is_test_data']!,
          _isTestDataMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId};
  @override
  Source map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Source(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      authorsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authors_json'],
      )!,
      organization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization'],
      ),
      journal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal'],
      ),
      publicationYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publication_year'],
      ),
      edition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edition'],
      ),
      doi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doi'],
      ),
      pmid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pmid'],
      ),
      officialUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}official_url'],
      ),
      accessedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accessed_date'],
      ),
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tier'],
      )!,
      evidenceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_level'],
      )!,
      licenseMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_mode'],
      )!,
      licenseAgreementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_agreement_id'],
      ),
      identifierVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}identifier_verified'],
      )!,
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isTestData: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_test_data'],
      )!,
    );
  }

  @override
  Sources createAlias(String alias) {
    return Sources(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get dontWriteConstraints => true;
}

class Source extends DataClass implements Insertable<Source> {
  final String sourceId;
  final String sourceType;
  final String title;
  final String authorsJson;
  final String? organization;
  final String? journal;
  final int? publicationYear;
  final String? edition;
  final String? doi;
  final String? pmid;
  final String? officialUrl;
  final String? accessedDate;
  final int tier;
  final String evidenceLevel;
  final String licenseMode;
  final String? licenseAgreementId;
  final int identifierVerified;
  final String reviewStatus;
  final String? lastReviewedAt;
  final int version;
  final int isTestData;
  const Source({
    required this.sourceId,
    required this.sourceType,
    required this.title,
    required this.authorsJson,
    this.organization,
    this.journal,
    this.publicationYear,
    this.edition,
    this.doi,
    this.pmid,
    this.officialUrl,
    this.accessedDate,
    required this.tier,
    required this.evidenceLevel,
    required this.licenseMode,
    this.licenseAgreementId,
    required this.identifierVerified,
    required this.reviewStatus,
    this.lastReviewedAt,
    required this.version,
    required this.isTestData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['source_type'] = Variable<String>(sourceType);
    map['title'] = Variable<String>(title);
    map['authors_json'] = Variable<String>(authorsJson);
    if (!nullToAbsent || organization != null) {
      map['organization'] = Variable<String>(organization);
    }
    if (!nullToAbsent || journal != null) {
      map['journal'] = Variable<String>(journal);
    }
    if (!nullToAbsent || publicationYear != null) {
      map['publication_year'] = Variable<int>(publicationYear);
    }
    if (!nullToAbsent || edition != null) {
      map['edition'] = Variable<String>(edition);
    }
    if (!nullToAbsent || doi != null) {
      map['doi'] = Variable<String>(doi);
    }
    if (!nullToAbsent || pmid != null) {
      map['pmid'] = Variable<String>(pmid);
    }
    if (!nullToAbsent || officialUrl != null) {
      map['official_url'] = Variable<String>(officialUrl);
    }
    if (!nullToAbsent || accessedDate != null) {
      map['accessed_date'] = Variable<String>(accessedDate);
    }
    map['tier'] = Variable<int>(tier);
    map['evidence_level'] = Variable<String>(evidenceLevel);
    map['license_mode'] = Variable<String>(licenseMode);
    if (!nullToAbsent || licenseAgreementId != null) {
      map['license_agreement_id'] = Variable<String>(licenseAgreementId);
    }
    map['identifier_verified'] = Variable<int>(identifierVerified);
    map['review_status'] = Variable<String>(reviewStatus);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<String>(lastReviewedAt);
    }
    map['version'] = Variable<int>(version);
    map['is_test_data'] = Variable<int>(isTestData);
    return map;
  }

  SourcesCompanion toCompanion(bool nullToAbsent) {
    return SourcesCompanion(
      sourceId: Value(sourceId),
      sourceType: Value(sourceType),
      title: Value(title),
      authorsJson: Value(authorsJson),
      organization: organization == null && nullToAbsent
          ? const Value.absent()
          : Value(organization),
      journal: journal == null && nullToAbsent
          ? const Value.absent()
          : Value(journal),
      publicationYear: publicationYear == null && nullToAbsent
          ? const Value.absent()
          : Value(publicationYear),
      edition: edition == null && nullToAbsent
          ? const Value.absent()
          : Value(edition),
      doi: doi == null && nullToAbsent ? const Value.absent() : Value(doi),
      pmid: pmid == null && nullToAbsent ? const Value.absent() : Value(pmid),
      officialUrl: officialUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(officialUrl),
      accessedDate: accessedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(accessedDate),
      tier: Value(tier),
      evidenceLevel: Value(evidenceLevel),
      licenseMode: Value(licenseMode),
      licenseAgreementId: licenseAgreementId == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseAgreementId),
      identifierVerified: Value(identifierVerified),
      reviewStatus: Value(reviewStatus),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      version: Value(version),
      isTestData: Value(isTestData),
    );
  }

  factory Source.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Source(
      sourceId: serializer.fromJson<String>(json['source_id']),
      sourceType: serializer.fromJson<String>(json['source_type']),
      title: serializer.fromJson<String>(json['title']),
      authorsJson: serializer.fromJson<String>(json['authors_json']),
      organization: serializer.fromJson<String?>(json['organization']),
      journal: serializer.fromJson<String?>(json['journal']),
      publicationYear: serializer.fromJson<int?>(json['publication_year']),
      edition: serializer.fromJson<String?>(json['edition']),
      doi: serializer.fromJson<String?>(json['doi']),
      pmid: serializer.fromJson<String?>(json['pmid']),
      officialUrl: serializer.fromJson<String?>(json['official_url']),
      accessedDate: serializer.fromJson<String?>(json['accessed_date']),
      tier: serializer.fromJson<int>(json['tier']),
      evidenceLevel: serializer.fromJson<String>(json['evidence_level']),
      licenseMode: serializer.fromJson<String>(json['license_mode']),
      licenseAgreementId: serializer.fromJson<String?>(
        json['license_agreement_id'],
      ),
      identifierVerified: serializer.fromJson<int>(json['identifier_verified']),
      reviewStatus: serializer.fromJson<String>(json['review_status']),
      lastReviewedAt: serializer.fromJson<String?>(json['last_reviewed_at']),
      version: serializer.fromJson<int>(json['version']),
      isTestData: serializer.fromJson<int>(json['is_test_data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source_id': serializer.toJson<String>(sourceId),
      'source_type': serializer.toJson<String>(sourceType),
      'title': serializer.toJson<String>(title),
      'authors_json': serializer.toJson<String>(authorsJson),
      'organization': serializer.toJson<String?>(organization),
      'journal': serializer.toJson<String?>(journal),
      'publication_year': serializer.toJson<int?>(publicationYear),
      'edition': serializer.toJson<String?>(edition),
      'doi': serializer.toJson<String?>(doi),
      'pmid': serializer.toJson<String?>(pmid),
      'official_url': serializer.toJson<String?>(officialUrl),
      'accessed_date': serializer.toJson<String?>(accessedDate),
      'tier': serializer.toJson<int>(tier),
      'evidence_level': serializer.toJson<String>(evidenceLevel),
      'license_mode': serializer.toJson<String>(licenseMode),
      'license_agreement_id': serializer.toJson<String?>(licenseAgreementId),
      'identifier_verified': serializer.toJson<int>(identifierVerified),
      'review_status': serializer.toJson<String>(reviewStatus),
      'last_reviewed_at': serializer.toJson<String?>(lastReviewedAt),
      'version': serializer.toJson<int>(version),
      'is_test_data': serializer.toJson<int>(isTestData),
    };
  }

  Source copyWith({
    String? sourceId,
    String? sourceType,
    String? title,
    String? authorsJson,
    Value<String?> organization = const Value.absent(),
    Value<String?> journal = const Value.absent(),
    Value<int?> publicationYear = const Value.absent(),
    Value<String?> edition = const Value.absent(),
    Value<String?> doi = const Value.absent(),
    Value<String?> pmid = const Value.absent(),
    Value<String?> officialUrl = const Value.absent(),
    Value<String?> accessedDate = const Value.absent(),
    int? tier,
    String? evidenceLevel,
    String? licenseMode,
    Value<String?> licenseAgreementId = const Value.absent(),
    int? identifierVerified,
    String? reviewStatus,
    Value<String?> lastReviewedAt = const Value.absent(),
    int? version,
    int? isTestData,
  }) => Source(
    sourceId: sourceId ?? this.sourceId,
    sourceType: sourceType ?? this.sourceType,
    title: title ?? this.title,
    authorsJson: authorsJson ?? this.authorsJson,
    organization: organization.present ? organization.value : this.organization,
    journal: journal.present ? journal.value : this.journal,
    publicationYear: publicationYear.present
        ? publicationYear.value
        : this.publicationYear,
    edition: edition.present ? edition.value : this.edition,
    doi: doi.present ? doi.value : this.doi,
    pmid: pmid.present ? pmid.value : this.pmid,
    officialUrl: officialUrl.present ? officialUrl.value : this.officialUrl,
    accessedDate: accessedDate.present ? accessedDate.value : this.accessedDate,
    tier: tier ?? this.tier,
    evidenceLevel: evidenceLevel ?? this.evidenceLevel,
    licenseMode: licenseMode ?? this.licenseMode,
    licenseAgreementId: licenseAgreementId.present
        ? licenseAgreementId.value
        : this.licenseAgreementId,
    identifierVerified: identifierVerified ?? this.identifierVerified,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    version: version ?? this.version,
    isTestData: isTestData ?? this.isTestData,
  );
  Source copyWithCompanion(SourcesCompanion data) {
    return Source(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      title: data.title.present ? data.title.value : this.title,
      authorsJson: data.authorsJson.present
          ? data.authorsJson.value
          : this.authorsJson,
      organization: data.organization.present
          ? data.organization.value
          : this.organization,
      journal: data.journal.present ? data.journal.value : this.journal,
      publicationYear: data.publicationYear.present
          ? data.publicationYear.value
          : this.publicationYear,
      edition: data.edition.present ? data.edition.value : this.edition,
      doi: data.doi.present ? data.doi.value : this.doi,
      pmid: data.pmid.present ? data.pmid.value : this.pmid,
      officialUrl: data.officialUrl.present
          ? data.officialUrl.value
          : this.officialUrl,
      accessedDate: data.accessedDate.present
          ? data.accessedDate.value
          : this.accessedDate,
      tier: data.tier.present ? data.tier.value : this.tier,
      evidenceLevel: data.evidenceLevel.present
          ? data.evidenceLevel.value
          : this.evidenceLevel,
      licenseMode: data.licenseMode.present
          ? data.licenseMode.value
          : this.licenseMode,
      licenseAgreementId: data.licenseAgreementId.present
          ? data.licenseAgreementId.value
          : this.licenseAgreementId,
      identifierVerified: data.identifierVerified.present
          ? data.identifierVerified.value
          : this.identifierVerified,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      version: data.version.present ? data.version.value : this.version,
      isTestData: data.isTestData.present
          ? data.isTestData.value
          : this.isTestData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Source(')
          ..write('sourceId: $sourceId, ')
          ..write('sourceType: $sourceType, ')
          ..write('title: $title, ')
          ..write('authorsJson: $authorsJson, ')
          ..write('organization: $organization, ')
          ..write('journal: $journal, ')
          ..write('publicationYear: $publicationYear, ')
          ..write('edition: $edition, ')
          ..write('doi: $doi, ')
          ..write('pmid: $pmid, ')
          ..write('officialUrl: $officialUrl, ')
          ..write('accessedDate: $accessedDate, ')
          ..write('tier: $tier, ')
          ..write('evidenceLevel: $evidenceLevel, ')
          ..write('licenseMode: $licenseMode, ')
          ..write('licenseAgreementId: $licenseAgreementId, ')
          ..write('identifierVerified: $identifierVerified, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('version: $version, ')
          ..write('isTestData: $isTestData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    sourceId,
    sourceType,
    title,
    authorsJson,
    organization,
    journal,
    publicationYear,
    edition,
    doi,
    pmid,
    officialUrl,
    accessedDate,
    tier,
    evidenceLevel,
    licenseMode,
    licenseAgreementId,
    identifierVerified,
    reviewStatus,
    lastReviewedAt,
    version,
    isTestData,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Source &&
          other.sourceId == this.sourceId &&
          other.sourceType == this.sourceType &&
          other.title == this.title &&
          other.authorsJson == this.authorsJson &&
          other.organization == this.organization &&
          other.journal == this.journal &&
          other.publicationYear == this.publicationYear &&
          other.edition == this.edition &&
          other.doi == this.doi &&
          other.pmid == this.pmid &&
          other.officialUrl == this.officialUrl &&
          other.accessedDate == this.accessedDate &&
          other.tier == this.tier &&
          other.evidenceLevel == this.evidenceLevel &&
          other.licenseMode == this.licenseMode &&
          other.licenseAgreementId == this.licenseAgreementId &&
          other.identifierVerified == this.identifierVerified &&
          other.reviewStatus == this.reviewStatus &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.version == this.version &&
          other.isTestData == this.isTestData);
}

class SourcesCompanion extends UpdateCompanion<Source> {
  final Value<String> sourceId;
  final Value<String> sourceType;
  final Value<String> title;
  final Value<String> authorsJson;
  final Value<String?> organization;
  final Value<String?> journal;
  final Value<int?> publicationYear;
  final Value<String?> edition;
  final Value<String?> doi;
  final Value<String?> pmid;
  final Value<String?> officialUrl;
  final Value<String?> accessedDate;
  final Value<int> tier;
  final Value<String> evidenceLevel;
  final Value<String> licenseMode;
  final Value<String?> licenseAgreementId;
  final Value<int> identifierVerified;
  final Value<String> reviewStatus;
  final Value<String?> lastReviewedAt;
  final Value<int> version;
  final Value<int> isTestData;
  const SourcesCompanion({
    this.sourceId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.title = const Value.absent(),
    this.authorsJson = const Value.absent(),
    this.organization = const Value.absent(),
    this.journal = const Value.absent(),
    this.publicationYear = const Value.absent(),
    this.edition = const Value.absent(),
    this.doi = const Value.absent(),
    this.pmid = const Value.absent(),
    this.officialUrl = const Value.absent(),
    this.accessedDate = const Value.absent(),
    this.tier = const Value.absent(),
    this.evidenceLevel = const Value.absent(),
    this.licenseMode = const Value.absent(),
    this.licenseAgreementId = const Value.absent(),
    this.identifierVerified = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isTestData = const Value.absent(),
  });
  SourcesCompanion.insert({
    required String sourceId,
    required String sourceType,
    required String title,
    this.authorsJson = const Value.absent(),
    this.organization = const Value.absent(),
    this.journal = const Value.absent(),
    this.publicationYear = const Value.absent(),
    this.edition = const Value.absent(),
    this.doi = const Value.absent(),
    this.pmid = const Value.absent(),
    this.officialUrl = const Value.absent(),
    this.accessedDate = const Value.absent(),
    required int tier,
    required String evidenceLevel,
    required String licenseMode,
    this.licenseAgreementId = const Value.absent(),
    this.identifierVerified = const Value.absent(),
    required String reviewStatus,
    this.lastReviewedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isTestData = const Value.absent(),
  }) : sourceId = Value(sourceId),
       sourceType = Value(sourceType),
       title = Value(title),
       tier = Value(tier),
       evidenceLevel = Value(evidenceLevel),
       licenseMode = Value(licenseMode),
       reviewStatus = Value(reviewStatus);
  static Insertable<Source> custom({
    Expression<String>? sourceId,
    Expression<String>? sourceType,
    Expression<String>? title,
    Expression<String>? authorsJson,
    Expression<String>? organization,
    Expression<String>? journal,
    Expression<int>? publicationYear,
    Expression<String>? edition,
    Expression<String>? doi,
    Expression<String>? pmid,
    Expression<String>? officialUrl,
    Expression<String>? accessedDate,
    Expression<int>? tier,
    Expression<String>? evidenceLevel,
    Expression<String>? licenseMode,
    Expression<String>? licenseAgreementId,
    Expression<int>? identifierVerified,
    Expression<String>? reviewStatus,
    Expression<String>? lastReviewedAt,
    Expression<int>? version,
    Expression<int>? isTestData,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (sourceType != null) 'source_type': sourceType,
      if (title != null) 'title': title,
      if (authorsJson != null) 'authors_json': authorsJson,
      if (organization != null) 'organization': organization,
      if (journal != null) 'journal': journal,
      if (publicationYear != null) 'publication_year': publicationYear,
      if (edition != null) 'edition': edition,
      if (doi != null) 'doi': doi,
      if (pmid != null) 'pmid': pmid,
      if (officialUrl != null) 'official_url': officialUrl,
      if (accessedDate != null) 'accessed_date': accessedDate,
      if (tier != null) 'tier': tier,
      if (evidenceLevel != null) 'evidence_level': evidenceLevel,
      if (licenseMode != null) 'license_mode': licenseMode,
      if (licenseAgreementId != null)
        'license_agreement_id': licenseAgreementId,
      if (identifierVerified != null) 'identifier_verified': identifierVerified,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (version != null) 'version': version,
      if (isTestData != null) 'is_test_data': isTestData,
    });
  }

  SourcesCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? sourceType,
    Value<String>? title,
    Value<String>? authorsJson,
    Value<String?>? organization,
    Value<String?>? journal,
    Value<int?>? publicationYear,
    Value<String?>? edition,
    Value<String?>? doi,
    Value<String?>? pmid,
    Value<String?>? officialUrl,
    Value<String?>? accessedDate,
    Value<int>? tier,
    Value<String>? evidenceLevel,
    Value<String>? licenseMode,
    Value<String?>? licenseAgreementId,
    Value<int>? identifierVerified,
    Value<String>? reviewStatus,
    Value<String?>? lastReviewedAt,
    Value<int>? version,
    Value<int>? isTestData,
  }) {
    return SourcesCompanion(
      sourceId: sourceId ?? this.sourceId,
      sourceType: sourceType ?? this.sourceType,
      title: title ?? this.title,
      authorsJson: authorsJson ?? this.authorsJson,
      organization: organization ?? this.organization,
      journal: journal ?? this.journal,
      publicationYear: publicationYear ?? this.publicationYear,
      edition: edition ?? this.edition,
      doi: doi ?? this.doi,
      pmid: pmid ?? this.pmid,
      officialUrl: officialUrl ?? this.officialUrl,
      accessedDate: accessedDate ?? this.accessedDate,
      tier: tier ?? this.tier,
      evidenceLevel: evidenceLevel ?? this.evidenceLevel,
      licenseMode: licenseMode ?? this.licenseMode,
      licenseAgreementId: licenseAgreementId ?? this.licenseAgreementId,
      identifierVerified: identifierVerified ?? this.identifierVerified,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      version: version ?? this.version,
      isTestData: isTestData ?? this.isTestData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (authorsJson.present) {
      map['authors_json'] = Variable<String>(authorsJson.value);
    }
    if (organization.present) {
      map['organization'] = Variable<String>(organization.value);
    }
    if (journal.present) {
      map['journal'] = Variable<String>(journal.value);
    }
    if (publicationYear.present) {
      map['publication_year'] = Variable<int>(publicationYear.value);
    }
    if (edition.present) {
      map['edition'] = Variable<String>(edition.value);
    }
    if (doi.present) {
      map['doi'] = Variable<String>(doi.value);
    }
    if (pmid.present) {
      map['pmid'] = Variable<String>(pmid.value);
    }
    if (officialUrl.present) {
      map['official_url'] = Variable<String>(officialUrl.value);
    }
    if (accessedDate.present) {
      map['accessed_date'] = Variable<String>(accessedDate.value);
    }
    if (tier.present) {
      map['tier'] = Variable<int>(tier.value);
    }
    if (evidenceLevel.present) {
      map['evidence_level'] = Variable<String>(evidenceLevel.value);
    }
    if (licenseMode.present) {
      map['license_mode'] = Variable<String>(licenseMode.value);
    }
    if (licenseAgreementId.present) {
      map['license_agreement_id'] = Variable<String>(licenseAgreementId.value);
    }
    if (identifierVerified.present) {
      map['identifier_verified'] = Variable<int>(identifierVerified.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<String>(lastReviewedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isTestData.present) {
      map['is_test_data'] = Variable<int>(isTestData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourcesCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('sourceType: $sourceType, ')
          ..write('title: $title, ')
          ..write('authorsJson: $authorsJson, ')
          ..write('organization: $organization, ')
          ..write('journal: $journal, ')
          ..write('publicationYear: $publicationYear, ')
          ..write('edition: $edition, ')
          ..write('doi: $doi, ')
          ..write('pmid: $pmid, ')
          ..write('officialUrl: $officialUrl, ')
          ..write('accessedDate: $accessedDate, ')
          ..write('tier: $tier, ')
          ..write('evidenceLevel: $evidenceLevel, ')
          ..write('licenseMode: $licenseMode, ')
          ..write('licenseAgreementId: $licenseAgreementId, ')
          ..write('identifierVerified: $identifierVerified, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('version: $version, ')
          ..write('isTestData: $isTestData')
          ..write(')'))
        .toString();
  }
}

class Jurisdictions extends Table with TableInfo<Jurisdictions, Jurisdiction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Jurisdictions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta(
    'jurisdictionId',
  );
  late final GeneratedColumn<String> jurisdictionId = GeneratedColumn<String>(
    'jurisdiction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (level IN (\'international\', \'supranational\', \'country\', \'subdivision\'))',
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES jurisdictions(jurisdiction_id)',
  );
  static const VerificationMeta _iso3166Meta = const VerificationMeta(
    'iso3166',
  );
  late final GeneratedColumn<String> iso3166 = GeneratedColumn<String>(
    'iso3166',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _namesJsonMeta = const VerificationMeta(
    'namesJson',
  );
  late final GeneratedColumn<String> namesJson = GeneratedColumn<String>(
    'names_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'{}\'',
    defaultValue: const CustomExpression('\'{}\''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    jurisdictionId,
    level,
    parentId,
    iso3166,
    namesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jurisdictions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Jurisdiction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(
          data['jurisdiction_id']!,
          _jurisdictionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionIdMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('iso3166')) {
      context.handle(
        _iso3166Meta,
        iso3166.isAcceptableOrUnknown(data['iso3166']!, _iso3166Meta),
      );
    }
    if (data.containsKey('names_json')) {
      context.handle(
        _namesJsonMeta,
        namesJson.isAcceptableOrUnknown(data['names_json']!, _namesJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {jurisdictionId};
  @override
  Jurisdiction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Jurisdiction(
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jurisdiction_id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      iso3166: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iso3166'],
      ),
      namesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}names_json'],
      )!,
    );
  }

  @override
  Jurisdictions createAlias(String alias) {
    return Jurisdictions(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get dontWriteConstraints => true;
}

class Jurisdiction extends DataClass implements Insertable<Jurisdiction> {
  final String jurisdictionId;

  /// INT, EU, UZ, US, US-CA
  final String level;
  final String? parentId;
  final String? iso3166;
  final String namesJson;
  const Jurisdiction({
    required this.jurisdictionId,
    required this.level,
    this.parentId,
    this.iso3166,
    required this.namesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['jurisdiction_id'] = Variable<String>(jurisdictionId);
    map['level'] = Variable<String>(level);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || iso3166 != null) {
      map['iso3166'] = Variable<String>(iso3166);
    }
    map['names_json'] = Variable<String>(namesJson);
    return map;
  }

  JurisdictionsCompanion toCompanion(bool nullToAbsent) {
    return JurisdictionsCompanion(
      jurisdictionId: Value(jurisdictionId),
      level: Value(level),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      iso3166: iso3166 == null && nullToAbsent
          ? const Value.absent()
          : Value(iso3166),
      namesJson: Value(namesJson),
    );
  }

  factory Jurisdiction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Jurisdiction(
      jurisdictionId: serializer.fromJson<String>(json['jurisdiction_id']),
      level: serializer.fromJson<String>(json['level']),
      parentId: serializer.fromJson<String?>(json['parent_id']),
      iso3166: serializer.fromJson<String?>(json['iso3166']),
      namesJson: serializer.fromJson<String>(json['names_json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'jurisdiction_id': serializer.toJson<String>(jurisdictionId),
      'level': serializer.toJson<String>(level),
      'parent_id': serializer.toJson<String?>(parentId),
      'iso3166': serializer.toJson<String?>(iso3166),
      'names_json': serializer.toJson<String>(namesJson),
    };
  }

  Jurisdiction copyWith({
    String? jurisdictionId,
    String? level,
    Value<String?> parentId = const Value.absent(),
    Value<String?> iso3166 = const Value.absent(),
    String? namesJson,
  }) => Jurisdiction(
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    level: level ?? this.level,
    parentId: parentId.present ? parentId.value : this.parentId,
    iso3166: iso3166.present ? iso3166.value : this.iso3166,
    namesJson: namesJson ?? this.namesJson,
  );
  Jurisdiction copyWithCompanion(JurisdictionsCompanion data) {
    return Jurisdiction(
      jurisdictionId: data.jurisdictionId.present
          ? data.jurisdictionId.value
          : this.jurisdictionId,
      level: data.level.present ? data.level.value : this.level,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      iso3166: data.iso3166.present ? data.iso3166.value : this.iso3166,
      namesJson: data.namesJson.present ? data.namesJson.value : this.namesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Jurisdiction(')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('level: $level, ')
          ..write('parentId: $parentId, ')
          ..write('iso3166: $iso3166, ')
          ..write('namesJson: $namesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(jurisdictionId, level, parentId, iso3166, namesJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Jurisdiction &&
          other.jurisdictionId == this.jurisdictionId &&
          other.level == this.level &&
          other.parentId == this.parentId &&
          other.iso3166 == this.iso3166 &&
          other.namesJson == this.namesJson);
}

class JurisdictionsCompanion extends UpdateCompanion<Jurisdiction> {
  final Value<String> jurisdictionId;
  final Value<String> level;
  final Value<String?> parentId;
  final Value<String?> iso3166;
  final Value<String> namesJson;
  const JurisdictionsCompanion({
    this.jurisdictionId = const Value.absent(),
    this.level = const Value.absent(),
    this.parentId = const Value.absent(),
    this.iso3166 = const Value.absent(),
    this.namesJson = const Value.absent(),
  });
  JurisdictionsCompanion.insert({
    required String jurisdictionId,
    required String level,
    this.parentId = const Value.absent(),
    this.iso3166 = const Value.absent(),
    this.namesJson = const Value.absent(),
  }) : jurisdictionId = Value(jurisdictionId),
       level = Value(level);
  static Insertable<Jurisdiction> custom({
    Expression<String>? jurisdictionId,
    Expression<String>? level,
    Expression<String>? parentId,
    Expression<String>? iso3166,
    Expression<String>? namesJson,
  }) {
    return RawValuesInsertable({
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (level != null) 'level': level,
      if (parentId != null) 'parent_id': parentId,
      if (iso3166 != null) 'iso3166': iso3166,
      if (namesJson != null) 'names_json': namesJson,
    });
  }

  JurisdictionsCompanion copyWith({
    Value<String>? jurisdictionId,
    Value<String>? level,
    Value<String?>? parentId,
    Value<String?>? iso3166,
    Value<String>? namesJson,
  }) {
    return JurisdictionsCompanion(
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      level: level ?? this.level,
      parentId: parentId ?? this.parentId,
      iso3166: iso3166 ?? this.iso3166,
      namesJson: namesJson ?? this.namesJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<String>(jurisdictionId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (iso3166.present) {
      map['iso3166'] = Variable<String>(iso3166.value);
    }
    if (namesJson.present) {
      map['names_json'] = Variable<String>(namesJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JurisdictionsCompanion(')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('level: $level, ')
          ..write('parentId: $parentId, ')
          ..write('iso3166: $iso3166, ')
          ..write('namesJson: $namesJson')
          ..write(')'))
        .toString();
  }
}

class Authorities extends Table with TableInfo<Authorities, Authority> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Authorities(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _authorityIdMeta = const VerificationMeta(
    'authorityId',
  );
  late final GeneratedColumn<String> authorityId = GeneratedColumn<String>(
    'authority_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta(
    'jurisdictionId',
  );
  late final GeneratedColumn<String> jurisdictionId = GeneratedColumn<String>(
    'jurisdiction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES jurisdictions(jurisdiction_id)',
  );
  static const VerificationMeta _namesJsonMeta = const VerificationMeta(
    'namesJson',
  );
  late final GeneratedColumn<String> namesJson = GeneratedColumn<String>(
    'names_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'{}\'',
    defaultValue: const CustomExpression('\'{}\''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    authorityId,
    jurisdictionId,
    namesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'authorities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Authority> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('authority_id')) {
      context.handle(
        _authorityIdMeta,
        authorityId.isAcceptableOrUnknown(
          data['authority_id']!,
          _authorityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_authorityIdMeta);
    }
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(
          data['jurisdiction_id']!,
          _jurisdictionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionIdMeta);
    }
    if (data.containsKey('names_json')) {
      context.handle(
        _namesJsonMeta,
        namesJson.isAcceptableOrUnknown(data['names_json']!, _namesJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {authorityId};
  @override
  Authority map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Authority(
      authorityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authority_id'],
      )!,
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jurisdiction_id'],
      )!,
      namesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}names_json'],
      )!,
    );
  }

  @override
  Authorities createAlias(String alias) {
    return Authorities(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get dontWriteConstraints => true;
}

class Authority extends DataClass implements Insertable<Authority> {
  final String authorityId;
  final String jurisdictionId;
  final String namesJson;
  const Authority({
    required this.authorityId,
    required this.jurisdictionId,
    required this.namesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['authority_id'] = Variable<String>(authorityId);
    map['jurisdiction_id'] = Variable<String>(jurisdictionId);
    map['names_json'] = Variable<String>(namesJson);
    return map;
  }

  AuthoritiesCompanion toCompanion(bool nullToAbsent) {
    return AuthoritiesCompanion(
      authorityId: Value(authorityId),
      jurisdictionId: Value(jurisdictionId),
      namesJson: Value(namesJson),
    );
  }

  factory Authority.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Authority(
      authorityId: serializer.fromJson<String>(json['authority_id']),
      jurisdictionId: serializer.fromJson<String>(json['jurisdiction_id']),
      namesJson: serializer.fromJson<String>(json['names_json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'authority_id': serializer.toJson<String>(authorityId),
      'jurisdiction_id': serializer.toJson<String>(jurisdictionId),
      'names_json': serializer.toJson<String>(namesJson),
    };
  }

  Authority copyWith({
    String? authorityId,
    String? jurisdictionId,
    String? namesJson,
  }) => Authority(
    authorityId: authorityId ?? this.authorityId,
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    namesJson: namesJson ?? this.namesJson,
  );
  Authority copyWithCompanion(AuthoritiesCompanion data) {
    return Authority(
      authorityId: data.authorityId.present
          ? data.authorityId.value
          : this.authorityId,
      jurisdictionId: data.jurisdictionId.present
          ? data.jurisdictionId.value
          : this.jurisdictionId,
      namesJson: data.namesJson.present ? data.namesJson.value : this.namesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Authority(')
          ..write('authorityId: $authorityId, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('namesJson: $namesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(authorityId, jurisdictionId, namesJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Authority &&
          other.authorityId == this.authorityId &&
          other.jurisdictionId == this.jurisdictionId &&
          other.namesJson == this.namesJson);
}

class AuthoritiesCompanion extends UpdateCompanion<Authority> {
  final Value<String> authorityId;
  final Value<String> jurisdictionId;
  final Value<String> namesJson;
  const AuthoritiesCompanion({
    this.authorityId = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.namesJson = const Value.absent(),
  });
  AuthoritiesCompanion.insert({
    required String authorityId,
    required String jurisdictionId,
    this.namesJson = const Value.absent(),
  }) : authorityId = Value(authorityId),
       jurisdictionId = Value(jurisdictionId);
  static Insertable<Authority> custom({
    Expression<String>? authorityId,
    Expression<String>? jurisdictionId,
    Expression<String>? namesJson,
  }) {
    return RawValuesInsertable({
      if (authorityId != null) 'authority_id': authorityId,
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (namesJson != null) 'names_json': namesJson,
    });
  }

  AuthoritiesCompanion copyWith({
    Value<String>? authorityId,
    Value<String>? jurisdictionId,
    Value<String>? namesJson,
  }) {
    return AuthoritiesCompanion(
      authorityId: authorityId ?? this.authorityId,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      namesJson: namesJson ?? this.namesJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (authorityId.present) {
      map['authority_id'] = Variable<String>(authorityId.value);
    }
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<String>(jurisdictionId.value);
    }
    if (namesJson.present) {
      map['names_json'] = Variable<String>(namesJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthoritiesCompanion(')
          ..write('authorityId: $authorityId, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('namesJson: $namesJson')
          ..write(')'))
        .toString();
  }
}

class JurisdictionalInstruments extends Table
    with TableInfo<JurisdictionalInstruments, JurisdictionalInstrument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  JurisdictionalInstruments(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta(
    'jurisdictionId',
  );
  late final GeneratedColumn<String> jurisdictionId = GeneratedColumn<String>(
    'jurisdiction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES jurisdictions(jurisdiction_id)',
  );
  static const VerificationMeta _instrumentTypeMeta = const VerificationMeta(
    'instrumentType',
  );
  late final GeneratedColumn<String> instrumentType = GeneratedColumn<String>(
    'instrument_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (instrument_type IN (\'law\', \'regulation\', \'controlled_substance_schedule\', \'standard\', \'national_method\', \'official_guideline\', \'international_convention\'))',
  );
  static const VerificationMeta _titlesJsonMeta = const VerificationMeta(
    'titlesJson',
  );
  late final GeneratedColumn<String> titlesJson = GeneratedColumn<String>(
    'titles_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'{}\'',
    defaultValue: const CustomExpression('\'{}\''),
  );
  static const VerificationMeta _officialSourceIdMeta = const VerificationMeta(
    'officialSourceId',
  );
  late final GeneratedColumn<String> officialSourceId = GeneratedColumn<String>(
    'official_source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES sources(source_id)',
  );
  static const VerificationMeta _officialReferenceMeta = const VerificationMeta(
    'officialReference',
  );
  late final GeneratedColumn<String> officialReference =
      GeneratedColumn<String>(
        'official_reference',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  late final GeneratedColumn<String> effectiveFrom = GeneratedColumn<String>(
    'effective_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _effectiveToMeta = const VerificationMeta(
    'effectiveTo',
  );
  late final GeneratedColumn<String> effectiveTo = GeneratedColumn<String>(
    'effective_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(version) > 0)',
  );
  static const VerificationMeta _lastVerifiedAtMeta = const VerificationMeta(
    'lastVerifiedAt',
  );
  late final GeneratedColumn<String> lastVerifiedAt = GeneratedColumn<String>(
    'last_verified_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (review_status IN (\'DRAFT\', \'VERIFIED\', \'REVIEWED\', \'NEEDS_REVIEW\', \'OUTDATED\', \'REJECTED\'))',
  );
  static const VerificationMeta _isTestDataMeta = const VerificationMeta(
    'isTestData',
  );
  late final GeneratedColumn<int> isTestData = GeneratedColumn<int>(
    'is_test_data',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _authorityIdMeta = const VerificationMeta(
    'authorityId',
  );
  late final GeneratedColumn<String> authorityId = GeneratedColumn<String>(
    'authority_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES authorities(authority_id)',
  );
  static const VerificationMeta _publicationDateMeta = const VerificationMeta(
    'publicationDate',
  );
  late final GeneratedColumn<String> publicationDate = GeneratedColumn<String>(
    'publication_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _lastAmendedAtMeta = const VerificationMeta(
    'lastAmendedAt',
  );
  late final GeneratedColumn<String> lastAmendedAt = GeneratedColumn<String>(
    'last_amended_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _legalStatusMeta = const VerificationMeta(
    'legalStatus',
  );
  late final GeneratedColumn<String> legalStatus = GeneratedColumn<String>(
    'legal_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'in_force\' CHECK (legal_status IN (\'in_force\', \'amended\', \'superseded\', \'repealed\'))',
    defaultValue: const CustomExpression('\'in_force\''),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _translationStatusMeta = const VerificationMeta(
    'translationStatus',
  );
  late final GeneratedColumn<String> translationStatus =
      GeneratedColumn<String>(
        'translation_status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'CHECK (translation_status IS NULL OR translation_status IN (\'machine_draft\', \'translated\', \'reviewed\'))',
      );
  @override
  List<GeneratedColumn> get $columns => [
    instrumentId,
    jurisdictionId,
    instrumentType,
    titlesJson,
    officialSourceId,
    officialReference,
    effectiveFrom,
    effectiveTo,
    version,
    lastVerifiedAt,
    reviewStatus,
    isTestData,
    authorityId,
    publicationDate,
    lastAmendedAt,
    legalStatus,
    language,
    translationStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jurisdictional_instruments';
  @override
  VerificationContext validateIntegrity(
    Insertable<JurisdictionalInstrument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(
          data['jurisdiction_id']!,
          _jurisdictionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionIdMeta);
    }
    if (data.containsKey('instrument_type')) {
      context.handle(
        _instrumentTypeMeta,
        instrumentType.isAcceptableOrUnknown(
          data['instrument_type']!,
          _instrumentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentTypeMeta);
    }
    if (data.containsKey('titles_json')) {
      context.handle(
        _titlesJsonMeta,
        titlesJson.isAcceptableOrUnknown(data['titles_json']!, _titlesJsonMeta),
      );
    }
    if (data.containsKey('official_source_id')) {
      context.handle(
        _officialSourceIdMeta,
        officialSourceId.isAcceptableOrUnknown(
          data['official_source_id']!,
          _officialSourceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_officialSourceIdMeta);
    }
    if (data.containsKey('official_reference')) {
      context.handle(
        _officialReferenceMeta,
        officialReference.isAcceptableOrUnknown(
          data['official_reference']!,
          _officialReferenceMeta,
        ),
      );
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('effective_to')) {
      context.handle(
        _effectiveToMeta,
        effectiveTo.isAcceptableOrUnknown(
          data['effective_to']!,
          _effectiveToMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('last_verified_at')) {
      context.handle(
        _lastVerifiedAtMeta,
        lastVerifiedAt.isAcceptableOrUnknown(
          data['last_verified_at']!,
          _lastVerifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewStatusMeta);
    }
    if (data.containsKey('is_test_data')) {
      context.handle(
        _isTestDataMeta,
        isTestData.isAcceptableOrUnknown(
          data['is_test_data']!,
          _isTestDataMeta,
        ),
      );
    }
    if (data.containsKey('authority_id')) {
      context.handle(
        _authorityIdMeta,
        authorityId.isAcceptableOrUnknown(
          data['authority_id']!,
          _authorityIdMeta,
        ),
      );
    }
    if (data.containsKey('publication_date')) {
      context.handle(
        _publicationDateMeta,
        publicationDate.isAcceptableOrUnknown(
          data['publication_date']!,
          _publicationDateMeta,
        ),
      );
    }
    if (data.containsKey('last_amended_at')) {
      context.handle(
        _lastAmendedAtMeta,
        lastAmendedAt.isAcceptableOrUnknown(
          data['last_amended_at']!,
          _lastAmendedAtMeta,
        ),
      );
    }
    if (data.containsKey('legal_status')) {
      context.handle(
        _legalStatusMeta,
        legalStatus.isAcceptableOrUnknown(
          data['legal_status']!,
          _legalStatusMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('translation_status')) {
      context.handle(
        _translationStatusMeta,
        translationStatus.isAcceptableOrUnknown(
          data['translation_status']!,
          _translationStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instrumentId};
  @override
  JurisdictionalInstrument map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JurisdictionalInstrument(
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jurisdiction_id'],
      )!,
      instrumentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_type'],
      )!,
      titlesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titles_json'],
      )!,
      officialSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}official_source_id'],
      )!,
      officialReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}official_reference'],
      ),
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_from'],
      )!,
      effectiveTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_to'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      lastVerifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_verified_at'],
      ),
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      isTestData: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_test_data'],
      )!,
      authorityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authority_id'],
      ),
      publicationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publication_date'],
      ),
      lastAmendedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_amended_at'],
      ),
      legalStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_status'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      translationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_status'],
      ),
    );
  }

  @override
  JurisdictionalInstruments createAlias(String alias) {
    return JurisdictionalInstruments(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'CHECK(effective_to IS NULL OR effective_to > effective_from)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class JurisdictionalInstrument extends DataClass
    implements Insertable<JurisdictionalInstrument> {
  final String instrumentId;
  final String jurisdictionId;
  final String instrumentType;
  final String titlesJson;
  final String officialSourceId;
  final String? officialReference;
  final String effectiveFrom;
  final String? effectiveTo;
  final String version;
  final String? lastVerifiedAt;
  final String reviewStatus;
  final int isTestData;
  final String? authorityId;
  final String? publicationDate;
  final String? lastAmendedAt;
  final String legalStatus;
  final String? language;
  final String? translationStatus;
  const JurisdictionalInstrument({
    required this.instrumentId,
    required this.jurisdictionId,
    required this.instrumentType,
    required this.titlesJson,
    required this.officialSourceId,
    this.officialReference,
    required this.effectiveFrom,
    this.effectiveTo,
    required this.version,
    this.lastVerifiedAt,
    required this.reviewStatus,
    required this.isTestData,
    this.authorityId,
    this.publicationDate,
    this.lastAmendedAt,
    required this.legalStatus,
    this.language,
    this.translationStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instrument_id'] = Variable<String>(instrumentId);
    map['jurisdiction_id'] = Variable<String>(jurisdictionId);
    map['instrument_type'] = Variable<String>(instrumentType);
    map['titles_json'] = Variable<String>(titlesJson);
    map['official_source_id'] = Variable<String>(officialSourceId);
    if (!nullToAbsent || officialReference != null) {
      map['official_reference'] = Variable<String>(officialReference);
    }
    map['effective_from'] = Variable<String>(effectiveFrom);
    if (!nullToAbsent || effectiveTo != null) {
      map['effective_to'] = Variable<String>(effectiveTo);
    }
    map['version'] = Variable<String>(version);
    if (!nullToAbsent || lastVerifiedAt != null) {
      map['last_verified_at'] = Variable<String>(lastVerifiedAt);
    }
    map['review_status'] = Variable<String>(reviewStatus);
    map['is_test_data'] = Variable<int>(isTestData);
    if (!nullToAbsent || authorityId != null) {
      map['authority_id'] = Variable<String>(authorityId);
    }
    if (!nullToAbsent || publicationDate != null) {
      map['publication_date'] = Variable<String>(publicationDate);
    }
    if (!nullToAbsent || lastAmendedAt != null) {
      map['last_amended_at'] = Variable<String>(lastAmendedAt);
    }
    map['legal_status'] = Variable<String>(legalStatus);
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    if (!nullToAbsent || translationStatus != null) {
      map['translation_status'] = Variable<String>(translationStatus);
    }
    return map;
  }

  JurisdictionalInstrumentsCompanion toCompanion(bool nullToAbsent) {
    return JurisdictionalInstrumentsCompanion(
      instrumentId: Value(instrumentId),
      jurisdictionId: Value(jurisdictionId),
      instrumentType: Value(instrumentType),
      titlesJson: Value(titlesJson),
      officialSourceId: Value(officialSourceId),
      officialReference: officialReference == null && nullToAbsent
          ? const Value.absent()
          : Value(officialReference),
      effectiveFrom: Value(effectiveFrom),
      effectiveTo: effectiveTo == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveTo),
      version: Value(version),
      lastVerifiedAt: lastVerifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVerifiedAt),
      reviewStatus: Value(reviewStatus),
      isTestData: Value(isTestData),
      authorityId: authorityId == null && nullToAbsent
          ? const Value.absent()
          : Value(authorityId),
      publicationDate: publicationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(publicationDate),
      lastAmendedAt: lastAmendedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAmendedAt),
      legalStatus: Value(legalStatus),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      translationStatus: translationStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(translationStatus),
    );
  }

  factory JurisdictionalInstrument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JurisdictionalInstrument(
      instrumentId: serializer.fromJson<String>(json['instrument_id']),
      jurisdictionId: serializer.fromJson<String>(json['jurisdiction_id']),
      instrumentType: serializer.fromJson<String>(json['instrument_type']),
      titlesJson: serializer.fromJson<String>(json['titles_json']),
      officialSourceId: serializer.fromJson<String>(json['official_source_id']),
      officialReference: serializer.fromJson<String?>(
        json['official_reference'],
      ),
      effectiveFrom: serializer.fromJson<String>(json['effective_from']),
      effectiveTo: serializer.fromJson<String?>(json['effective_to']),
      version: serializer.fromJson<String>(json['version']),
      lastVerifiedAt: serializer.fromJson<String?>(json['last_verified_at']),
      reviewStatus: serializer.fromJson<String>(json['review_status']),
      isTestData: serializer.fromJson<int>(json['is_test_data']),
      authorityId: serializer.fromJson<String?>(json['authority_id']),
      publicationDate: serializer.fromJson<String?>(json['publication_date']),
      lastAmendedAt: serializer.fromJson<String?>(json['last_amended_at']),
      legalStatus: serializer.fromJson<String>(json['legal_status']),
      language: serializer.fromJson<String?>(json['language']),
      translationStatus: serializer.fromJson<String?>(
        json['translation_status'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instrument_id': serializer.toJson<String>(instrumentId),
      'jurisdiction_id': serializer.toJson<String>(jurisdictionId),
      'instrument_type': serializer.toJson<String>(instrumentType),
      'titles_json': serializer.toJson<String>(titlesJson),
      'official_source_id': serializer.toJson<String>(officialSourceId),
      'official_reference': serializer.toJson<String?>(officialReference),
      'effective_from': serializer.toJson<String>(effectiveFrom),
      'effective_to': serializer.toJson<String?>(effectiveTo),
      'version': serializer.toJson<String>(version),
      'last_verified_at': serializer.toJson<String?>(lastVerifiedAt),
      'review_status': serializer.toJson<String>(reviewStatus),
      'is_test_data': serializer.toJson<int>(isTestData),
      'authority_id': serializer.toJson<String?>(authorityId),
      'publication_date': serializer.toJson<String?>(publicationDate),
      'last_amended_at': serializer.toJson<String?>(lastAmendedAt),
      'legal_status': serializer.toJson<String>(legalStatus),
      'language': serializer.toJson<String?>(language),
      'translation_status': serializer.toJson<String?>(translationStatus),
    };
  }

  JurisdictionalInstrument copyWith({
    String? instrumentId,
    String? jurisdictionId,
    String? instrumentType,
    String? titlesJson,
    String? officialSourceId,
    Value<String?> officialReference = const Value.absent(),
    String? effectiveFrom,
    Value<String?> effectiveTo = const Value.absent(),
    String? version,
    Value<String?> lastVerifiedAt = const Value.absent(),
    String? reviewStatus,
    int? isTestData,
    Value<String?> authorityId = const Value.absent(),
    Value<String?> publicationDate = const Value.absent(),
    Value<String?> lastAmendedAt = const Value.absent(),
    String? legalStatus,
    Value<String?> language = const Value.absent(),
    Value<String?> translationStatus = const Value.absent(),
  }) => JurisdictionalInstrument(
    instrumentId: instrumentId ?? this.instrumentId,
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    instrumentType: instrumentType ?? this.instrumentType,
    titlesJson: titlesJson ?? this.titlesJson,
    officialSourceId: officialSourceId ?? this.officialSourceId,
    officialReference: officialReference.present
        ? officialReference.value
        : this.officialReference,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    effectiveTo: effectiveTo.present ? effectiveTo.value : this.effectiveTo,
    version: version ?? this.version,
    lastVerifiedAt: lastVerifiedAt.present
        ? lastVerifiedAt.value
        : this.lastVerifiedAt,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    isTestData: isTestData ?? this.isTestData,
    authorityId: authorityId.present ? authorityId.value : this.authorityId,
    publicationDate: publicationDate.present
        ? publicationDate.value
        : this.publicationDate,
    lastAmendedAt: lastAmendedAt.present
        ? lastAmendedAt.value
        : this.lastAmendedAt,
    legalStatus: legalStatus ?? this.legalStatus,
    language: language.present ? language.value : this.language,
    translationStatus: translationStatus.present
        ? translationStatus.value
        : this.translationStatus,
  );
  JurisdictionalInstrument copyWithCompanion(
    JurisdictionalInstrumentsCompanion data,
  ) {
    return JurisdictionalInstrument(
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      jurisdictionId: data.jurisdictionId.present
          ? data.jurisdictionId.value
          : this.jurisdictionId,
      instrumentType: data.instrumentType.present
          ? data.instrumentType.value
          : this.instrumentType,
      titlesJson: data.titlesJson.present
          ? data.titlesJson.value
          : this.titlesJson,
      officialSourceId: data.officialSourceId.present
          ? data.officialSourceId.value
          : this.officialSourceId,
      officialReference: data.officialReference.present
          ? data.officialReference.value
          : this.officialReference,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      effectiveTo: data.effectiveTo.present
          ? data.effectiveTo.value
          : this.effectiveTo,
      version: data.version.present ? data.version.value : this.version,
      lastVerifiedAt: data.lastVerifiedAt.present
          ? data.lastVerifiedAt.value
          : this.lastVerifiedAt,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      isTestData: data.isTestData.present
          ? data.isTestData.value
          : this.isTestData,
      authorityId: data.authorityId.present
          ? data.authorityId.value
          : this.authorityId,
      publicationDate: data.publicationDate.present
          ? data.publicationDate.value
          : this.publicationDate,
      lastAmendedAt: data.lastAmendedAt.present
          ? data.lastAmendedAt.value
          : this.lastAmendedAt,
      legalStatus: data.legalStatus.present
          ? data.legalStatus.value
          : this.legalStatus,
      language: data.language.present ? data.language.value : this.language,
      translationStatus: data.translationStatus.present
          ? data.translationStatus.value
          : this.translationStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JurisdictionalInstrument(')
          ..write('instrumentId: $instrumentId, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('instrumentType: $instrumentType, ')
          ..write('titlesJson: $titlesJson, ')
          ..write('officialSourceId: $officialSourceId, ')
          ..write('officialReference: $officialReference, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo, ')
          ..write('version: $version, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('isTestData: $isTestData, ')
          ..write('authorityId: $authorityId, ')
          ..write('publicationDate: $publicationDate, ')
          ..write('lastAmendedAt: $lastAmendedAt, ')
          ..write('legalStatus: $legalStatus, ')
          ..write('language: $language, ')
          ..write('translationStatus: $translationStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    instrumentId,
    jurisdictionId,
    instrumentType,
    titlesJson,
    officialSourceId,
    officialReference,
    effectiveFrom,
    effectiveTo,
    version,
    lastVerifiedAt,
    reviewStatus,
    isTestData,
    authorityId,
    publicationDate,
    lastAmendedAt,
    legalStatus,
    language,
    translationStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JurisdictionalInstrument &&
          other.instrumentId == this.instrumentId &&
          other.jurisdictionId == this.jurisdictionId &&
          other.instrumentType == this.instrumentType &&
          other.titlesJson == this.titlesJson &&
          other.officialSourceId == this.officialSourceId &&
          other.officialReference == this.officialReference &&
          other.effectiveFrom == this.effectiveFrom &&
          other.effectiveTo == this.effectiveTo &&
          other.version == this.version &&
          other.lastVerifiedAt == this.lastVerifiedAt &&
          other.reviewStatus == this.reviewStatus &&
          other.isTestData == this.isTestData &&
          other.authorityId == this.authorityId &&
          other.publicationDate == this.publicationDate &&
          other.lastAmendedAt == this.lastAmendedAt &&
          other.legalStatus == this.legalStatus &&
          other.language == this.language &&
          other.translationStatus == this.translationStatus);
}

class JurisdictionalInstrumentsCompanion
    extends UpdateCompanion<JurisdictionalInstrument> {
  final Value<String> instrumentId;
  final Value<String> jurisdictionId;
  final Value<String> instrumentType;
  final Value<String> titlesJson;
  final Value<String> officialSourceId;
  final Value<String?> officialReference;
  final Value<String> effectiveFrom;
  final Value<String?> effectiveTo;
  final Value<String> version;
  final Value<String?> lastVerifiedAt;
  final Value<String> reviewStatus;
  final Value<int> isTestData;
  final Value<String?> authorityId;
  final Value<String?> publicationDate;
  final Value<String?> lastAmendedAt;
  final Value<String> legalStatus;
  final Value<String?> language;
  final Value<String?> translationStatus;
  const JurisdictionalInstrumentsCompanion({
    this.instrumentId = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.instrumentType = const Value.absent(),
    this.titlesJson = const Value.absent(),
    this.officialSourceId = const Value.absent(),
    this.officialReference = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.effectiveTo = const Value.absent(),
    this.version = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.isTestData = const Value.absent(),
    this.authorityId = const Value.absent(),
    this.publicationDate = const Value.absent(),
    this.lastAmendedAt = const Value.absent(),
    this.legalStatus = const Value.absent(),
    this.language = const Value.absent(),
    this.translationStatus = const Value.absent(),
  });
  JurisdictionalInstrumentsCompanion.insert({
    required String instrumentId,
    required String jurisdictionId,
    required String instrumentType,
    this.titlesJson = const Value.absent(),
    required String officialSourceId,
    this.officialReference = const Value.absent(),
    required String effectiveFrom,
    this.effectiveTo = const Value.absent(),
    required String version,
    this.lastVerifiedAt = const Value.absent(),
    required String reviewStatus,
    this.isTestData = const Value.absent(),
    this.authorityId = const Value.absent(),
    this.publicationDate = const Value.absent(),
    this.lastAmendedAt = const Value.absent(),
    this.legalStatus = const Value.absent(),
    this.language = const Value.absent(),
    this.translationStatus = const Value.absent(),
  }) : instrumentId = Value(instrumentId),
       jurisdictionId = Value(jurisdictionId),
       instrumentType = Value(instrumentType),
       officialSourceId = Value(officialSourceId),
       effectiveFrom = Value(effectiveFrom),
       version = Value(version),
       reviewStatus = Value(reviewStatus);
  static Insertable<JurisdictionalInstrument> custom({
    Expression<String>? instrumentId,
    Expression<String>? jurisdictionId,
    Expression<String>? instrumentType,
    Expression<String>? titlesJson,
    Expression<String>? officialSourceId,
    Expression<String>? officialReference,
    Expression<String>? effectiveFrom,
    Expression<String>? effectiveTo,
    Expression<String>? version,
    Expression<String>? lastVerifiedAt,
    Expression<String>? reviewStatus,
    Expression<int>? isTestData,
    Expression<String>? authorityId,
    Expression<String>? publicationDate,
    Expression<String>? lastAmendedAt,
    Expression<String>? legalStatus,
    Expression<String>? language,
    Expression<String>? translationStatus,
  }) {
    return RawValuesInsertable({
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (instrumentType != null) 'instrument_type': instrumentType,
      if (titlesJson != null) 'titles_json': titlesJson,
      if (officialSourceId != null) 'official_source_id': officialSourceId,
      if (officialReference != null) 'official_reference': officialReference,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (effectiveTo != null) 'effective_to': effectiveTo,
      if (version != null) 'version': version,
      if (lastVerifiedAt != null) 'last_verified_at': lastVerifiedAt,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (isTestData != null) 'is_test_data': isTestData,
      if (authorityId != null) 'authority_id': authorityId,
      if (publicationDate != null) 'publication_date': publicationDate,
      if (lastAmendedAt != null) 'last_amended_at': lastAmendedAt,
      if (legalStatus != null) 'legal_status': legalStatus,
      if (language != null) 'language': language,
      if (translationStatus != null) 'translation_status': translationStatus,
    });
  }

  JurisdictionalInstrumentsCompanion copyWith({
    Value<String>? instrumentId,
    Value<String>? jurisdictionId,
    Value<String>? instrumentType,
    Value<String>? titlesJson,
    Value<String>? officialSourceId,
    Value<String?>? officialReference,
    Value<String>? effectiveFrom,
    Value<String?>? effectiveTo,
    Value<String>? version,
    Value<String?>? lastVerifiedAt,
    Value<String>? reviewStatus,
    Value<int>? isTestData,
    Value<String?>? authorityId,
    Value<String?>? publicationDate,
    Value<String?>? lastAmendedAt,
    Value<String>? legalStatus,
    Value<String?>? language,
    Value<String?>? translationStatus,
  }) {
    return JurisdictionalInstrumentsCompanion(
      instrumentId: instrumentId ?? this.instrumentId,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      instrumentType: instrumentType ?? this.instrumentType,
      titlesJson: titlesJson ?? this.titlesJson,
      officialSourceId: officialSourceId ?? this.officialSourceId,
      officialReference: officialReference ?? this.officialReference,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      version: version ?? this.version,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      isTestData: isTestData ?? this.isTestData,
      authorityId: authorityId ?? this.authorityId,
      publicationDate: publicationDate ?? this.publicationDate,
      lastAmendedAt: lastAmendedAt ?? this.lastAmendedAt,
      legalStatus: legalStatus ?? this.legalStatus,
      language: language ?? this.language,
      translationStatus: translationStatus ?? this.translationStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<String>(jurisdictionId.value);
    }
    if (instrumentType.present) {
      map['instrument_type'] = Variable<String>(instrumentType.value);
    }
    if (titlesJson.present) {
      map['titles_json'] = Variable<String>(titlesJson.value);
    }
    if (officialSourceId.present) {
      map['official_source_id'] = Variable<String>(officialSourceId.value);
    }
    if (officialReference.present) {
      map['official_reference'] = Variable<String>(officialReference.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<String>(effectiveFrom.value);
    }
    if (effectiveTo.present) {
      map['effective_to'] = Variable<String>(effectiveTo.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (lastVerifiedAt.present) {
      map['last_verified_at'] = Variable<String>(lastVerifiedAt.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (isTestData.present) {
      map['is_test_data'] = Variable<int>(isTestData.value);
    }
    if (authorityId.present) {
      map['authority_id'] = Variable<String>(authorityId.value);
    }
    if (publicationDate.present) {
      map['publication_date'] = Variable<String>(publicationDate.value);
    }
    if (lastAmendedAt.present) {
      map['last_amended_at'] = Variable<String>(lastAmendedAt.value);
    }
    if (legalStatus.present) {
      map['legal_status'] = Variable<String>(legalStatus.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (translationStatus.present) {
      map['translation_status'] = Variable<String>(translationStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JurisdictionalInstrumentsCompanion(')
          ..write('instrumentId: $instrumentId, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('instrumentType: $instrumentType, ')
          ..write('titlesJson: $titlesJson, ')
          ..write('officialSourceId: $officialSourceId, ')
          ..write('officialReference: $officialReference, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo, ')
          ..write('version: $version, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('isTestData: $isTestData, ')
          ..write('authorityId: $authorityId, ')
          ..write('publicationDate: $publicationDate, ')
          ..write('lastAmendedAt: $lastAmendedAt, ')
          ..write('legalStatus: $legalStatus, ')
          ..write('language: $language, ')
          ..write('translationStatus: $translationStatus')
          ..write(')'))
        .toString();
  }
}

class JurisdictionalRules extends Table
    with TableInfo<JurisdictionalRules, JurisdictionalRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  JurisdictionalRules(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES jurisdictional_instruments(instrument_id)',
  );
  static const VerificationMeta _ruleTypeMeta = const VerificationMeta(
    'ruleType',
  );
  late final GeneratedColumn<String> ruleType = GeneratedColumn<String>(
    'rule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (rule_type IN (\'control_status\', \'procedure_requirement\', \'legal_threshold\'))',
  );
  static const VerificationMeta _subjectTypeMeta = const VerificationMeta(
    'subjectType',
  );
  late final GeneratedColumn<String> subjectType = GeneratedColumn<String>(
    'subject_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  late final GeneratedColumn<String> effectiveFrom = GeneratedColumn<String>(
    'effective_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _effectiveToMeta = const VerificationMeta(
    'effectiveTo',
  );
  late final GeneratedColumn<String> effectiveTo = GeneratedColumn<String>(
    'effective_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (review_status IN (\'DRAFT\', \'VERIFIED\', \'REVIEWED\', \'NEEDS_REVIEW\', \'OUTDATED\', \'REJECTED\'))',
  );
  static const VerificationMeta _isTestDataMeta = const VerificationMeta(
    'isTestData',
  );
  late final GeneratedColumn<int> isTestData = GeneratedColumn<int>(
    'is_test_data',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _articleSectionMeta = const VerificationMeta(
    'articleSection',
  );
  late final GeneratedColumn<String> articleSection = GeneratedColumn<String>(
    'article_section',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _topicKeyMeta = const VerificationMeta(
    'topicKey',
  );
  late final GeneratedColumn<String> topicKey = GeneratedColumn<String>(
    'topic_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _appliesToJsonMeta = const VerificationMeta(
    'appliesToJson',
  );
  late final GeneratedColumn<String> appliesToJson = GeneratedColumn<String>(
    'applies_to_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    ruleId,
    instrumentId,
    ruleType,
    subjectType,
    subjectId,
    valueJson,
    effectiveFrom,
    effectiveTo,
    reviewStatus,
    isTestData,
    articleSection,
    topicKey,
    appliesToJson,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jurisdictional_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<JurisdictionalRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('rule_type')) {
      context.handle(
        _ruleTypeMeta,
        ruleType.isAcceptableOrUnknown(data['rule_type']!, _ruleTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleTypeMeta);
    }
    if (data.containsKey('subject_type')) {
      context.handle(
        _subjectTypeMeta,
        subjectType.isAcceptableOrUnknown(
          data['subject_type']!,
          _subjectTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subjectTypeMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('effective_to')) {
      context.handle(
        _effectiveToMeta,
        effectiveTo.isAcceptableOrUnknown(
          data['effective_to']!,
          _effectiveToMeta,
        ),
      );
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewStatusMeta);
    }
    if (data.containsKey('is_test_data')) {
      context.handle(
        _isTestDataMeta,
        isTestData.isAcceptableOrUnknown(
          data['is_test_data']!,
          _isTestDataMeta,
        ),
      );
    }
    if (data.containsKey('article_section')) {
      context.handle(
        _articleSectionMeta,
        articleSection.isAcceptableOrUnknown(
          data['article_section']!,
          _articleSectionMeta,
        ),
      );
    }
    if (data.containsKey('topic_key')) {
      context.handle(
        _topicKeyMeta,
        topicKey.isAcceptableOrUnknown(data['topic_key']!, _topicKeyMeta),
      );
    }
    if (data.containsKey('applies_to_json')) {
      context.handle(
        _appliesToJsonMeta,
        appliesToJson.isAcceptableOrUnknown(
          data['applies_to_json']!,
          _appliesToJsonMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ruleId};
  @override
  JurisdictionalRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JurisdictionalRule(
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      ruleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_type'],
      )!,
      subjectType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_type'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_from'],
      )!,
      effectiveTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_to'],
      ),
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      isTestData: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_test_data'],
      )!,
      articleSection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_section'],
      ),
      topicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_key'],
      ),
      appliesToJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applies_to_json'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  JurisdictionalRules createAlias(String alias) {
    return JurisdictionalRules(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'CHECK(effective_to IS NULL OR effective_to > effective_from)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class JurisdictionalRule extends DataClass
    implements Insertable<JurisdictionalRule> {
  final String ruleId;
  final String instrumentId;
  final String ruleType;
  final String subjectType;
  final String subjectId;
  final String valueJson;
  final String effectiveFrom;
  final String? effectiveTo;
  final String reviewStatus;
  final int isTestData;
  final String? articleSection;
  final String? topicKey;
  final String? appliesToJson;
  final int version;
  const JurisdictionalRule({
    required this.ruleId,
    required this.instrumentId,
    required this.ruleType,
    required this.subjectType,
    required this.subjectId,
    required this.valueJson,
    required this.effectiveFrom,
    this.effectiveTo,
    required this.reviewStatus,
    required this.isTestData,
    this.articleSection,
    this.topicKey,
    this.appliesToJson,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['rule_id'] = Variable<String>(ruleId);
    map['instrument_id'] = Variable<String>(instrumentId);
    map['rule_type'] = Variable<String>(ruleType);
    map['subject_type'] = Variable<String>(subjectType);
    map['subject_id'] = Variable<String>(subjectId);
    map['value_json'] = Variable<String>(valueJson);
    map['effective_from'] = Variable<String>(effectiveFrom);
    if (!nullToAbsent || effectiveTo != null) {
      map['effective_to'] = Variable<String>(effectiveTo);
    }
    map['review_status'] = Variable<String>(reviewStatus);
    map['is_test_data'] = Variable<int>(isTestData);
    if (!nullToAbsent || articleSection != null) {
      map['article_section'] = Variable<String>(articleSection);
    }
    if (!nullToAbsent || topicKey != null) {
      map['topic_key'] = Variable<String>(topicKey);
    }
    if (!nullToAbsent || appliesToJson != null) {
      map['applies_to_json'] = Variable<String>(appliesToJson);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  JurisdictionalRulesCompanion toCompanion(bool nullToAbsent) {
    return JurisdictionalRulesCompanion(
      ruleId: Value(ruleId),
      instrumentId: Value(instrumentId),
      ruleType: Value(ruleType),
      subjectType: Value(subjectType),
      subjectId: Value(subjectId),
      valueJson: Value(valueJson),
      effectiveFrom: Value(effectiveFrom),
      effectiveTo: effectiveTo == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveTo),
      reviewStatus: Value(reviewStatus),
      isTestData: Value(isTestData),
      articleSection: articleSection == null && nullToAbsent
          ? const Value.absent()
          : Value(articleSection),
      topicKey: topicKey == null && nullToAbsent
          ? const Value.absent()
          : Value(topicKey),
      appliesToJson: appliesToJson == null && nullToAbsent
          ? const Value.absent()
          : Value(appliesToJson),
      version: Value(version),
    );
  }

  factory JurisdictionalRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JurisdictionalRule(
      ruleId: serializer.fromJson<String>(json['rule_id']),
      instrumentId: serializer.fromJson<String>(json['instrument_id']),
      ruleType: serializer.fromJson<String>(json['rule_type']),
      subjectType: serializer.fromJson<String>(json['subject_type']),
      subjectId: serializer.fromJson<String>(json['subject_id']),
      valueJson: serializer.fromJson<String>(json['value_json']),
      effectiveFrom: serializer.fromJson<String>(json['effective_from']),
      effectiveTo: serializer.fromJson<String?>(json['effective_to']),
      reviewStatus: serializer.fromJson<String>(json['review_status']),
      isTestData: serializer.fromJson<int>(json['is_test_data']),
      articleSection: serializer.fromJson<String?>(json['article_section']),
      topicKey: serializer.fromJson<String?>(json['topic_key']),
      appliesToJson: serializer.fromJson<String?>(json['applies_to_json']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rule_id': serializer.toJson<String>(ruleId),
      'instrument_id': serializer.toJson<String>(instrumentId),
      'rule_type': serializer.toJson<String>(ruleType),
      'subject_type': serializer.toJson<String>(subjectType),
      'subject_id': serializer.toJson<String>(subjectId),
      'value_json': serializer.toJson<String>(valueJson),
      'effective_from': serializer.toJson<String>(effectiveFrom),
      'effective_to': serializer.toJson<String?>(effectiveTo),
      'review_status': serializer.toJson<String>(reviewStatus),
      'is_test_data': serializer.toJson<int>(isTestData),
      'article_section': serializer.toJson<String?>(articleSection),
      'topic_key': serializer.toJson<String?>(topicKey),
      'applies_to_json': serializer.toJson<String?>(appliesToJson),
      'version': serializer.toJson<int>(version),
    };
  }

  JurisdictionalRule copyWith({
    String? ruleId,
    String? instrumentId,
    String? ruleType,
    String? subjectType,
    String? subjectId,
    String? valueJson,
    String? effectiveFrom,
    Value<String?> effectiveTo = const Value.absent(),
    String? reviewStatus,
    int? isTestData,
    Value<String?> articleSection = const Value.absent(),
    Value<String?> topicKey = const Value.absent(),
    Value<String?> appliesToJson = const Value.absent(),
    int? version,
  }) => JurisdictionalRule(
    ruleId: ruleId ?? this.ruleId,
    instrumentId: instrumentId ?? this.instrumentId,
    ruleType: ruleType ?? this.ruleType,
    subjectType: subjectType ?? this.subjectType,
    subjectId: subjectId ?? this.subjectId,
    valueJson: valueJson ?? this.valueJson,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    effectiveTo: effectiveTo.present ? effectiveTo.value : this.effectiveTo,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    isTestData: isTestData ?? this.isTestData,
    articleSection: articleSection.present
        ? articleSection.value
        : this.articleSection,
    topicKey: topicKey.present ? topicKey.value : this.topicKey,
    appliesToJson: appliesToJson.present
        ? appliesToJson.value
        : this.appliesToJson,
    version: version ?? this.version,
  );
  JurisdictionalRule copyWithCompanion(JurisdictionalRulesCompanion data) {
    return JurisdictionalRule(
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      ruleType: data.ruleType.present ? data.ruleType.value : this.ruleType,
      subjectType: data.subjectType.present
          ? data.subjectType.value
          : this.subjectType,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      effectiveTo: data.effectiveTo.present
          ? data.effectiveTo.value
          : this.effectiveTo,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      isTestData: data.isTestData.present
          ? data.isTestData.value
          : this.isTestData,
      articleSection: data.articleSection.present
          ? data.articleSection.value
          : this.articleSection,
      topicKey: data.topicKey.present ? data.topicKey.value : this.topicKey,
      appliesToJson: data.appliesToJson.present
          ? data.appliesToJson.value
          : this.appliesToJson,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JurisdictionalRule(')
          ..write('ruleId: $ruleId, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('ruleType: $ruleType, ')
          ..write('subjectType: $subjectType, ')
          ..write('subjectId: $subjectId, ')
          ..write('valueJson: $valueJson, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('isTestData: $isTestData, ')
          ..write('articleSection: $articleSection, ')
          ..write('topicKey: $topicKey, ')
          ..write('appliesToJson: $appliesToJson, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ruleId,
    instrumentId,
    ruleType,
    subjectType,
    subjectId,
    valueJson,
    effectiveFrom,
    effectiveTo,
    reviewStatus,
    isTestData,
    articleSection,
    topicKey,
    appliesToJson,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JurisdictionalRule &&
          other.ruleId == this.ruleId &&
          other.instrumentId == this.instrumentId &&
          other.ruleType == this.ruleType &&
          other.subjectType == this.subjectType &&
          other.subjectId == this.subjectId &&
          other.valueJson == this.valueJson &&
          other.effectiveFrom == this.effectiveFrom &&
          other.effectiveTo == this.effectiveTo &&
          other.reviewStatus == this.reviewStatus &&
          other.isTestData == this.isTestData &&
          other.articleSection == this.articleSection &&
          other.topicKey == this.topicKey &&
          other.appliesToJson == this.appliesToJson &&
          other.version == this.version);
}

class JurisdictionalRulesCompanion extends UpdateCompanion<JurisdictionalRule> {
  final Value<String> ruleId;
  final Value<String> instrumentId;
  final Value<String> ruleType;
  final Value<String> subjectType;
  final Value<String> subjectId;
  final Value<String> valueJson;
  final Value<String> effectiveFrom;
  final Value<String?> effectiveTo;
  final Value<String> reviewStatus;
  final Value<int> isTestData;
  final Value<String?> articleSection;
  final Value<String?> topicKey;
  final Value<String?> appliesToJson;
  final Value<int> version;
  const JurisdictionalRulesCompanion({
    this.ruleId = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.ruleType = const Value.absent(),
    this.subjectType = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.effectiveTo = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.isTestData = const Value.absent(),
    this.articleSection = const Value.absent(),
    this.topicKey = const Value.absent(),
    this.appliesToJson = const Value.absent(),
    this.version = const Value.absent(),
  });
  JurisdictionalRulesCompanion.insert({
    required String ruleId,
    required String instrumentId,
    required String ruleType,
    required String subjectType,
    required String subjectId,
    required String valueJson,
    required String effectiveFrom,
    this.effectiveTo = const Value.absent(),
    required String reviewStatus,
    this.isTestData = const Value.absent(),
    this.articleSection = const Value.absent(),
    this.topicKey = const Value.absent(),
    this.appliesToJson = const Value.absent(),
    this.version = const Value.absent(),
  }) : ruleId = Value(ruleId),
       instrumentId = Value(instrumentId),
       ruleType = Value(ruleType),
       subjectType = Value(subjectType),
       subjectId = Value(subjectId),
       valueJson = Value(valueJson),
       effectiveFrom = Value(effectiveFrom),
       reviewStatus = Value(reviewStatus);
  static Insertable<JurisdictionalRule> custom({
    Expression<String>? ruleId,
    Expression<String>? instrumentId,
    Expression<String>? ruleType,
    Expression<String>? subjectType,
    Expression<String>? subjectId,
    Expression<String>? valueJson,
    Expression<String>? effectiveFrom,
    Expression<String>? effectiveTo,
    Expression<String>? reviewStatus,
    Expression<int>? isTestData,
    Expression<String>? articleSection,
    Expression<String>? topicKey,
    Expression<String>? appliesToJson,
    Expression<int>? version,
  }) {
    return RawValuesInsertable({
      if (ruleId != null) 'rule_id': ruleId,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (ruleType != null) 'rule_type': ruleType,
      if (subjectType != null) 'subject_type': subjectType,
      if (subjectId != null) 'subject_id': subjectId,
      if (valueJson != null) 'value_json': valueJson,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (effectiveTo != null) 'effective_to': effectiveTo,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (isTestData != null) 'is_test_data': isTestData,
      if (articleSection != null) 'article_section': articleSection,
      if (topicKey != null) 'topic_key': topicKey,
      if (appliesToJson != null) 'applies_to_json': appliesToJson,
      if (version != null) 'version': version,
    });
  }

  JurisdictionalRulesCompanion copyWith({
    Value<String>? ruleId,
    Value<String>? instrumentId,
    Value<String>? ruleType,
    Value<String>? subjectType,
    Value<String>? subjectId,
    Value<String>? valueJson,
    Value<String>? effectiveFrom,
    Value<String?>? effectiveTo,
    Value<String>? reviewStatus,
    Value<int>? isTestData,
    Value<String?>? articleSection,
    Value<String?>? topicKey,
    Value<String?>? appliesToJson,
    Value<int>? version,
  }) {
    return JurisdictionalRulesCompanion(
      ruleId: ruleId ?? this.ruleId,
      instrumentId: instrumentId ?? this.instrumentId,
      ruleType: ruleType ?? this.ruleType,
      subjectType: subjectType ?? this.subjectType,
      subjectId: subjectId ?? this.subjectId,
      valueJson: valueJson ?? this.valueJson,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      isTestData: isTestData ?? this.isTestData,
      articleSection: articleSection ?? this.articleSection,
      topicKey: topicKey ?? this.topicKey,
      appliesToJson: appliesToJson ?? this.appliesToJson,
      version: version ?? this.version,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (ruleType.present) {
      map['rule_type'] = Variable<String>(ruleType.value);
    }
    if (subjectType.present) {
      map['subject_type'] = Variable<String>(subjectType.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<String>(effectiveFrom.value);
    }
    if (effectiveTo.present) {
      map['effective_to'] = Variable<String>(effectiveTo.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (isTestData.present) {
      map['is_test_data'] = Variable<int>(isTestData.value);
    }
    if (articleSection.present) {
      map['article_section'] = Variable<String>(articleSection.value);
    }
    if (topicKey.present) {
      map['topic_key'] = Variable<String>(topicKey.value);
    }
    if (appliesToJson.present) {
      map['applies_to_json'] = Variable<String>(appliesToJson.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JurisdictionalRulesCompanion(')
          ..write('ruleId: $ruleId, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('ruleType: $ruleType, ')
          ..write('subjectType: $subjectType, ')
          ..write('subjectId: $subjectId, ')
          ..write('valueJson: $valueJson, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('isTestData: $isTestData, ')
          ..write('articleSection: $articleSection, ')
          ..write('topicKey: $topicKey, ')
          ..write('appliesToJson: $appliesToJson, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }
}

class KnowledgeEntities extends Table
    with TableInfo<KnowledgeEntities, KnowledgeEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  KnowledgeEntities(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (entity_type IN (\'topic\', \'reagent\', \'screening_test\', \'method\', \'emerging_issue\'))',
  );
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  late final GeneratedColumn<String> area = GeneratedColumn<String>(
    'area',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _subtypeMeta = const VerificationMeta(
    'subtype',
  );
  late final GeneratedColumn<String> subtype = GeneratedColumn<String>(
    'subtype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _namesJsonMeta = const VerificationMeta(
    'namesJson',
  );
  late final GeneratedColumn<String> namesJson = GeneratedColumn<String>(
    'names_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _tierAccessMeta = const VerificationMeta(
    'tierAccess',
  );
  late final GeneratedColumn<String> tierAccess = GeneratedColumn<String>(
    'tier_access',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (tier_access IN (\'free\', \'student\', \'pro\'))',
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (review_status IN (\'DRAFT\', \'VERIFIED\', \'REVIEWED\', \'NEEDS_REVIEW\', \'OUTDATED\', \'REJECTED\'))',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta(
    'jurisdictionId',
  );
  late final GeneratedColumn<String> jurisdictionId = GeneratedColumn<String>(
    'jurisdiction_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES jurisdictions(jurisdiction_id)',
  );
  static const VerificationMeta _organizationMeta = const VerificationMeta(
    'organization',
  );
  late final GeneratedColumn<String> organization = GeneratedColumn<String>(
    'organization',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  late final GeneratedColumn<String> eventDate = GeneratedColumn<String>(
    'event_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'{}\'',
    defaultValue: const CustomExpression('\'{}\''),
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  late final GeneratedColumn<String> contentVersion = GeneratedColumn<String>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _isTestDataMeta = const VerificationMeta(
    'isTestData',
  );
  late final GeneratedColumn<int> isTestData = GeneratedColumn<int>(
    'is_test_data',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityId,
    entityType,
    area,
    subtype,
    namesJson,
    tierAccess,
    reviewStatus,
    version,
    jurisdictionId,
    organization,
    eventDate,
    payloadJson,
    contentVersion,
    isTestData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'knowledge_entities';
  @override
  VerificationContext validateIntegrity(
    Insertable<KnowledgeEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('area')) {
      context.handle(
        _areaMeta,
        area.isAcceptableOrUnknown(data['area']!, _areaMeta),
      );
    } else if (isInserting) {
      context.missing(_areaMeta);
    }
    if (data.containsKey('subtype')) {
      context.handle(
        _subtypeMeta,
        subtype.isAcceptableOrUnknown(data['subtype']!, _subtypeMeta),
      );
    }
    if (data.containsKey('names_json')) {
      context.handle(
        _namesJsonMeta,
        namesJson.isAcceptableOrUnknown(data['names_json']!, _namesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_namesJsonMeta);
    }
    if (data.containsKey('tier_access')) {
      context.handle(
        _tierAccessMeta,
        tierAccess.isAcceptableOrUnknown(data['tier_access']!, _tierAccessMeta),
      );
    } else if (isInserting) {
      context.missing(_tierAccessMeta);
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewStatusMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(
          data['jurisdiction_id']!,
          _jurisdictionIdMeta,
        ),
      );
    }
    if (data.containsKey('organization')) {
      context.handle(
        _organizationMeta,
        organization.isAcceptableOrUnknown(
          data['organization']!,
          _organizationMeta,
        ),
      );
    }
    if (data.containsKey('event_date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentVersionMeta);
    }
    if (data.containsKey('is_test_data')) {
      context.handle(
        _isTestDataMeta,
        isTestData.isAcceptableOrUnknown(
          data['is_test_data']!,
          _isTestDataMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityId};
  @override
  KnowledgeEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KnowledgeEntity(
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      area: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area'],
      )!,
      subtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtype'],
      ),
      namesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}names_json'],
      )!,
      tierAccess: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier_access'],
      )!,
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jurisdiction_id'],
      ),
      organization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization'],
      ),
      eventDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_date'],
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_version'],
      )!,
      isTestData: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_test_data'],
      )!,
    );
  }

  @override
  KnowledgeEntities createAlias(String alias) {
    return KnowledgeEntities(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get dontWriteConstraints => true;
}

class KnowledgeEntity extends DataClass implements Insertable<KnowledgeEntity> {
  final String entityId;
  final String entityType;
  final String area;
  final String? subtype;
  final String namesJson;
  final String tierAccess;
  final String reviewStatus;
  final int version;
  final String? jurisdictionId;
  final String? organization;
  final String? eventDate;
  final String payloadJson;
  final String contentVersion;
  final int isTestData;
  const KnowledgeEntity({
    required this.entityId,
    required this.entityType,
    required this.area,
    this.subtype,
    required this.namesJson,
    required this.tierAccess,
    required this.reviewStatus,
    required this.version,
    this.jurisdictionId,
    this.organization,
    this.eventDate,
    required this.payloadJson,
    required this.contentVersion,
    required this.isTestData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_id'] = Variable<String>(entityId);
    map['entity_type'] = Variable<String>(entityType);
    map['area'] = Variable<String>(area);
    if (!nullToAbsent || subtype != null) {
      map['subtype'] = Variable<String>(subtype);
    }
    map['names_json'] = Variable<String>(namesJson);
    map['tier_access'] = Variable<String>(tierAccess);
    map['review_status'] = Variable<String>(reviewStatus);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || jurisdictionId != null) {
      map['jurisdiction_id'] = Variable<String>(jurisdictionId);
    }
    if (!nullToAbsent || organization != null) {
      map['organization'] = Variable<String>(organization);
    }
    if (!nullToAbsent || eventDate != null) {
      map['event_date'] = Variable<String>(eventDate);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    map['content_version'] = Variable<String>(contentVersion);
    map['is_test_data'] = Variable<int>(isTestData);
    return map;
  }

  KnowledgeEntitiesCompanion toCompanion(bool nullToAbsent) {
    return KnowledgeEntitiesCompanion(
      entityId: Value(entityId),
      entityType: Value(entityType),
      area: Value(area),
      subtype: subtype == null && nullToAbsent
          ? const Value.absent()
          : Value(subtype),
      namesJson: Value(namesJson),
      tierAccess: Value(tierAccess),
      reviewStatus: Value(reviewStatus),
      version: Value(version),
      jurisdictionId: jurisdictionId == null && nullToAbsent
          ? const Value.absent()
          : Value(jurisdictionId),
      organization: organization == null && nullToAbsent
          ? const Value.absent()
          : Value(organization),
      eventDate: eventDate == null && nullToAbsent
          ? const Value.absent()
          : Value(eventDate),
      payloadJson: Value(payloadJson),
      contentVersion: Value(contentVersion),
      isTestData: Value(isTestData),
    );
  }

  factory KnowledgeEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KnowledgeEntity(
      entityId: serializer.fromJson<String>(json['entity_id']),
      entityType: serializer.fromJson<String>(json['entity_type']),
      area: serializer.fromJson<String>(json['area']),
      subtype: serializer.fromJson<String?>(json['subtype']),
      namesJson: serializer.fromJson<String>(json['names_json']),
      tierAccess: serializer.fromJson<String>(json['tier_access']),
      reviewStatus: serializer.fromJson<String>(json['review_status']),
      version: serializer.fromJson<int>(json['version']),
      jurisdictionId: serializer.fromJson<String?>(json['jurisdiction_id']),
      organization: serializer.fromJson<String?>(json['organization']),
      eventDate: serializer.fromJson<String?>(json['event_date']),
      payloadJson: serializer.fromJson<String>(json['payload_json']),
      contentVersion: serializer.fromJson<String>(json['content_version']),
      isTestData: serializer.fromJson<int>(json['is_test_data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity_id': serializer.toJson<String>(entityId),
      'entity_type': serializer.toJson<String>(entityType),
      'area': serializer.toJson<String>(area),
      'subtype': serializer.toJson<String?>(subtype),
      'names_json': serializer.toJson<String>(namesJson),
      'tier_access': serializer.toJson<String>(tierAccess),
      'review_status': serializer.toJson<String>(reviewStatus),
      'version': serializer.toJson<int>(version),
      'jurisdiction_id': serializer.toJson<String?>(jurisdictionId),
      'organization': serializer.toJson<String?>(organization),
      'event_date': serializer.toJson<String?>(eventDate),
      'payload_json': serializer.toJson<String>(payloadJson),
      'content_version': serializer.toJson<String>(contentVersion),
      'is_test_data': serializer.toJson<int>(isTestData),
    };
  }

  KnowledgeEntity copyWith({
    String? entityId,
    String? entityType,
    String? area,
    Value<String?> subtype = const Value.absent(),
    String? namesJson,
    String? tierAccess,
    String? reviewStatus,
    int? version,
    Value<String?> jurisdictionId = const Value.absent(),
    Value<String?> organization = const Value.absent(),
    Value<String?> eventDate = const Value.absent(),
    String? payloadJson,
    String? contentVersion,
    int? isTestData,
  }) => KnowledgeEntity(
    entityId: entityId ?? this.entityId,
    entityType: entityType ?? this.entityType,
    area: area ?? this.area,
    subtype: subtype.present ? subtype.value : this.subtype,
    namesJson: namesJson ?? this.namesJson,
    tierAccess: tierAccess ?? this.tierAccess,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    version: version ?? this.version,
    jurisdictionId: jurisdictionId.present
        ? jurisdictionId.value
        : this.jurisdictionId,
    organization: organization.present ? organization.value : this.organization,
    eventDate: eventDate.present ? eventDate.value : this.eventDate,
    payloadJson: payloadJson ?? this.payloadJson,
    contentVersion: contentVersion ?? this.contentVersion,
    isTestData: isTestData ?? this.isTestData,
  );
  KnowledgeEntity copyWithCompanion(KnowledgeEntitiesCompanion data) {
    return KnowledgeEntity(
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      area: data.area.present ? data.area.value : this.area,
      subtype: data.subtype.present ? data.subtype.value : this.subtype,
      namesJson: data.namesJson.present ? data.namesJson.value : this.namesJson,
      tierAccess: data.tierAccess.present
          ? data.tierAccess.value
          : this.tierAccess,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      version: data.version.present ? data.version.value : this.version,
      jurisdictionId: data.jurisdictionId.present
          ? data.jurisdictionId.value
          : this.jurisdictionId,
      organization: data.organization.present
          ? data.organization.value
          : this.organization,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      isTestData: data.isTestData.present
          ? data.isTestData.value
          : this.isTestData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KnowledgeEntity(')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('area: $area, ')
          ..write('subtype: $subtype, ')
          ..write('namesJson: $namesJson, ')
          ..write('tierAccess: $tierAccess, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('version: $version, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('organization: $organization, ')
          ..write('eventDate: $eventDate, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('isTestData: $isTestData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entityId,
    entityType,
    area,
    subtype,
    namesJson,
    tierAccess,
    reviewStatus,
    version,
    jurisdictionId,
    organization,
    eventDate,
    payloadJson,
    contentVersion,
    isTestData,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KnowledgeEntity &&
          other.entityId == this.entityId &&
          other.entityType == this.entityType &&
          other.area == this.area &&
          other.subtype == this.subtype &&
          other.namesJson == this.namesJson &&
          other.tierAccess == this.tierAccess &&
          other.reviewStatus == this.reviewStatus &&
          other.version == this.version &&
          other.jurisdictionId == this.jurisdictionId &&
          other.organization == this.organization &&
          other.eventDate == this.eventDate &&
          other.payloadJson == this.payloadJson &&
          other.contentVersion == this.contentVersion &&
          other.isTestData == this.isTestData);
}

class KnowledgeEntitiesCompanion extends UpdateCompanion<KnowledgeEntity> {
  final Value<String> entityId;
  final Value<String> entityType;
  final Value<String> area;
  final Value<String?> subtype;
  final Value<String> namesJson;
  final Value<String> tierAccess;
  final Value<String> reviewStatus;
  final Value<int> version;
  final Value<String?> jurisdictionId;
  final Value<String?> organization;
  final Value<String?> eventDate;
  final Value<String> payloadJson;
  final Value<String> contentVersion;
  final Value<int> isTestData;
  const KnowledgeEntitiesCompanion({
    this.entityId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.area = const Value.absent(),
    this.subtype = const Value.absent(),
    this.namesJson = const Value.absent(),
    this.tierAccess = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.version = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.organization = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.isTestData = const Value.absent(),
  });
  KnowledgeEntitiesCompanion.insert({
    required String entityId,
    required String entityType,
    required String area,
    this.subtype = const Value.absent(),
    required String namesJson,
    required String tierAccess,
    required String reviewStatus,
    this.version = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.organization = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.payloadJson = const Value.absent(),
    required String contentVersion,
    this.isTestData = const Value.absent(),
  }) : entityId = Value(entityId),
       entityType = Value(entityType),
       area = Value(area),
       namesJson = Value(namesJson),
       tierAccess = Value(tierAccess),
       reviewStatus = Value(reviewStatus),
       contentVersion = Value(contentVersion);
  static Insertable<KnowledgeEntity> custom({
    Expression<String>? entityId,
    Expression<String>? entityType,
    Expression<String>? area,
    Expression<String>? subtype,
    Expression<String>? namesJson,
    Expression<String>? tierAccess,
    Expression<String>? reviewStatus,
    Expression<int>? version,
    Expression<String>? jurisdictionId,
    Expression<String>? organization,
    Expression<String>? eventDate,
    Expression<String>? payloadJson,
    Expression<String>? contentVersion,
    Expression<int>? isTestData,
  }) {
    return RawValuesInsertable({
      if (entityId != null) 'entity_id': entityId,
      if (entityType != null) 'entity_type': entityType,
      if (area != null) 'area': area,
      if (subtype != null) 'subtype': subtype,
      if (namesJson != null) 'names_json': namesJson,
      if (tierAccess != null) 'tier_access': tierAccess,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (version != null) 'version': version,
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (organization != null) 'organization': organization,
      if (eventDate != null) 'event_date': eventDate,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (contentVersion != null) 'content_version': contentVersion,
      if (isTestData != null) 'is_test_data': isTestData,
    });
  }

  KnowledgeEntitiesCompanion copyWith({
    Value<String>? entityId,
    Value<String>? entityType,
    Value<String>? area,
    Value<String?>? subtype,
    Value<String>? namesJson,
    Value<String>? tierAccess,
    Value<String>? reviewStatus,
    Value<int>? version,
    Value<String?>? jurisdictionId,
    Value<String?>? organization,
    Value<String?>? eventDate,
    Value<String>? payloadJson,
    Value<String>? contentVersion,
    Value<int>? isTestData,
  }) {
    return KnowledgeEntitiesCompanion(
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      area: area ?? this.area,
      subtype: subtype ?? this.subtype,
      namesJson: namesJson ?? this.namesJson,
      tierAccess: tierAccess ?? this.tierAccess,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      version: version ?? this.version,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      organization: organization ?? this.organization,
      eventDate: eventDate ?? this.eventDate,
      payloadJson: payloadJson ?? this.payloadJson,
      contentVersion: contentVersion ?? this.contentVersion,
      isTestData: isTestData ?? this.isTestData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (area.present) {
      map['area'] = Variable<String>(area.value);
    }
    if (subtype.present) {
      map['subtype'] = Variable<String>(subtype.value);
    }
    if (namesJson.present) {
      map['names_json'] = Variable<String>(namesJson.value);
    }
    if (tierAccess.present) {
      map['tier_access'] = Variable<String>(tierAccess.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<String>(jurisdictionId.value);
    }
    if (organization.present) {
      map['organization'] = Variable<String>(organization.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<String>(eventDate.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<String>(contentVersion.value);
    }
    if (isTestData.present) {
      map['is_test_data'] = Variable<int>(isTestData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KnowledgeEntitiesCompanion(')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('area: $area, ')
          ..write('subtype: $subtype, ')
          ..write('namesJson: $namesJson, ')
          ..write('tierAccess: $tierAccess, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('version: $version, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('organization: $organization, ')
          ..write('eventDate: $eventDate, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('isTestData: $isTestData')
          ..write(')'))
        .toString();
  }
}

class EntitySources extends Table with TableInfo<EntitySources, EntitySource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  EntitySources(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES knowledge_entities(entity_id)',
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES sources(source_id)',
  );
  static const VerificationMeta _locatorMeta = const VerificationMeta(
    'locator',
  );
  late final GeneratedColumn<String> locator = GeneratedColumn<String>(
    'locator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [entityId, sourceId, locator];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitySource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('locator')) {
      context.handle(
        _locatorMeta,
        locator.isAcceptableOrUnknown(data['locator']!, _locatorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityId, sourceId};
  @override
  EntitySource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitySource(
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      locator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator'],
      ),
    );
  }

  @override
  EntitySources createAlias(String alias) {
    return EntitySources(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(entity_id, source_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class EntitySource extends DataClass implements Insertable<EntitySource> {
  final String entityId;
  final String sourceId;
  final String? locator;
  const EntitySource({
    required this.entityId,
    required this.sourceId,
    this.locator,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_id'] = Variable<String>(entityId);
    map['source_id'] = Variable<String>(sourceId);
    if (!nullToAbsent || locator != null) {
      map['locator'] = Variable<String>(locator);
    }
    return map;
  }

  EntitySourcesCompanion toCompanion(bool nullToAbsent) {
    return EntitySourcesCompanion(
      entityId: Value(entityId),
      sourceId: Value(sourceId),
      locator: locator == null && nullToAbsent
          ? const Value.absent()
          : Value(locator),
    );
  }

  factory EntitySource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitySource(
      entityId: serializer.fromJson<String>(json['entity_id']),
      sourceId: serializer.fromJson<String>(json['source_id']),
      locator: serializer.fromJson<String?>(json['locator']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity_id': serializer.toJson<String>(entityId),
      'source_id': serializer.toJson<String>(sourceId),
      'locator': serializer.toJson<String?>(locator),
    };
  }

  EntitySource copyWith({
    String? entityId,
    String? sourceId,
    Value<String?> locator = const Value.absent(),
  }) => EntitySource(
    entityId: entityId ?? this.entityId,
    sourceId: sourceId ?? this.sourceId,
    locator: locator.present ? locator.value : this.locator,
  );
  EntitySource copyWithCompanion(EntitySourcesCompanion data) {
    return EntitySource(
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      locator: data.locator.present ? data.locator.value : this.locator,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitySource(')
          ..write('entityId: $entityId, ')
          ..write('sourceId: $sourceId, ')
          ..write('locator: $locator')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityId, sourceId, locator);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitySource &&
          other.entityId == this.entityId &&
          other.sourceId == this.sourceId &&
          other.locator == this.locator);
}

class EntitySourcesCompanion extends UpdateCompanion<EntitySource> {
  final Value<String> entityId;
  final Value<String> sourceId;
  final Value<String?> locator;
  const EntitySourcesCompanion({
    this.entityId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.locator = const Value.absent(),
  });
  EntitySourcesCompanion.insert({
    required String entityId,
    required String sourceId,
    this.locator = const Value.absent(),
  }) : entityId = Value(entityId),
       sourceId = Value(sourceId);
  static Insertable<EntitySource> custom({
    Expression<String>? entityId,
    Expression<String>? sourceId,
    Expression<String>? locator,
  }) {
    return RawValuesInsertable({
      if (entityId != null) 'entity_id': entityId,
      if (sourceId != null) 'source_id': sourceId,
      if (locator != null) 'locator': locator,
    });
  }

  EntitySourcesCompanion copyWith({
    Value<String>? entityId,
    Value<String>? sourceId,
    Value<String?>? locator,
  }) {
    return EntitySourcesCompanion(
      entityId: entityId ?? this.entityId,
      sourceId: sourceId ?? this.sourceId,
      locator: locator ?? this.locator,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (locator.present) {
      map['locator'] = Variable<String>(locator.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntitySourcesCompanion(')
          ..write('entityId: $entityId, ')
          ..write('sourceId: $sourceId, ')
          ..write('locator: $locator')
          ..write(')'))
        .toString();
  }
}

class ClaimGroups extends Table with TableInfo<ClaimGroups, ClaimGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ClaimGroups(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _contextKeyMeta = const VerificationMeta(
    'contextKey',
  );
  late final GeneratedColumn<String> contextKey = GeneratedColumn<String>(
    'context_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _conflictStateMeta = const VerificationMeta(
    'conflictState',
  );
  late final GeneratedColumn<String> conflictState = GeneratedColumn<String>(
    'conflict_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (conflict_state IN (\'consistent\', \'minor_difference\', \'conflict\', \'unresolved\'))',
  );
  static const VerificationMeta _editorialNoteMeta = const VerificationMeta(
    'editorialNote',
  );
  late final GeneratedColumn<String> editorialNote = GeneratedColumn<String>(
    'editorial_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _displayPolicyMeta = const VerificationMeta(
    'displayPolicy',
  );
  late final GeneratedColumn<String> displayPolicy = GeneratedColumn<String>(
    'display_policy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'show_all\'',
    defaultValue: const CustomExpression('\'show_all\''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    groupId,
    entityType,
    entityId,
    field,
    contextKey,
    conflictState,
    editorialNote,
    displayPolicy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'claim_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClaimGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('context_key')) {
      context.handle(
        _contextKeyMeta,
        contextKey.isAcceptableOrUnknown(data['context_key']!, _contextKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_contextKeyMeta);
    }
    if (data.containsKey('conflict_state')) {
      context.handle(
        _conflictStateMeta,
        conflictState.isAcceptableOrUnknown(
          data['conflict_state']!,
          _conflictStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conflictStateMeta);
    }
    if (data.containsKey('editorial_note')) {
      context.handle(
        _editorialNoteMeta,
        editorialNote.isAcceptableOrUnknown(
          data['editorial_note']!,
          _editorialNoteMeta,
        ),
      );
    }
    if (data.containsKey('display_policy')) {
      context.handle(
        _displayPolicyMeta,
        displayPolicy.isAcceptableOrUnknown(
          data['display_policy']!,
          _displayPolicyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId};
  @override
  ClaimGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClaimGroup(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      contextKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_key'],
      )!,
      conflictState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_state'],
      )!,
      editorialNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}editorial_note'],
      ),
      displayPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_policy'],
      )!,
    );
  }

  @override
  ClaimGroups createAlias(String alias) {
    return ClaimGroups(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get dontWriteConstraints => true;
}

class ClaimGroup extends DataClass implements Insertable<ClaimGroup> {
  final String groupId;
  final String entityType;
  final String entityId;
  final String field;
  final String contextKey;
  final String conflictState;
  final String? editorialNote;
  final String displayPolicy;
  const ClaimGroup({
    required this.groupId,
    required this.entityType,
    required this.entityId,
    required this.field,
    required this.contextKey,
    required this.conflictState,
    this.editorialNote,
    required this.displayPolicy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['field'] = Variable<String>(field);
    map['context_key'] = Variable<String>(contextKey);
    map['conflict_state'] = Variable<String>(conflictState);
    if (!nullToAbsent || editorialNote != null) {
      map['editorial_note'] = Variable<String>(editorialNote);
    }
    map['display_policy'] = Variable<String>(displayPolicy);
    return map;
  }

  ClaimGroupsCompanion toCompanion(bool nullToAbsent) {
    return ClaimGroupsCompanion(
      groupId: Value(groupId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      field: Value(field),
      contextKey: Value(contextKey),
      conflictState: Value(conflictState),
      editorialNote: editorialNote == null && nullToAbsent
          ? const Value.absent()
          : Value(editorialNote),
      displayPolicy: Value(displayPolicy),
    );
  }

  factory ClaimGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClaimGroup(
      groupId: serializer.fromJson<String>(json['group_id']),
      entityType: serializer.fromJson<String>(json['entity_type']),
      entityId: serializer.fromJson<String>(json['entity_id']),
      field: serializer.fromJson<String>(json['field']),
      contextKey: serializer.fromJson<String>(json['context_key']),
      conflictState: serializer.fromJson<String>(json['conflict_state']),
      editorialNote: serializer.fromJson<String?>(json['editorial_note']),
      displayPolicy: serializer.fromJson<String>(json['display_policy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'group_id': serializer.toJson<String>(groupId),
      'entity_type': serializer.toJson<String>(entityType),
      'entity_id': serializer.toJson<String>(entityId),
      'field': serializer.toJson<String>(field),
      'context_key': serializer.toJson<String>(contextKey),
      'conflict_state': serializer.toJson<String>(conflictState),
      'editorial_note': serializer.toJson<String?>(editorialNote),
      'display_policy': serializer.toJson<String>(displayPolicy),
    };
  }

  ClaimGroup copyWith({
    String? groupId,
    String? entityType,
    String? entityId,
    String? field,
    String? contextKey,
    String? conflictState,
    Value<String?> editorialNote = const Value.absent(),
    String? displayPolicy,
  }) => ClaimGroup(
    groupId: groupId ?? this.groupId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    field: field ?? this.field,
    contextKey: contextKey ?? this.contextKey,
    conflictState: conflictState ?? this.conflictState,
    editorialNote: editorialNote.present
        ? editorialNote.value
        : this.editorialNote,
    displayPolicy: displayPolicy ?? this.displayPolicy,
  );
  ClaimGroup copyWithCompanion(ClaimGroupsCompanion data) {
    return ClaimGroup(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      field: data.field.present ? data.field.value : this.field,
      contextKey: data.contextKey.present
          ? data.contextKey.value
          : this.contextKey,
      conflictState: data.conflictState.present
          ? data.conflictState.value
          : this.conflictState,
      editorialNote: data.editorialNote.present
          ? data.editorialNote.value
          : this.editorialNote,
      displayPolicy: data.displayPolicy.present
          ? data.displayPolicy.value
          : this.displayPolicy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClaimGroup(')
          ..write('groupId: $groupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('contextKey: $contextKey, ')
          ..write('conflictState: $conflictState, ')
          ..write('editorialNote: $editorialNote, ')
          ..write('displayPolicy: $displayPolicy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    groupId,
    entityType,
    entityId,
    field,
    contextKey,
    conflictState,
    editorialNote,
    displayPolicy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClaimGroup &&
          other.groupId == this.groupId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.field == this.field &&
          other.contextKey == this.contextKey &&
          other.conflictState == this.conflictState &&
          other.editorialNote == this.editorialNote &&
          other.displayPolicy == this.displayPolicy);
}

class ClaimGroupsCompanion extends UpdateCompanion<ClaimGroup> {
  final Value<String> groupId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> field;
  final Value<String> contextKey;
  final Value<String> conflictState;
  final Value<String?> editorialNote;
  final Value<String> displayPolicy;
  const ClaimGroupsCompanion({
    this.groupId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.field = const Value.absent(),
    this.contextKey = const Value.absent(),
    this.conflictState = const Value.absent(),
    this.editorialNote = const Value.absent(),
    this.displayPolicy = const Value.absent(),
  });
  ClaimGroupsCompanion.insert({
    required String groupId,
    required String entityType,
    required String entityId,
    required String field,
    required String contextKey,
    required String conflictState,
    this.editorialNote = const Value.absent(),
    this.displayPolicy = const Value.absent(),
  }) : groupId = Value(groupId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       field = Value(field),
       contextKey = Value(contextKey),
       conflictState = Value(conflictState);
  static Insertable<ClaimGroup> custom({
    Expression<String>? groupId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? field,
    Expression<String>? contextKey,
    Expression<String>? conflictState,
    Expression<String>? editorialNote,
    Expression<String>? displayPolicy,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (field != null) 'field': field,
      if (contextKey != null) 'context_key': contextKey,
      if (conflictState != null) 'conflict_state': conflictState,
      if (editorialNote != null) 'editorial_note': editorialNote,
      if (displayPolicy != null) 'display_policy': displayPolicy,
    });
  }

  ClaimGroupsCompanion copyWith({
    Value<String>? groupId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? field,
    Value<String>? contextKey,
    Value<String>? conflictState,
    Value<String?>? editorialNote,
    Value<String>? displayPolicy,
  }) {
    return ClaimGroupsCompanion(
      groupId: groupId ?? this.groupId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      field: field ?? this.field,
      contextKey: contextKey ?? this.contextKey,
      conflictState: conflictState ?? this.conflictState,
      editorialNote: editorialNote ?? this.editorialNote,
      displayPolicy: displayPolicy ?? this.displayPolicy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (contextKey.present) {
      map['context_key'] = Variable<String>(contextKey.value);
    }
    if (conflictState.present) {
      map['conflict_state'] = Variable<String>(conflictState.value);
    }
    if (editorialNote.present) {
      map['editorial_note'] = Variable<String>(editorialNote.value);
    }
    if (displayPolicy.present) {
      map['display_policy'] = Variable<String>(displayPolicy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClaimGroupsCompanion(')
          ..write('groupId: $groupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('contextKey: $contextKey, ')
          ..write('conflictState: $conflictState, ')
          ..write('editorialNote: $editorialNote, ')
          ..write('displayPolicy: $displayPolicy')
          ..write(')'))
        .toString();
  }
}

class Claims extends Table with TableInfo<Claims, Claim> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Claims(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _claimIdMeta = const VerificationMeta(
    'claimId',
  );
  late final GeneratedColumn<String> claimId = GeneratedColumn<String>(
    'claim_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (domain IN (\'tox\', \'fm\', \'lab\', \'legal\', \'edu\', \'i18n\'))',
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (review_status IN (\'DRAFT\', \'VERIFIED\', \'REVIEWED\', \'NEEDS_REVIEW\', \'OUTDATED\', \'REJECTED\'))',
  );
  static const VerificationMeta _evidenceLevelMeta = const VerificationMeta(
    'evidenceLevel',
  );
  late final GeneratedColumn<String> evidenceLevel = GeneratedColumn<String>(
    'evidence_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES claim_groups(group_id)',
  );
  static const VerificationMeta _preferredMeta = const VerificationMeta(
    'preferred',
  );
  late final GeneratedColumn<int> preferred = GeneratedColumn<int>(
    'preferred',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _preferenceReasonMeta = const VerificationMeta(
    'preferenceReason',
  );
  late final GeneratedColumn<String> preferenceReason = GeneratedColumn<String>(
    'preference_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _isTestDataMeta = const VerificationMeta(
    'isTestData',
  );
  late final GeneratedColumn<int> isTestData = GeneratedColumn<int>(
    'is_test_data',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _knowledgeLayerMeta = const VerificationMeta(
    'knowledgeLayer',
  );
  late final GeneratedColumn<String> knowledgeLayer = GeneratedColumn<String>(
    'knowledge_layer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'international_scientific\' CHECK (knowledge_layer IN (\'international_scientific\', \'international_standard\', \'jurisdictional\'))',
    defaultValue: const CustomExpression('\'international_scientific\''),
  );
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta(
    'jurisdictionId',
  );
  late final GeneratedColumn<String> jurisdictionId = GeneratedColumn<String>(
    'jurisdiction_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES jurisdictions(jurisdiction_id)',
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES jurisdictional_instruments(instrument_id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    claimId,
    entityType,
    entityId,
    field,
    valueJson,
    domain,
    reviewStatus,
    evidenceLevel,
    groupId,
    preferred,
    preferenceReason,
    version,
    updatedAt,
    isTestData,
    knowledgeLayer,
    jurisdictionId,
    instrumentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'claims';
  @override
  VerificationContext validateIntegrity(
    Insertable<Claim> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('claim_id')) {
      context.handle(
        _claimIdMeta,
        claimId.isAcceptableOrUnknown(data['claim_id']!, _claimIdMeta),
      );
    } else if (isInserting) {
      context.missing(_claimIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewStatusMeta);
    }
    if (data.containsKey('evidence_level')) {
      context.handle(
        _evidenceLevelMeta,
        evidenceLevel.isAcceptableOrUnknown(
          data['evidence_level']!,
          _evidenceLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_evidenceLevelMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('preferred')) {
      context.handle(
        _preferredMeta,
        preferred.isAcceptableOrUnknown(data['preferred']!, _preferredMeta),
      );
    }
    if (data.containsKey('preference_reason')) {
      context.handle(
        _preferenceReasonMeta,
        preferenceReason.isAcceptableOrUnknown(
          data['preference_reason']!,
          _preferenceReasonMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_test_data')) {
      context.handle(
        _isTestDataMeta,
        isTestData.isAcceptableOrUnknown(
          data['is_test_data']!,
          _isTestDataMeta,
        ),
      );
    }
    if (data.containsKey('knowledge_layer')) {
      context.handle(
        _knowledgeLayerMeta,
        knowledgeLayer.isAcceptableOrUnknown(
          data['knowledge_layer']!,
          _knowledgeLayerMeta,
        ),
      );
    }
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(
          data['jurisdiction_id']!,
          _jurisdictionIdMeta,
        ),
      );
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {claimId};
  @override
  Claim map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Claim(
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      evidenceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_level'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      preferred: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preferred'],
      )!,
      preferenceReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preference_reason'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      isTestData: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_test_data'],
      )!,
      knowledgeLayer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}knowledge_layer'],
      )!,
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jurisdiction_id'],
      ),
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      ),
    );
  }

  @override
  Claims createAlias(String alias) {
    return Claims(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'CHECK(preferred = 0 OR preference_reason IS NOT NULL)',
    'CHECK((knowledge_layer = \'jurisdictional\' AND jurisdiction_id IS NOT NULL AND instrument_id IS NOT NULL)OR(knowledge_layer <> \'jurisdictional\' AND jurisdiction_id IS NULL AND instrument_id IS NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Claim extends DataClass implements Insertable<Claim> {
  final String claimId;
  final String entityType;
  final String entityId;
  final String field;
  final String valueJson;
  final String domain;
  final String reviewStatus;
  final String evidenceLevel;
  final String? groupId;
  final int preferred;
  final String? preferenceReason;
  final int version;
  final String updatedAt;
  final int isTestData;

  /// Global Scientific Core + Jurisdiction Layer (schema_version = 2).
  final String knowledgeLayer;
  final String? jurisdictionId;
  final String? instrumentId;
  const Claim({
    required this.claimId,
    required this.entityType,
    required this.entityId,
    required this.field,
    required this.valueJson,
    required this.domain,
    required this.reviewStatus,
    required this.evidenceLevel,
    this.groupId,
    required this.preferred,
    this.preferenceReason,
    required this.version,
    required this.updatedAt,
    required this.isTestData,
    required this.knowledgeLayer,
    this.jurisdictionId,
    this.instrumentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['claim_id'] = Variable<String>(claimId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['field'] = Variable<String>(field);
    map['value_json'] = Variable<String>(valueJson);
    map['domain'] = Variable<String>(domain);
    map['review_status'] = Variable<String>(reviewStatus);
    map['evidence_level'] = Variable<String>(evidenceLevel);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['preferred'] = Variable<int>(preferred);
    if (!nullToAbsent || preferenceReason != null) {
      map['preference_reason'] = Variable<String>(preferenceReason);
    }
    map['version'] = Variable<int>(version);
    map['updated_at'] = Variable<String>(updatedAt);
    map['is_test_data'] = Variable<int>(isTestData);
    map['knowledge_layer'] = Variable<String>(knowledgeLayer);
    if (!nullToAbsent || jurisdictionId != null) {
      map['jurisdiction_id'] = Variable<String>(jurisdictionId);
    }
    if (!nullToAbsent || instrumentId != null) {
      map['instrument_id'] = Variable<String>(instrumentId);
    }
    return map;
  }

  ClaimsCompanion toCompanion(bool nullToAbsent) {
    return ClaimsCompanion(
      claimId: Value(claimId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      field: Value(field),
      valueJson: Value(valueJson),
      domain: Value(domain),
      reviewStatus: Value(reviewStatus),
      evidenceLevel: Value(evidenceLevel),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      preferred: Value(preferred),
      preferenceReason: preferenceReason == null && nullToAbsent
          ? const Value.absent()
          : Value(preferenceReason),
      version: Value(version),
      updatedAt: Value(updatedAt),
      isTestData: Value(isTestData),
      knowledgeLayer: Value(knowledgeLayer),
      jurisdictionId: jurisdictionId == null && nullToAbsent
          ? const Value.absent()
          : Value(jurisdictionId),
      instrumentId: instrumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(instrumentId),
    );
  }

  factory Claim.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Claim(
      claimId: serializer.fromJson<String>(json['claim_id']),
      entityType: serializer.fromJson<String>(json['entity_type']),
      entityId: serializer.fromJson<String>(json['entity_id']),
      field: serializer.fromJson<String>(json['field']),
      valueJson: serializer.fromJson<String>(json['value_json']),
      domain: serializer.fromJson<String>(json['domain']),
      reviewStatus: serializer.fromJson<String>(json['review_status']),
      evidenceLevel: serializer.fromJson<String>(json['evidence_level']),
      groupId: serializer.fromJson<String?>(json['group_id']),
      preferred: serializer.fromJson<int>(json['preferred']),
      preferenceReason: serializer.fromJson<String?>(json['preference_reason']),
      version: serializer.fromJson<int>(json['version']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      isTestData: serializer.fromJson<int>(json['is_test_data']),
      knowledgeLayer: serializer.fromJson<String>(json['knowledge_layer']),
      jurisdictionId: serializer.fromJson<String?>(json['jurisdiction_id']),
      instrumentId: serializer.fromJson<String?>(json['instrument_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'claim_id': serializer.toJson<String>(claimId),
      'entity_type': serializer.toJson<String>(entityType),
      'entity_id': serializer.toJson<String>(entityId),
      'field': serializer.toJson<String>(field),
      'value_json': serializer.toJson<String>(valueJson),
      'domain': serializer.toJson<String>(domain),
      'review_status': serializer.toJson<String>(reviewStatus),
      'evidence_level': serializer.toJson<String>(evidenceLevel),
      'group_id': serializer.toJson<String?>(groupId),
      'preferred': serializer.toJson<int>(preferred),
      'preference_reason': serializer.toJson<String?>(preferenceReason),
      'version': serializer.toJson<int>(version),
      'updated_at': serializer.toJson<String>(updatedAt),
      'is_test_data': serializer.toJson<int>(isTestData),
      'knowledge_layer': serializer.toJson<String>(knowledgeLayer),
      'jurisdiction_id': serializer.toJson<String?>(jurisdictionId),
      'instrument_id': serializer.toJson<String?>(instrumentId),
    };
  }

  Claim copyWith({
    String? claimId,
    String? entityType,
    String? entityId,
    String? field,
    String? valueJson,
    String? domain,
    String? reviewStatus,
    String? evidenceLevel,
    Value<String?> groupId = const Value.absent(),
    int? preferred,
    Value<String?> preferenceReason = const Value.absent(),
    int? version,
    String? updatedAt,
    int? isTestData,
    String? knowledgeLayer,
    Value<String?> jurisdictionId = const Value.absent(),
    Value<String?> instrumentId = const Value.absent(),
  }) => Claim(
    claimId: claimId ?? this.claimId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    field: field ?? this.field,
    valueJson: valueJson ?? this.valueJson,
    domain: domain ?? this.domain,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    evidenceLevel: evidenceLevel ?? this.evidenceLevel,
    groupId: groupId.present ? groupId.value : this.groupId,
    preferred: preferred ?? this.preferred,
    preferenceReason: preferenceReason.present
        ? preferenceReason.value
        : this.preferenceReason,
    version: version ?? this.version,
    updatedAt: updatedAt ?? this.updatedAt,
    isTestData: isTestData ?? this.isTestData,
    knowledgeLayer: knowledgeLayer ?? this.knowledgeLayer,
    jurisdictionId: jurisdictionId.present
        ? jurisdictionId.value
        : this.jurisdictionId,
    instrumentId: instrumentId.present ? instrumentId.value : this.instrumentId,
  );
  Claim copyWithCompanion(ClaimsCompanion data) {
    return Claim(
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      field: data.field.present ? data.field.value : this.field,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      domain: data.domain.present ? data.domain.value : this.domain,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      evidenceLevel: data.evidenceLevel.present
          ? data.evidenceLevel.value
          : this.evidenceLevel,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      preferred: data.preferred.present ? data.preferred.value : this.preferred,
      preferenceReason: data.preferenceReason.present
          ? data.preferenceReason.value
          : this.preferenceReason,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isTestData: data.isTestData.present
          ? data.isTestData.value
          : this.isTestData,
      knowledgeLayer: data.knowledgeLayer.present
          ? data.knowledgeLayer.value
          : this.knowledgeLayer,
      jurisdictionId: data.jurisdictionId.present
          ? data.jurisdictionId.value
          : this.jurisdictionId,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Claim(')
          ..write('claimId: $claimId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('valueJson: $valueJson, ')
          ..write('domain: $domain, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('evidenceLevel: $evidenceLevel, ')
          ..write('groupId: $groupId, ')
          ..write('preferred: $preferred, ')
          ..write('preferenceReason: $preferenceReason, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isTestData: $isTestData, ')
          ..write('knowledgeLayer: $knowledgeLayer, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('instrumentId: $instrumentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    claimId,
    entityType,
    entityId,
    field,
    valueJson,
    domain,
    reviewStatus,
    evidenceLevel,
    groupId,
    preferred,
    preferenceReason,
    version,
    updatedAt,
    isTestData,
    knowledgeLayer,
    jurisdictionId,
    instrumentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Claim &&
          other.claimId == this.claimId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.field == this.field &&
          other.valueJson == this.valueJson &&
          other.domain == this.domain &&
          other.reviewStatus == this.reviewStatus &&
          other.evidenceLevel == this.evidenceLevel &&
          other.groupId == this.groupId &&
          other.preferred == this.preferred &&
          other.preferenceReason == this.preferenceReason &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt &&
          other.isTestData == this.isTestData &&
          other.knowledgeLayer == this.knowledgeLayer &&
          other.jurisdictionId == this.jurisdictionId &&
          other.instrumentId == this.instrumentId);
}

class ClaimsCompanion extends UpdateCompanion<Claim> {
  final Value<String> claimId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> field;
  final Value<String> valueJson;
  final Value<String> domain;
  final Value<String> reviewStatus;
  final Value<String> evidenceLevel;
  final Value<String?> groupId;
  final Value<int> preferred;
  final Value<String?> preferenceReason;
  final Value<int> version;
  final Value<String> updatedAt;
  final Value<int> isTestData;
  final Value<String> knowledgeLayer;
  final Value<String?> jurisdictionId;
  final Value<String?> instrumentId;
  const ClaimsCompanion({
    this.claimId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.field = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.domain = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.evidenceLevel = const Value.absent(),
    this.groupId = const Value.absent(),
    this.preferred = const Value.absent(),
    this.preferenceReason = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isTestData = const Value.absent(),
    this.knowledgeLayer = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.instrumentId = const Value.absent(),
  });
  ClaimsCompanion.insert({
    required String claimId,
    required String entityType,
    required String entityId,
    required String field,
    required String valueJson,
    required String domain,
    required String reviewStatus,
    required String evidenceLevel,
    this.groupId = const Value.absent(),
    this.preferred = const Value.absent(),
    this.preferenceReason = const Value.absent(),
    this.version = const Value.absent(),
    required String updatedAt,
    this.isTestData = const Value.absent(),
    this.knowledgeLayer = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.instrumentId = const Value.absent(),
  }) : claimId = Value(claimId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       field = Value(field),
       valueJson = Value(valueJson),
       domain = Value(domain),
       reviewStatus = Value(reviewStatus),
       evidenceLevel = Value(evidenceLevel),
       updatedAt = Value(updatedAt);
  static Insertable<Claim> custom({
    Expression<String>? claimId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? field,
    Expression<String>? valueJson,
    Expression<String>? domain,
    Expression<String>? reviewStatus,
    Expression<String>? evidenceLevel,
    Expression<String>? groupId,
    Expression<int>? preferred,
    Expression<String>? preferenceReason,
    Expression<int>? version,
    Expression<String>? updatedAt,
    Expression<int>? isTestData,
    Expression<String>? knowledgeLayer,
    Expression<String>? jurisdictionId,
    Expression<String>? instrumentId,
  }) {
    return RawValuesInsertable({
      if (claimId != null) 'claim_id': claimId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (field != null) 'field': field,
      if (valueJson != null) 'value_json': valueJson,
      if (domain != null) 'domain': domain,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (evidenceLevel != null) 'evidence_level': evidenceLevel,
      if (groupId != null) 'group_id': groupId,
      if (preferred != null) 'preferred': preferred,
      if (preferenceReason != null) 'preference_reason': preferenceReason,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isTestData != null) 'is_test_data': isTestData,
      if (knowledgeLayer != null) 'knowledge_layer': knowledgeLayer,
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (instrumentId != null) 'instrument_id': instrumentId,
    });
  }

  ClaimsCompanion copyWith({
    Value<String>? claimId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? field,
    Value<String>? valueJson,
    Value<String>? domain,
    Value<String>? reviewStatus,
    Value<String>? evidenceLevel,
    Value<String?>? groupId,
    Value<int>? preferred,
    Value<String?>? preferenceReason,
    Value<int>? version,
    Value<String>? updatedAt,
    Value<int>? isTestData,
    Value<String>? knowledgeLayer,
    Value<String?>? jurisdictionId,
    Value<String?>? instrumentId,
  }) {
    return ClaimsCompanion(
      claimId: claimId ?? this.claimId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      field: field ?? this.field,
      valueJson: valueJson ?? this.valueJson,
      domain: domain ?? this.domain,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      evidenceLevel: evidenceLevel ?? this.evidenceLevel,
      groupId: groupId ?? this.groupId,
      preferred: preferred ?? this.preferred,
      preferenceReason: preferenceReason ?? this.preferenceReason,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      isTestData: isTestData ?? this.isTestData,
      knowledgeLayer: knowledgeLayer ?? this.knowledgeLayer,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      instrumentId: instrumentId ?? this.instrumentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (claimId.present) {
      map['claim_id'] = Variable<String>(claimId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (evidenceLevel.present) {
      map['evidence_level'] = Variable<String>(evidenceLevel.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (preferred.present) {
      map['preferred'] = Variable<int>(preferred.value);
    }
    if (preferenceReason.present) {
      map['preference_reason'] = Variable<String>(preferenceReason.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (isTestData.present) {
      map['is_test_data'] = Variable<int>(isTestData.value);
    }
    if (knowledgeLayer.present) {
      map['knowledge_layer'] = Variable<String>(knowledgeLayer.value);
    }
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<String>(jurisdictionId.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClaimsCompanion(')
          ..write('claimId: $claimId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('valueJson: $valueJson, ')
          ..write('domain: $domain, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('evidenceLevel: $evidenceLevel, ')
          ..write('groupId: $groupId, ')
          ..write('preferred: $preferred, ')
          ..write('preferenceReason: $preferenceReason, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isTestData: $isTestData, ')
          ..write('knowledgeLayer: $knowledgeLayer, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('instrumentId: $instrumentId')
          ..write(')'))
        .toString();
  }
}

class Citations extends Table with TableInfo<Citations, Citation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Citations(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _claimIdMeta = const VerificationMeta(
    'claimId',
  );
  late final GeneratedColumn<String> claimId = GeneratedColumn<String>(
    'claim_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES claims(claim_id)',
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES sources(source_id)',
  );
  static const VerificationMeta _locatorMeta = const VerificationMeta(
    'locator',
  );
  late final GeneratedColumn<String> locator = GeneratedColumn<String>(
    'locator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [claimId, sourceId, locator];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'citations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Citation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('claim_id')) {
      context.handle(
        _claimIdMeta,
        claimId.isAcceptableOrUnknown(data['claim_id']!, _claimIdMeta),
      );
    } else if (isInserting) {
      context.missing(_claimIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('locator')) {
      context.handle(
        _locatorMeta,
        locator.isAcceptableOrUnknown(data['locator']!, _locatorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {claimId, sourceId};
  @override
  Citation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Citation(
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      locator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator'],
      ),
    );
  }

  @override
  Citations createAlias(String alias) {
    return Citations(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(claim_id, source_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Citation extends DataClass implements Insertable<Citation> {
  final String claimId;
  final String sourceId;
  final String? locator;
  const Citation({required this.claimId, required this.sourceId, this.locator});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['claim_id'] = Variable<String>(claimId);
    map['source_id'] = Variable<String>(sourceId);
    if (!nullToAbsent || locator != null) {
      map['locator'] = Variable<String>(locator);
    }
    return map;
  }

  CitationsCompanion toCompanion(bool nullToAbsent) {
    return CitationsCompanion(
      claimId: Value(claimId),
      sourceId: Value(sourceId),
      locator: locator == null && nullToAbsent
          ? const Value.absent()
          : Value(locator),
    );
  }

  factory Citation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Citation(
      claimId: serializer.fromJson<String>(json['claim_id']),
      sourceId: serializer.fromJson<String>(json['source_id']),
      locator: serializer.fromJson<String?>(json['locator']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'claim_id': serializer.toJson<String>(claimId),
      'source_id': serializer.toJson<String>(sourceId),
      'locator': serializer.toJson<String?>(locator),
    };
  }

  Citation copyWith({
    String? claimId,
    String? sourceId,
    Value<String?> locator = const Value.absent(),
  }) => Citation(
    claimId: claimId ?? this.claimId,
    sourceId: sourceId ?? this.sourceId,
    locator: locator.present ? locator.value : this.locator,
  );
  Citation copyWithCompanion(CitationsCompanion data) {
    return Citation(
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      locator: data.locator.present ? data.locator.value : this.locator,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Citation(')
          ..write('claimId: $claimId, ')
          ..write('sourceId: $sourceId, ')
          ..write('locator: $locator')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(claimId, sourceId, locator);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Citation &&
          other.claimId == this.claimId &&
          other.sourceId == this.sourceId &&
          other.locator == this.locator);
}

class CitationsCompanion extends UpdateCompanion<Citation> {
  final Value<String> claimId;
  final Value<String> sourceId;
  final Value<String?> locator;
  const CitationsCompanion({
    this.claimId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.locator = const Value.absent(),
  });
  CitationsCompanion.insert({
    required String claimId,
    required String sourceId,
    this.locator = const Value.absent(),
  }) : claimId = Value(claimId),
       sourceId = Value(sourceId);
  static Insertable<Citation> custom({
    Expression<String>? claimId,
    Expression<String>? sourceId,
    Expression<String>? locator,
  }) {
    return RawValuesInsertable({
      if (claimId != null) 'claim_id': claimId,
      if (sourceId != null) 'source_id': sourceId,
      if (locator != null) 'locator': locator,
    });
  }

  CitationsCompanion copyWith({
    Value<String>? claimId,
    Value<String>? sourceId,
    Value<String?>? locator,
  }) {
    return CitationsCompanion(
      claimId: claimId ?? this.claimId,
      sourceId: sourceId ?? this.sourceId,
      locator: locator ?? this.locator,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (claimId.present) {
      map['claim_id'] = Variable<String>(claimId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (locator.present) {
      map['locator'] = Variable<String>(locator.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CitationsCompanion(')
          ..write('claimId: $claimId, ')
          ..write('sourceId: $sourceId, ')
          ..write('locator: $locator')
          ..write(')'))
        .toString();
  }
}

class Reviewers extends Table with TableInfo<Reviewers, Reviewer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Reviewers(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _reviewerIdMeta = const VerificationMeta(
    'reviewerId',
  );
  late final GeneratedColumn<String> reviewerId = GeneratedColumn<String>(
    'reviewer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _qualificationMeta = const VerificationMeta(
    'qualification',
  );
  late final GeneratedColumn<String> qualification = GeneratedColumn<String>(
    'qualification',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  late final GeneratedColumn<int> active = GeneratedColumn<int>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    reviewerId,
    displayName,
    qualification,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reviewers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reviewer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reviewer_id')) {
      context.handle(
        _reviewerIdMeta,
        reviewerId.isAcceptableOrUnknown(data['reviewer_id']!, _reviewerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewerIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('qualification')) {
      context.handle(
        _qualificationMeta,
        qualification.isAcceptableOrUnknown(
          data['qualification']!,
          _qualificationMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {reviewerId};
  @override
  Reviewer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reviewer(
      reviewerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewer_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      qualification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qualification'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  Reviewers createAlias(String alias) {
    return Reviewers(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get dontWriteConstraints => true;
}

class Reviewer extends DataClass implements Insertable<Reviewer> {
  final String reviewerId;
  final String displayName;
  final String? qualification;
  final int active;
  const Reviewer({
    required this.reviewerId,
    required this.displayName,
    this.qualification,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reviewer_id'] = Variable<String>(reviewerId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || qualification != null) {
      map['qualification'] = Variable<String>(qualification);
    }
    map['active'] = Variable<int>(active);
    return map;
  }

  ReviewersCompanion toCompanion(bool nullToAbsent) {
    return ReviewersCompanion(
      reviewerId: Value(reviewerId),
      displayName: Value(displayName),
      qualification: qualification == null && nullToAbsent
          ? const Value.absent()
          : Value(qualification),
      active: Value(active),
    );
  }

  factory Reviewer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reviewer(
      reviewerId: serializer.fromJson<String>(json['reviewer_id']),
      displayName: serializer.fromJson<String>(json['display_name']),
      qualification: serializer.fromJson<String?>(json['qualification']),
      active: serializer.fromJson<int>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'reviewer_id': serializer.toJson<String>(reviewerId),
      'display_name': serializer.toJson<String>(displayName),
      'qualification': serializer.toJson<String?>(qualification),
      'active': serializer.toJson<int>(active),
    };
  }

  Reviewer copyWith({
    String? reviewerId,
    String? displayName,
    Value<String?> qualification = const Value.absent(),
    int? active,
  }) => Reviewer(
    reviewerId: reviewerId ?? this.reviewerId,
    displayName: displayName ?? this.displayName,
    qualification: qualification.present
        ? qualification.value
        : this.qualification,
    active: active ?? this.active,
  );
  Reviewer copyWithCompanion(ReviewersCompanion data) {
    return Reviewer(
      reviewerId: data.reviewerId.present
          ? data.reviewerId.value
          : this.reviewerId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      qualification: data.qualification.present
          ? data.qualification.value
          : this.qualification,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reviewer(')
          ..write('reviewerId: $reviewerId, ')
          ..write('displayName: $displayName, ')
          ..write('qualification: $qualification, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(reviewerId, displayName, qualification, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reviewer &&
          other.reviewerId == this.reviewerId &&
          other.displayName == this.displayName &&
          other.qualification == this.qualification &&
          other.active == this.active);
}

class ReviewersCompanion extends UpdateCompanion<Reviewer> {
  final Value<String> reviewerId;
  final Value<String> displayName;
  final Value<String?> qualification;
  final Value<int> active;
  const ReviewersCompanion({
    this.reviewerId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.qualification = const Value.absent(),
    this.active = const Value.absent(),
  });
  ReviewersCompanion.insert({
    required String reviewerId,
    required String displayName,
    this.qualification = const Value.absent(),
    this.active = const Value.absent(),
  }) : reviewerId = Value(reviewerId),
       displayName = Value(displayName);
  static Insertable<Reviewer> custom({
    Expression<String>? reviewerId,
    Expression<String>? displayName,
    Expression<String>? qualification,
    Expression<int>? active,
  }) {
    return RawValuesInsertable({
      if (reviewerId != null) 'reviewer_id': reviewerId,
      if (displayName != null) 'display_name': displayName,
      if (qualification != null) 'qualification': qualification,
      if (active != null) 'active': active,
    });
  }

  ReviewersCompanion copyWith({
    Value<String>? reviewerId,
    Value<String>? displayName,
    Value<String?>? qualification,
    Value<int>? active,
  }) {
    return ReviewersCompanion(
      reviewerId: reviewerId ?? this.reviewerId,
      displayName: displayName ?? this.displayName,
      qualification: qualification ?? this.qualification,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (reviewerId.present) {
      map['reviewer_id'] = Variable<String>(reviewerId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (qualification.present) {
      map['qualification'] = Variable<String>(qualification.value);
    }
    if (active.present) {
      map['active'] = Variable<int>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewersCompanion(')
          ..write('reviewerId: $reviewerId, ')
          ..write('displayName: $displayName, ')
          ..write('qualification: $qualification, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class ReviewerDomains extends Table
    with TableInfo<ReviewerDomains, ReviewerDomain> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ReviewerDomains(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _reviewerIdMeta = const VerificationMeta(
    'reviewerId',
  );
  late final GeneratedColumn<String> reviewerId = GeneratedColumn<String>(
    'reviewer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES reviewers(reviewer_id)',
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _canVerifyMeta = const VerificationMeta(
    'canVerify',
  );
  late final GeneratedColumn<int> canVerify = GeneratedColumn<int>(
    'can_verify',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [reviewerId, domain, canVerify];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reviewer_domains';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewerDomain> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reviewer_id')) {
      context.handle(
        _reviewerIdMeta,
        reviewerId.isAcceptableOrUnknown(data['reviewer_id']!, _reviewerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewerIdMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('can_verify')) {
      context.handle(
        _canVerifyMeta,
        canVerify.isAcceptableOrUnknown(data['can_verify']!, _canVerifyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {reviewerId, domain};
  @override
  ReviewerDomain map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewerDomain(
      reviewerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewer_id'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      canVerify: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}can_verify'],
      )!,
    );
  }

  @override
  ReviewerDomains createAlias(String alias) {
    return ReviewerDomains(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(reviewer_id, domain)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ReviewerDomain extends DataClass implements Insertable<ReviewerDomain> {
  final String reviewerId;
  final String domain;
  final int canVerify;
  const ReviewerDomain({
    required this.reviewerId,
    required this.domain,
    required this.canVerify,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reviewer_id'] = Variable<String>(reviewerId);
    map['domain'] = Variable<String>(domain);
    map['can_verify'] = Variable<int>(canVerify);
    return map;
  }

  ReviewerDomainsCompanion toCompanion(bool nullToAbsent) {
    return ReviewerDomainsCompanion(
      reviewerId: Value(reviewerId),
      domain: Value(domain),
      canVerify: Value(canVerify),
    );
  }

  factory ReviewerDomain.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewerDomain(
      reviewerId: serializer.fromJson<String>(json['reviewer_id']),
      domain: serializer.fromJson<String>(json['domain']),
      canVerify: serializer.fromJson<int>(json['can_verify']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'reviewer_id': serializer.toJson<String>(reviewerId),
      'domain': serializer.toJson<String>(domain),
      'can_verify': serializer.toJson<int>(canVerify),
    };
  }

  ReviewerDomain copyWith({
    String? reviewerId,
    String? domain,
    int? canVerify,
  }) => ReviewerDomain(
    reviewerId: reviewerId ?? this.reviewerId,
    domain: domain ?? this.domain,
    canVerify: canVerify ?? this.canVerify,
  );
  ReviewerDomain copyWithCompanion(ReviewerDomainsCompanion data) {
    return ReviewerDomain(
      reviewerId: data.reviewerId.present
          ? data.reviewerId.value
          : this.reviewerId,
      domain: data.domain.present ? data.domain.value : this.domain,
      canVerify: data.canVerify.present ? data.canVerify.value : this.canVerify,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewerDomain(')
          ..write('reviewerId: $reviewerId, ')
          ..write('domain: $domain, ')
          ..write('canVerify: $canVerify')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(reviewerId, domain, canVerify);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewerDomain &&
          other.reviewerId == this.reviewerId &&
          other.domain == this.domain &&
          other.canVerify == this.canVerify);
}

class ReviewerDomainsCompanion extends UpdateCompanion<ReviewerDomain> {
  final Value<String> reviewerId;
  final Value<String> domain;
  final Value<int> canVerify;
  const ReviewerDomainsCompanion({
    this.reviewerId = const Value.absent(),
    this.domain = const Value.absent(),
    this.canVerify = const Value.absent(),
  });
  ReviewerDomainsCompanion.insert({
    required String reviewerId,
    required String domain,
    this.canVerify = const Value.absent(),
  }) : reviewerId = Value(reviewerId),
       domain = Value(domain);
  static Insertable<ReviewerDomain> custom({
    Expression<String>? reviewerId,
    Expression<String>? domain,
    Expression<int>? canVerify,
  }) {
    return RawValuesInsertable({
      if (reviewerId != null) 'reviewer_id': reviewerId,
      if (domain != null) 'domain': domain,
      if (canVerify != null) 'can_verify': canVerify,
    });
  }

  ReviewerDomainsCompanion copyWith({
    Value<String>? reviewerId,
    Value<String>? domain,
    Value<int>? canVerify,
  }) {
    return ReviewerDomainsCompanion(
      reviewerId: reviewerId ?? this.reviewerId,
      domain: domain ?? this.domain,
      canVerify: canVerify ?? this.canVerify,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (reviewerId.present) {
      map['reviewer_id'] = Variable<String>(reviewerId.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (canVerify.present) {
      map['can_verify'] = Variable<int>(canVerify.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewerDomainsCompanion(')
          ..write('reviewerId: $reviewerId, ')
          ..write('domain: $domain, ')
          ..write('canVerify: $canVerify')
          ..write(')'))
        .toString();
  }
}

class Reviews extends Table with TableInfo<Reviews, Review> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Reviews(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _reviewIdMeta = const VerificationMeta(
    'reviewId',
  );
  late final GeneratedColumn<String> reviewId = GeneratedColumn<String>(
    'review_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _targetVersionMeta = const VerificationMeta(
    'targetVersion',
  );
  late final GeneratedColumn<int> targetVersion = GeneratedColumn<int>(
    'target_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _reviewerIdMeta = const VerificationMeta(
    'reviewerId',
  );
  late final GeneratedColumn<String> reviewerId = GeneratedColumn<String>(
    'reviewer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES reviewers(reviewer_id)',
  );
  static const VerificationMeta _decisionMeta = const VerificationMeta(
    'decision',
  );
  late final GeneratedColumn<String> decision = GeneratedColumn<String>(
    'decision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (decision IN (\'approve\', \'request_changes\', \'reject\'))',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    reviewId,
    targetType,
    targetId,
    targetVersion,
    domain,
    reviewerId,
    decision,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<Review> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('review_id')) {
      context.handle(
        _reviewIdMeta,
        reviewId.isAcceptableOrUnknown(data['review_id']!, _reviewIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewIdMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('target_version')) {
      context.handle(
        _targetVersionMeta,
        targetVersion.isAcceptableOrUnknown(
          data['target_version']!,
          _targetVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetVersionMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('reviewer_id')) {
      context.handle(
        _reviewerIdMeta,
        reviewerId.isAcceptableOrUnknown(data['reviewer_id']!, _reviewerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewerIdMeta);
    }
    if (data.containsKey('decision')) {
      context.handle(
        _decisionMeta,
        decision.isAcceptableOrUnknown(data['decision']!, _decisionMeta),
      );
    } else if (isInserting) {
      context.missing(_decisionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {reviewId};
  @override
  Review map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Review(
      reviewId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_id'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      targetVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_version'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      reviewerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewer_id'],
      )!,
      decision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  Reviews createAlias(String alias) {
    return Reviews(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get dontWriteConstraints => true;
}

class Review extends DataClass implements Insertable<Review> {
  final String reviewId;
  final String targetType;
  final String targetId;
  final int targetVersion;
  final String domain;
  final String reviewerId;
  final String decision;
  final String createdAt;
  const Review({
    required this.reviewId,
    required this.targetType,
    required this.targetId,
    required this.targetVersion,
    required this.domain,
    required this.reviewerId,
    required this.decision,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['review_id'] = Variable<String>(reviewId);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<String>(targetId);
    map['target_version'] = Variable<int>(targetVersion);
    map['domain'] = Variable<String>(domain);
    map['reviewer_id'] = Variable<String>(reviewerId);
    map['decision'] = Variable<String>(decision);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ReviewsCompanion toCompanion(bool nullToAbsent) {
    return ReviewsCompanion(
      reviewId: Value(reviewId),
      targetType: Value(targetType),
      targetId: Value(targetId),
      targetVersion: Value(targetVersion),
      domain: Value(domain),
      reviewerId: Value(reviewerId),
      decision: Value(decision),
      createdAt: Value(createdAt),
    );
  }

  factory Review.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Review(
      reviewId: serializer.fromJson<String>(json['review_id']),
      targetType: serializer.fromJson<String>(json['target_type']),
      targetId: serializer.fromJson<String>(json['target_id']),
      targetVersion: serializer.fromJson<int>(json['target_version']),
      domain: serializer.fromJson<String>(json['domain']),
      reviewerId: serializer.fromJson<String>(json['reviewer_id']),
      decision: serializer.fromJson<String>(json['decision']),
      createdAt: serializer.fromJson<String>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'review_id': serializer.toJson<String>(reviewId),
      'target_type': serializer.toJson<String>(targetType),
      'target_id': serializer.toJson<String>(targetId),
      'target_version': serializer.toJson<int>(targetVersion),
      'domain': serializer.toJson<String>(domain),
      'reviewer_id': serializer.toJson<String>(reviewerId),
      'decision': serializer.toJson<String>(decision),
      'created_at': serializer.toJson<String>(createdAt),
    };
  }

  Review copyWith({
    String? reviewId,
    String? targetType,
    String? targetId,
    int? targetVersion,
    String? domain,
    String? reviewerId,
    String? decision,
    String? createdAt,
  }) => Review(
    reviewId: reviewId ?? this.reviewId,
    targetType: targetType ?? this.targetType,
    targetId: targetId ?? this.targetId,
    targetVersion: targetVersion ?? this.targetVersion,
    domain: domain ?? this.domain,
    reviewerId: reviewerId ?? this.reviewerId,
    decision: decision ?? this.decision,
    createdAt: createdAt ?? this.createdAt,
  );
  Review copyWithCompanion(ReviewsCompanion data) {
    return Review(
      reviewId: data.reviewId.present ? data.reviewId.value : this.reviewId,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      targetVersion: data.targetVersion.present
          ? data.targetVersion.value
          : this.targetVersion,
      domain: data.domain.present ? data.domain.value : this.domain,
      reviewerId: data.reviewerId.present
          ? data.reviewerId.value
          : this.reviewerId,
      decision: data.decision.present ? data.decision.value : this.decision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Review(')
          ..write('reviewId: $reviewId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('targetVersion: $targetVersion, ')
          ..write('domain: $domain, ')
          ..write('reviewerId: $reviewerId, ')
          ..write('decision: $decision, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    reviewId,
    targetType,
    targetId,
    targetVersion,
    domain,
    reviewerId,
    decision,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Review &&
          other.reviewId == this.reviewId &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.targetVersion == this.targetVersion &&
          other.domain == this.domain &&
          other.reviewerId == this.reviewerId &&
          other.decision == this.decision &&
          other.createdAt == this.createdAt);
}

class ReviewsCompanion extends UpdateCompanion<Review> {
  final Value<String> reviewId;
  final Value<String> targetType;
  final Value<String> targetId;
  final Value<int> targetVersion;
  final Value<String> domain;
  final Value<String> reviewerId;
  final Value<String> decision;
  final Value<String> createdAt;
  const ReviewsCompanion({
    this.reviewId = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.targetVersion = const Value.absent(),
    this.domain = const Value.absent(),
    this.reviewerId = const Value.absent(),
    this.decision = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReviewsCompanion.insert({
    required String reviewId,
    required String targetType,
    required String targetId,
    required int targetVersion,
    required String domain,
    required String reviewerId,
    required String decision,
    required String createdAt,
  }) : reviewId = Value(reviewId),
       targetType = Value(targetType),
       targetId = Value(targetId),
       targetVersion = Value(targetVersion),
       domain = Value(domain),
       reviewerId = Value(reviewerId),
       decision = Value(decision),
       createdAt = Value(createdAt);
  static Insertable<Review> custom({
    Expression<String>? reviewId,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<int>? targetVersion,
    Expression<String>? domain,
    Expression<String>? reviewerId,
    Expression<String>? decision,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (reviewId != null) 'review_id': reviewId,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (targetVersion != null) 'target_version': targetVersion,
      if (domain != null) 'domain': domain,
      if (reviewerId != null) 'reviewer_id': reviewerId,
      if (decision != null) 'decision': decision,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReviewsCompanion copyWith({
    Value<String>? reviewId,
    Value<String>? targetType,
    Value<String>? targetId,
    Value<int>? targetVersion,
    Value<String>? domain,
    Value<String>? reviewerId,
    Value<String>? decision,
    Value<String>? createdAt,
  }) {
    return ReviewsCompanion(
      reviewId: reviewId ?? this.reviewId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetVersion: targetVersion ?? this.targetVersion,
      domain: domain ?? this.domain,
      reviewerId: reviewerId ?? this.reviewerId,
      decision: decision ?? this.decision,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (reviewId.present) {
      map['review_id'] = Variable<String>(reviewId.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (targetVersion.present) {
      map['target_version'] = Variable<int>(targetVersion.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (reviewerId.present) {
      map['reviewer_id'] = Variable<String>(reviewerId.value);
    }
    if (decision.present) {
      map['decision'] = Variable<String>(decision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewsCompanion(')
          ..write('reviewId: $reviewId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('targetVersion: $targetVersion, ')
          ..write('domain: $domain, ')
          ..write('reviewerId: $reviewerId, ')
          ..write('decision: $decision, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class Substances extends Table with TableInfo<Substances, Substance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Substances(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _substanceIdMeta = const VerificationMeta(
    'substanceId',
  );
  late final GeneratedColumn<String> substanceId = GeneratedColumn<String>(
    'substance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _canonicalNameMeta = const VerificationMeta(
    'canonicalName',
  );
  late final GeneratedColumn<String> canonicalName = GeneratedColumn<String>(
    'canonical_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _entityKindMeta = const VerificationMeta(
    'entityKind',
  );
  late final GeneratedColumn<String> entityKind = GeneratedColumn<String>(
    'entity_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _molecularFormulaMeta = const VerificationMeta(
    'molecularFormula',
  );
  late final GeneratedColumn<String> molecularFormula = GeneratedColumn<String>(
    'molecular_formula',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _tierAccessMeta = const VerificationMeta(
    'tierAccess',
  );
  late final GeneratedColumn<String> tierAccess = GeneratedColumn<String>(
    'tier_access',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (tier_access IN (\'free\', \'student\', \'pro\'))',
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  late final GeneratedColumn<String> lastReviewedAt = GeneratedColumn<String>(
    'last_reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  late final GeneratedColumn<String> contentVersion = GeneratedColumn<String>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _isTestDataMeta = const VerificationMeta(
    'isTestData',
  );
  late final GeneratedColumn<int> isTestData = GeneratedColumn<int>(
    'is_test_data',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _substanceGroupMeta = const VerificationMeta(
    'substanceGroup',
  );
  late final GeneratedColumn<String> substanceGroup = GeneratedColumn<String>(
    'substance_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    substanceId,
    canonicalName,
    entityKind,
    molecularFormula,
    tierAccess,
    reviewStatus,
    lastReviewedAt,
    contentVersion,
    isTestData,
    substanceGroup,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'substances';
  @override
  VerificationContext validateIntegrity(
    Insertable<Substance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('substance_id')) {
      context.handle(
        _substanceIdMeta,
        substanceId.isAcceptableOrUnknown(
          data['substance_id']!,
          _substanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_substanceIdMeta);
    }
    if (data.containsKey('canonical_name')) {
      context.handle(
        _canonicalNameMeta,
        canonicalName.isAcceptableOrUnknown(
          data['canonical_name']!,
          _canonicalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalNameMeta);
    }
    if (data.containsKey('entity_kind')) {
      context.handle(
        _entityKindMeta,
        entityKind.isAcceptableOrUnknown(data['entity_kind']!, _entityKindMeta),
      );
    } else if (isInserting) {
      context.missing(_entityKindMeta);
    }
    if (data.containsKey('molecular_formula')) {
      context.handle(
        _molecularFormulaMeta,
        molecularFormula.isAcceptableOrUnknown(
          data['molecular_formula']!,
          _molecularFormulaMeta,
        ),
      );
    }
    if (data.containsKey('tier_access')) {
      context.handle(
        _tierAccessMeta,
        tierAccess.isAcceptableOrUnknown(data['tier_access']!, _tierAccessMeta),
      );
    } else if (isInserting) {
      context.missing(_tierAccessMeta);
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewStatusMeta);
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentVersionMeta);
    }
    if (data.containsKey('is_test_data')) {
      context.handle(
        _isTestDataMeta,
        isTestData.isAcceptableOrUnknown(
          data['is_test_data']!,
          _isTestDataMeta,
        ),
      );
    }
    if (data.containsKey('substance_group')) {
      context.handle(
        _substanceGroupMeta,
        substanceGroup.isAcceptableOrUnknown(
          data['substance_group']!,
          _substanceGroupMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {substanceId};
  @override
  Substance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Substance(
      substanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}substance_id'],
      )!,
      canonicalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_name'],
      )!,
      entityKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_kind'],
      )!,
      molecularFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}molecular_formula'],
      ),
      tierAccess: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier_access'],
      )!,
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_version'],
      )!,
      isTestData: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_test_data'],
      )!,
      substanceGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}substance_group'],
      ),
    );
  }

  @override
  Substances createAlias(String alias) {
    return Substances(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get dontWriteConstraints => true;
}

class Substance extends DataClass implements Insertable<Substance> {
  final String substanceId;
  final String canonicalName;
  final String entityKind;
  final String? molecularFormula;
  final String tierAccess;
  final String reviewStatus;
  final String? lastReviewedAt;
  final String contentVersion;
  final int isTestData;

  /// PHASE 5: tahririy guruh (navigatsiya uchun; ilmiy claim emas).
  final String? substanceGroup;
  const Substance({
    required this.substanceId,
    required this.canonicalName,
    required this.entityKind,
    this.molecularFormula,
    required this.tierAccess,
    required this.reviewStatus,
    this.lastReviewedAt,
    required this.contentVersion,
    required this.isTestData,
    this.substanceGroup,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['substance_id'] = Variable<String>(substanceId);
    map['canonical_name'] = Variable<String>(canonicalName);
    map['entity_kind'] = Variable<String>(entityKind);
    if (!nullToAbsent || molecularFormula != null) {
      map['molecular_formula'] = Variable<String>(molecularFormula);
    }
    map['tier_access'] = Variable<String>(tierAccess);
    map['review_status'] = Variable<String>(reviewStatus);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<String>(lastReviewedAt);
    }
    map['content_version'] = Variable<String>(contentVersion);
    map['is_test_data'] = Variable<int>(isTestData);
    if (!nullToAbsent || substanceGroup != null) {
      map['substance_group'] = Variable<String>(substanceGroup);
    }
    return map;
  }

  SubstancesCompanion toCompanion(bool nullToAbsent) {
    return SubstancesCompanion(
      substanceId: Value(substanceId),
      canonicalName: Value(canonicalName),
      entityKind: Value(entityKind),
      molecularFormula: molecularFormula == null && nullToAbsent
          ? const Value.absent()
          : Value(molecularFormula),
      tierAccess: Value(tierAccess),
      reviewStatus: Value(reviewStatus),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      contentVersion: Value(contentVersion),
      isTestData: Value(isTestData),
      substanceGroup: substanceGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(substanceGroup),
    );
  }

  factory Substance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Substance(
      substanceId: serializer.fromJson<String>(json['substance_id']),
      canonicalName: serializer.fromJson<String>(json['canonical_name']),
      entityKind: serializer.fromJson<String>(json['entity_kind']),
      molecularFormula: serializer.fromJson<String?>(json['molecular_formula']),
      tierAccess: serializer.fromJson<String>(json['tier_access']),
      reviewStatus: serializer.fromJson<String>(json['review_status']),
      lastReviewedAt: serializer.fromJson<String?>(json['last_reviewed_at']),
      contentVersion: serializer.fromJson<String>(json['content_version']),
      isTestData: serializer.fromJson<int>(json['is_test_data']),
      substanceGroup: serializer.fromJson<String?>(json['substance_group']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'substance_id': serializer.toJson<String>(substanceId),
      'canonical_name': serializer.toJson<String>(canonicalName),
      'entity_kind': serializer.toJson<String>(entityKind),
      'molecular_formula': serializer.toJson<String?>(molecularFormula),
      'tier_access': serializer.toJson<String>(tierAccess),
      'review_status': serializer.toJson<String>(reviewStatus),
      'last_reviewed_at': serializer.toJson<String?>(lastReviewedAt),
      'content_version': serializer.toJson<String>(contentVersion),
      'is_test_data': serializer.toJson<int>(isTestData),
      'substance_group': serializer.toJson<String?>(substanceGroup),
    };
  }

  Substance copyWith({
    String? substanceId,
    String? canonicalName,
    String? entityKind,
    Value<String?> molecularFormula = const Value.absent(),
    String? tierAccess,
    String? reviewStatus,
    Value<String?> lastReviewedAt = const Value.absent(),
    String? contentVersion,
    int? isTestData,
    Value<String?> substanceGroup = const Value.absent(),
  }) => Substance(
    substanceId: substanceId ?? this.substanceId,
    canonicalName: canonicalName ?? this.canonicalName,
    entityKind: entityKind ?? this.entityKind,
    molecularFormula: molecularFormula.present
        ? molecularFormula.value
        : this.molecularFormula,
    tierAccess: tierAccess ?? this.tierAccess,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    contentVersion: contentVersion ?? this.contentVersion,
    isTestData: isTestData ?? this.isTestData,
    substanceGroup: substanceGroup.present
        ? substanceGroup.value
        : this.substanceGroup,
  );
  Substance copyWithCompanion(SubstancesCompanion data) {
    return Substance(
      substanceId: data.substanceId.present
          ? data.substanceId.value
          : this.substanceId,
      canonicalName: data.canonicalName.present
          ? data.canonicalName.value
          : this.canonicalName,
      entityKind: data.entityKind.present
          ? data.entityKind.value
          : this.entityKind,
      molecularFormula: data.molecularFormula.present
          ? data.molecularFormula.value
          : this.molecularFormula,
      tierAccess: data.tierAccess.present
          ? data.tierAccess.value
          : this.tierAccess,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      isTestData: data.isTestData.present
          ? data.isTestData.value
          : this.isTestData,
      substanceGroup: data.substanceGroup.present
          ? data.substanceGroup.value
          : this.substanceGroup,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Substance(')
          ..write('substanceId: $substanceId, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('entityKind: $entityKind, ')
          ..write('molecularFormula: $molecularFormula, ')
          ..write('tierAccess: $tierAccess, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('isTestData: $isTestData, ')
          ..write('substanceGroup: $substanceGroup')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    substanceId,
    canonicalName,
    entityKind,
    molecularFormula,
    tierAccess,
    reviewStatus,
    lastReviewedAt,
    contentVersion,
    isTestData,
    substanceGroup,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Substance &&
          other.substanceId == this.substanceId &&
          other.canonicalName == this.canonicalName &&
          other.entityKind == this.entityKind &&
          other.molecularFormula == this.molecularFormula &&
          other.tierAccess == this.tierAccess &&
          other.reviewStatus == this.reviewStatus &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.contentVersion == this.contentVersion &&
          other.isTestData == this.isTestData &&
          other.substanceGroup == this.substanceGroup);
}

class SubstancesCompanion extends UpdateCompanion<Substance> {
  final Value<String> substanceId;
  final Value<String> canonicalName;
  final Value<String> entityKind;
  final Value<String?> molecularFormula;
  final Value<String> tierAccess;
  final Value<String> reviewStatus;
  final Value<String?> lastReviewedAt;
  final Value<String> contentVersion;
  final Value<int> isTestData;
  final Value<String?> substanceGroup;
  const SubstancesCompanion({
    this.substanceId = const Value.absent(),
    this.canonicalName = const Value.absent(),
    this.entityKind = const Value.absent(),
    this.molecularFormula = const Value.absent(),
    this.tierAccess = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.isTestData = const Value.absent(),
    this.substanceGroup = const Value.absent(),
  });
  SubstancesCompanion.insert({
    required String substanceId,
    required String canonicalName,
    required String entityKind,
    this.molecularFormula = const Value.absent(),
    required String tierAccess,
    required String reviewStatus,
    this.lastReviewedAt = const Value.absent(),
    required String contentVersion,
    this.isTestData = const Value.absent(),
    this.substanceGroup = const Value.absent(),
  }) : substanceId = Value(substanceId),
       canonicalName = Value(canonicalName),
       entityKind = Value(entityKind),
       tierAccess = Value(tierAccess),
       reviewStatus = Value(reviewStatus),
       contentVersion = Value(contentVersion);
  static Insertable<Substance> custom({
    Expression<String>? substanceId,
    Expression<String>? canonicalName,
    Expression<String>? entityKind,
    Expression<String>? molecularFormula,
    Expression<String>? tierAccess,
    Expression<String>? reviewStatus,
    Expression<String>? lastReviewedAt,
    Expression<String>? contentVersion,
    Expression<int>? isTestData,
    Expression<String>? substanceGroup,
  }) {
    return RawValuesInsertable({
      if (substanceId != null) 'substance_id': substanceId,
      if (canonicalName != null) 'canonical_name': canonicalName,
      if (entityKind != null) 'entity_kind': entityKind,
      if (molecularFormula != null) 'molecular_formula': molecularFormula,
      if (tierAccess != null) 'tier_access': tierAccess,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (contentVersion != null) 'content_version': contentVersion,
      if (isTestData != null) 'is_test_data': isTestData,
      if (substanceGroup != null) 'substance_group': substanceGroup,
    });
  }

  SubstancesCompanion copyWith({
    Value<String>? substanceId,
    Value<String>? canonicalName,
    Value<String>? entityKind,
    Value<String?>? molecularFormula,
    Value<String>? tierAccess,
    Value<String>? reviewStatus,
    Value<String?>? lastReviewedAt,
    Value<String>? contentVersion,
    Value<int>? isTestData,
    Value<String?>? substanceGroup,
  }) {
    return SubstancesCompanion(
      substanceId: substanceId ?? this.substanceId,
      canonicalName: canonicalName ?? this.canonicalName,
      entityKind: entityKind ?? this.entityKind,
      molecularFormula: molecularFormula ?? this.molecularFormula,
      tierAccess: tierAccess ?? this.tierAccess,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      contentVersion: contentVersion ?? this.contentVersion,
      isTestData: isTestData ?? this.isTestData,
      substanceGroup: substanceGroup ?? this.substanceGroup,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (substanceId.present) {
      map['substance_id'] = Variable<String>(substanceId.value);
    }
    if (canonicalName.present) {
      map['canonical_name'] = Variable<String>(canonicalName.value);
    }
    if (entityKind.present) {
      map['entity_kind'] = Variable<String>(entityKind.value);
    }
    if (molecularFormula.present) {
      map['molecular_formula'] = Variable<String>(molecularFormula.value);
    }
    if (tierAccess.present) {
      map['tier_access'] = Variable<String>(tierAccess.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<String>(lastReviewedAt.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<String>(contentVersion.value);
    }
    if (isTestData.present) {
      map['is_test_data'] = Variable<int>(isTestData.value);
    }
    if (substanceGroup.present) {
      map['substance_group'] = Variable<String>(substanceGroup.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubstancesCompanion(')
          ..write('substanceId: $substanceId, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('entityKind: $entityKind, ')
          ..write('molecularFormula: $molecularFormula, ')
          ..write('tierAccess: $tierAccess, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('isTestData: $isTestData, ')
          ..write('substanceGroup: $substanceGroup')
          ..write(')'))
        .toString();
  }
}

class SubstanceI18n extends Table
    with TableInfo<SubstanceI18n, SubstanceI18nData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SubstanceI18n(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _substanceIdMeta = const VerificationMeta(
    'substanceId',
  );
  late final GeneratedColumn<String> substanceId = GeneratedColumn<String>(
    'substance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES substances(substance_id)',
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _descriptionMdMeta = const VerificationMeta(
    'descriptionMd',
  );
  late final GeneratedColumn<String> descriptionMd = GeneratedColumn<String>(
    'description_md',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _translationStatusMeta = const VerificationMeta(
    'translationStatus',
  );
  late final GeneratedColumn<String> translationStatus =
      GeneratedColumn<String>(
        'translation_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL CHECK (translation_status IN (\'machine_draft\', \'translated\', \'reviewed\'))',
      );
  @override
  List<GeneratedColumn> get $columns => [
    substanceId,
    lang,
    name,
    descriptionMd,
    translationStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'substance_i18n';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubstanceI18nData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('substance_id')) {
      context.handle(
        _substanceIdMeta,
        substanceId.isAcceptableOrUnknown(
          data['substance_id']!,
          _substanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_substanceIdMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description_md')) {
      context.handle(
        _descriptionMdMeta,
        descriptionMd.isAcceptableOrUnknown(
          data['description_md']!,
          _descriptionMdMeta,
        ),
      );
    }
    if (data.containsKey('translation_status')) {
      context.handle(
        _translationStatusMeta,
        translationStatus.isAcceptableOrUnknown(
          data['translation_status']!,
          _translationStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {substanceId, lang};
  @override
  SubstanceI18nData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubstanceI18nData(
      substanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}substance_id'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      descriptionMd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_md'],
      ),
      translationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_status'],
      )!,
    );
  }

  @override
  SubstanceI18n createAlias(String alias) {
    return SubstanceI18n(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(substance_id, lang)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class SubstanceI18nData extends DataClass
    implements Insertable<SubstanceI18nData> {
  final String substanceId;
  final String lang;
  final String name;
  final String? descriptionMd;
  final String translationStatus;
  const SubstanceI18nData({
    required this.substanceId,
    required this.lang,
    required this.name,
    this.descriptionMd,
    required this.translationStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['substance_id'] = Variable<String>(substanceId);
    map['lang'] = Variable<String>(lang);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || descriptionMd != null) {
      map['description_md'] = Variable<String>(descriptionMd);
    }
    map['translation_status'] = Variable<String>(translationStatus);
    return map;
  }

  SubstanceI18nCompanion toCompanion(bool nullToAbsent) {
    return SubstanceI18nCompanion(
      substanceId: Value(substanceId),
      lang: Value(lang),
      name: Value(name),
      descriptionMd: descriptionMd == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionMd),
      translationStatus: Value(translationStatus),
    );
  }

  factory SubstanceI18nData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubstanceI18nData(
      substanceId: serializer.fromJson<String>(json['substance_id']),
      lang: serializer.fromJson<String>(json['lang']),
      name: serializer.fromJson<String>(json['name']),
      descriptionMd: serializer.fromJson<String?>(json['description_md']),
      translationStatus: serializer.fromJson<String>(
        json['translation_status'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'substance_id': serializer.toJson<String>(substanceId),
      'lang': serializer.toJson<String>(lang),
      'name': serializer.toJson<String>(name),
      'description_md': serializer.toJson<String?>(descriptionMd),
      'translation_status': serializer.toJson<String>(translationStatus),
    };
  }

  SubstanceI18nData copyWith({
    String? substanceId,
    String? lang,
    String? name,
    Value<String?> descriptionMd = const Value.absent(),
    String? translationStatus,
  }) => SubstanceI18nData(
    substanceId: substanceId ?? this.substanceId,
    lang: lang ?? this.lang,
    name: name ?? this.name,
    descriptionMd: descriptionMd.present
        ? descriptionMd.value
        : this.descriptionMd,
    translationStatus: translationStatus ?? this.translationStatus,
  );
  SubstanceI18nData copyWithCompanion(SubstanceI18nCompanion data) {
    return SubstanceI18nData(
      substanceId: data.substanceId.present
          ? data.substanceId.value
          : this.substanceId,
      lang: data.lang.present ? data.lang.value : this.lang,
      name: data.name.present ? data.name.value : this.name,
      descriptionMd: data.descriptionMd.present
          ? data.descriptionMd.value
          : this.descriptionMd,
      translationStatus: data.translationStatus.present
          ? data.translationStatus.value
          : this.translationStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubstanceI18nData(')
          ..write('substanceId: $substanceId, ')
          ..write('lang: $lang, ')
          ..write('name: $name, ')
          ..write('descriptionMd: $descriptionMd, ')
          ..write('translationStatus: $translationStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(substanceId, lang, name, descriptionMd, translationStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubstanceI18nData &&
          other.substanceId == this.substanceId &&
          other.lang == this.lang &&
          other.name == this.name &&
          other.descriptionMd == this.descriptionMd &&
          other.translationStatus == this.translationStatus);
}

class SubstanceI18nCompanion extends UpdateCompanion<SubstanceI18nData> {
  final Value<String> substanceId;
  final Value<String> lang;
  final Value<String> name;
  final Value<String?> descriptionMd;
  final Value<String> translationStatus;
  const SubstanceI18nCompanion({
    this.substanceId = const Value.absent(),
    this.lang = const Value.absent(),
    this.name = const Value.absent(),
    this.descriptionMd = const Value.absent(),
    this.translationStatus = const Value.absent(),
  });
  SubstanceI18nCompanion.insert({
    required String substanceId,
    required String lang,
    required String name,
    this.descriptionMd = const Value.absent(),
    required String translationStatus,
  }) : substanceId = Value(substanceId),
       lang = Value(lang),
       name = Value(name),
       translationStatus = Value(translationStatus);
  static Insertable<SubstanceI18nData> custom({
    Expression<String>? substanceId,
    Expression<String>? lang,
    Expression<String>? name,
    Expression<String>? descriptionMd,
    Expression<String>? translationStatus,
  }) {
    return RawValuesInsertable({
      if (substanceId != null) 'substance_id': substanceId,
      if (lang != null) 'lang': lang,
      if (name != null) 'name': name,
      if (descriptionMd != null) 'description_md': descriptionMd,
      if (translationStatus != null) 'translation_status': translationStatus,
    });
  }

  SubstanceI18nCompanion copyWith({
    Value<String>? substanceId,
    Value<String>? lang,
    Value<String>? name,
    Value<String?>? descriptionMd,
    Value<String>? translationStatus,
  }) {
    return SubstanceI18nCompanion(
      substanceId: substanceId ?? this.substanceId,
      lang: lang ?? this.lang,
      name: name ?? this.name,
      descriptionMd: descriptionMd ?? this.descriptionMd,
      translationStatus: translationStatus ?? this.translationStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (substanceId.present) {
      map['substance_id'] = Variable<String>(substanceId.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (descriptionMd.present) {
      map['description_md'] = Variable<String>(descriptionMd.value);
    }
    if (translationStatus.present) {
      map['translation_status'] = Variable<String>(translationStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubstanceI18nCompanion(')
          ..write('substanceId: $substanceId, ')
          ..write('lang: $lang, ')
          ..write('name: $name, ')
          ..write('descriptionMd: $descriptionMd, ')
          ..write('translationStatus: $translationStatus')
          ..write(')'))
        .toString();
  }
}

class ExternalIdentifiers extends Table
    with TableInfo<ExternalIdentifiers, ExternalIdentifier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ExternalIdentifiers(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _schemeMeta = const VerificationMeta('scheme');
  late final GeneratedColumn<String> scheme = GeneratedColumn<String>(
    'scheme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _identifierValueMeta = const VerificationMeta(
    'identifierValue',
  );
  late final GeneratedColumn<String> identifierValue = GeneratedColumn<String>(
    'identifier_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES sources(source_id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityType,
    entityId,
    scheme,
    identifierValue,
    sourceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'external_identifiers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExternalIdentifier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('scheme')) {
      context.handle(
        _schemeMeta,
        scheme.isAcceptableOrUnknown(data['scheme']!, _schemeMeta),
      );
    } else if (isInserting) {
      context.missing(_schemeMeta);
    }
    if (data.containsKey('identifier_value')) {
      context.handle(
        _identifierValueMeta,
        identifierValue.isAcceptableOrUnknown(
          data['identifier_value']!,
          _identifierValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_identifierValueMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    entityType,
    entityId,
    scheme,
    identifierValue,
  };
  @override
  ExternalIdentifier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExternalIdentifier(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      scheme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheme'],
      )!,
      identifierValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identifier_value'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
    );
  }

  @override
  ExternalIdentifiers createAlias(String alias) {
    return ExternalIdentifiers(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(entity_type, entity_id, scheme, identifier_value)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ExternalIdentifier extends DataClass
    implements Insertable<ExternalIdentifier> {
  final String entityType;
  final String entityId;
  final String scheme;
  final String identifierValue;
  final String sourceId;
  const ExternalIdentifier({
    required this.entityType,
    required this.entityId,
    required this.scheme,
    required this.identifierValue,
    required this.sourceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['scheme'] = Variable<String>(scheme);
    map['identifier_value'] = Variable<String>(identifierValue);
    map['source_id'] = Variable<String>(sourceId);
    return map;
  }

  ExternalIdentifiersCompanion toCompanion(bool nullToAbsent) {
    return ExternalIdentifiersCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      scheme: Value(scheme),
      identifierValue: Value(identifierValue),
      sourceId: Value(sourceId),
    );
  }

  factory ExternalIdentifier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExternalIdentifier(
      entityType: serializer.fromJson<String>(json['entity_type']),
      entityId: serializer.fromJson<String>(json['entity_id']),
      scheme: serializer.fromJson<String>(json['scheme']),
      identifierValue: serializer.fromJson<String>(json['identifier_value']),
      sourceId: serializer.fromJson<String>(json['source_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity_type': serializer.toJson<String>(entityType),
      'entity_id': serializer.toJson<String>(entityId),
      'scheme': serializer.toJson<String>(scheme),
      'identifier_value': serializer.toJson<String>(identifierValue),
      'source_id': serializer.toJson<String>(sourceId),
    };
  }

  ExternalIdentifier copyWith({
    String? entityType,
    String? entityId,
    String? scheme,
    String? identifierValue,
    String? sourceId,
  }) => ExternalIdentifier(
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    scheme: scheme ?? this.scheme,
    identifierValue: identifierValue ?? this.identifierValue,
    sourceId: sourceId ?? this.sourceId,
  );
  ExternalIdentifier copyWithCompanion(ExternalIdentifiersCompanion data) {
    return ExternalIdentifier(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      scheme: data.scheme.present ? data.scheme.value : this.scheme,
      identifierValue: data.identifierValue.present
          ? data.identifierValue.value
          : this.identifierValue,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExternalIdentifier(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('scheme: $scheme, ')
          ..write('identifierValue: $identifierValue, ')
          ..write('sourceId: $sourceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(entityType, entityId, scheme, identifierValue, sourceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExternalIdentifier &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.scheme == this.scheme &&
          other.identifierValue == this.identifierValue &&
          other.sourceId == this.sourceId);
}

class ExternalIdentifiersCompanion extends UpdateCompanion<ExternalIdentifier> {
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> scheme;
  final Value<String> identifierValue;
  final Value<String> sourceId;
  const ExternalIdentifiersCompanion({
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.scheme = const Value.absent(),
    this.identifierValue = const Value.absent(),
    this.sourceId = const Value.absent(),
  });
  ExternalIdentifiersCompanion.insert({
    required String entityType,
    required String entityId,
    required String scheme,
    required String identifierValue,
    required String sourceId,
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       scheme = Value(scheme),
       identifierValue = Value(identifierValue),
       sourceId = Value(sourceId);
  static Insertable<ExternalIdentifier> custom({
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? scheme,
    Expression<String>? identifierValue,
    Expression<String>? sourceId,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (scheme != null) 'scheme': scheme,
      if (identifierValue != null) 'identifier_value': identifierValue,
      if (sourceId != null) 'source_id': sourceId,
    });
  }

  ExternalIdentifiersCompanion copyWith({
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? scheme,
    Value<String>? identifierValue,
    Value<String>? sourceId,
  }) {
    return ExternalIdentifiersCompanion(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      scheme: scheme ?? this.scheme,
      identifierValue: identifierValue ?? this.identifierValue,
      sourceId: sourceId ?? this.sourceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (scheme.present) {
      map['scheme'] = Variable<String>(scheme.value);
    }
    if (identifierValue.present) {
      map['identifier_value'] = Variable<String>(identifierValue.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExternalIdentifiersCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('scheme: $scheme, ')
          ..write('identifierValue: $identifierValue, ')
          ..write('sourceId: $sourceId')
          ..write(')'))
        .toString();
  }
}

class ConcentrationRecords extends Table
    with TableInfo<ConcentrationRecords, ConcentrationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ConcentrationRecords(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _substanceIdMeta = const VerificationMeta(
    'substanceId',
  );
  late final GeneratedColumn<String> substanceId = GeneratedColumn<String>(
    'substance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES substances(substance_id)',
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (category IN (\'therapeutic_reference\', \'toxic_reference\', \'reported_postmortem\', \'reported_impairment\'))',
  );
  static const VerificationMeta _specimenCodeMeta = const VerificationMeta(
    'specimenCode',
  );
  late final GeneratedColumn<String> specimenCode = GeneratedColumn<String>(
    'specimen_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _populationMeta = const VerificationMeta(
    'population',
  );
  late final GeneratedColumn<String> population = GeneratedColumn<String>(
    'population',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _valueTypeMeta = const VerificationMeta(
    'valueType',
  );
  late final GeneratedColumn<String> valueType = GeneratedColumn<String>(
    'value_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _valueLowMeta = const VerificationMeta(
    'valueLow',
  );
  late final GeneratedColumn<double> valueLow = GeneratedColumn<double>(
    'value_low',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _valueHighMeta = const VerificationMeta(
    'valueHigh',
  );
  late final GeneratedColumn<double> valueHigh = GeneratedColumn<double>(
    'value_high',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _valueCentralMeta = const VerificationMeta(
    'valueCentral',
  );
  late final GeneratedColumn<double> valueCentral = GeneratedColumn<double>(
    'value_central',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nCasesMeta = const VerificationMeta('nCases');
  late final GeneratedColumn<int> nCases = GeneratedColumn<int>(
    'n_cases',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _claimIdMeta = const VerificationMeta(
    'claimId',
  );
  late final GeneratedColumn<String> claimId = GeneratedColumn<String>(
    'claim_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES claims(claim_id)',
  );
  static const VerificationMeta _isTestDataMeta = const VerificationMeta(
    'isTestData',
  );
  late final GeneratedColumn<int> isTestData = GeneratedColumn<int>(
    'is_test_data',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    recordId,
    substanceId,
    category,
    specimenCode,
    population,
    valueType,
    valueLow,
    valueHigh,
    valueCentral,
    unit,
    nCases,
    claimId,
    isTestData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'concentration_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConcentrationRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('substance_id')) {
      context.handle(
        _substanceIdMeta,
        substanceId.isAcceptableOrUnknown(
          data['substance_id']!,
          _substanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_substanceIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('specimen_code')) {
      context.handle(
        _specimenCodeMeta,
        specimenCode.isAcceptableOrUnknown(
          data['specimen_code']!,
          _specimenCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_specimenCodeMeta);
    }
    if (data.containsKey('population')) {
      context.handle(
        _populationMeta,
        population.isAcceptableOrUnknown(data['population']!, _populationMeta),
      );
    } else if (isInserting) {
      context.missing(_populationMeta);
    }
    if (data.containsKey('value_type')) {
      context.handle(
        _valueTypeMeta,
        valueType.isAcceptableOrUnknown(data['value_type']!, _valueTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_valueTypeMeta);
    }
    if (data.containsKey('value_low')) {
      context.handle(
        _valueLowMeta,
        valueLow.isAcceptableOrUnknown(data['value_low']!, _valueLowMeta),
      );
    }
    if (data.containsKey('value_high')) {
      context.handle(
        _valueHighMeta,
        valueHigh.isAcceptableOrUnknown(data['value_high']!, _valueHighMeta),
      );
    }
    if (data.containsKey('value_central')) {
      context.handle(
        _valueCentralMeta,
        valueCentral.isAcceptableOrUnknown(
          data['value_central']!,
          _valueCentralMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('n_cases')) {
      context.handle(
        _nCasesMeta,
        nCases.isAcceptableOrUnknown(data['n_cases']!, _nCasesMeta),
      );
    }
    if (data.containsKey('claim_id')) {
      context.handle(
        _claimIdMeta,
        claimId.isAcceptableOrUnknown(data['claim_id']!, _claimIdMeta),
      );
    } else if (isInserting) {
      context.missing(_claimIdMeta);
    }
    if (data.containsKey('is_test_data')) {
      context.handle(
        _isTestDataMeta,
        isTestData.isAcceptableOrUnknown(
          data['is_test_data']!,
          _isTestDataMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recordId};
  @override
  ConcentrationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConcentrationRecord(
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      substanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}substance_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      specimenCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specimen_code'],
      )!,
      population: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}population'],
      )!,
      valueType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_type'],
      )!,
      valueLow: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_low'],
      ),
      valueHigh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_high'],
      ),
      valueCentral: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_central'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      nCases: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n_cases'],
      ),
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_id'],
      )!,
      isTestData: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_test_data'],
      )!,
    );
  }

  @override
  ConcentrationRecords createAlias(String alias) {
    return ConcentrationRecords(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get dontWriteConstraints => true;
}

class ConcentrationRecord extends DataClass
    implements Insertable<ConcentrationRecord> {
  final String recordId;
  final String substanceId;
  final String category;
  final String specimenCode;
  final String population;
  final String valueType;
  final double? valueLow;
  final double? valueHigh;
  final double? valueCentral;
  final String unit;
  final int? nCases;
  final String claimId;
  final int isTestData;
  const ConcentrationRecord({
    required this.recordId,
    required this.substanceId,
    required this.category,
    required this.specimenCode,
    required this.population,
    required this.valueType,
    this.valueLow,
    this.valueHigh,
    this.valueCentral,
    required this.unit,
    this.nCases,
    required this.claimId,
    required this.isTestData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['record_id'] = Variable<String>(recordId);
    map['substance_id'] = Variable<String>(substanceId);
    map['category'] = Variable<String>(category);
    map['specimen_code'] = Variable<String>(specimenCode);
    map['population'] = Variable<String>(population);
    map['value_type'] = Variable<String>(valueType);
    if (!nullToAbsent || valueLow != null) {
      map['value_low'] = Variable<double>(valueLow);
    }
    if (!nullToAbsent || valueHigh != null) {
      map['value_high'] = Variable<double>(valueHigh);
    }
    if (!nullToAbsent || valueCentral != null) {
      map['value_central'] = Variable<double>(valueCentral);
    }
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || nCases != null) {
      map['n_cases'] = Variable<int>(nCases);
    }
    map['claim_id'] = Variable<String>(claimId);
    map['is_test_data'] = Variable<int>(isTestData);
    return map;
  }

  ConcentrationRecordsCompanion toCompanion(bool nullToAbsent) {
    return ConcentrationRecordsCompanion(
      recordId: Value(recordId),
      substanceId: Value(substanceId),
      category: Value(category),
      specimenCode: Value(specimenCode),
      population: Value(population),
      valueType: Value(valueType),
      valueLow: valueLow == null && nullToAbsent
          ? const Value.absent()
          : Value(valueLow),
      valueHigh: valueHigh == null && nullToAbsent
          ? const Value.absent()
          : Value(valueHigh),
      valueCentral: valueCentral == null && nullToAbsent
          ? const Value.absent()
          : Value(valueCentral),
      unit: Value(unit),
      nCases: nCases == null && nullToAbsent
          ? const Value.absent()
          : Value(nCases),
      claimId: Value(claimId),
      isTestData: Value(isTestData),
    );
  }

  factory ConcentrationRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConcentrationRecord(
      recordId: serializer.fromJson<String>(json['record_id']),
      substanceId: serializer.fromJson<String>(json['substance_id']),
      category: serializer.fromJson<String>(json['category']),
      specimenCode: serializer.fromJson<String>(json['specimen_code']),
      population: serializer.fromJson<String>(json['population']),
      valueType: serializer.fromJson<String>(json['value_type']),
      valueLow: serializer.fromJson<double?>(json['value_low']),
      valueHigh: serializer.fromJson<double?>(json['value_high']),
      valueCentral: serializer.fromJson<double?>(json['value_central']),
      unit: serializer.fromJson<String>(json['unit']),
      nCases: serializer.fromJson<int?>(json['n_cases']),
      claimId: serializer.fromJson<String>(json['claim_id']),
      isTestData: serializer.fromJson<int>(json['is_test_data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'record_id': serializer.toJson<String>(recordId),
      'substance_id': serializer.toJson<String>(substanceId),
      'category': serializer.toJson<String>(category),
      'specimen_code': serializer.toJson<String>(specimenCode),
      'population': serializer.toJson<String>(population),
      'value_type': serializer.toJson<String>(valueType),
      'value_low': serializer.toJson<double?>(valueLow),
      'value_high': serializer.toJson<double?>(valueHigh),
      'value_central': serializer.toJson<double?>(valueCentral),
      'unit': serializer.toJson<String>(unit),
      'n_cases': serializer.toJson<int?>(nCases),
      'claim_id': serializer.toJson<String>(claimId),
      'is_test_data': serializer.toJson<int>(isTestData),
    };
  }

  ConcentrationRecord copyWith({
    String? recordId,
    String? substanceId,
    String? category,
    String? specimenCode,
    String? population,
    String? valueType,
    Value<double?> valueLow = const Value.absent(),
    Value<double?> valueHigh = const Value.absent(),
    Value<double?> valueCentral = const Value.absent(),
    String? unit,
    Value<int?> nCases = const Value.absent(),
    String? claimId,
    int? isTestData,
  }) => ConcentrationRecord(
    recordId: recordId ?? this.recordId,
    substanceId: substanceId ?? this.substanceId,
    category: category ?? this.category,
    specimenCode: specimenCode ?? this.specimenCode,
    population: population ?? this.population,
    valueType: valueType ?? this.valueType,
    valueLow: valueLow.present ? valueLow.value : this.valueLow,
    valueHigh: valueHigh.present ? valueHigh.value : this.valueHigh,
    valueCentral: valueCentral.present ? valueCentral.value : this.valueCentral,
    unit: unit ?? this.unit,
    nCases: nCases.present ? nCases.value : this.nCases,
    claimId: claimId ?? this.claimId,
    isTestData: isTestData ?? this.isTestData,
  );
  ConcentrationRecord copyWithCompanion(ConcentrationRecordsCompanion data) {
    return ConcentrationRecord(
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      substanceId: data.substanceId.present
          ? data.substanceId.value
          : this.substanceId,
      category: data.category.present ? data.category.value : this.category,
      specimenCode: data.specimenCode.present
          ? data.specimenCode.value
          : this.specimenCode,
      population: data.population.present
          ? data.population.value
          : this.population,
      valueType: data.valueType.present ? data.valueType.value : this.valueType,
      valueLow: data.valueLow.present ? data.valueLow.value : this.valueLow,
      valueHigh: data.valueHigh.present ? data.valueHigh.value : this.valueHigh,
      valueCentral: data.valueCentral.present
          ? data.valueCentral.value
          : this.valueCentral,
      unit: data.unit.present ? data.unit.value : this.unit,
      nCases: data.nCases.present ? data.nCases.value : this.nCases,
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      isTestData: data.isTestData.present
          ? data.isTestData.value
          : this.isTestData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConcentrationRecord(')
          ..write('recordId: $recordId, ')
          ..write('substanceId: $substanceId, ')
          ..write('category: $category, ')
          ..write('specimenCode: $specimenCode, ')
          ..write('population: $population, ')
          ..write('valueType: $valueType, ')
          ..write('valueLow: $valueLow, ')
          ..write('valueHigh: $valueHigh, ')
          ..write('valueCentral: $valueCentral, ')
          ..write('unit: $unit, ')
          ..write('nCases: $nCases, ')
          ..write('claimId: $claimId, ')
          ..write('isTestData: $isTestData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    recordId,
    substanceId,
    category,
    specimenCode,
    population,
    valueType,
    valueLow,
    valueHigh,
    valueCentral,
    unit,
    nCases,
    claimId,
    isTestData,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConcentrationRecord &&
          other.recordId == this.recordId &&
          other.substanceId == this.substanceId &&
          other.category == this.category &&
          other.specimenCode == this.specimenCode &&
          other.population == this.population &&
          other.valueType == this.valueType &&
          other.valueLow == this.valueLow &&
          other.valueHigh == this.valueHigh &&
          other.valueCentral == this.valueCentral &&
          other.unit == this.unit &&
          other.nCases == this.nCases &&
          other.claimId == this.claimId &&
          other.isTestData == this.isTestData);
}

class ConcentrationRecordsCompanion
    extends UpdateCompanion<ConcentrationRecord> {
  final Value<String> recordId;
  final Value<String> substanceId;
  final Value<String> category;
  final Value<String> specimenCode;
  final Value<String> population;
  final Value<String> valueType;
  final Value<double?> valueLow;
  final Value<double?> valueHigh;
  final Value<double?> valueCentral;
  final Value<String> unit;
  final Value<int?> nCases;
  final Value<String> claimId;
  final Value<int> isTestData;
  const ConcentrationRecordsCompanion({
    this.recordId = const Value.absent(),
    this.substanceId = const Value.absent(),
    this.category = const Value.absent(),
    this.specimenCode = const Value.absent(),
    this.population = const Value.absent(),
    this.valueType = const Value.absent(),
    this.valueLow = const Value.absent(),
    this.valueHigh = const Value.absent(),
    this.valueCentral = const Value.absent(),
    this.unit = const Value.absent(),
    this.nCases = const Value.absent(),
    this.claimId = const Value.absent(),
    this.isTestData = const Value.absent(),
  });
  ConcentrationRecordsCompanion.insert({
    required String recordId,
    required String substanceId,
    required String category,
    required String specimenCode,
    required String population,
    required String valueType,
    this.valueLow = const Value.absent(),
    this.valueHigh = const Value.absent(),
    this.valueCentral = const Value.absent(),
    required String unit,
    this.nCases = const Value.absent(),
    required String claimId,
    this.isTestData = const Value.absent(),
  }) : recordId = Value(recordId),
       substanceId = Value(substanceId),
       category = Value(category),
       specimenCode = Value(specimenCode),
       population = Value(population),
       valueType = Value(valueType),
       unit = Value(unit),
       claimId = Value(claimId);
  static Insertable<ConcentrationRecord> custom({
    Expression<String>? recordId,
    Expression<String>? substanceId,
    Expression<String>? category,
    Expression<String>? specimenCode,
    Expression<String>? population,
    Expression<String>? valueType,
    Expression<double>? valueLow,
    Expression<double>? valueHigh,
    Expression<double>? valueCentral,
    Expression<String>? unit,
    Expression<int>? nCases,
    Expression<String>? claimId,
    Expression<int>? isTestData,
  }) {
    return RawValuesInsertable({
      if (recordId != null) 'record_id': recordId,
      if (substanceId != null) 'substance_id': substanceId,
      if (category != null) 'category': category,
      if (specimenCode != null) 'specimen_code': specimenCode,
      if (population != null) 'population': population,
      if (valueType != null) 'value_type': valueType,
      if (valueLow != null) 'value_low': valueLow,
      if (valueHigh != null) 'value_high': valueHigh,
      if (valueCentral != null) 'value_central': valueCentral,
      if (unit != null) 'unit': unit,
      if (nCases != null) 'n_cases': nCases,
      if (claimId != null) 'claim_id': claimId,
      if (isTestData != null) 'is_test_data': isTestData,
    });
  }

  ConcentrationRecordsCompanion copyWith({
    Value<String>? recordId,
    Value<String>? substanceId,
    Value<String>? category,
    Value<String>? specimenCode,
    Value<String>? population,
    Value<String>? valueType,
    Value<double?>? valueLow,
    Value<double?>? valueHigh,
    Value<double?>? valueCentral,
    Value<String>? unit,
    Value<int?>? nCases,
    Value<String>? claimId,
    Value<int>? isTestData,
  }) {
    return ConcentrationRecordsCompanion(
      recordId: recordId ?? this.recordId,
      substanceId: substanceId ?? this.substanceId,
      category: category ?? this.category,
      specimenCode: specimenCode ?? this.specimenCode,
      population: population ?? this.population,
      valueType: valueType ?? this.valueType,
      valueLow: valueLow ?? this.valueLow,
      valueHigh: valueHigh ?? this.valueHigh,
      valueCentral: valueCentral ?? this.valueCentral,
      unit: unit ?? this.unit,
      nCases: nCases ?? this.nCases,
      claimId: claimId ?? this.claimId,
      isTestData: isTestData ?? this.isTestData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (substanceId.present) {
      map['substance_id'] = Variable<String>(substanceId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (specimenCode.present) {
      map['specimen_code'] = Variable<String>(specimenCode.value);
    }
    if (population.present) {
      map['population'] = Variable<String>(population.value);
    }
    if (valueType.present) {
      map['value_type'] = Variable<String>(valueType.value);
    }
    if (valueLow.present) {
      map['value_low'] = Variable<double>(valueLow.value);
    }
    if (valueHigh.present) {
      map['value_high'] = Variable<double>(valueHigh.value);
    }
    if (valueCentral.present) {
      map['value_central'] = Variable<double>(valueCentral.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (nCases.present) {
      map['n_cases'] = Variable<int>(nCases.value);
    }
    if (claimId.present) {
      map['claim_id'] = Variable<String>(claimId.value);
    }
    if (isTestData.present) {
      map['is_test_data'] = Variable<int>(isTestData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConcentrationRecordsCompanion(')
          ..write('recordId: $recordId, ')
          ..write('substanceId: $substanceId, ')
          ..write('category: $category, ')
          ..write('specimenCode: $specimenCode, ')
          ..write('population: $population, ')
          ..write('valueType: $valueType, ')
          ..write('valueLow: $valueLow, ')
          ..write('valueHigh: $valueHigh, ')
          ..write('valueCentral: $valueCentral, ')
          ..write('unit: $unit, ')
          ..write('nCases: $nCases, ')
          ..write('claimId: $claimId, ')
          ..write('isTestData: $isTestData')
          ..write(')'))
        .toString();
  }
}

class SearchTerms extends Table with TableInfo<SearchTerms, SearchTermRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SearchTerms(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _termIdMeta = const VerificationMeta('termId');
  late final GeneratedColumn<int> termId = GeneratedColumn<int>(
    'term_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _searchKeyMeta = const VerificationMeta(
    'searchKey',
  );
  late final GeneratedColumn<String> searchKey = GeneratedColumn<String>(
    'search_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _termKindMeta = const VerificationMeta(
    'termKind',
  );
  late final GeneratedColumn<String> termKind = GeneratedColumn<String>(
    'term_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1.0',
    defaultValue: const CustomExpression('1.0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    termId,
    entityType,
    entityId,
    category,
    lang,
    term,
    searchKey,
    termKind,
    weight,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_terms';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchTermRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('term_id')) {
      context.handle(
        _termIdMeta,
        termId.isAcceptableOrUnknown(data['term_id']!, _termIdMeta),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('search_key')) {
      context.handle(
        _searchKeyMeta,
        searchKey.isAcceptableOrUnknown(data['search_key']!, _searchKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_searchKeyMeta);
    }
    if (data.containsKey('term_kind')) {
      context.handle(
        _termKindMeta,
        termKind.isAcceptableOrUnknown(data['term_kind']!, _termKindMeta),
      );
    } else if (isInserting) {
      context.missing(_termKindMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {termId};
  @override
  SearchTermRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchTermRow(
      termId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}term_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      ),
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      searchKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_key'],
      )!,
      termKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_kind'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
    );
  }

  @override
  SearchTerms createAlias(String alias) {
    return SearchTerms(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SearchTermRow extends DataClass implements Insertable<SearchTermRow> {
  final int termId;
  final String entityType;
  final String entityId;
  final String category;
  final String? lang;
  final String term;
  final String searchKey;
  final String termKind;
  final double weight;
  const SearchTermRow({
    required this.termId,
    required this.entityType,
    required this.entityId,
    required this.category,
    this.lang,
    required this.term,
    required this.searchKey,
    required this.termKind,
    required this.weight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['term_id'] = Variable<int>(termId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || lang != null) {
      map['lang'] = Variable<String>(lang);
    }
    map['term'] = Variable<String>(term);
    map['search_key'] = Variable<String>(searchKey);
    map['term_kind'] = Variable<String>(termKind);
    map['weight'] = Variable<double>(weight);
    return map;
  }

  SearchTermsCompanion toCompanion(bool nullToAbsent) {
    return SearchTermsCompanion(
      termId: Value(termId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      category: Value(category),
      lang: lang == null && nullToAbsent ? const Value.absent() : Value(lang),
      term: Value(term),
      searchKey: Value(searchKey),
      termKind: Value(termKind),
      weight: Value(weight),
    );
  }

  factory SearchTermRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchTermRow(
      termId: serializer.fromJson<int>(json['term_id']),
      entityType: serializer.fromJson<String>(json['entity_type']),
      entityId: serializer.fromJson<String>(json['entity_id']),
      category: serializer.fromJson<String>(json['category']),
      lang: serializer.fromJson<String?>(json['lang']),
      term: serializer.fromJson<String>(json['term']),
      searchKey: serializer.fromJson<String>(json['search_key']),
      termKind: serializer.fromJson<String>(json['term_kind']),
      weight: serializer.fromJson<double>(json['weight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'term_id': serializer.toJson<int>(termId),
      'entity_type': serializer.toJson<String>(entityType),
      'entity_id': serializer.toJson<String>(entityId),
      'category': serializer.toJson<String>(category),
      'lang': serializer.toJson<String?>(lang),
      'term': serializer.toJson<String>(term),
      'search_key': serializer.toJson<String>(searchKey),
      'term_kind': serializer.toJson<String>(termKind),
      'weight': serializer.toJson<double>(weight),
    };
  }

  SearchTermRow copyWith({
    int? termId,
    String? entityType,
    String? entityId,
    String? category,
    Value<String?> lang = const Value.absent(),
    String? term,
    String? searchKey,
    String? termKind,
    double? weight,
  }) => SearchTermRow(
    termId: termId ?? this.termId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    category: category ?? this.category,
    lang: lang.present ? lang.value : this.lang,
    term: term ?? this.term,
    searchKey: searchKey ?? this.searchKey,
    termKind: termKind ?? this.termKind,
    weight: weight ?? this.weight,
  );
  SearchTermRow copyWithCompanion(SearchTermsCompanion data) {
    return SearchTermRow(
      termId: data.termId.present ? data.termId.value : this.termId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      category: data.category.present ? data.category.value : this.category,
      lang: data.lang.present ? data.lang.value : this.lang,
      term: data.term.present ? data.term.value : this.term,
      searchKey: data.searchKey.present ? data.searchKey.value : this.searchKey,
      termKind: data.termKind.present ? data.termKind.value : this.termKind,
      weight: data.weight.present ? data.weight.value : this.weight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchTermRow(')
          ..write('termId: $termId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('category: $category, ')
          ..write('lang: $lang, ')
          ..write('term: $term, ')
          ..write('searchKey: $searchKey, ')
          ..write('termKind: $termKind, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    termId,
    entityType,
    entityId,
    category,
    lang,
    term,
    searchKey,
    termKind,
    weight,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchTermRow &&
          other.termId == this.termId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.category == this.category &&
          other.lang == this.lang &&
          other.term == this.term &&
          other.searchKey == this.searchKey &&
          other.termKind == this.termKind &&
          other.weight == this.weight);
}

class SearchTermsCompanion extends UpdateCompanion<SearchTermRow> {
  final Value<int> termId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> category;
  final Value<String?> lang;
  final Value<String> term;
  final Value<String> searchKey;
  final Value<String> termKind;
  final Value<double> weight;
  const SearchTermsCompanion({
    this.termId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.category = const Value.absent(),
    this.lang = const Value.absent(),
    this.term = const Value.absent(),
    this.searchKey = const Value.absent(),
    this.termKind = const Value.absent(),
    this.weight = const Value.absent(),
  });
  SearchTermsCompanion.insert({
    this.termId = const Value.absent(),
    required String entityType,
    required String entityId,
    required String category,
    this.lang = const Value.absent(),
    required String term,
    required String searchKey,
    required String termKind,
    this.weight = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       category = Value(category),
       term = Value(term),
       searchKey = Value(searchKey),
       termKind = Value(termKind);
  static Insertable<SearchTermRow> custom({
    Expression<int>? termId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? category,
    Expression<String>? lang,
    Expression<String>? term,
    Expression<String>? searchKey,
    Expression<String>? termKind,
    Expression<double>? weight,
  }) {
    return RawValuesInsertable({
      if (termId != null) 'term_id': termId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (category != null) 'category': category,
      if (lang != null) 'lang': lang,
      if (term != null) 'term': term,
      if (searchKey != null) 'search_key': searchKey,
      if (termKind != null) 'term_kind': termKind,
      if (weight != null) 'weight': weight,
    });
  }

  SearchTermsCompanion copyWith({
    Value<int>? termId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? category,
    Value<String?>? lang,
    Value<String>? term,
    Value<String>? searchKey,
    Value<String>? termKind,
    Value<double>? weight,
  }) {
    return SearchTermsCompanion(
      termId: termId ?? this.termId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      category: category ?? this.category,
      lang: lang ?? this.lang,
      term: term ?? this.term,
      searchKey: searchKey ?? this.searchKey,
      termKind: termKind ?? this.termKind,
      weight: weight ?? this.weight,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (termId.present) {
      map['term_id'] = Variable<int>(termId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (searchKey.present) {
      map['search_key'] = Variable<String>(searchKey.value);
    }
    if (termKind.present) {
      map['term_kind'] = Variable<String>(termKind.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchTermsCompanion(')
          ..write('termId: $termId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('category: $category, ')
          ..write('lang: $lang, ')
          ..write('term: $term, ')
          ..write('searchKey: $searchKey, ')
          ..write('termKind: $termKind, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }
}

class SearchFtsTri extends Table
    with
        TableInfo<SearchFtsTri, SearchFtsTriData>,
        VirtualTableInfo<SearchFtsTri, SearchFtsTriData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SearchFtsTri(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _searchKeyMeta = const VerificationMeta(
    'searchKey',
  );
  late final GeneratedColumn<String> searchKey = GeneratedColumn<String>(
    'search_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [searchKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_fts_tri';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchFtsTriData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('search_key')) {
      context.handle(
        _searchKeyMeta,
        searchKey.isAcceptableOrUnknown(data['search_key']!, _searchKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_searchKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  SearchFtsTriData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchFtsTriData(
      searchKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_key'],
      )!,
    );
  }

  @override
  SearchFtsTri createAlias(String alias) {
    return SearchFtsTri(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(search_key, content=\'search_terms\', content_rowid=\'term_id\', tokenize=\'trigram\')';
}

class SearchFtsTriData extends DataClass
    implements Insertable<SearchFtsTriData> {
  final String searchKey;
  const SearchFtsTriData({required this.searchKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['search_key'] = Variable<String>(searchKey);
    return map;
  }

  SearchFtsTriCompanion toCompanion(bool nullToAbsent) {
    return SearchFtsTriCompanion(searchKey: Value(searchKey));
  }

  factory SearchFtsTriData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchFtsTriData(
      searchKey: serializer.fromJson<String>(json['search_key']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'search_key': serializer.toJson<String>(searchKey),
    };
  }

  SearchFtsTriData copyWith({String? searchKey}) =>
      SearchFtsTriData(searchKey: searchKey ?? this.searchKey);
  SearchFtsTriData copyWithCompanion(SearchFtsTriCompanion data) {
    return SearchFtsTriData(
      searchKey: data.searchKey.present ? data.searchKey.value : this.searchKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchFtsTriData(')
          ..write('searchKey: $searchKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => searchKey.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchFtsTriData && other.searchKey == this.searchKey);
}

class SearchFtsTriCompanion extends UpdateCompanion<SearchFtsTriData> {
  final Value<String> searchKey;
  final Value<int> rowid;
  const SearchFtsTriCompanion({
    this.searchKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchFtsTriCompanion.insert({
    required String searchKey,
    this.rowid = const Value.absent(),
  }) : searchKey = Value(searchKey);
  static Insertable<SearchFtsTriData> custom({
    Expression<String>? searchKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (searchKey != null) 'search_key': searchKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchFtsTriCompanion copyWith({
    Value<String>? searchKey,
    Value<int>? rowid,
  }) {
    return SearchFtsTriCompanion(
      searchKey: searchKey ?? this.searchKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (searchKey.present) {
      map['search_key'] = Variable<String>(searchKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchFtsTriCompanion(')
          ..write('searchKey: $searchKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ResearchRecords extends Table
    with TableInfo<ResearchRecords, ResearchRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ResearchRecords(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _researchIdMeta = const VerificationMeta(
    'researchId',
  );
  late final GeneratedColumn<String> researchId = GeneratedColumn<String>(
    'research_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (kind IN (\'journal_article\', \'review\', \'systematic_review\', \'meta_analysis\', \'case_report\', \'conference_abstract\', \'conference_paper\', \'dissertation\', \'thesis\', \'official_report\', \'standard\', \'guideline\', \'validation_study\', \'case_series\'))',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _authorsJsonMeta = const VerificationMeta(
    'authorsJson',
  );
  late final GeneratedColumn<String> authorsJson = GeneratedColumn<String>(
    'authors_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'[]\'',
    defaultValue: const CustomExpression('\'[]\''),
  );
  static const VerificationMeta _organizationMeta = const VerificationMeta(
    'organization',
  );
  late final GeneratedColumn<String> organization = GeneratedColumn<String>(
    'organization',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _containerMeta = const VerificationMeta(
    'container',
  );
  late final GeneratedColumn<String> container = GeneratedColumn<String>(
    'container',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _pubYearMeta = const VerificationMeta(
    'pubYear',
  );
  late final GeneratedColumn<String> pubYear = GeneratedColumn<String>(
    'pub_year',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _doiMeta = const VerificationMeta('doi');
  late final GeneratedColumn<String> doi = GeneratedColumn<String>(
    'doi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _pmidMeta = const VerificationMeta('pmid');
  late final GeneratedColumn<String> pmid = GeneratedColumn<String>(
    'pmid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _pmcidMeta = const VerificationMeta('pmcid');
  late final GeneratedColumn<String> pmcid = GeneratedColumn<String>(
    'pmcid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _handleMeta = const VerificationMeta('handle');
  late final GeneratedColumn<String> handle = GeneratedColumn<String>(
    'handle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _degreeMeta = const VerificationMeta('degree');
  late final GeneratedColumn<String> degree = GeneratedColumn<String>(
    'degree',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _openAccessMeta = const VerificationMeta(
    'openAccess',
  );
  late final GeneratedColumn<String> openAccess = GeneratedColumn<String>(
    'open_access',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sourceApiMeta = const VerificationMeta(
    'sourceApi',
  );
  late final GeneratedColumn<String> sourceApi = GeneratedColumn<String>(
    'source_api',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _accessedDateMeta = const VerificationMeta(
    'accessedDate',
  );
  late final GeneratedColumn<String> accessedDate = GeneratedColumn<String>(
    'accessed_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _evidenceLevelMeta = const VerificationMeta(
    'evidenceLevel',
  );
  late final GeneratedColumn<String> evidenceLevel = GeneratedColumn<String>(
    'evidence_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _peerReviewedMeta = const VerificationMeta(
    'peerReviewed',
  );
  late final GeneratedColumn<int> peerReviewed = GeneratedColumn<int>(
    'peer_reviewed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (review_status IN (\'DRAFT\', \'VERIFIED\', \'REVIEWED\', \'NEEDS_REVIEW\', \'OUTDATED\', \'REJECTED\'))',
  );
  static const VerificationMeta _isTestDataMeta = const VerificationMeta(
    'isTestData',
  );
  late final GeneratedColumn<int> isTestData = GeneratedColumn<int>(
    'is_test_data',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _forensicRelevanceMeta = const VerificationMeta(
    'forensicRelevance',
  );
  late final GeneratedColumn<String> forensicRelevance =
      GeneratedColumn<String>(
        'forensic_relevance',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'NOT NULL DEFAULT \'unassessed\' CHECK (forensic_relevance IN (\'unassessed\', \'direct\', \'supporting\', \'background\'))',
        defaultValue: const CustomExpression('\'unassessed\''),
      );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    researchId,
    kind,
    title,
    authorsJson,
    organization,
    container,
    pubYear,
    doi,
    pmid,
    pmcid,
    handle,
    url,
    degree,
    openAccess,
    sourceApi,
    accessedDate,
    evidenceLevel,
    peerReviewed,
    reviewStatus,
    isTestData,
    forensicRelevance,
    language,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'research_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResearchRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('research_id')) {
      context.handle(
        _researchIdMeta,
        researchId.isAcceptableOrUnknown(data['research_id']!, _researchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_researchIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('authors_json')) {
      context.handle(
        _authorsJsonMeta,
        authorsJson.isAcceptableOrUnknown(
          data['authors_json']!,
          _authorsJsonMeta,
        ),
      );
    }
    if (data.containsKey('organization')) {
      context.handle(
        _organizationMeta,
        organization.isAcceptableOrUnknown(
          data['organization']!,
          _organizationMeta,
        ),
      );
    }
    if (data.containsKey('container')) {
      context.handle(
        _containerMeta,
        container.isAcceptableOrUnknown(data['container']!, _containerMeta),
      );
    }
    if (data.containsKey('pub_year')) {
      context.handle(
        _pubYearMeta,
        pubYear.isAcceptableOrUnknown(data['pub_year']!, _pubYearMeta),
      );
    }
    if (data.containsKey('doi')) {
      context.handle(
        _doiMeta,
        doi.isAcceptableOrUnknown(data['doi']!, _doiMeta),
      );
    }
    if (data.containsKey('pmid')) {
      context.handle(
        _pmidMeta,
        pmid.isAcceptableOrUnknown(data['pmid']!, _pmidMeta),
      );
    }
    if (data.containsKey('pmcid')) {
      context.handle(
        _pmcidMeta,
        pmcid.isAcceptableOrUnknown(data['pmcid']!, _pmcidMeta),
      );
    }
    if (data.containsKey('handle')) {
      context.handle(
        _handleMeta,
        handle.isAcceptableOrUnknown(data['handle']!, _handleMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('degree')) {
      context.handle(
        _degreeMeta,
        degree.isAcceptableOrUnknown(data['degree']!, _degreeMeta),
      );
    }
    if (data.containsKey('open_access')) {
      context.handle(
        _openAccessMeta,
        openAccess.isAcceptableOrUnknown(data['open_access']!, _openAccessMeta),
      );
    }
    if (data.containsKey('source_api')) {
      context.handle(
        _sourceApiMeta,
        sourceApi.isAcceptableOrUnknown(data['source_api']!, _sourceApiMeta),
      );
    }
    if (data.containsKey('accessed_date')) {
      context.handle(
        _accessedDateMeta,
        accessedDate.isAcceptableOrUnknown(
          data['accessed_date']!,
          _accessedDateMeta,
        ),
      );
    }
    if (data.containsKey('evidence_level')) {
      context.handle(
        _evidenceLevelMeta,
        evidenceLevel.isAcceptableOrUnknown(
          data['evidence_level']!,
          _evidenceLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_evidenceLevelMeta);
    }
    if (data.containsKey('peer_reviewed')) {
      context.handle(
        _peerReviewedMeta,
        peerReviewed.isAcceptableOrUnknown(
          data['peer_reviewed']!,
          _peerReviewedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peerReviewedMeta);
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewStatusMeta);
    }
    if (data.containsKey('is_test_data')) {
      context.handle(
        _isTestDataMeta,
        isTestData.isAcceptableOrUnknown(
          data['is_test_data']!,
          _isTestDataMeta,
        ),
      );
    }
    if (data.containsKey('forensic_relevance')) {
      context.handle(
        _forensicRelevanceMeta,
        forensicRelevance.isAcceptableOrUnknown(
          data['forensic_relevance']!,
          _forensicRelevanceMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {researchId};
  @override
  ResearchRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResearchRecord(
      researchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}research_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      authorsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authors_json'],
      )!,
      organization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization'],
      ),
      container: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}container'],
      ),
      pubYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pub_year'],
      ),
      doi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doi'],
      ),
      pmid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pmid'],
      ),
      pmcid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pmcid'],
      ),
      handle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}handle'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      degree: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}degree'],
      ),
      openAccess: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open_access'],
      ),
      sourceApi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_api'],
      ),
      accessedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accessed_date'],
      ),
      evidenceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_level'],
      )!,
      peerReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}peer_reviewed'],
      )!,
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      isTestData: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_test_data'],
      )!,
      forensicRelevance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}forensic_relevance'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
    );
  }

  @override
  ResearchRecords createAlias(String alias) {
    return ResearchRecords(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'CHECK(doi IS NOT NULL OR pmid IS NOT NULL OR handle IS NOT NULL OR url IS NOT NULL)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ResearchRecord extends DataClass implements Insertable<ResearchRecord> {
  final String researchId;
  final String kind;
  final String title;
  final String authorsJson;
  final String? organization;
  final String? container;
  final String? pubYear;
  final String? doi;
  final String? pmid;
  final String? pmcid;
  final String? handle;
  final String? url;
  final String? degree;
  final String? openAccess;
  final String? sourceApi;
  final String? accessedDate;
  final String evidenceLevel;
  final int peerReviewed;
  final String reviewStatus;
  final int isTestData;

  /// PHASE 6: forensik dolzarblik dalil sifatidan alohida (reviewer belgilaydi).
  final String forensicRelevance;
  final String? language;
  const ResearchRecord({
    required this.researchId,
    required this.kind,
    required this.title,
    required this.authorsJson,
    this.organization,
    this.container,
    this.pubYear,
    this.doi,
    this.pmid,
    this.pmcid,
    this.handle,
    this.url,
    this.degree,
    this.openAccess,
    this.sourceApi,
    this.accessedDate,
    required this.evidenceLevel,
    required this.peerReviewed,
    required this.reviewStatus,
    required this.isTestData,
    required this.forensicRelevance,
    this.language,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['research_id'] = Variable<String>(researchId);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['authors_json'] = Variable<String>(authorsJson);
    if (!nullToAbsent || organization != null) {
      map['organization'] = Variable<String>(organization);
    }
    if (!nullToAbsent || container != null) {
      map['container'] = Variable<String>(container);
    }
    if (!nullToAbsent || pubYear != null) {
      map['pub_year'] = Variable<String>(pubYear);
    }
    if (!nullToAbsent || doi != null) {
      map['doi'] = Variable<String>(doi);
    }
    if (!nullToAbsent || pmid != null) {
      map['pmid'] = Variable<String>(pmid);
    }
    if (!nullToAbsent || pmcid != null) {
      map['pmcid'] = Variable<String>(pmcid);
    }
    if (!nullToAbsent || handle != null) {
      map['handle'] = Variable<String>(handle);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || degree != null) {
      map['degree'] = Variable<String>(degree);
    }
    if (!nullToAbsent || openAccess != null) {
      map['open_access'] = Variable<String>(openAccess);
    }
    if (!nullToAbsent || sourceApi != null) {
      map['source_api'] = Variable<String>(sourceApi);
    }
    if (!nullToAbsent || accessedDate != null) {
      map['accessed_date'] = Variable<String>(accessedDate);
    }
    map['evidence_level'] = Variable<String>(evidenceLevel);
    map['peer_reviewed'] = Variable<int>(peerReviewed);
    map['review_status'] = Variable<String>(reviewStatus);
    map['is_test_data'] = Variable<int>(isTestData);
    map['forensic_relevance'] = Variable<String>(forensicRelevance);
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    return map;
  }

  ResearchRecordsCompanion toCompanion(bool nullToAbsent) {
    return ResearchRecordsCompanion(
      researchId: Value(researchId),
      kind: Value(kind),
      title: Value(title),
      authorsJson: Value(authorsJson),
      organization: organization == null && nullToAbsent
          ? const Value.absent()
          : Value(organization),
      container: container == null && nullToAbsent
          ? const Value.absent()
          : Value(container),
      pubYear: pubYear == null && nullToAbsent
          ? const Value.absent()
          : Value(pubYear),
      doi: doi == null && nullToAbsent ? const Value.absent() : Value(doi),
      pmid: pmid == null && nullToAbsent ? const Value.absent() : Value(pmid),
      pmcid: pmcid == null && nullToAbsent
          ? const Value.absent()
          : Value(pmcid),
      handle: handle == null && nullToAbsent
          ? const Value.absent()
          : Value(handle),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      degree: degree == null && nullToAbsent
          ? const Value.absent()
          : Value(degree),
      openAccess: openAccess == null && nullToAbsent
          ? const Value.absent()
          : Value(openAccess),
      sourceApi: sourceApi == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceApi),
      accessedDate: accessedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(accessedDate),
      evidenceLevel: Value(evidenceLevel),
      peerReviewed: Value(peerReviewed),
      reviewStatus: Value(reviewStatus),
      isTestData: Value(isTestData),
      forensicRelevance: Value(forensicRelevance),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
    );
  }

  factory ResearchRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResearchRecord(
      researchId: serializer.fromJson<String>(json['research_id']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      authorsJson: serializer.fromJson<String>(json['authors_json']),
      organization: serializer.fromJson<String?>(json['organization']),
      container: serializer.fromJson<String?>(json['container']),
      pubYear: serializer.fromJson<String?>(json['pub_year']),
      doi: serializer.fromJson<String?>(json['doi']),
      pmid: serializer.fromJson<String?>(json['pmid']),
      pmcid: serializer.fromJson<String?>(json['pmcid']),
      handle: serializer.fromJson<String?>(json['handle']),
      url: serializer.fromJson<String?>(json['url']),
      degree: serializer.fromJson<String?>(json['degree']),
      openAccess: serializer.fromJson<String?>(json['open_access']),
      sourceApi: serializer.fromJson<String?>(json['source_api']),
      accessedDate: serializer.fromJson<String?>(json['accessed_date']),
      evidenceLevel: serializer.fromJson<String>(json['evidence_level']),
      peerReviewed: serializer.fromJson<int>(json['peer_reviewed']),
      reviewStatus: serializer.fromJson<String>(json['review_status']),
      isTestData: serializer.fromJson<int>(json['is_test_data']),
      forensicRelevance: serializer.fromJson<String>(
        json['forensic_relevance'],
      ),
      language: serializer.fromJson<String?>(json['language']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'research_id': serializer.toJson<String>(researchId),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'authors_json': serializer.toJson<String>(authorsJson),
      'organization': serializer.toJson<String?>(organization),
      'container': serializer.toJson<String?>(container),
      'pub_year': serializer.toJson<String?>(pubYear),
      'doi': serializer.toJson<String?>(doi),
      'pmid': serializer.toJson<String?>(pmid),
      'pmcid': serializer.toJson<String?>(pmcid),
      'handle': serializer.toJson<String?>(handle),
      'url': serializer.toJson<String?>(url),
      'degree': serializer.toJson<String?>(degree),
      'open_access': serializer.toJson<String?>(openAccess),
      'source_api': serializer.toJson<String?>(sourceApi),
      'accessed_date': serializer.toJson<String?>(accessedDate),
      'evidence_level': serializer.toJson<String>(evidenceLevel),
      'peer_reviewed': serializer.toJson<int>(peerReviewed),
      'review_status': serializer.toJson<String>(reviewStatus),
      'is_test_data': serializer.toJson<int>(isTestData),
      'forensic_relevance': serializer.toJson<String>(forensicRelevance),
      'language': serializer.toJson<String?>(language),
    };
  }

  ResearchRecord copyWith({
    String? researchId,
    String? kind,
    String? title,
    String? authorsJson,
    Value<String?> organization = const Value.absent(),
    Value<String?> container = const Value.absent(),
    Value<String?> pubYear = const Value.absent(),
    Value<String?> doi = const Value.absent(),
    Value<String?> pmid = const Value.absent(),
    Value<String?> pmcid = const Value.absent(),
    Value<String?> handle = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<String?> degree = const Value.absent(),
    Value<String?> openAccess = const Value.absent(),
    Value<String?> sourceApi = const Value.absent(),
    Value<String?> accessedDate = const Value.absent(),
    String? evidenceLevel,
    int? peerReviewed,
    String? reviewStatus,
    int? isTestData,
    String? forensicRelevance,
    Value<String?> language = const Value.absent(),
  }) => ResearchRecord(
    researchId: researchId ?? this.researchId,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    authorsJson: authorsJson ?? this.authorsJson,
    organization: organization.present ? organization.value : this.organization,
    container: container.present ? container.value : this.container,
    pubYear: pubYear.present ? pubYear.value : this.pubYear,
    doi: doi.present ? doi.value : this.doi,
    pmid: pmid.present ? pmid.value : this.pmid,
    pmcid: pmcid.present ? pmcid.value : this.pmcid,
    handle: handle.present ? handle.value : this.handle,
    url: url.present ? url.value : this.url,
    degree: degree.present ? degree.value : this.degree,
    openAccess: openAccess.present ? openAccess.value : this.openAccess,
    sourceApi: sourceApi.present ? sourceApi.value : this.sourceApi,
    accessedDate: accessedDate.present ? accessedDate.value : this.accessedDate,
    evidenceLevel: evidenceLevel ?? this.evidenceLevel,
    peerReviewed: peerReviewed ?? this.peerReviewed,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    isTestData: isTestData ?? this.isTestData,
    forensicRelevance: forensicRelevance ?? this.forensicRelevance,
    language: language.present ? language.value : this.language,
  );
  ResearchRecord copyWithCompanion(ResearchRecordsCompanion data) {
    return ResearchRecord(
      researchId: data.researchId.present
          ? data.researchId.value
          : this.researchId,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      authorsJson: data.authorsJson.present
          ? data.authorsJson.value
          : this.authorsJson,
      organization: data.organization.present
          ? data.organization.value
          : this.organization,
      container: data.container.present ? data.container.value : this.container,
      pubYear: data.pubYear.present ? data.pubYear.value : this.pubYear,
      doi: data.doi.present ? data.doi.value : this.doi,
      pmid: data.pmid.present ? data.pmid.value : this.pmid,
      pmcid: data.pmcid.present ? data.pmcid.value : this.pmcid,
      handle: data.handle.present ? data.handle.value : this.handle,
      url: data.url.present ? data.url.value : this.url,
      degree: data.degree.present ? data.degree.value : this.degree,
      openAccess: data.openAccess.present
          ? data.openAccess.value
          : this.openAccess,
      sourceApi: data.sourceApi.present ? data.sourceApi.value : this.sourceApi,
      accessedDate: data.accessedDate.present
          ? data.accessedDate.value
          : this.accessedDate,
      evidenceLevel: data.evidenceLevel.present
          ? data.evidenceLevel.value
          : this.evidenceLevel,
      peerReviewed: data.peerReviewed.present
          ? data.peerReviewed.value
          : this.peerReviewed,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      isTestData: data.isTestData.present
          ? data.isTestData.value
          : this.isTestData,
      forensicRelevance: data.forensicRelevance.present
          ? data.forensicRelevance.value
          : this.forensicRelevance,
      language: data.language.present ? data.language.value : this.language,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResearchRecord(')
          ..write('researchId: $researchId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('authorsJson: $authorsJson, ')
          ..write('organization: $organization, ')
          ..write('container: $container, ')
          ..write('pubYear: $pubYear, ')
          ..write('doi: $doi, ')
          ..write('pmid: $pmid, ')
          ..write('pmcid: $pmcid, ')
          ..write('handle: $handle, ')
          ..write('url: $url, ')
          ..write('degree: $degree, ')
          ..write('openAccess: $openAccess, ')
          ..write('sourceApi: $sourceApi, ')
          ..write('accessedDate: $accessedDate, ')
          ..write('evidenceLevel: $evidenceLevel, ')
          ..write('peerReviewed: $peerReviewed, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('isTestData: $isTestData, ')
          ..write('forensicRelevance: $forensicRelevance, ')
          ..write('language: $language')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    researchId,
    kind,
    title,
    authorsJson,
    organization,
    container,
    pubYear,
    doi,
    pmid,
    pmcid,
    handle,
    url,
    degree,
    openAccess,
    sourceApi,
    accessedDate,
    evidenceLevel,
    peerReviewed,
    reviewStatus,
    isTestData,
    forensicRelevance,
    language,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResearchRecord &&
          other.researchId == this.researchId &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.authorsJson == this.authorsJson &&
          other.organization == this.organization &&
          other.container == this.container &&
          other.pubYear == this.pubYear &&
          other.doi == this.doi &&
          other.pmid == this.pmid &&
          other.pmcid == this.pmcid &&
          other.handle == this.handle &&
          other.url == this.url &&
          other.degree == this.degree &&
          other.openAccess == this.openAccess &&
          other.sourceApi == this.sourceApi &&
          other.accessedDate == this.accessedDate &&
          other.evidenceLevel == this.evidenceLevel &&
          other.peerReviewed == this.peerReviewed &&
          other.reviewStatus == this.reviewStatus &&
          other.isTestData == this.isTestData &&
          other.forensicRelevance == this.forensicRelevance &&
          other.language == this.language);
}

class ResearchRecordsCompanion extends UpdateCompanion<ResearchRecord> {
  final Value<String> researchId;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> authorsJson;
  final Value<String?> organization;
  final Value<String?> container;
  final Value<String?> pubYear;
  final Value<String?> doi;
  final Value<String?> pmid;
  final Value<String?> pmcid;
  final Value<String?> handle;
  final Value<String?> url;
  final Value<String?> degree;
  final Value<String?> openAccess;
  final Value<String?> sourceApi;
  final Value<String?> accessedDate;
  final Value<String> evidenceLevel;
  final Value<int> peerReviewed;
  final Value<String> reviewStatus;
  final Value<int> isTestData;
  final Value<String> forensicRelevance;
  final Value<String?> language;
  const ResearchRecordsCompanion({
    this.researchId = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.authorsJson = const Value.absent(),
    this.organization = const Value.absent(),
    this.container = const Value.absent(),
    this.pubYear = const Value.absent(),
    this.doi = const Value.absent(),
    this.pmid = const Value.absent(),
    this.pmcid = const Value.absent(),
    this.handle = const Value.absent(),
    this.url = const Value.absent(),
    this.degree = const Value.absent(),
    this.openAccess = const Value.absent(),
    this.sourceApi = const Value.absent(),
    this.accessedDate = const Value.absent(),
    this.evidenceLevel = const Value.absent(),
    this.peerReviewed = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.isTestData = const Value.absent(),
    this.forensicRelevance = const Value.absent(),
    this.language = const Value.absent(),
  });
  ResearchRecordsCompanion.insert({
    required String researchId,
    required String kind,
    required String title,
    this.authorsJson = const Value.absent(),
    this.organization = const Value.absent(),
    this.container = const Value.absent(),
    this.pubYear = const Value.absent(),
    this.doi = const Value.absent(),
    this.pmid = const Value.absent(),
    this.pmcid = const Value.absent(),
    this.handle = const Value.absent(),
    this.url = const Value.absent(),
    this.degree = const Value.absent(),
    this.openAccess = const Value.absent(),
    this.sourceApi = const Value.absent(),
    this.accessedDate = const Value.absent(),
    required String evidenceLevel,
    required int peerReviewed,
    required String reviewStatus,
    this.isTestData = const Value.absent(),
    this.forensicRelevance = const Value.absent(),
    this.language = const Value.absent(),
  }) : researchId = Value(researchId),
       kind = Value(kind),
       title = Value(title),
       evidenceLevel = Value(evidenceLevel),
       peerReviewed = Value(peerReviewed),
       reviewStatus = Value(reviewStatus);
  static Insertable<ResearchRecord> custom({
    Expression<String>? researchId,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? authorsJson,
    Expression<String>? organization,
    Expression<String>? container,
    Expression<String>? pubYear,
    Expression<String>? doi,
    Expression<String>? pmid,
    Expression<String>? pmcid,
    Expression<String>? handle,
    Expression<String>? url,
    Expression<String>? degree,
    Expression<String>? openAccess,
    Expression<String>? sourceApi,
    Expression<String>? accessedDate,
    Expression<String>? evidenceLevel,
    Expression<int>? peerReviewed,
    Expression<String>? reviewStatus,
    Expression<int>? isTestData,
    Expression<String>? forensicRelevance,
    Expression<String>? language,
  }) {
    return RawValuesInsertable({
      if (researchId != null) 'research_id': researchId,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (authorsJson != null) 'authors_json': authorsJson,
      if (organization != null) 'organization': organization,
      if (container != null) 'container': container,
      if (pubYear != null) 'pub_year': pubYear,
      if (doi != null) 'doi': doi,
      if (pmid != null) 'pmid': pmid,
      if (pmcid != null) 'pmcid': pmcid,
      if (handle != null) 'handle': handle,
      if (url != null) 'url': url,
      if (degree != null) 'degree': degree,
      if (openAccess != null) 'open_access': openAccess,
      if (sourceApi != null) 'source_api': sourceApi,
      if (accessedDate != null) 'accessed_date': accessedDate,
      if (evidenceLevel != null) 'evidence_level': evidenceLevel,
      if (peerReviewed != null) 'peer_reviewed': peerReviewed,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (isTestData != null) 'is_test_data': isTestData,
      if (forensicRelevance != null) 'forensic_relevance': forensicRelevance,
      if (language != null) 'language': language,
    });
  }

  ResearchRecordsCompanion copyWith({
    Value<String>? researchId,
    Value<String>? kind,
    Value<String>? title,
    Value<String>? authorsJson,
    Value<String?>? organization,
    Value<String?>? container,
    Value<String?>? pubYear,
    Value<String?>? doi,
    Value<String?>? pmid,
    Value<String?>? pmcid,
    Value<String?>? handle,
    Value<String?>? url,
    Value<String?>? degree,
    Value<String?>? openAccess,
    Value<String?>? sourceApi,
    Value<String?>? accessedDate,
    Value<String>? evidenceLevel,
    Value<int>? peerReviewed,
    Value<String>? reviewStatus,
    Value<int>? isTestData,
    Value<String>? forensicRelevance,
    Value<String?>? language,
  }) {
    return ResearchRecordsCompanion(
      researchId: researchId ?? this.researchId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      authorsJson: authorsJson ?? this.authorsJson,
      organization: organization ?? this.organization,
      container: container ?? this.container,
      pubYear: pubYear ?? this.pubYear,
      doi: doi ?? this.doi,
      pmid: pmid ?? this.pmid,
      pmcid: pmcid ?? this.pmcid,
      handle: handle ?? this.handle,
      url: url ?? this.url,
      degree: degree ?? this.degree,
      openAccess: openAccess ?? this.openAccess,
      sourceApi: sourceApi ?? this.sourceApi,
      accessedDate: accessedDate ?? this.accessedDate,
      evidenceLevel: evidenceLevel ?? this.evidenceLevel,
      peerReviewed: peerReviewed ?? this.peerReviewed,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      isTestData: isTestData ?? this.isTestData,
      forensicRelevance: forensicRelevance ?? this.forensicRelevance,
      language: language ?? this.language,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (researchId.present) {
      map['research_id'] = Variable<String>(researchId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (authorsJson.present) {
      map['authors_json'] = Variable<String>(authorsJson.value);
    }
    if (organization.present) {
      map['organization'] = Variable<String>(organization.value);
    }
    if (container.present) {
      map['container'] = Variable<String>(container.value);
    }
    if (pubYear.present) {
      map['pub_year'] = Variable<String>(pubYear.value);
    }
    if (doi.present) {
      map['doi'] = Variable<String>(doi.value);
    }
    if (pmid.present) {
      map['pmid'] = Variable<String>(pmid.value);
    }
    if (pmcid.present) {
      map['pmcid'] = Variable<String>(pmcid.value);
    }
    if (handle.present) {
      map['handle'] = Variable<String>(handle.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (degree.present) {
      map['degree'] = Variable<String>(degree.value);
    }
    if (openAccess.present) {
      map['open_access'] = Variable<String>(openAccess.value);
    }
    if (sourceApi.present) {
      map['source_api'] = Variable<String>(sourceApi.value);
    }
    if (accessedDate.present) {
      map['accessed_date'] = Variable<String>(accessedDate.value);
    }
    if (evidenceLevel.present) {
      map['evidence_level'] = Variable<String>(evidenceLevel.value);
    }
    if (peerReviewed.present) {
      map['peer_reviewed'] = Variable<int>(peerReviewed.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (isTestData.present) {
      map['is_test_data'] = Variable<int>(isTestData.value);
    }
    if (forensicRelevance.present) {
      map['forensic_relevance'] = Variable<String>(forensicRelevance.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchRecordsCompanion(')
          ..write('researchId: $researchId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('authorsJson: $authorsJson, ')
          ..write('organization: $organization, ')
          ..write('container: $container, ')
          ..write('pubYear: $pubYear, ')
          ..write('doi: $doi, ')
          ..write('pmid: $pmid, ')
          ..write('pmcid: $pmcid, ')
          ..write('handle: $handle, ')
          ..write('url: $url, ')
          ..write('degree: $degree, ')
          ..write('openAccess: $openAccess, ')
          ..write('sourceApi: $sourceApi, ')
          ..write('accessedDate: $accessedDate, ')
          ..write('evidenceLevel: $evidenceLevel, ')
          ..write('peerReviewed: $peerReviewed, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('isTestData: $isTestData, ')
          ..write('forensicRelevance: $forensicRelevance, ')
          ..write('language: $language')
          ..write(')'))
        .toString();
  }
}

class EntityLinks extends Table with TableInfo<EntityLinks, EntityLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  EntityLinks(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fromIdMeta = const VerificationMeta('fromId');
  late final GeneratedColumn<String> fromId = GeneratedColumn<String>(
    'from_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _toIdMeta = const VerificationMeta('toId');
  late final GeneratedColumn<String> toId = GeneratedColumn<String>(
    'to_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (relation IN (\'analysed_by\', \'metabolism_co_mention\', \'confirmed_by\', \'used_in\', \'research\', \'related_topic\'))',
  );
  static const VerificationMeta _basisMeta = const VerificationMeta('basis');
  late final GeneratedColumn<String> basis = GeneratedColumn<String>(
    'basis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(basis) > 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [fromId, toId, relation, basis];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntityLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('from_id')) {
      context.handle(
        _fromIdMeta,
        fromId.isAcceptableOrUnknown(data['from_id']!, _fromIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fromIdMeta);
    }
    if (data.containsKey('to_id')) {
      context.handle(
        _toIdMeta,
        toId.isAcceptableOrUnknown(data['to_id']!, _toIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toIdMeta);
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    } else if (isInserting) {
      context.missing(_relationMeta);
    }
    if (data.containsKey('basis')) {
      context.handle(
        _basisMeta,
        basis.isAcceptableOrUnknown(data['basis']!, _basisMeta),
      );
    } else if (isInserting) {
      context.missing(_basisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fromId, toId, relation};
  @override
  EntityLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntityLink(
      fromId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_id'],
      )!,
      toId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_id'],
      )!,
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      )!,
      basis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}basis'],
      )!,
    );
  }

  @override
  EntityLinks createAlias(String alias) {
    return EntityLinks(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(from_id, to_id, relation)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class EntityLink extends DataClass implements Insertable<EntityLink> {
  final String fromId;
  final String toId;
  final String relation;
  final String basis;
  const EntityLink({
    required this.fromId,
    required this.toId,
    required this.relation,
    required this.basis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['from_id'] = Variable<String>(fromId);
    map['to_id'] = Variable<String>(toId);
    map['relation'] = Variable<String>(relation);
    map['basis'] = Variable<String>(basis);
    return map;
  }

  EntityLinksCompanion toCompanion(bool nullToAbsent) {
    return EntityLinksCompanion(
      fromId: Value(fromId),
      toId: Value(toId),
      relation: Value(relation),
      basis: Value(basis),
    );
  }

  factory EntityLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntityLink(
      fromId: serializer.fromJson<String>(json['from_id']),
      toId: serializer.fromJson<String>(json['to_id']),
      relation: serializer.fromJson<String>(json['relation']),
      basis: serializer.fromJson<String>(json['basis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'from_id': serializer.toJson<String>(fromId),
      'to_id': serializer.toJson<String>(toId),
      'relation': serializer.toJson<String>(relation),
      'basis': serializer.toJson<String>(basis),
    };
  }

  EntityLink copyWith({
    String? fromId,
    String? toId,
    String? relation,
    String? basis,
  }) => EntityLink(
    fromId: fromId ?? this.fromId,
    toId: toId ?? this.toId,
    relation: relation ?? this.relation,
    basis: basis ?? this.basis,
  );
  EntityLink copyWithCompanion(EntityLinksCompanion data) {
    return EntityLink(
      fromId: data.fromId.present ? data.fromId.value : this.fromId,
      toId: data.toId.present ? data.toId.value : this.toId,
      relation: data.relation.present ? data.relation.value : this.relation,
      basis: data.basis.present ? data.basis.value : this.basis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntityLink(')
          ..write('fromId: $fromId, ')
          ..write('toId: $toId, ')
          ..write('relation: $relation, ')
          ..write('basis: $basis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fromId, toId, relation, basis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityLink &&
          other.fromId == this.fromId &&
          other.toId == this.toId &&
          other.relation == this.relation &&
          other.basis == this.basis);
}

class EntityLinksCompanion extends UpdateCompanion<EntityLink> {
  final Value<String> fromId;
  final Value<String> toId;
  final Value<String> relation;
  final Value<String> basis;
  const EntityLinksCompanion({
    this.fromId = const Value.absent(),
    this.toId = const Value.absent(),
    this.relation = const Value.absent(),
    this.basis = const Value.absent(),
  });
  EntityLinksCompanion.insert({
    required String fromId,
    required String toId,
    required String relation,
    required String basis,
  }) : fromId = Value(fromId),
       toId = Value(toId),
       relation = Value(relation),
       basis = Value(basis);
  static Insertable<EntityLink> custom({
    Expression<String>? fromId,
    Expression<String>? toId,
    Expression<String>? relation,
    Expression<String>? basis,
  }) {
    return RawValuesInsertable({
      if (fromId != null) 'from_id': fromId,
      if (toId != null) 'to_id': toId,
      if (relation != null) 'relation': relation,
      if (basis != null) 'basis': basis,
    });
  }

  EntityLinksCompanion copyWith({
    Value<String>? fromId,
    Value<String>? toId,
    Value<String>? relation,
    Value<String>? basis,
  }) {
    return EntityLinksCompanion(
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      relation: relation ?? this.relation,
      basis: basis ?? this.basis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fromId.present) {
      map['from_id'] = Variable<String>(fromId.value);
    }
    if (toId.present) {
      map['to_id'] = Variable<String>(toId.value);
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (basis.present) {
      map['basis'] = Variable<String>(basis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityLinksCompanion(')
          ..write('fromId: $fromId, ')
          ..write('toId: $toId, ')
          ..write('relation: $relation, ')
          ..write('basis: $basis')
          ..write(')'))
        .toString();
  }
}

class Images extends Table with TableInfo<Images, Image> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Images(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _imageIdMeta = const VerificationMeta(
    'imageId',
  );
  late final GeneratedColumn<String> imageId = GeneratedColumn<String>(
    'image_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (kind IN (\'chemical_structure\', \'schematic\', \'chromatogram\', \'mass_spectrum\', \'micrograph\', \'tlc_plate\', \'colour_test\', \'photo\'))',
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _titleJsonMeta = const VerificationMeta(
    'titleJson',
  );
  late final GeneratedColumn<String> titleJson = GeneratedColumn<String>(
    'title_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _altJsonMeta = const VerificationMeta(
    'altJson',
  );
  late final GeneratedColumn<String> altJson = GeneratedColumn<String>(
    'alt_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _captionOriginalMeta = const VerificationMeta(
    'captionOriginal',
  );
  late final GeneratedColumn<String> captionOriginal = GeneratedColumn<String>(
    'caption_original',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _creatorMeta = const VerificationMeta(
    'creator',
  );
  late final GeneratedColumn<String> creator = GeneratedColumn<String>(
    'creator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _doiMeta = const VerificationMeta('doi');
  late final GeneratedColumn<String> doi = GeneratedColumn<String>(
    'doi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _licenseMeta = const VerificationMeta(
    'license',
  );
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
    'license',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _attributionMeta = const VerificationMeta(
    'attribution',
  );
  late final GeneratedColumn<String> attribution = GeneratedColumn<String>(
    'attribution',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(attribution) > 0)',
  );
  static const VerificationMeta _isOriginalDiagramMeta = const VerificationMeta(
    'isOriginalDiagram',
  );
  late final GeneratedColumn<int> isOriginalDiagram = GeneratedColumn<int>(
    'is_original_diagram',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _representsRealDataMeta =
      const VerificationMeta('representsRealData');
  late final GeneratedColumn<int> representsRealData = GeneratedColumn<int>(
    'represents_real_data',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _graphicMeta = const VerificationMeta(
    'graphic',
  );
  late final GeneratedColumn<int> graphic = GeneratedColumn<int>(
    'graphic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (graphic = 0)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _accessedDateMeta = const VerificationMeta(
    'accessedDate',
  );
  late final GeneratedColumn<String> accessedDate = GeneratedColumn<String>(
    'accessed_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    imageId,
    kind,
    entityId,
    mimeType,
    bytes,
    width,
    height,
    sha256,
    titleJson,
    altJson,
    captionOriginal,
    creator,
    sourceName,
    sourceUrl,
    doi,
    license,
    attribution,
    isOriginalDiagram,
    representsRealData,
    graphic,
    accessedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'images';
  @override
  VerificationContext validateIntegrity(
    Insertable<Image> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('image_id')) {
      context.handle(
        _imageIdMeta,
        imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_imageIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('title_json')) {
      context.handle(
        _titleJsonMeta,
        titleJson.isAcceptableOrUnknown(data['title_json']!, _titleJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_titleJsonMeta);
    }
    if (data.containsKey('alt_json')) {
      context.handle(
        _altJsonMeta,
        altJson.isAcceptableOrUnknown(data['alt_json']!, _altJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_altJsonMeta);
    }
    if (data.containsKey('caption_original')) {
      context.handle(
        _captionOriginalMeta,
        captionOriginal.isAcceptableOrUnknown(
          data['caption_original']!,
          _captionOriginalMeta,
        ),
      );
    }
    if (data.containsKey('creator')) {
      context.handle(
        _creatorMeta,
        creator.isAcceptableOrUnknown(data['creator']!, _creatorMeta),
      );
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('doi')) {
      context.handle(
        _doiMeta,
        doi.isAcceptableOrUnknown(data['doi']!, _doiMeta),
      );
    }
    if (data.containsKey('license')) {
      context.handle(
        _licenseMeta,
        license.isAcceptableOrUnknown(data['license']!, _licenseMeta),
      );
    } else if (isInserting) {
      context.missing(_licenseMeta);
    }
    if (data.containsKey('attribution')) {
      context.handle(
        _attributionMeta,
        attribution.isAcceptableOrUnknown(
          data['attribution']!,
          _attributionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attributionMeta);
    }
    if (data.containsKey('is_original_diagram')) {
      context.handle(
        _isOriginalDiagramMeta,
        isOriginalDiagram.isAcceptableOrUnknown(
          data['is_original_diagram']!,
          _isOriginalDiagramMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isOriginalDiagramMeta);
    }
    if (data.containsKey('represents_real_data')) {
      context.handle(
        _representsRealDataMeta,
        representsRealData.isAcceptableOrUnknown(
          data['represents_real_data']!,
          _representsRealDataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_representsRealDataMeta);
    }
    if (data.containsKey('graphic')) {
      context.handle(
        _graphicMeta,
        graphic.isAcceptableOrUnknown(data['graphic']!, _graphicMeta),
      );
    }
    if (data.containsKey('accessed_date')) {
      context.handle(
        _accessedDateMeta,
        accessedDate.isAcceptableOrUnknown(
          data['accessed_date']!,
          _accessedDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {imageId};
  @override
  Image map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Image(
      imageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      titleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_json'],
      )!,
      altJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alt_json'],
      )!,
      captionOriginal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption_original'],
      ),
      creator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator'],
      ),
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      doi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doi'],
      ),
      license: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license'],
      )!,
      attribution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attribution'],
      )!,
      isOriginalDiagram: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_original_diagram'],
      )!,
      representsRealData: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}represents_real_data'],
      )!,
      graphic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}graphic'],
      )!,
      accessedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accessed_date'],
      ),
    );
  }

  @override
  Images createAlias(String alias) {
    return Images(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK(NOT(is_original_diagram = 1 AND represents_real_data = 1))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Image extends DataClass implements Insertable<Image> {
  final String imageId;
  final String kind;
  final String entityId;
  final String mimeType;
  final Uint8List bytes;
  final int? width;
  final int? height;
  final String sha256;
  final String titleJson;
  final String altJson;
  final String? captionOriginal;
  final String? creator;
  final String? sourceName;
  final String? sourceUrl;
  final String? doi;
  final String license;
  final String attribution;
  final int isOriginalDiagram;
  final int representsRealData;
  final int graphic;
  final String? accessedDate;
  const Image({
    required this.imageId,
    required this.kind,
    required this.entityId,
    required this.mimeType,
    required this.bytes,
    this.width,
    this.height,
    required this.sha256,
    required this.titleJson,
    required this.altJson,
    this.captionOriginal,
    this.creator,
    this.sourceName,
    this.sourceUrl,
    this.doi,
    required this.license,
    required this.attribution,
    required this.isOriginalDiagram,
    required this.representsRealData,
    required this.graphic,
    this.accessedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['image_id'] = Variable<String>(imageId);
    map['kind'] = Variable<String>(kind);
    map['entity_id'] = Variable<String>(entityId);
    map['mime_type'] = Variable<String>(mimeType);
    map['bytes'] = Variable<Uint8List>(bytes);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['sha256'] = Variable<String>(sha256);
    map['title_json'] = Variable<String>(titleJson);
    map['alt_json'] = Variable<String>(altJson);
    if (!nullToAbsent || captionOriginal != null) {
      map['caption_original'] = Variable<String>(captionOriginal);
    }
    if (!nullToAbsent || creator != null) {
      map['creator'] = Variable<String>(creator);
    }
    if (!nullToAbsent || sourceName != null) {
      map['source_name'] = Variable<String>(sourceName);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || doi != null) {
      map['doi'] = Variable<String>(doi);
    }
    map['license'] = Variable<String>(license);
    map['attribution'] = Variable<String>(attribution);
    map['is_original_diagram'] = Variable<int>(isOriginalDiagram);
    map['represents_real_data'] = Variable<int>(representsRealData);
    map['graphic'] = Variable<int>(graphic);
    if (!nullToAbsent || accessedDate != null) {
      map['accessed_date'] = Variable<String>(accessedDate);
    }
    return map;
  }

  ImagesCompanion toCompanion(bool nullToAbsent) {
    return ImagesCompanion(
      imageId: Value(imageId),
      kind: Value(kind),
      entityId: Value(entityId),
      mimeType: Value(mimeType),
      bytes: Value(bytes),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      sha256: Value(sha256),
      titleJson: Value(titleJson),
      altJson: Value(altJson),
      captionOriginal: captionOriginal == null && nullToAbsent
          ? const Value.absent()
          : Value(captionOriginal),
      creator: creator == null && nullToAbsent
          ? const Value.absent()
          : Value(creator),
      sourceName: sourceName == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceName),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      doi: doi == null && nullToAbsent ? const Value.absent() : Value(doi),
      license: Value(license),
      attribution: Value(attribution),
      isOriginalDiagram: Value(isOriginalDiagram),
      representsRealData: Value(representsRealData),
      graphic: Value(graphic),
      accessedDate: accessedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(accessedDate),
    );
  }

  factory Image.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Image(
      imageId: serializer.fromJson<String>(json['image_id']),
      kind: serializer.fromJson<String>(json['kind']),
      entityId: serializer.fromJson<String>(json['entity_id']),
      mimeType: serializer.fromJson<String>(json['mime_type']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      sha256: serializer.fromJson<String>(json['sha256']),
      titleJson: serializer.fromJson<String>(json['title_json']),
      altJson: serializer.fromJson<String>(json['alt_json']),
      captionOriginal: serializer.fromJson<String?>(json['caption_original']),
      creator: serializer.fromJson<String?>(json['creator']),
      sourceName: serializer.fromJson<String?>(json['source_name']),
      sourceUrl: serializer.fromJson<String?>(json['source_url']),
      doi: serializer.fromJson<String?>(json['doi']),
      license: serializer.fromJson<String>(json['license']),
      attribution: serializer.fromJson<String>(json['attribution']),
      isOriginalDiagram: serializer.fromJson<int>(json['is_original_diagram']),
      representsRealData: serializer.fromJson<int>(
        json['represents_real_data'],
      ),
      graphic: serializer.fromJson<int>(json['graphic']),
      accessedDate: serializer.fromJson<String?>(json['accessed_date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'image_id': serializer.toJson<String>(imageId),
      'kind': serializer.toJson<String>(kind),
      'entity_id': serializer.toJson<String>(entityId),
      'mime_type': serializer.toJson<String>(mimeType),
      'bytes': serializer.toJson<Uint8List>(bytes),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'sha256': serializer.toJson<String>(sha256),
      'title_json': serializer.toJson<String>(titleJson),
      'alt_json': serializer.toJson<String>(altJson),
      'caption_original': serializer.toJson<String?>(captionOriginal),
      'creator': serializer.toJson<String?>(creator),
      'source_name': serializer.toJson<String?>(sourceName),
      'source_url': serializer.toJson<String?>(sourceUrl),
      'doi': serializer.toJson<String?>(doi),
      'license': serializer.toJson<String>(license),
      'attribution': serializer.toJson<String>(attribution),
      'is_original_diagram': serializer.toJson<int>(isOriginalDiagram),
      'represents_real_data': serializer.toJson<int>(representsRealData),
      'graphic': serializer.toJson<int>(graphic),
      'accessed_date': serializer.toJson<String?>(accessedDate),
    };
  }

  Image copyWith({
    String? imageId,
    String? kind,
    String? entityId,
    String? mimeType,
    Uint8List? bytes,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    String? sha256,
    String? titleJson,
    String? altJson,
    Value<String?> captionOriginal = const Value.absent(),
    Value<String?> creator = const Value.absent(),
    Value<String?> sourceName = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    Value<String?> doi = const Value.absent(),
    String? license,
    String? attribution,
    int? isOriginalDiagram,
    int? representsRealData,
    int? graphic,
    Value<String?> accessedDate = const Value.absent(),
  }) => Image(
    imageId: imageId ?? this.imageId,
    kind: kind ?? this.kind,
    entityId: entityId ?? this.entityId,
    mimeType: mimeType ?? this.mimeType,
    bytes: bytes ?? this.bytes,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    sha256: sha256 ?? this.sha256,
    titleJson: titleJson ?? this.titleJson,
    altJson: altJson ?? this.altJson,
    captionOriginal: captionOriginal.present
        ? captionOriginal.value
        : this.captionOriginal,
    creator: creator.present ? creator.value : this.creator,
    sourceName: sourceName.present ? sourceName.value : this.sourceName,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    doi: doi.present ? doi.value : this.doi,
    license: license ?? this.license,
    attribution: attribution ?? this.attribution,
    isOriginalDiagram: isOriginalDiagram ?? this.isOriginalDiagram,
    representsRealData: representsRealData ?? this.representsRealData,
    graphic: graphic ?? this.graphic,
    accessedDate: accessedDate.present ? accessedDate.value : this.accessedDate,
  );
  Image copyWithCompanion(ImagesCompanion data) {
    return Image(
      imageId: data.imageId.present ? data.imageId.value : this.imageId,
      kind: data.kind.present ? data.kind.value : this.kind,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      titleJson: data.titleJson.present ? data.titleJson.value : this.titleJson,
      altJson: data.altJson.present ? data.altJson.value : this.altJson,
      captionOriginal: data.captionOriginal.present
          ? data.captionOriginal.value
          : this.captionOriginal,
      creator: data.creator.present ? data.creator.value : this.creator,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      doi: data.doi.present ? data.doi.value : this.doi,
      license: data.license.present ? data.license.value : this.license,
      attribution: data.attribution.present
          ? data.attribution.value
          : this.attribution,
      isOriginalDiagram: data.isOriginalDiagram.present
          ? data.isOriginalDiagram.value
          : this.isOriginalDiagram,
      representsRealData: data.representsRealData.present
          ? data.representsRealData.value
          : this.representsRealData,
      graphic: data.graphic.present ? data.graphic.value : this.graphic,
      accessedDate: data.accessedDate.present
          ? data.accessedDate.value
          : this.accessedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Image(')
          ..write('imageId: $imageId, ')
          ..write('kind: $kind, ')
          ..write('entityId: $entityId, ')
          ..write('mimeType: $mimeType, ')
          ..write('bytes: $bytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sha256: $sha256, ')
          ..write('titleJson: $titleJson, ')
          ..write('altJson: $altJson, ')
          ..write('captionOriginal: $captionOriginal, ')
          ..write('creator: $creator, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('doi: $doi, ')
          ..write('license: $license, ')
          ..write('attribution: $attribution, ')
          ..write('isOriginalDiagram: $isOriginalDiagram, ')
          ..write('representsRealData: $representsRealData, ')
          ..write('graphic: $graphic, ')
          ..write('accessedDate: $accessedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    imageId,
    kind,
    entityId,
    mimeType,
    $driftBlobEquality.hash(bytes),
    width,
    height,
    sha256,
    titleJson,
    altJson,
    captionOriginal,
    creator,
    sourceName,
    sourceUrl,
    doi,
    license,
    attribution,
    isOriginalDiagram,
    representsRealData,
    graphic,
    accessedDate,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Image &&
          other.imageId == this.imageId &&
          other.kind == this.kind &&
          other.entityId == this.entityId &&
          other.mimeType == this.mimeType &&
          $driftBlobEquality.equals(other.bytes, this.bytes) &&
          other.width == this.width &&
          other.height == this.height &&
          other.sha256 == this.sha256 &&
          other.titleJson == this.titleJson &&
          other.altJson == this.altJson &&
          other.captionOriginal == this.captionOriginal &&
          other.creator == this.creator &&
          other.sourceName == this.sourceName &&
          other.sourceUrl == this.sourceUrl &&
          other.doi == this.doi &&
          other.license == this.license &&
          other.attribution == this.attribution &&
          other.isOriginalDiagram == this.isOriginalDiagram &&
          other.representsRealData == this.representsRealData &&
          other.graphic == this.graphic &&
          other.accessedDate == this.accessedDate);
}

class ImagesCompanion extends UpdateCompanion<Image> {
  final Value<String> imageId;
  final Value<String> kind;
  final Value<String> entityId;
  final Value<String> mimeType;
  final Value<Uint8List> bytes;
  final Value<int?> width;
  final Value<int?> height;
  final Value<String> sha256;
  final Value<String> titleJson;
  final Value<String> altJson;
  final Value<String?> captionOriginal;
  final Value<String?> creator;
  final Value<String?> sourceName;
  final Value<String?> sourceUrl;
  final Value<String?> doi;
  final Value<String> license;
  final Value<String> attribution;
  final Value<int> isOriginalDiagram;
  final Value<int> representsRealData;
  final Value<int> graphic;
  final Value<String?> accessedDate;
  final Value<int> rowid;
  const ImagesCompanion({
    this.imageId = const Value.absent(),
    this.kind = const Value.absent(),
    this.entityId = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.bytes = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.titleJson = const Value.absent(),
    this.altJson = const Value.absent(),
    this.captionOriginal = const Value.absent(),
    this.creator = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.doi = const Value.absent(),
    this.license = const Value.absent(),
    this.attribution = const Value.absent(),
    this.isOriginalDiagram = const Value.absent(),
    this.representsRealData = const Value.absent(),
    this.graphic = const Value.absent(),
    this.accessedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImagesCompanion.insert({
    required String imageId,
    required String kind,
    required String entityId,
    required String mimeType,
    required Uint8List bytes,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required String sha256,
    required String titleJson,
    required String altJson,
    this.captionOriginal = const Value.absent(),
    this.creator = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.doi = const Value.absent(),
    required String license,
    required String attribution,
    required int isOriginalDiagram,
    required int representsRealData,
    this.graphic = const Value.absent(),
    this.accessedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : imageId = Value(imageId),
       kind = Value(kind),
       entityId = Value(entityId),
       mimeType = Value(mimeType),
       bytes = Value(bytes),
       sha256 = Value(sha256),
       titleJson = Value(titleJson),
       altJson = Value(altJson),
       license = Value(license),
       attribution = Value(attribution),
       isOriginalDiagram = Value(isOriginalDiagram),
       representsRealData = Value(representsRealData);
  static Insertable<Image> custom({
    Expression<String>? imageId,
    Expression<String>? kind,
    Expression<String>? entityId,
    Expression<String>? mimeType,
    Expression<Uint8List>? bytes,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? sha256,
    Expression<String>? titleJson,
    Expression<String>? altJson,
    Expression<String>? captionOriginal,
    Expression<String>? creator,
    Expression<String>? sourceName,
    Expression<String>? sourceUrl,
    Expression<String>? doi,
    Expression<String>? license,
    Expression<String>? attribution,
    Expression<int>? isOriginalDiagram,
    Expression<int>? representsRealData,
    Expression<int>? graphic,
    Expression<String>? accessedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (imageId != null) 'image_id': imageId,
      if (kind != null) 'kind': kind,
      if (entityId != null) 'entity_id': entityId,
      if (mimeType != null) 'mime_type': mimeType,
      if (bytes != null) 'bytes': bytes,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (sha256 != null) 'sha256': sha256,
      if (titleJson != null) 'title_json': titleJson,
      if (altJson != null) 'alt_json': altJson,
      if (captionOriginal != null) 'caption_original': captionOriginal,
      if (creator != null) 'creator': creator,
      if (sourceName != null) 'source_name': sourceName,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (doi != null) 'doi': doi,
      if (license != null) 'license': license,
      if (attribution != null) 'attribution': attribution,
      if (isOriginalDiagram != null) 'is_original_diagram': isOriginalDiagram,
      if (representsRealData != null)
        'represents_real_data': representsRealData,
      if (graphic != null) 'graphic': graphic,
      if (accessedDate != null) 'accessed_date': accessedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImagesCompanion copyWith({
    Value<String>? imageId,
    Value<String>? kind,
    Value<String>? entityId,
    Value<String>? mimeType,
    Value<Uint8List>? bytes,
    Value<int?>? width,
    Value<int?>? height,
    Value<String>? sha256,
    Value<String>? titleJson,
    Value<String>? altJson,
    Value<String?>? captionOriginal,
    Value<String?>? creator,
    Value<String?>? sourceName,
    Value<String?>? sourceUrl,
    Value<String?>? doi,
    Value<String>? license,
    Value<String>? attribution,
    Value<int>? isOriginalDiagram,
    Value<int>? representsRealData,
    Value<int>? graphic,
    Value<String?>? accessedDate,
    Value<int>? rowid,
  }) {
    return ImagesCompanion(
      imageId: imageId ?? this.imageId,
      kind: kind ?? this.kind,
      entityId: entityId ?? this.entityId,
      mimeType: mimeType ?? this.mimeType,
      bytes: bytes ?? this.bytes,
      width: width ?? this.width,
      height: height ?? this.height,
      sha256: sha256 ?? this.sha256,
      titleJson: titleJson ?? this.titleJson,
      altJson: altJson ?? this.altJson,
      captionOriginal: captionOriginal ?? this.captionOriginal,
      creator: creator ?? this.creator,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      doi: doi ?? this.doi,
      license: license ?? this.license,
      attribution: attribution ?? this.attribution,
      isOriginalDiagram: isOriginalDiagram ?? this.isOriginalDiagram,
      representsRealData: representsRealData ?? this.representsRealData,
      graphic: graphic ?? this.graphic,
      accessedDate: accessedDate ?? this.accessedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (imageId.present) {
      map['image_id'] = Variable<String>(imageId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (titleJson.present) {
      map['title_json'] = Variable<String>(titleJson.value);
    }
    if (altJson.present) {
      map['alt_json'] = Variable<String>(altJson.value);
    }
    if (captionOriginal.present) {
      map['caption_original'] = Variable<String>(captionOriginal.value);
    }
    if (creator.present) {
      map['creator'] = Variable<String>(creator.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (doi.present) {
      map['doi'] = Variable<String>(doi.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    if (attribution.present) {
      map['attribution'] = Variable<String>(attribution.value);
    }
    if (isOriginalDiagram.present) {
      map['is_original_diagram'] = Variable<int>(isOriginalDiagram.value);
    }
    if (representsRealData.present) {
      map['represents_real_data'] = Variable<int>(representsRealData.value);
    }
    if (graphic.present) {
      map['graphic'] = Variable<int>(graphic.value);
    }
    if (accessedDate.present) {
      map['accessed_date'] = Variable<String>(accessedDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImagesCompanion(')
          ..write('imageId: $imageId, ')
          ..write('kind: $kind, ')
          ..write('entityId: $entityId, ')
          ..write('mimeType: $mimeType, ')
          ..write('bytes: $bytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sha256: $sha256, ')
          ..write('titleJson: $titleJson, ')
          ..write('altJson: $altJson, ')
          ..write('captionOriginal: $captionOriginal, ')
          ..write('creator: $creator, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('doi: $doi, ')
          ..write('license: $license, ')
          ..write('attribution: $attribution, ')
          ..write('isOriginalDiagram: $isOriginalDiagram, ')
          ..write('representsRealData: $representsRealData, ')
          ..write('graphic: $graphic, ')
          ..write('accessedDate: $accessedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ContentDatabase extends GeneratedDatabase {
  _$ContentDatabase(QueryExecutor e) : super(e);
  $ContentDatabaseManager get managers => $ContentDatabaseManager(this);
  late final ContentMeta contentMeta = ContentMeta(this);
  late final Sources sources = Sources(this);
  late final Jurisdictions jurisdictions = Jurisdictions(this);
  late final Authorities authorities = Authorities(this);
  late final JurisdictionalInstruments jurisdictionalInstruments =
      JurisdictionalInstruments(this);
  late final Index instrumentsByJurisdiction = Index(
    'instruments_by_jurisdiction',
    'CREATE INDEX instruments_by_jurisdiction ON jurisdictional_instruments (jurisdiction_id)',
  );
  late final JurisdictionalRules jurisdictionalRules = JurisdictionalRules(
    this,
  );
  late final Index rulesBySubject = Index(
    'rules_by_subject',
    'CREATE INDEX rules_by_subject ON jurisdictional_rules (subject_type, subject_id)',
  );
  late final KnowledgeEntities knowledgeEntities = KnowledgeEntities(this);
  late final Index knowledgeByType = Index(
    'knowledge_by_type',
    'CREATE INDEX knowledge_by_type ON knowledge_entities (entity_type, area)',
  );
  late final EntitySources entitySources = EntitySources(this);
  late final ClaimGroups claimGroups = ClaimGroups(this);
  late final Claims claims = Claims(this);
  late final Index claimsByEntity = Index(
    'claims_by_entity',
    'CREATE INDEX claims_by_entity ON claims (entity_type, entity_id, field)',
  );
  late final Citations citations = Citations(this);
  late final Reviewers reviewers = Reviewers(this);
  late final ReviewerDomains reviewerDomains = ReviewerDomains(this);
  late final Reviews reviews = Reviews(this);
  late final Substances substances = Substances(this);
  late final SubstanceI18n substanceI18n = SubstanceI18n(this);
  late final ExternalIdentifiers externalIdentifiers = ExternalIdentifiers(
    this,
  );
  late final ConcentrationRecords concentrationRecords = ConcentrationRecords(
    this,
  );
  late final SearchTerms searchTerms = SearchTerms(this);
  late final Index searchTermsKey = Index(
    'search_terms_key',
    'CREATE INDEX search_terms_key ON search_terms (search_key)',
  );
  late final SearchFtsTri searchFtsTri = SearchFtsTri(this);
  late final ResearchRecords researchRecords = ResearchRecords(this);
  late final Index researchByKind = Index(
    'research_by_kind',
    'CREATE INDEX research_by_kind ON research_records (kind)',
  );
  late final EntityLinks entityLinks = EntityLinks(this);
  late final Index linksByTo = Index(
    'links_by_to',
    'CREATE INDEX links_by_to ON entity_links (to_id)',
  );
  late final Images images = Images(this);
  late final Index imagesByEntity = Index(
    'images_by_entity',
    'CREATE INDEX images_by_entity ON images (entity_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contentMeta,
    sources,
    jurisdictions,
    authorities,
    jurisdictionalInstruments,
    instrumentsByJurisdiction,
    jurisdictionalRules,
    rulesBySubject,
    knowledgeEntities,
    knowledgeByType,
    entitySources,
    claimGroups,
    claims,
    claimsByEntity,
    citations,
    reviewers,
    reviewerDomains,
    reviews,
    substances,
    substanceI18n,
    externalIdentifiers,
    concentrationRecords,
    searchTerms,
    searchTermsKey,
    searchFtsTri,
    researchRecords,
    researchByKind,
    entityLinks,
    linksByTo,
    images,
    imagesByEntity,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $ContentMetaCreateCompanionBuilder = ContentMetaCompanion Function({
  required String metaKey,
  required String metaValue,
});
typedef $ContentMetaUpdateCompanionBuilder = ContentMetaCompanion Function({
  Value<String> metaKey,
  Value<String> metaValue,
});

class $ContentMetaFilterComposer
    extends Composer<_$ContentDatabase, ContentMeta> {
  $ContentMetaFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get metaKey => $composableBuilder(
    column: $table.metaKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metaValue => $composableBuilder(
    column: $table.metaValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $ContentMetaOrderingComposer
    extends Composer<_$ContentDatabase, ContentMeta> {
  $ContentMetaOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get metaKey => $composableBuilder(
    column: $table.metaKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metaValue => $composableBuilder(
    column: $table.metaValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ContentMetaAnnotationComposer
    extends Composer<_$ContentDatabase, ContentMeta> {
  $ContentMetaAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get metaKey =>
      $composableBuilder(column: $table.metaKey, builder: (column) => column);

  GeneratedColumn<String> get metaValue =>
      $composableBuilder(column: $table.metaValue, builder: (column) => column);
}

class $ContentMetaTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          ContentMeta,
          ContentMetaData,
          $ContentMetaFilterComposer,
          $ContentMetaOrderingComposer,
          $ContentMetaAnnotationComposer,
          $ContentMetaCreateCompanionBuilder,
          $ContentMetaUpdateCompanionBuilder,
          (
            ContentMetaData,
            BaseReferences<_$ContentDatabase, ContentMeta, ContentMetaData>,
          ),
          ContentMetaData,
          PrefetchHooks Function()
        > {
  $ContentMetaTableManager(_$ContentDatabase db, ContentMeta table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ContentMetaFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ContentMetaOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ContentMetaAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> metaKey = const Value.absent(),
            Value<String> metaValue = const Value.absent(),
          }) => ContentMetaCompanion(metaKey: metaKey, metaValue: metaValue),
          createCompanionCallback:
              ({required String metaKey, required String metaValue}) =>
                  ContentMetaCompanion.insert(
                    metaKey: metaKey,
                    metaValue: metaValue,
                  ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ContentMeta, ContentMetaData>(table),
                  BaseReferences<
                    _$ContentDatabase,
                    ContentMeta,
                    ContentMetaData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ContentMetaProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      ContentMeta,
      ContentMetaData,
      $ContentMetaFilterComposer,
      $ContentMetaOrderingComposer,
      $ContentMetaAnnotationComposer,
      $ContentMetaCreateCompanionBuilder,
      $ContentMetaUpdateCompanionBuilder,
      (
        ContentMetaData,
        BaseReferences<_$ContentDatabase, ContentMeta, ContentMetaData>,
      ),
      ContentMetaData,
      PrefetchHooks Function()
    >;
typedef $SourcesCreateCompanionBuilder = SourcesCompanion Function({
  required String sourceId,
  required String sourceType,
  required String title,
  Value<String> authorsJson,
  Value<String?> organization,
  Value<String?> journal,
  Value<int?> publicationYear,
  Value<String?> edition,
  Value<String?> doi,
  Value<String?> pmid,
  Value<String?> officialUrl,
  Value<String?> accessedDate,
  required int tier,
  required String evidenceLevel,
  required String licenseMode,
  Value<String?> licenseAgreementId,
  Value<int> identifierVerified,
  required String reviewStatus,
  Value<String?> lastReviewedAt,
  Value<int> version,
  Value<int> isTestData,
});
typedef $SourcesUpdateCompanionBuilder = SourcesCompanion Function({
  Value<String> sourceId,
  Value<String> sourceType,
  Value<String> title,
  Value<String> authorsJson,
  Value<String?> organization,
  Value<String?> journal,
  Value<int?> publicationYear,
  Value<String?> edition,
  Value<String?> doi,
  Value<String?> pmid,
  Value<String?> officialUrl,
  Value<String?> accessedDate,
  Value<int> tier,
  Value<String> evidenceLevel,
  Value<String> licenseMode,
  Value<String?> licenseAgreementId,
  Value<int> identifierVerified,
  Value<String> reviewStatus,
  Value<String?> lastReviewedAt,
  Value<int> version,
  Value<int> isTestData,
});

final class $SourcesReferences
    extends BaseReferences<_$ContentDatabase, Sources, Source> {
  $SourcesReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    JurisdictionalInstruments,
    List<JurisdictionalInstrument>
  >
  _jurisdictionalInstrumentsRefsTable(
    _$ContentDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jurisdictionalInstruments,
    aliasName:
        'sources__source_id__jurisdictional_instruments__official_source_id',
  );

  $JurisdictionalInstrumentsProcessedTableManager
  get jurisdictionalInstrumentsRefs {
    final manager =
        $JurisdictionalInstrumentsTableManager(
          $_db,
          $_db.jurisdictionalInstruments,
        ).filter(
          (f) => f.officialSourceId.sourceId.sqlEquals(
            $_itemColumn<String>('source_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _jurisdictionalInstrumentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<EntitySources, List<EntitySource>>
  _entitySourcesRefsTable(_$ContentDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.entitySources,
        aliasName: 'sources__source_id__entity_sources__source_id',
      );

  $EntitySourcesProcessedTableManager get entitySourcesRefs {
    final manager = $EntitySourcesTableManager($_db, $_db.entitySources).filter(
      (f) => f.sourceId.sourceId.sqlEquals($_itemColumn<String>('source_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_entitySourcesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Citations, List<Citation>> _citationsRefsTable(
    _$ContentDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.citations,
    aliasName: 'sources__source_id__citations__source_id',
  );

  $CitationsProcessedTableManager get citationsRefs {
    final manager = $CitationsTableManager($_db, $_db.citations).filter(
      (f) => f.sourceId.sourceId.sqlEquals($_itemColumn<String>('source_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_citationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<ExternalIdentifiers, List<ExternalIdentifier>>
  _externalIdentifiersRefsTable(_$ContentDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.externalIdentifiers,
        aliasName: 'sources__source_id__external_identifiers__source_id',
      );

  $ExternalIdentifiersProcessedTableManager get externalIdentifiersRefs {
    final manager =
        $ExternalIdentifiersTableManager($_db, $_db.externalIdentifiers).filter(
          (f) =>
              f.sourceId.sourceId.sqlEquals($_itemColumn<String>('source_id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _externalIdentifiersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $SourcesFilterComposer extends Composer<_$ContentDatabase, Sources> {
  $SourcesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorsJson => $composableBuilder(
    column: $table.authorsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journal => $composableBuilder(
    column: $table.journal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publicationYear => $composableBuilder(
    column: $table.publicationYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get edition => $composableBuilder(
    column: $table.edition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doi => $composableBuilder(
    column: $table.doi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pmid => $composableBuilder(
    column: $table.pmid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officialUrl => $composableBuilder(
    column: $table.officialUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessedDate => $composableBuilder(
    column: $table.accessedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceLevel => $composableBuilder(
    column: $table.evidenceLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseMode => $composableBuilder(
    column: $table.licenseMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseAgreementId => $composableBuilder(
    column: $table.licenseAgreementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get identifierVerified => $composableBuilder(
    column: $table.identifierVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> jurisdictionalInstrumentsRefs(
    Expression<bool> Function($JurisdictionalInstrumentsFilterComposer f) f,
  ) {
    final $JurisdictionalInstrumentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.jurisdictionalInstruments,
      getReferencedColumn: (t) => t.officialSourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionalInstrumentsFilterComposer(
            $db: $db,
            $table: $db.jurisdictionalInstruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entitySourcesRefs(
    Expression<bool> Function($EntitySourcesFilterComposer f) f,
  ) {
    final $EntitySourcesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.entitySources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitySourcesFilterComposer(
            $db: $db,
            $table: $db.entitySources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> citationsRefs(
    Expression<bool> Function($CitationsFilterComposer f) f,
  ) {
    final $CitationsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.citations,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CitationsFilterComposer(
            $db: $db,
            $table: $db.citations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> externalIdentifiersRefs(
    Expression<bool> Function($ExternalIdentifiersFilterComposer f) f,
  ) {
    final $ExternalIdentifiersFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.externalIdentifiers,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExternalIdentifiersFilterComposer(
            $db: $db,
            $table: $db.externalIdentifiers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SourcesOrderingComposer extends Composer<_$ContentDatabase, Sources> {
  $SourcesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorsJson => $composableBuilder(
    column: $table.authorsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journal => $composableBuilder(
    column: $table.journal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publicationYear => $composableBuilder(
    column: $table.publicationYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get edition => $composableBuilder(
    column: $table.edition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doi => $composableBuilder(
    column: $table.doi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pmid => $composableBuilder(
    column: $table.pmid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officialUrl => $composableBuilder(
    column: $table.officialUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessedDate => $composableBuilder(
    column: $table.accessedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceLevel => $composableBuilder(
    column: $table.evidenceLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseMode => $composableBuilder(
    column: $table.licenseMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseAgreementId => $composableBuilder(
    column: $table.licenseAgreementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get identifierVerified => $composableBuilder(
    column: $table.identifierVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SourcesAnnotationComposer extends Composer<_$ContentDatabase, Sources> {
  $SourcesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get authorsJson => $composableBuilder(
    column: $table.authorsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => column,
  );

  GeneratedColumn<String> get journal =>
      $composableBuilder(column: $table.journal, builder: (column) => column);

  GeneratedColumn<int> get publicationYear => $composableBuilder(
    column: $table.publicationYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get edition =>
      $composableBuilder(column: $table.edition, builder: (column) => column);

  GeneratedColumn<String> get doi =>
      $composableBuilder(column: $table.doi, builder: (column) => column);

  GeneratedColumn<String> get pmid =>
      $composableBuilder(column: $table.pmid, builder: (column) => column);

  GeneratedColumn<String> get officialUrl => $composableBuilder(
    column: $table.officialUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accessedDate => $composableBuilder(
    column: $table.accessedDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<String> get evidenceLevel => $composableBuilder(
    column: $table.evidenceLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get licenseMode => $composableBuilder(
    column: $table.licenseMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get licenseAgreementId => $composableBuilder(
    column: $table.licenseAgreementId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get identifierVerified => $composableBuilder(
    column: $table.identifierVerified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => column,
  );

  Expression<T> jurisdictionalInstrumentsRefs<T extends Object>(
    Expression<T> Function($JurisdictionalInstrumentsAnnotationComposer a) f,
  ) {
    final $JurisdictionalInstrumentsAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceId,
          referencedTable: $db.jurisdictionalInstruments,
          getReferencedColumn: (t) => t.officialSourceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $JurisdictionalInstrumentsAnnotationComposer(
                $db: $db,
                $table: $db.jurisdictionalInstruments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> entitySourcesRefs<T extends Object>(
    Expression<T> Function($EntitySourcesAnnotationComposer a) f,
  ) {
    final $EntitySourcesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.entitySources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitySourcesAnnotationComposer(
            $db: $db,
            $table: $db.entitySources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> citationsRefs<T extends Object>(
    Expression<T> Function($CitationsAnnotationComposer a) f,
  ) {
    final $CitationsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.citations,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CitationsAnnotationComposer(
            $db: $db,
            $table: $db.citations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> externalIdentifiersRefs<T extends Object>(
    Expression<T> Function($ExternalIdentifiersAnnotationComposer a) f,
  ) {
    final $ExternalIdentifiersAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.externalIdentifiers,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExternalIdentifiersAnnotationComposer(
            $db: $db,
            $table: $db.externalIdentifiers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SourcesTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          Sources,
          Source,
          $SourcesFilterComposer,
          $SourcesOrderingComposer,
          $SourcesAnnotationComposer,
          $SourcesCreateCompanionBuilder,
          $SourcesUpdateCompanionBuilder,
          (Source, $SourcesReferences),
          Source,
          PrefetchHooks Function({
            bool jurisdictionalInstrumentsRefs,
            bool entitySourcesRefs,
            bool citationsRefs,
            bool externalIdentifiersRefs,
          })
        > {
  $SourcesTableManager(_$ContentDatabase db, Sources table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SourcesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SourcesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SourcesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> authorsJson = const Value.absent(),
                Value<String?> organization = const Value.absent(),
                Value<String?> journal = const Value.absent(),
                Value<int?> publicationYear = const Value.absent(),
                Value<String?> edition = const Value.absent(),
                Value<String?> doi = const Value.absent(),
                Value<String?> pmid = const Value.absent(),
                Value<String?> officialUrl = const Value.absent(),
                Value<String?> accessedDate = const Value.absent(),
                Value<int> tier = const Value.absent(),
                Value<String> evidenceLevel = const Value.absent(),
                Value<String> licenseMode = const Value.absent(),
                Value<String?> licenseAgreementId = const Value.absent(),
                Value<int> identifierVerified = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<String?> lastReviewedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> isTestData = const Value.absent(),
              }) => SourcesCompanion(
                sourceId: sourceId,
                sourceType: sourceType,
                title: title,
                authorsJson: authorsJson,
                organization: organization,
                journal: journal,
                publicationYear: publicationYear,
                edition: edition,
                doi: doi,
                pmid: pmid,
                officialUrl: officialUrl,
                accessedDate: accessedDate,
                tier: tier,
                evidenceLevel: evidenceLevel,
                licenseMode: licenseMode,
                licenseAgreementId: licenseAgreementId,
                identifierVerified: identifierVerified,
                reviewStatus: reviewStatus,
                lastReviewedAt: lastReviewedAt,
                version: version,
                isTestData: isTestData,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String sourceType,
                required String title,
                Value<String> authorsJson = const Value.absent(),
                Value<String?> organization = const Value.absent(),
                Value<String?> journal = const Value.absent(),
                Value<int?> publicationYear = const Value.absent(),
                Value<String?> edition = const Value.absent(),
                Value<String?> doi = const Value.absent(),
                Value<String?> pmid = const Value.absent(),
                Value<String?> officialUrl = const Value.absent(),
                Value<String?> accessedDate = const Value.absent(),
                required int tier,
                required String evidenceLevel,
                required String licenseMode,
                Value<String?> licenseAgreementId = const Value.absent(),
                Value<int> identifierVerified = const Value.absent(),
                required String reviewStatus,
                Value<String?> lastReviewedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> isTestData = const Value.absent(),
              }) => SourcesCompanion.insert(
                sourceId: sourceId,
                sourceType: sourceType,
                title: title,
                authorsJson: authorsJson,
                organization: organization,
                journal: journal,
                publicationYear: publicationYear,
                edition: edition,
                doi: doi,
                pmid: pmid,
                officialUrl: officialUrl,
                accessedDate: accessedDate,
                tier: tier,
                evidenceLevel: evidenceLevel,
                licenseMode: licenseMode,
                licenseAgreementId: licenseAgreementId,
                identifierVerified: identifierVerified,
                reviewStatus: reviewStatus,
                lastReviewedAt: lastReviewedAt,
                version: version,
                isTestData: isTestData,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Sources, Source>(table),
                  $SourcesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                jurisdictionalInstrumentsRefs = false,
                entitySourcesRefs = false,
                citationsRefs = false,
                externalIdentifiersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (jurisdictionalInstrumentsRefs)
                      db.jurisdictionalInstruments,
                    if (entitySourcesRefs) db.entitySources,
                    if (citationsRefs) db.citations,
                    if (externalIdentifiersRefs) db.externalIdentifiers,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (jurisdictionalInstrumentsRefs)
                        await $_getPrefetchedData<
                          Source,
                          Sources,
                          JurisdictionalInstrument
                        >(
                          currentTable: table,
                          referencedTable: $SourcesReferences
                              ._jurisdictionalInstrumentsRefsTable(db),
                          managerFromTypedResult: (p0) => $SourcesReferences(
                            db,
                            table,
                            p0,
                          ).jurisdictionalInstrumentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.officialSourceId == item.sourceId,
                              ),
                          typedResults: items,
                        ),
                      if (entitySourcesRefs)
                        await $_getPrefetchedData<
                          Source,
                          Sources,
                          EntitySource
                        >(
                          currentTable: table,
                          referencedTable: $SourcesReferences
                              ._entitySourcesRefsTable(db),
                          managerFromTypedResult: (p0) => $SourcesReferences(
                            db,
                            table,
                            p0,
                          ).entitySourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.sourceId,
                              ),
                          typedResults: items,
                        ),
                      if (citationsRefs)
                        await $_getPrefetchedData<Source, Sources, Citation>(
                          currentTable: table,
                          referencedTable: $SourcesReferences
                              ._citationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $SourcesReferences(db, table, p0).citationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.sourceId,
                              ),
                          typedResults: items,
                        ),
                      if (externalIdentifiersRefs)
                        await $_getPrefetchedData<
                          Source,
                          Sources,
                          ExternalIdentifier
                        >(
                          currentTable: table,
                          referencedTable: $SourcesReferences
                              ._externalIdentifiersRefsTable(db),
                          managerFromTypedResult: (p0) => $SourcesReferences(
                            db,
                            table,
                            p0,
                          ).externalIdentifiersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.sourceId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $SourcesProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      Sources,
      Source,
      $SourcesFilterComposer,
      $SourcesOrderingComposer,
      $SourcesAnnotationComposer,
      $SourcesCreateCompanionBuilder,
      $SourcesUpdateCompanionBuilder,
      (Source, $SourcesReferences),
      Source,
      PrefetchHooks Function({
        bool jurisdictionalInstrumentsRefs,
        bool entitySourcesRefs,
        bool citationsRefs,
        bool externalIdentifiersRefs,
      })
    >;
typedef $JurisdictionsCreateCompanionBuilder = JurisdictionsCompanion Function({
  required String jurisdictionId,
  required String level,
  Value<String?> parentId,
  Value<String?> iso3166,
  Value<String> namesJson,
});
typedef $JurisdictionsUpdateCompanionBuilder = JurisdictionsCompanion Function({
  Value<String> jurisdictionId,
  Value<String> level,
  Value<String?> parentId,
  Value<String?> iso3166,
  Value<String> namesJson,
});

final class $JurisdictionsReferences
    extends BaseReferences<_$ContentDatabase, Jurisdictions, Jurisdiction> {
  $JurisdictionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Jurisdictions _parentIdTable(_$ContentDatabase db) => db.jurisdictions
      .createAlias('jurisdictions__parent_id__jurisdictions__jurisdiction_id');

  $JurisdictionsProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $JurisdictionsTableManager(
      $_db,
      $_db.jurisdictions,
    ).filter((f) => f.jurisdictionId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Authorities, List<Authority>>
  _authoritiesRefsTable(_$ContentDatabase db) => MultiTypedResultKey.fromTable(
    db.authorities,
    aliasName: 'jurisdictions__jurisdiction_id__authorities__jurisdiction_id',
  );

  $AuthoritiesProcessedTableManager get authoritiesRefs {
    final manager = $AuthoritiesTableManager($_db, $_db.authorities).filter(
      (f) => f.jurisdictionId.jurisdictionId.sqlEquals(
        $_itemColumn<String>('jurisdiction_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_authoritiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    JurisdictionalInstruments,
    List<JurisdictionalInstrument>
  >
  _jurisdictionalInstrumentsRefsTable(_$ContentDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.jurisdictionalInstruments,
        aliasName: 'jurisdictions__jurisdiction_id__jurisdictional_instruments__jurisdiction_id',
      );

  $JurisdictionalInstrumentsProcessedTableManager
  get jurisdictionalInstrumentsRefs {
    final manager =
        $JurisdictionalInstrumentsTableManager(
          $_db,
          $_db.jurisdictionalInstruments,
        ).filter(
          (f) => f.jurisdictionId.jurisdictionId.sqlEquals(
            $_itemColumn<String>('jurisdiction_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _jurisdictionalInstrumentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<KnowledgeEntities, List<KnowledgeEntity>>
  _knowledgeEntitiesRefsTable(
    _$ContentDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.knowledgeEntities,
    aliasName:
        'jurisdictions__jurisdiction_id__knowledge_entities__jurisdiction_id',
  );

  $KnowledgeEntitiesProcessedTableManager get knowledgeEntitiesRefs {
    final manager = $KnowledgeEntitiesTableManager($_db, $_db.knowledgeEntities)
        .filter(
          (f) => f.jurisdictionId.jurisdictionId.sqlEquals(
            $_itemColumn<String>('jurisdiction_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _knowledgeEntitiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Claims, List<Claim>> _claimsRefsTable(
    _$ContentDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.claims,
    aliasName: 'jurisdictions__jurisdiction_id__claims__jurisdiction_id',
  );

  $ClaimsProcessedTableManager get claimsRefs {
    final manager = $ClaimsTableManager($_db, $_db.claims).filter(
      (f) => f.jurisdictionId.jurisdictionId.sqlEquals(
        $_itemColumn<String>('jurisdiction_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_claimsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $JurisdictionsFilterComposer
    extends Composer<_$ContentDatabase, Jurisdictions> {
  $JurisdictionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get jurisdictionId => $composableBuilder(
    column: $table.jurisdictionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iso3166 => $composableBuilder(
    column: $table.iso3166,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namesJson => $composableBuilder(
    column: $table.namesJson,
    builder: (column) => ColumnFilters(column),
  );

  $JurisdictionsFilterComposer get parentId {
    final $JurisdictionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsFilterComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> authoritiesRefs(
    Expression<bool> Function($AuthoritiesFilterComposer f) f,
  ) {
    final $AuthoritiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.authorities,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AuthoritiesFilterComposer(
            $db: $db,
            $table: $db.authorities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> jurisdictionalInstrumentsRefs(
    Expression<bool> Function($JurisdictionalInstrumentsFilterComposer f) f,
  ) {
    final $JurisdictionalInstrumentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.jurisdictionalInstruments,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionalInstrumentsFilterComposer(
            $db: $db,
            $table: $db.jurisdictionalInstruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> knowledgeEntitiesRefs(
    Expression<bool> Function($KnowledgeEntitiesFilterComposer f) f,
  ) {
    final $KnowledgeEntitiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.knowledgeEntities,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $KnowledgeEntitiesFilterComposer(
            $db: $db,
            $table: $db.knowledgeEntities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> claimsRefs(
    Expression<bool> Function($ClaimsFilterComposer f) f,
  ) {
    final $ClaimsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimsFilterComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $JurisdictionsOrderingComposer
    extends Composer<_$ContentDatabase, Jurisdictions> {
  $JurisdictionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get jurisdictionId => $composableBuilder(
    column: $table.jurisdictionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iso3166 => $composableBuilder(
    column: $table.iso3166,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namesJson => $composableBuilder(
    column: $table.namesJson,
    builder: (column) => ColumnOrderings(column),
  );

  $JurisdictionsOrderingComposer get parentId {
    final $JurisdictionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsOrderingComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $JurisdictionsAnnotationComposer
    extends Composer<_$ContentDatabase, Jurisdictions> {
  $JurisdictionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get jurisdictionId => $composableBuilder(
    column: $table.jurisdictionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get iso3166 =>
      $composableBuilder(column: $table.iso3166, builder: (column) => column);

  GeneratedColumn<String> get namesJson =>
      $composableBuilder(column: $table.namesJson, builder: (column) => column);

  $JurisdictionsAnnotationComposer get parentId {
    final $JurisdictionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsAnnotationComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> authoritiesRefs<T extends Object>(
    Expression<T> Function($AuthoritiesAnnotationComposer a) f,
  ) {
    final $AuthoritiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.authorities,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AuthoritiesAnnotationComposer(
            $db: $db,
            $table: $db.authorities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> jurisdictionalInstrumentsRefs<T extends Object>(
    Expression<T> Function($JurisdictionalInstrumentsAnnotationComposer a) f,
  ) {
    final $JurisdictionalInstrumentsAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.jurisdictionId,
          referencedTable: $db.jurisdictionalInstruments,
          getReferencedColumn: (t) => t.jurisdictionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $JurisdictionalInstrumentsAnnotationComposer(
                $db: $db,
                $table: $db.jurisdictionalInstruments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> knowledgeEntitiesRefs<T extends Object>(
    Expression<T> Function($KnowledgeEntitiesAnnotationComposer a) f,
  ) {
    final $KnowledgeEntitiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.knowledgeEntities,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $KnowledgeEntitiesAnnotationComposer(
            $db: $db,
            $table: $db.knowledgeEntities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> claimsRefs<T extends Object>(
    Expression<T> Function($ClaimsAnnotationComposer a) f,
  ) {
    final $ClaimsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimsAnnotationComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $JurisdictionsTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          Jurisdictions,
          Jurisdiction,
          $JurisdictionsFilterComposer,
          $JurisdictionsOrderingComposer,
          $JurisdictionsAnnotationComposer,
          $JurisdictionsCreateCompanionBuilder,
          $JurisdictionsUpdateCompanionBuilder,
          (Jurisdiction, $JurisdictionsReferences),
          Jurisdiction,
          PrefetchHooks Function({
            bool parentId,
            bool authoritiesRefs,
            bool jurisdictionalInstrumentsRefs,
            bool knowledgeEntitiesRefs,
            bool claimsRefs,
          })
        > {
  $JurisdictionsTableManager(_$ContentDatabase db, Jurisdictions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $JurisdictionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $JurisdictionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $JurisdictionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> jurisdictionId = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> iso3166 = const Value.absent(),
                Value<String> namesJson = const Value.absent(),
              }) => JurisdictionsCompanion(
                jurisdictionId: jurisdictionId,
                level: level,
                parentId: parentId,
                iso3166: iso3166,
                namesJson: namesJson,
              ),
          createCompanionCallback:
              ({
                required String jurisdictionId,
                required String level,
                Value<String?> parentId = const Value.absent(),
                Value<String?> iso3166 = const Value.absent(),
                Value<String> namesJson = const Value.absent(),
              }) => JurisdictionsCompanion.insert(
                jurisdictionId: jurisdictionId,
                level: level,
                parentId: parentId,
                iso3166: iso3166,
                namesJson: namesJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Jurisdictions, Jurisdiction>(table),
                  $JurisdictionsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                parentId = false,
                authoritiesRefs = false,
                jurisdictionalInstrumentsRefs = false,
                knowledgeEntitiesRefs = false,
                claimsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (authoritiesRefs) db.authorities,
                    if (jurisdictionalInstrumentsRefs)
                      db.jurisdictionalInstruments,
                    if (knowledgeEntitiesRefs) db.knowledgeEntities,
                    if (claimsRefs) db.claims,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (parentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.parentId,
                            referencedTable: $JurisdictionsReferences
                                ._parentIdTable(db),
                            referencedColumn: $JurisdictionsReferences
                                ._parentIdTable(db)
                                .jurisdictionId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (authoritiesRefs)
                        await $_getPrefetchedData<
                          Jurisdiction,
                          Jurisdictions,
                          Authority
                        >(
                          currentTable: table,
                          referencedTable: $JurisdictionsReferences
                              ._authoritiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $JurisdictionsReferences(
                                db,
                                table,
                                p0,
                              ).authoritiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jurisdictionId == item.jurisdictionId,
                              ),
                          typedResults: items,
                        ),
                      if (jurisdictionalInstrumentsRefs)
                        await $_getPrefetchedData<
                          Jurisdiction,
                          Jurisdictions,
                          JurisdictionalInstrument
                        >(
                          currentTable: table,
                          referencedTable: $JurisdictionsReferences
                              ._jurisdictionalInstrumentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $JurisdictionsReferences(
                                db,
                                table,
                                p0,
                              ).jurisdictionalInstrumentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jurisdictionId == item.jurisdictionId,
                              ),
                          typedResults: items,
                        ),
                      if (knowledgeEntitiesRefs)
                        await $_getPrefetchedData<
                          Jurisdiction,
                          Jurisdictions,
                          KnowledgeEntity
                        >(
                          currentTable: table,
                          referencedTable: $JurisdictionsReferences
                              ._knowledgeEntitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $JurisdictionsReferences(
                                db,
                                table,
                                p0,
                              ).knowledgeEntitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jurisdictionId == item.jurisdictionId,
                              ),
                          typedResults: items,
                        ),
                      if (claimsRefs)
                        await $_getPrefetchedData<
                          Jurisdiction,
                          Jurisdictions,
                          Claim
                        >(
                          currentTable: table,
                          referencedTable: $JurisdictionsReferences
                              ._claimsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $JurisdictionsReferences(
                                db,
                                table,
                                p0,
                              ).claimsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jurisdictionId == item.jurisdictionId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $JurisdictionsProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      Jurisdictions,
      Jurisdiction,
      $JurisdictionsFilterComposer,
      $JurisdictionsOrderingComposer,
      $JurisdictionsAnnotationComposer,
      $JurisdictionsCreateCompanionBuilder,
      $JurisdictionsUpdateCompanionBuilder,
      (Jurisdiction, $JurisdictionsReferences),
      Jurisdiction,
      PrefetchHooks Function({
        bool parentId,
        bool authoritiesRefs,
        bool jurisdictionalInstrumentsRefs,
        bool knowledgeEntitiesRefs,
        bool claimsRefs,
      })
    >;
typedef $AuthoritiesCreateCompanionBuilder = AuthoritiesCompanion Function({
  required String authorityId,
  required String jurisdictionId,
  Value<String> namesJson,
});
typedef $AuthoritiesUpdateCompanionBuilder = AuthoritiesCompanion Function({
  Value<String> authorityId,
  Value<String> jurisdictionId,
  Value<String> namesJson,
});

final class $AuthoritiesReferences
    extends BaseReferences<_$ContentDatabase, Authorities, Authority> {
  $AuthoritiesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Jurisdictions _jurisdictionIdTable(_$ContentDatabase db) =>
      db.jurisdictions.createAlias(
        'authorities__jurisdiction_id__jurisdictions__jurisdiction_id',
      );

  $JurisdictionsProcessedTableManager get jurisdictionId {
    final $_column = $_itemColumn<String>('jurisdiction_id')!;

    final manager = $JurisdictionsTableManager(
      $_db,
      $_db.jurisdictions,
    ).filter((f) => f.jurisdictionId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jurisdictionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    JurisdictionalInstruments,
    List<JurisdictionalInstrument>
  >
  _jurisdictionalInstrumentsRefsTable(
    _$ContentDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jurisdictionalInstruments,
    aliasName:
        'authorities__authority_id__jurisdictional_instruments__authority_id',
  );

  $JurisdictionalInstrumentsProcessedTableManager
  get jurisdictionalInstrumentsRefs {
    final manager =
        $JurisdictionalInstrumentsTableManager(
          $_db,
          $_db.jurisdictionalInstruments,
        ).filter(
          (f) => f.authorityId.authorityId.sqlEquals(
            $_itemColumn<String>('authority_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _jurisdictionalInstrumentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $AuthoritiesFilterComposer
    extends Composer<_$ContentDatabase, Authorities> {
  $AuthoritiesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get authorityId => $composableBuilder(
    column: $table.authorityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namesJson => $composableBuilder(
    column: $table.namesJson,
    builder: (column) => ColumnFilters(column),
  );

  $JurisdictionsFilterComposer get jurisdictionId {
    final $JurisdictionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsFilterComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> jurisdictionalInstrumentsRefs(
    Expression<bool> Function($JurisdictionalInstrumentsFilterComposer f) f,
  ) {
    final $JurisdictionalInstrumentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorityId,
      referencedTable: $db.jurisdictionalInstruments,
      getReferencedColumn: (t) => t.authorityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionalInstrumentsFilterComposer(
            $db: $db,
            $table: $db.jurisdictionalInstruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $AuthoritiesOrderingComposer
    extends Composer<_$ContentDatabase, Authorities> {
  $AuthoritiesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get authorityId => $composableBuilder(
    column: $table.authorityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namesJson => $composableBuilder(
    column: $table.namesJson,
    builder: (column) => ColumnOrderings(column),
  );

  $JurisdictionsOrderingComposer get jurisdictionId {
    final $JurisdictionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsOrderingComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AuthoritiesAnnotationComposer
    extends Composer<_$ContentDatabase, Authorities> {
  $AuthoritiesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get authorityId => $composableBuilder(
    column: $table.authorityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get namesJson =>
      $composableBuilder(column: $table.namesJson, builder: (column) => column);

  $JurisdictionsAnnotationComposer get jurisdictionId {
    final $JurisdictionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsAnnotationComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> jurisdictionalInstrumentsRefs<T extends Object>(
    Expression<T> Function($JurisdictionalInstrumentsAnnotationComposer a) f,
  ) {
    final $JurisdictionalInstrumentsAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.authorityId,
          referencedTable: $db.jurisdictionalInstruments,
          getReferencedColumn: (t) => t.authorityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $JurisdictionalInstrumentsAnnotationComposer(
                $db: $db,
                $table: $db.jurisdictionalInstruments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $AuthoritiesTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          Authorities,
          Authority,
          $AuthoritiesFilterComposer,
          $AuthoritiesOrderingComposer,
          $AuthoritiesAnnotationComposer,
          $AuthoritiesCreateCompanionBuilder,
          $AuthoritiesUpdateCompanionBuilder,
          (Authority, $AuthoritiesReferences),
          Authority,
          PrefetchHooks Function({
            bool jurisdictionId,
            bool jurisdictionalInstrumentsRefs,
          })
        > {
  $AuthoritiesTableManager(_$ContentDatabase db, Authorities table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AuthoritiesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AuthoritiesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AuthoritiesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> authorityId = const Value.absent(),
                Value<String> jurisdictionId = const Value.absent(),
                Value<String> namesJson = const Value.absent(),
              }) => AuthoritiesCompanion(
                authorityId: authorityId,
                jurisdictionId: jurisdictionId,
                namesJson: namesJson,
              ),
          createCompanionCallback:
              ({
                required String authorityId,
                required String jurisdictionId,
                Value<String> namesJson = const Value.absent(),
              }) => AuthoritiesCompanion.insert(
                authorityId: authorityId,
                jurisdictionId: jurisdictionId,
                namesJson: namesJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Authorities, Authority>(table),
                  $AuthoritiesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                jurisdictionId = false,
                jurisdictionalInstrumentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (jurisdictionalInstrumentsRefs)
                      db.jurisdictionalInstruments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (jurisdictionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.jurisdictionId,
                            referencedTable: $AuthoritiesReferences
                                ._jurisdictionIdTable(db),
                            referencedColumn: $AuthoritiesReferences
                                ._jurisdictionIdTable(db)
                                .jurisdictionId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (jurisdictionalInstrumentsRefs)
                        await $_getPrefetchedData<
                          Authority,
                          Authorities,
                          JurisdictionalInstrument
                        >(
                          currentTable: table,
                          referencedTable: $AuthoritiesReferences
                              ._jurisdictionalInstrumentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $AuthoritiesReferences(
                                db,
                                table,
                                p0,
                              ).jurisdictionalInstrumentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.authorityId == item.authorityId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $AuthoritiesProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      Authorities,
      Authority,
      $AuthoritiesFilterComposer,
      $AuthoritiesOrderingComposer,
      $AuthoritiesAnnotationComposer,
      $AuthoritiesCreateCompanionBuilder,
      $AuthoritiesUpdateCompanionBuilder,
      (Authority, $AuthoritiesReferences),
      Authority,
      PrefetchHooks Function({
        bool jurisdictionId,
        bool jurisdictionalInstrumentsRefs,
      })
    >;
typedef $JurisdictionalInstrumentsCreateCompanionBuilder =
    JurisdictionalInstrumentsCompanion Function({
      required String instrumentId,
      required String jurisdictionId,
      required String instrumentType,
      Value<String> titlesJson,
      required String officialSourceId,
      Value<String?> officialReference,
      required String effectiveFrom,
      Value<String?> effectiveTo,
      required String version,
      Value<String?> lastVerifiedAt,
      required String reviewStatus,
      Value<int> isTestData,
      Value<String?> authorityId,
      Value<String?> publicationDate,
      Value<String?> lastAmendedAt,
      Value<String> legalStatus,
      Value<String?> language,
      Value<String?> translationStatus,
    });
typedef $JurisdictionalInstrumentsUpdateCompanionBuilder =
    JurisdictionalInstrumentsCompanion Function({
      Value<String> instrumentId,
      Value<String> jurisdictionId,
      Value<String> instrumentType,
      Value<String> titlesJson,
      Value<String> officialSourceId,
      Value<String?> officialReference,
      Value<String> effectiveFrom,
      Value<String?> effectiveTo,
      Value<String> version,
      Value<String?> lastVerifiedAt,
      Value<String> reviewStatus,
      Value<int> isTestData,
      Value<String?> authorityId,
      Value<String?> publicationDate,
      Value<String?> lastAmendedAt,
      Value<String> legalStatus,
      Value<String?> language,
      Value<String?> translationStatus,
    });

final class $JurisdictionalInstrumentsReferences
    extends
        BaseReferences<
          _$ContentDatabase,
          JurisdictionalInstruments,
          JurisdictionalInstrument
        > {
  $JurisdictionalInstrumentsReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static Jurisdictions _jurisdictionIdTable(_$ContentDatabase db) =>
      db.jurisdictions.createAlias(
        'jurisdictional_instruments__jurisdiction_id__jurisdictions__jurisdiction_id',
      );

  $JurisdictionsProcessedTableManager get jurisdictionId {
    final $_column = $_itemColumn<String>('jurisdiction_id')!;

    final manager = $JurisdictionsTableManager(
      $_db,
      $_db.jurisdictions,
    ).filter((f) => f.jurisdictionId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jurisdictionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Sources _officialSourceIdTable(_$ContentDatabase db) =>
      db.sources.createAlias(
        'jurisdictional_instruments__official_source_id__sources__source_id',
      );

  $SourcesProcessedTableManager get officialSourceId {
    final $_column = $_itemColumn<String>('official_source_id')!;

    final manager = $SourcesTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.sourceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_officialSourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Authorities _authorityIdTable(_$ContentDatabase db) =>
      db.authorities.createAlias(
        'jurisdictional_instruments__authority_id__authorities__authority_id',
      );

  $AuthoritiesProcessedTableManager? get authorityId {
    final $_column = $_itemColumn<String>('authority_id');
    if ($_column == null) return null;
    final manager = $AuthoritiesTableManager(
      $_db,
      $_db.authorities,
    ).filter((f) => f.authorityId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_authorityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<JurisdictionalRules, List<JurisdictionalRule>>
  _jurisdictionalRulesRefsTable(_$ContentDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.jurisdictionalRules,
        aliasName: 'jurisdictional_instruments__instrument_id__jurisdictional_rules__instrument_id',
      );

  $JurisdictionalRulesProcessedTableManager get jurisdictionalRulesRefs {
    final manager =
        $JurisdictionalRulesTableManager($_db, $_db.jurisdictionalRules).filter(
          (f) => f.instrumentId.instrumentId.sqlEquals(
            $_itemColumn<String>('instrument_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _jurisdictionalRulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Claims, List<Claim>> _claimsRefsTable(
    _$ContentDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.claims,
    aliasName:
        'jurisdictional_instruments__instrument_id__claims__instrument_id',
  );

  $ClaimsProcessedTableManager get claimsRefs {
    final manager = $ClaimsTableManager($_db, $_db.claims).filter(
      (f) => f.instrumentId.instrumentId.sqlEquals(
        $_itemColumn<String>('instrument_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_claimsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $JurisdictionalInstrumentsFilterComposer
    extends Composer<_$ContentDatabase, JurisdictionalInstruments> {
  $JurisdictionalInstrumentsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get instrumentId => $composableBuilder(
    column: $table.instrumentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instrumentType => $composableBuilder(
    column: $table.instrumentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titlesJson => $composableBuilder(
    column: $table.titlesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officialReference => $composableBuilder(
    column: $table.officialReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveTo => $composableBuilder(
    column: $table.effectiveTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicationDate => $composableBuilder(
    column: $table.publicationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastAmendedAt => $composableBuilder(
    column: $table.lastAmendedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalStatus => $composableBuilder(
    column: $table.legalStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationStatus => $composableBuilder(
    column: $table.translationStatus,
    builder: (column) => ColumnFilters(column),
  );

  $JurisdictionsFilterComposer get jurisdictionId {
    final $JurisdictionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsFilterComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SourcesFilterComposer get officialSourceId {
    final $SourcesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.officialSourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SourcesFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AuthoritiesFilterComposer get authorityId {
    final $AuthoritiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorityId,
      referencedTable: $db.authorities,
      getReferencedColumn: (t) => t.authorityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AuthoritiesFilterComposer(
            $db: $db,
            $table: $db.authorities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> jurisdictionalRulesRefs(
    Expression<bool> Function($JurisdictionalRulesFilterComposer f) f,
  ) {
    final $JurisdictionalRulesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.jurisdictionalRules,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionalRulesFilterComposer(
            $db: $db,
            $table: $db.jurisdictionalRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> claimsRefs(
    Expression<bool> Function($ClaimsFilterComposer f) f,
  ) {
    final $ClaimsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimsFilterComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $JurisdictionalInstrumentsOrderingComposer
    extends Composer<_$ContentDatabase, JurisdictionalInstruments> {
  $JurisdictionalInstrumentsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get instrumentId => $composableBuilder(
    column: $table.instrumentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrumentType => $composableBuilder(
    column: $table.instrumentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titlesJson => $composableBuilder(
    column: $table.titlesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officialReference => $composableBuilder(
    column: $table.officialReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveTo => $composableBuilder(
    column: $table.effectiveTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicationDate => $composableBuilder(
    column: $table.publicationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastAmendedAt => $composableBuilder(
    column: $table.lastAmendedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalStatus => $composableBuilder(
    column: $table.legalStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationStatus => $composableBuilder(
    column: $table.translationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $JurisdictionsOrderingComposer get jurisdictionId {
    final $JurisdictionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsOrderingComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SourcesOrderingComposer get officialSourceId {
    final $SourcesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.officialSourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SourcesOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AuthoritiesOrderingComposer get authorityId {
    final $AuthoritiesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorityId,
      referencedTable: $db.authorities,
      getReferencedColumn: (t) => t.authorityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AuthoritiesOrderingComposer(
            $db: $db,
            $table: $db.authorities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $JurisdictionalInstrumentsAnnotationComposer
    extends Composer<_$ContentDatabase, JurisdictionalInstruments> {
  $JurisdictionalInstrumentsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get instrumentId => $composableBuilder(
    column: $table.instrumentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instrumentType => $composableBuilder(
    column: $table.instrumentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get titlesJson => $composableBuilder(
    column: $table.titlesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get officialReference => $composableBuilder(
    column: $table.officialReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effectiveTo => $composableBuilder(
    column: $table.effectiveTo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicationDate => $composableBuilder(
    column: $table.publicationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastAmendedAt => $composableBuilder(
    column: $table.lastAmendedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalStatus => $composableBuilder(
    column: $table.legalStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get translationStatus => $composableBuilder(
    column: $table.translationStatus,
    builder: (column) => column,
  );

  $JurisdictionsAnnotationComposer get jurisdictionId {
    final $JurisdictionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsAnnotationComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SourcesAnnotationComposer get officialSourceId {
    final $SourcesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.officialSourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SourcesAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AuthoritiesAnnotationComposer get authorityId {
    final $AuthoritiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorityId,
      referencedTable: $db.authorities,
      getReferencedColumn: (t) => t.authorityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AuthoritiesAnnotationComposer(
            $db: $db,
            $table: $db.authorities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> jurisdictionalRulesRefs<T extends Object>(
    Expression<T> Function($JurisdictionalRulesAnnotationComposer a) f,
  ) {
    final $JurisdictionalRulesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.jurisdictionalRules,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionalRulesAnnotationComposer(
            $db: $db,
            $table: $db.jurisdictionalRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> claimsRefs<T extends Object>(
    Expression<T> Function($ClaimsAnnotationComposer a) f,
  ) {
    final $ClaimsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimsAnnotationComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $JurisdictionalInstrumentsTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          JurisdictionalInstruments,
          JurisdictionalInstrument,
          $JurisdictionalInstrumentsFilterComposer,
          $JurisdictionalInstrumentsOrderingComposer,
          $JurisdictionalInstrumentsAnnotationComposer,
          $JurisdictionalInstrumentsCreateCompanionBuilder,
          $JurisdictionalInstrumentsUpdateCompanionBuilder,
          (JurisdictionalInstrument, $JurisdictionalInstrumentsReferences),
          JurisdictionalInstrument,
          PrefetchHooks Function({
            bool jurisdictionId,
            bool officialSourceId,
            bool authorityId,
            bool jurisdictionalRulesRefs,
            bool claimsRefs,
          })
        > {
  $JurisdictionalInstrumentsTableManager(
    _$ContentDatabase db,
    JurisdictionalInstruments table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $JurisdictionalInstrumentsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $JurisdictionalInstrumentsOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $JurisdictionalInstrumentsAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> instrumentId = const Value.absent(),
                Value<String> jurisdictionId = const Value.absent(),
                Value<String> instrumentType = const Value.absent(),
                Value<String> titlesJson = const Value.absent(),
                Value<String> officialSourceId = const Value.absent(),
                Value<String?> officialReference = const Value.absent(),
                Value<String> effectiveFrom = const Value.absent(),
                Value<String?> effectiveTo = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String?> lastVerifiedAt = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<int> isTestData = const Value.absent(),
                Value<String?> authorityId = const Value.absent(),
                Value<String?> publicationDate = const Value.absent(),
                Value<String?> lastAmendedAt = const Value.absent(),
                Value<String> legalStatus = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String?> translationStatus = const Value.absent(),
              }) => JurisdictionalInstrumentsCompanion(
                instrumentId: instrumentId,
                jurisdictionId: jurisdictionId,
                instrumentType: instrumentType,
                titlesJson: titlesJson,
                officialSourceId: officialSourceId,
                officialReference: officialReference,
                effectiveFrom: effectiveFrom,
                effectiveTo: effectiveTo,
                version: version,
                lastVerifiedAt: lastVerifiedAt,
                reviewStatus: reviewStatus,
                isTestData: isTestData,
                authorityId: authorityId,
                publicationDate: publicationDate,
                lastAmendedAt: lastAmendedAt,
                legalStatus: legalStatus,
                language: language,
                translationStatus: translationStatus,
              ),
          createCompanionCallback:
              ({
                required String instrumentId,
                required String jurisdictionId,
                required String instrumentType,
                Value<String> titlesJson = const Value.absent(),
                required String officialSourceId,
                Value<String?> officialReference = const Value.absent(),
                required String effectiveFrom,
                Value<String?> effectiveTo = const Value.absent(),
                required String version,
                Value<String?> lastVerifiedAt = const Value.absent(),
                required String reviewStatus,
                Value<int> isTestData = const Value.absent(),
                Value<String?> authorityId = const Value.absent(),
                Value<String?> publicationDate = const Value.absent(),
                Value<String?> lastAmendedAt = const Value.absent(),
                Value<String> legalStatus = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String?> translationStatus = const Value.absent(),
              }) => JurisdictionalInstrumentsCompanion.insert(
                instrumentId: instrumentId,
                jurisdictionId: jurisdictionId,
                instrumentType: instrumentType,
                titlesJson: titlesJson,
                officialSourceId: officialSourceId,
                officialReference: officialReference,
                effectiveFrom: effectiveFrom,
                effectiveTo: effectiveTo,
                version: version,
                lastVerifiedAt: lastVerifiedAt,
                reviewStatus: reviewStatus,
                isTestData: isTestData,
                authorityId: authorityId,
                publicationDate: publicationDate,
                lastAmendedAt: lastAmendedAt,
                legalStatus: legalStatus,
                language: language,
                translationStatus: translationStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    JurisdictionalInstruments,
                    JurisdictionalInstrument
                  >(table),
                  $JurisdictionalInstrumentsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                jurisdictionId = false,
                officialSourceId = false,
                authorityId = false,
                jurisdictionalRulesRefs = false,
                claimsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (jurisdictionalRulesRefs) db.jurisdictionalRules,
                    if (claimsRefs) db.claims,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (jurisdictionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.jurisdictionId,
                            referencedTable:
                                $JurisdictionalInstrumentsReferences
                                    ._jurisdictionIdTable(db),
                            referencedColumn:
                                $JurisdictionalInstrumentsReferences
                                    ._jurisdictionIdTable(db)
                                    .jurisdictionId,
                          ) as T;
                        }
                        if (officialSourceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.officialSourceId,
                            referencedTable:
                                $JurisdictionalInstrumentsReferences
                                    ._officialSourceIdTable(db),
                            referencedColumn:
                                $JurisdictionalInstrumentsReferences
                                    ._officialSourceIdTable(db)
                                    .sourceId,
                          ) as T;
                        }
                        if (authorityId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.authorityId,
                            referencedTable:
                                $JurisdictionalInstrumentsReferences
                                    ._authorityIdTable(db),
                            referencedColumn:
                                $JurisdictionalInstrumentsReferences
                                    ._authorityIdTable(db)
                                    .authorityId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (jurisdictionalRulesRefs)
                        await $_getPrefetchedData<
                          JurisdictionalInstrument,
                          JurisdictionalInstruments,
                          JurisdictionalRule
                        >(
                          currentTable: table,
                          referencedTable: $JurisdictionalInstrumentsReferences
                              ._jurisdictionalRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $JurisdictionalInstrumentsReferences(
                                db,
                                table,
                                p0,
                              ).jurisdictionalRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.instrumentId,
                              ),
                          typedResults: items,
                        ),
                      if (claimsRefs)
                        await $_getPrefetchedData<
                          JurisdictionalInstrument,
                          JurisdictionalInstruments,
                          Claim
                        >(
                          currentTable: table,
                          referencedTable: $JurisdictionalInstrumentsReferences
                              ._claimsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $JurisdictionalInstrumentsReferences(
                                db,
                                table,
                                p0,
                              ).claimsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.instrumentId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $JurisdictionalInstrumentsProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      JurisdictionalInstruments,
      JurisdictionalInstrument,
      $JurisdictionalInstrumentsFilterComposer,
      $JurisdictionalInstrumentsOrderingComposer,
      $JurisdictionalInstrumentsAnnotationComposer,
      $JurisdictionalInstrumentsCreateCompanionBuilder,
      $JurisdictionalInstrumentsUpdateCompanionBuilder,
      (JurisdictionalInstrument, $JurisdictionalInstrumentsReferences),
      JurisdictionalInstrument,
      PrefetchHooks Function({
        bool jurisdictionId,
        bool officialSourceId,
        bool authorityId,
        bool jurisdictionalRulesRefs,
        bool claimsRefs,
      })
    >;
typedef $JurisdictionalRulesCreateCompanionBuilder =
    JurisdictionalRulesCompanion Function({
      required String ruleId,
      required String instrumentId,
      required String ruleType,
      required String subjectType,
      required String subjectId,
      required String valueJson,
      required String effectiveFrom,
      Value<String?> effectiveTo,
      required String reviewStatus,
      Value<int> isTestData,
      Value<String?> articleSection,
      Value<String?> topicKey,
      Value<String?> appliesToJson,
      Value<int> version,
    });
typedef $JurisdictionalRulesUpdateCompanionBuilder =
    JurisdictionalRulesCompanion Function({
      Value<String> ruleId,
      Value<String> instrumentId,
      Value<String> ruleType,
      Value<String> subjectType,
      Value<String> subjectId,
      Value<String> valueJson,
      Value<String> effectiveFrom,
      Value<String?> effectiveTo,
      Value<String> reviewStatus,
      Value<int> isTestData,
      Value<String?> articleSection,
      Value<String?> topicKey,
      Value<String?> appliesToJson,
      Value<int> version,
    });

final class $JurisdictionalRulesReferences
    extends
        BaseReferences<
          _$ContentDatabase,
          JurisdictionalRules,
          JurisdictionalRule
        > {
  $JurisdictionalRulesReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static JurisdictionalInstruments _instrumentIdTable(_$ContentDatabase db) =>
      db.jurisdictionalInstruments.createAlias(
        'jurisdictional_rules__instrument_id__jurisdictional_instruments__instrument_id',
      );

  $JurisdictionalInstrumentsProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $JurisdictionalInstrumentsTableManager(
      $_db,
      $_db.jurisdictionalInstruments,
    ).filter((f) => f.instrumentId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $JurisdictionalRulesFilterComposer
    extends Composer<_$ContentDatabase, JurisdictionalRules> {
  $JurisdictionalRulesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleType => $composableBuilder(
    column: $table.ruleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectType => $composableBuilder(
    column: $table.subjectType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveTo => $composableBuilder(
    column: $table.effectiveTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleSection => $composableBuilder(
    column: $table.articleSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicKey => $composableBuilder(
    column: $table.topicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appliesToJson => $composableBuilder(
    column: $table.appliesToJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  $JurisdictionalInstrumentsFilterComposer get instrumentId {
    final $JurisdictionalInstrumentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.jurisdictionalInstruments,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionalInstrumentsFilterComposer(
            $db: $db,
            $table: $db.jurisdictionalInstruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $JurisdictionalRulesOrderingComposer
    extends Composer<_$ContentDatabase, JurisdictionalRules> {
  $JurisdictionalRulesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleType => $composableBuilder(
    column: $table.ruleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectType => $composableBuilder(
    column: $table.subjectType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveTo => $composableBuilder(
    column: $table.effectiveTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleSection => $composableBuilder(
    column: $table.articleSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicKey => $composableBuilder(
    column: $table.topicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appliesToJson => $composableBuilder(
    column: $table.appliesToJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  $JurisdictionalInstrumentsOrderingComposer get instrumentId {
    final $JurisdictionalInstrumentsOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.instrumentId,
          referencedTable: $db.jurisdictionalInstruments,
          getReferencedColumn: (t) => t.instrumentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $JurisdictionalInstrumentsOrderingComposer(
                $db: $db,
                $table: $db.jurisdictionalInstruments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $JurisdictionalRulesAnnotationComposer
    extends Composer<_$ContentDatabase, JurisdictionalRules> {
  $JurisdictionalRulesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get ruleType =>
      $composableBuilder(column: $table.ruleType, builder: (column) => column);

  GeneratedColumn<String> get subjectType => $composableBuilder(
    column: $table.subjectType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effectiveTo => $composableBuilder(
    column: $table.effectiveTo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get articleSection => $composableBuilder(
    column: $table.articleSection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topicKey =>
      $composableBuilder(column: $table.topicKey, builder: (column) => column);

  GeneratedColumn<String> get appliesToJson => $composableBuilder(
    column: $table.appliesToJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  $JurisdictionalInstrumentsAnnotationComposer get instrumentId {
    final $JurisdictionalInstrumentsAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.instrumentId,
          referencedTable: $db.jurisdictionalInstruments,
          getReferencedColumn: (t) => t.instrumentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $JurisdictionalInstrumentsAnnotationComposer(
                $db: $db,
                $table: $db.jurisdictionalInstruments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $JurisdictionalRulesTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          JurisdictionalRules,
          JurisdictionalRule,
          $JurisdictionalRulesFilterComposer,
          $JurisdictionalRulesOrderingComposer,
          $JurisdictionalRulesAnnotationComposer,
          $JurisdictionalRulesCreateCompanionBuilder,
          $JurisdictionalRulesUpdateCompanionBuilder,
          (JurisdictionalRule, $JurisdictionalRulesReferences),
          JurisdictionalRule,
          PrefetchHooks Function({bool instrumentId})
        > {
  $JurisdictionalRulesTableManager(
    _$ContentDatabase db,
    JurisdictionalRules table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $JurisdictionalRulesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $JurisdictionalRulesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $JurisdictionalRulesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ruleId = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<String> ruleType = const Value.absent(),
                Value<String> subjectType = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<String> effectiveFrom = const Value.absent(),
                Value<String?> effectiveTo = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<int> isTestData = const Value.absent(),
                Value<String?> articleSection = const Value.absent(),
                Value<String?> topicKey = const Value.absent(),
                Value<String?> appliesToJson = const Value.absent(),
                Value<int> version = const Value.absent(),
              }) => JurisdictionalRulesCompanion(
                ruleId: ruleId,
                instrumentId: instrumentId,
                ruleType: ruleType,
                subjectType: subjectType,
                subjectId: subjectId,
                valueJson: valueJson,
                effectiveFrom: effectiveFrom,
                effectiveTo: effectiveTo,
                reviewStatus: reviewStatus,
                isTestData: isTestData,
                articleSection: articleSection,
                topicKey: topicKey,
                appliesToJson: appliesToJson,
                version: version,
              ),
          createCompanionCallback:
              ({
                required String ruleId,
                required String instrumentId,
                required String ruleType,
                required String subjectType,
                required String subjectId,
                required String valueJson,
                required String effectiveFrom,
                Value<String?> effectiveTo = const Value.absent(),
                required String reviewStatus,
                Value<int> isTestData = const Value.absent(),
                Value<String?> articleSection = const Value.absent(),
                Value<String?> topicKey = const Value.absent(),
                Value<String?> appliesToJson = const Value.absent(),
                Value<int> version = const Value.absent(),
              }) => JurisdictionalRulesCompanion.insert(
                ruleId: ruleId,
                instrumentId: instrumentId,
                ruleType: ruleType,
                subjectType: subjectType,
                subjectId: subjectId,
                valueJson: valueJson,
                effectiveFrom: effectiveFrom,
                effectiveTo: effectiveTo,
                reviewStatus: reviewStatus,
                isTestData: isTestData,
                articleSection: articleSection,
                topicKey: topicKey,
                appliesToJson: appliesToJson,
                version: version,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<JurisdictionalRules, JurisdictionalRule>(table),
                  $JurisdictionalRulesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({instrumentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (instrumentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instrumentId,
                        referencedTable: $JurisdictionalRulesReferences
                            ._instrumentIdTable(db),
                        referencedColumn: $JurisdictionalRulesReferences
                            ._instrumentIdTable(db)
                            .instrumentId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $JurisdictionalRulesProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      JurisdictionalRules,
      JurisdictionalRule,
      $JurisdictionalRulesFilterComposer,
      $JurisdictionalRulesOrderingComposer,
      $JurisdictionalRulesAnnotationComposer,
      $JurisdictionalRulesCreateCompanionBuilder,
      $JurisdictionalRulesUpdateCompanionBuilder,
      (JurisdictionalRule, $JurisdictionalRulesReferences),
      JurisdictionalRule,
      PrefetchHooks Function({bool instrumentId})
    >;
typedef $KnowledgeEntitiesCreateCompanionBuilder =
    KnowledgeEntitiesCompanion Function({
      required String entityId,
      required String entityType,
      required String area,
      Value<String?> subtype,
      required String namesJson,
      required String tierAccess,
      required String reviewStatus,
      Value<int> version,
      Value<String?> jurisdictionId,
      Value<String?> organization,
      Value<String?> eventDate,
      Value<String> payloadJson,
      required String contentVersion,
      Value<int> isTestData,
    });
typedef $KnowledgeEntitiesUpdateCompanionBuilder =
    KnowledgeEntitiesCompanion Function({
      Value<String> entityId,
      Value<String> entityType,
      Value<String> area,
      Value<String?> subtype,
      Value<String> namesJson,
      Value<String> tierAccess,
      Value<String> reviewStatus,
      Value<int> version,
      Value<String?> jurisdictionId,
      Value<String?> organization,
      Value<String?> eventDate,
      Value<String> payloadJson,
      Value<String> contentVersion,
      Value<int> isTestData,
    });

final class $KnowledgeEntitiesReferences
    extends
        BaseReferences<_$ContentDatabase, KnowledgeEntities, KnowledgeEntity> {
  $KnowledgeEntitiesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Jurisdictions _jurisdictionIdTable(_$ContentDatabase db) =>
      db.jurisdictions.createAlias(
        'knowledge_entities__jurisdiction_id__jurisdictions__jurisdiction_id',
      );

  $JurisdictionsProcessedTableManager? get jurisdictionId {
    final $_column = $_itemColumn<String>('jurisdiction_id');
    if ($_column == null) return null;
    final manager = $JurisdictionsTableManager(
      $_db,
      $_db.jurisdictions,
    ).filter((f) => f.jurisdictionId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jurisdictionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<EntitySources, List<EntitySource>>
  _entitySourcesRefsTable(_$ContentDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.entitySources,
        aliasName: 'knowledge_entities__entity_id__entity_sources__entity_id',
      );

  $EntitySourcesProcessedTableManager get entitySourcesRefs {
    final manager = $EntitySourcesTableManager($_db, $_db.entitySources).filter(
      (f) => f.entityId.entityId.sqlEquals($_itemColumn<String>('entity_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_entitySourcesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $KnowledgeEntitiesFilterComposer
    extends Composer<_$ContentDatabase, KnowledgeEntities> {
  $KnowledgeEntitiesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namesJson => $composableBuilder(
    column: $table.namesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tierAccess => $composableBuilder(
    column: $table.tierAccess,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnFilters(column),
  );

  $JurisdictionsFilterComposer get jurisdictionId {
    final $JurisdictionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsFilterComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entitySourcesRefs(
    Expression<bool> Function($EntitySourcesFilterComposer f) f,
  ) {
    final $EntitySourcesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entitySources,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitySourcesFilterComposer(
            $db: $db,
            $table: $db.entitySources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $KnowledgeEntitiesOrderingComposer
    extends Composer<_$ContentDatabase, KnowledgeEntities> {
  $KnowledgeEntitiesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namesJson => $composableBuilder(
    column: $table.namesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tierAccess => $composableBuilder(
    column: $table.tierAccess,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnOrderings(column),
  );

  $JurisdictionsOrderingComposer get jurisdictionId {
    final $JurisdictionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsOrderingComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $KnowledgeEntitiesAnnotationComposer
    extends Composer<_$ContentDatabase, KnowledgeEntities> {
  $KnowledgeEntitiesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<String> get subtype =>
      $composableBuilder(column: $table.subtype, builder: (column) => column);

  GeneratedColumn<String> get namesJson =>
      $composableBuilder(column: $table.namesJson, builder: (column) => column);

  GeneratedColumn<String> get tierAccess => $composableBuilder(
    column: $table.tierAccess,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => column,
  );

  $JurisdictionsAnnotationComposer get jurisdictionId {
    final $JurisdictionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsAnnotationComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entitySourcesRefs<T extends Object>(
    Expression<T> Function($EntitySourcesAnnotationComposer a) f,
  ) {
    final $EntitySourcesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entitySources,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitySourcesAnnotationComposer(
            $db: $db,
            $table: $db.entitySources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $KnowledgeEntitiesTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          KnowledgeEntities,
          KnowledgeEntity,
          $KnowledgeEntitiesFilterComposer,
          $KnowledgeEntitiesOrderingComposer,
          $KnowledgeEntitiesAnnotationComposer,
          $KnowledgeEntitiesCreateCompanionBuilder,
          $KnowledgeEntitiesUpdateCompanionBuilder,
          (KnowledgeEntity, $KnowledgeEntitiesReferences),
          KnowledgeEntity,
          PrefetchHooks Function({bool jurisdictionId, bool entitySourcesRefs})
        > {
  $KnowledgeEntitiesTableManager(_$ContentDatabase db, KnowledgeEntities table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $KnowledgeEntitiesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $KnowledgeEntitiesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $KnowledgeEntitiesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> area = const Value.absent(),
                Value<String?> subtype = const Value.absent(),
                Value<String> namesJson = const Value.absent(),
                Value<String> tierAccess = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> jurisdictionId = const Value.absent(),
                Value<String?> organization = const Value.absent(),
                Value<String?> eventDate = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> contentVersion = const Value.absent(),
                Value<int> isTestData = const Value.absent(),
              }) => KnowledgeEntitiesCompanion(
                entityId: entityId,
                entityType: entityType,
                area: area,
                subtype: subtype,
                namesJson: namesJson,
                tierAccess: tierAccess,
                reviewStatus: reviewStatus,
                version: version,
                jurisdictionId: jurisdictionId,
                organization: organization,
                eventDate: eventDate,
                payloadJson: payloadJson,
                contentVersion: contentVersion,
                isTestData: isTestData,
              ),
          createCompanionCallback:
              ({
                required String entityId,
                required String entityType,
                required String area,
                Value<String?> subtype = const Value.absent(),
                required String namesJson,
                required String tierAccess,
                required String reviewStatus,
                Value<int> version = const Value.absent(),
                Value<String?> jurisdictionId = const Value.absent(),
                Value<String?> organization = const Value.absent(),
                Value<String?> eventDate = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                required String contentVersion,
                Value<int> isTestData = const Value.absent(),
              }) => KnowledgeEntitiesCompanion.insert(
                entityId: entityId,
                entityType: entityType,
                area: area,
                subtype: subtype,
                namesJson: namesJson,
                tierAccess: tierAccess,
                reviewStatus: reviewStatus,
                version: version,
                jurisdictionId: jurisdictionId,
                organization: organization,
                eventDate: eventDate,
                payloadJson: payloadJson,
                contentVersion: contentVersion,
                isTestData: isTestData,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<KnowledgeEntities, KnowledgeEntity>(table),
                  $KnowledgeEntitiesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({jurisdictionId = false, entitySourcesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entitySourcesRefs) db.entitySources,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (jurisdictionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.jurisdictionId,
                            referencedTable: $KnowledgeEntitiesReferences
                                ._jurisdictionIdTable(db),
                            referencedColumn: $KnowledgeEntitiesReferences
                                ._jurisdictionIdTable(db)
                                .jurisdictionId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entitySourcesRefs)
                        await $_getPrefetchedData<
                          KnowledgeEntity,
                          KnowledgeEntities,
                          EntitySource
                        >(
                          currentTable: table,
                          referencedTable: $KnowledgeEntitiesReferences
                              ._entitySourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $KnowledgeEntitiesReferences(
                                db,
                                table,
                                p0,
                              ).entitySourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entityId == item.entityId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $KnowledgeEntitiesProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      KnowledgeEntities,
      KnowledgeEntity,
      $KnowledgeEntitiesFilterComposer,
      $KnowledgeEntitiesOrderingComposer,
      $KnowledgeEntitiesAnnotationComposer,
      $KnowledgeEntitiesCreateCompanionBuilder,
      $KnowledgeEntitiesUpdateCompanionBuilder,
      (KnowledgeEntity, $KnowledgeEntitiesReferences),
      KnowledgeEntity,
      PrefetchHooks Function({bool jurisdictionId, bool entitySourcesRefs})
    >;
typedef $EntitySourcesCreateCompanionBuilder = EntitySourcesCompanion Function({
  required String entityId,
  required String sourceId,
  Value<String?> locator,
});
typedef $EntitySourcesUpdateCompanionBuilder = EntitySourcesCompanion Function({
  Value<String> entityId,
  Value<String> sourceId,
  Value<String?> locator,
});

final class $EntitySourcesReferences
    extends BaseReferences<_$ContentDatabase, EntitySources, EntitySource> {
  $EntitySourcesReferences(super.$_db, super.$_table, super.$_typedResult);

  static KnowledgeEntities _entityIdTable(_$ContentDatabase db) => db
      .knowledgeEntities
      .createAlias('entity_sources__entity_id__knowledge_entities__entity_id');

  $KnowledgeEntitiesProcessedTableManager get entityId {
    final $_column = $_itemColumn<String>('entity_id')!;

    final manager = $KnowledgeEntitiesTableManager(
      $_db,
      $_db.knowledgeEntities,
    ).filter((f) => f.entityId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Sources _sourceIdTable(_$ContentDatabase db) =>
      db.sources.createAlias('entity_sources__source_id__sources__source_id');

  $SourcesProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $SourcesTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.sourceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $EntitySourcesFilterComposer
    extends Composer<_$ContentDatabase, EntitySources> {
  $EntitySourcesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnFilters(column),
  );

  $KnowledgeEntitiesFilterComposer get entityId {
    final $KnowledgeEntitiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.knowledgeEntities,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $KnowledgeEntitiesFilterComposer(
            $db: $db,
            $table: $db.knowledgeEntities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SourcesFilterComposer get sourceId {
    final $SourcesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SourcesFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $EntitySourcesOrderingComposer
    extends Composer<_$ContentDatabase, EntitySources> {
  $EntitySourcesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnOrderings(column),
  );

  $KnowledgeEntitiesOrderingComposer get entityId {
    final $KnowledgeEntitiesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.knowledgeEntities,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $KnowledgeEntitiesOrderingComposer(
            $db: $db,
            $table: $db.knowledgeEntities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SourcesOrderingComposer get sourceId {
    final $SourcesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SourcesOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $EntitySourcesAnnotationComposer
    extends Composer<_$ContentDatabase, EntitySources> {
  $EntitySourcesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get locator =>
      $composableBuilder(column: $table.locator, builder: (column) => column);

  $KnowledgeEntitiesAnnotationComposer get entityId {
    final $KnowledgeEntitiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.knowledgeEntities,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $KnowledgeEntitiesAnnotationComposer(
            $db: $db,
            $table: $db.knowledgeEntities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SourcesAnnotationComposer get sourceId {
    final $SourcesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SourcesAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $EntitySourcesTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          EntitySources,
          EntitySource,
          $EntitySourcesFilterComposer,
          $EntitySourcesOrderingComposer,
          $EntitySourcesAnnotationComposer,
          $EntitySourcesCreateCompanionBuilder,
          $EntitySourcesUpdateCompanionBuilder,
          (EntitySource, $EntitySourcesReferences),
          EntitySource,
          PrefetchHooks Function({bool entityId, bool sourceId})
        > {
  $EntitySourcesTableManager(_$ContentDatabase db, EntitySources table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $EntitySourcesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $EntitySourcesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $EntitySourcesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityId = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String?> locator = const Value.absent(),
              }) => EntitySourcesCompanion(
                entityId: entityId,
                sourceId: sourceId,
                locator: locator,
              ),
          createCompanionCallback:
              ({
                required String entityId,
                required String sourceId,
                Value<String?> locator = const Value.absent(),
              }) => EntitySourcesCompanion.insert(
                entityId: entityId,
                sourceId: sourceId,
                locator: locator,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<EntitySources, EntitySource>(table),
                  $EntitySourcesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entityId = false, sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entityId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.entityId,
                        referencedTable: $EntitySourcesReferences
                            ._entityIdTable(db),
                        referencedColumn: $EntitySourcesReferences
                            ._entityIdTable(db)
                            .entityId,
                      ) as T;
                    }
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $EntitySourcesReferences
                            ._sourceIdTable(db),
                        referencedColumn: $EntitySourcesReferences
                            ._sourceIdTable(db)
                            .sourceId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $EntitySourcesProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      EntitySources,
      EntitySource,
      $EntitySourcesFilterComposer,
      $EntitySourcesOrderingComposer,
      $EntitySourcesAnnotationComposer,
      $EntitySourcesCreateCompanionBuilder,
      $EntitySourcesUpdateCompanionBuilder,
      (EntitySource, $EntitySourcesReferences),
      EntitySource,
      PrefetchHooks Function({bool entityId, bool sourceId})
    >;
typedef $ClaimGroupsCreateCompanionBuilder = ClaimGroupsCompanion Function({
  required String groupId,
  required String entityType,
  required String entityId,
  required String field,
  required String contextKey,
  required String conflictState,
  Value<String?> editorialNote,
  Value<String> displayPolicy,
});
typedef $ClaimGroupsUpdateCompanionBuilder = ClaimGroupsCompanion Function({
  Value<String> groupId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> field,
  Value<String> contextKey,
  Value<String> conflictState,
  Value<String?> editorialNote,
  Value<String> displayPolicy,
});

final class $ClaimGroupsReferences
    extends BaseReferences<_$ContentDatabase, ClaimGroups, ClaimGroup> {
  $ClaimGroupsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Claims, List<Claim>> _claimsRefsTable(
    _$ContentDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.claims,
    aliasName: 'claim_groups__group_id__claims__group_id',
  );

  $ClaimsProcessedTableManager get claimsRefs {
    final manager = $ClaimsTableManager($_db, $_db.claims).filter(
      (f) => f.groupId.groupId.sqlEquals($_itemColumn<String>('group_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_claimsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ClaimGroupsFilterComposer
    extends Composer<_$ContentDatabase, ClaimGroups> {
  $ClaimGroupsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictState => $composableBuilder(
    column: $table.conflictState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editorialNote => $composableBuilder(
    column: $table.editorialNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayPolicy => $composableBuilder(
    column: $table.displayPolicy,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> claimsRefs(
    Expression<bool> Function($ClaimsFilterComposer f) f,
  ) {
    final $ClaimsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimsFilterComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ClaimGroupsOrderingComposer
    extends Composer<_$ContentDatabase, ClaimGroups> {
  $ClaimGroupsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictState => $composableBuilder(
    column: $table.conflictState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editorialNote => $composableBuilder(
    column: $table.editorialNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayPolicy => $composableBuilder(
    column: $table.displayPolicy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ClaimGroupsAnnotationComposer
    extends Composer<_$ContentDatabase, ClaimGroups> {
  $ClaimGroupsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conflictState => $composableBuilder(
    column: $table.conflictState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get editorialNote => $composableBuilder(
    column: $table.editorialNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayPolicy => $composableBuilder(
    column: $table.displayPolicy,
    builder: (column) => column,
  );

  Expression<T> claimsRefs<T extends Object>(
    Expression<T> Function($ClaimsAnnotationComposer a) f,
  ) {
    final $ClaimsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimsAnnotationComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ClaimGroupsTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          ClaimGroups,
          ClaimGroup,
          $ClaimGroupsFilterComposer,
          $ClaimGroupsOrderingComposer,
          $ClaimGroupsAnnotationComposer,
          $ClaimGroupsCreateCompanionBuilder,
          $ClaimGroupsUpdateCompanionBuilder,
          (ClaimGroup, $ClaimGroupsReferences),
          ClaimGroup,
          PrefetchHooks Function({bool claimsRefs})
        > {
  $ClaimGroupsTableManager(_$ContentDatabase db, ClaimGroups table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ClaimGroupsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ClaimGroupsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ClaimGroupsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> groupId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String> contextKey = const Value.absent(),
                Value<String> conflictState = const Value.absent(),
                Value<String?> editorialNote = const Value.absent(),
                Value<String> displayPolicy = const Value.absent(),
              }) => ClaimGroupsCompanion(
                groupId: groupId,
                entityType: entityType,
                entityId: entityId,
                field: field,
                contextKey: contextKey,
                conflictState: conflictState,
                editorialNote: editorialNote,
                displayPolicy: displayPolicy,
              ),
          createCompanionCallback:
              ({
                required String groupId,
                required String entityType,
                required String entityId,
                required String field,
                required String contextKey,
                required String conflictState,
                Value<String?> editorialNote = const Value.absent(),
                Value<String> displayPolicy = const Value.absent(),
              }) => ClaimGroupsCompanion.insert(
                groupId: groupId,
                entityType: entityType,
                entityId: entityId,
                field: field,
                contextKey: contextKey,
                conflictState: conflictState,
                editorialNote: editorialNote,
                displayPolicy: displayPolicy,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ClaimGroups, ClaimGroup>(table),
                  $ClaimGroupsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({claimsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (claimsRefs) db.claims],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (claimsRefs)
                    await $_getPrefetchedData<ClaimGroup, ClaimGroups, Claim>(
                      currentTable: table,
                      referencedTable: $ClaimGroupsReferences._claimsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $ClaimGroupsReferences(db, table, p0).claimsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.groupId == item.groupId,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $ClaimGroupsProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      ClaimGroups,
      ClaimGroup,
      $ClaimGroupsFilterComposer,
      $ClaimGroupsOrderingComposer,
      $ClaimGroupsAnnotationComposer,
      $ClaimGroupsCreateCompanionBuilder,
      $ClaimGroupsUpdateCompanionBuilder,
      (ClaimGroup, $ClaimGroupsReferences),
      ClaimGroup,
      PrefetchHooks Function({bool claimsRefs})
    >;
typedef $ClaimsCreateCompanionBuilder = ClaimsCompanion Function({
  required String claimId,
  required String entityType,
  required String entityId,
  required String field,
  required String valueJson,
  required String domain,
  required String reviewStatus,
  required String evidenceLevel,
  Value<String?> groupId,
  Value<int> preferred,
  Value<String?> preferenceReason,
  Value<int> version,
  required String updatedAt,
  Value<int> isTestData,
  Value<String> knowledgeLayer,
  Value<String?> jurisdictionId,
  Value<String?> instrumentId,
});
typedef $ClaimsUpdateCompanionBuilder = ClaimsCompanion Function({
  Value<String> claimId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> field,
  Value<String> valueJson,
  Value<String> domain,
  Value<String> reviewStatus,
  Value<String> evidenceLevel,
  Value<String?> groupId,
  Value<int> preferred,
  Value<String?> preferenceReason,
  Value<int> version,
  Value<String> updatedAt,
  Value<int> isTestData,
  Value<String> knowledgeLayer,
  Value<String?> jurisdictionId,
  Value<String?> instrumentId,
});

final class $ClaimsReferences
    extends BaseReferences<_$ContentDatabase, Claims, Claim> {
  $ClaimsReferences(super.$_db, super.$_table, super.$_typedResult);

  static ClaimGroups _groupIdTable(_$ContentDatabase db) =>
      db.claimGroups.createAlias('claims__group_id__claim_groups__group_id');

  $ClaimGroupsProcessedTableManager? get groupId {
    final $_column = $_itemColumn<String>('group_id');
    if ($_column == null) return null;
    final manager = $ClaimGroupsTableManager(
      $_db,
      $_db.claimGroups,
    ).filter((f) => f.groupId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Jurisdictions _jurisdictionIdTable(_$ContentDatabase db) => db
      .jurisdictions
      .createAlias('claims__jurisdiction_id__jurisdictions__jurisdiction_id');

  $JurisdictionsProcessedTableManager? get jurisdictionId {
    final $_column = $_itemColumn<String>('jurisdiction_id');
    if ($_column == null) return null;
    final manager = $JurisdictionsTableManager(
      $_db,
      $_db.jurisdictions,
    ).filter((f) => f.jurisdictionId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jurisdictionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static JurisdictionalInstruments _instrumentIdTable(_$ContentDatabase db) =>
      db.jurisdictionalInstruments.createAlias(
        'claims__instrument_id__jurisdictional_instruments__instrument_id',
      );

  $JurisdictionalInstrumentsProcessedTableManager? get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id');
    if ($_column == null) return null;
    final manager = $JurisdictionalInstrumentsTableManager(
      $_db,
      $_db.jurisdictionalInstruments,
    ).filter((f) => f.instrumentId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Citations, List<Citation>> _citationsRefsTable(
    _$ContentDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.citations,
    aliasName: 'claims__claim_id__citations__claim_id',
  );

  $CitationsProcessedTableManager get citationsRefs {
    final manager = $CitationsTableManager($_db, $_db.citations).filter(
      (f) => f.claimId.claimId.sqlEquals($_itemColumn<String>('claim_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_citationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<ConcentrationRecords, List<ConcentrationRecord>>
  _concentrationRecordsRefsTable(_$ContentDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.concentrationRecords,
        aliasName: 'claims__claim_id__concentration_records__claim_id',
      );

  $ConcentrationRecordsProcessedTableManager get concentrationRecordsRefs {
    final manager =
        $ConcentrationRecordsTableManager(
          $_db,
          $_db.concentrationRecords,
        ).filter(
          (f) => f.claimId.claimId.sqlEquals($_itemColumn<String>('claim_id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _concentrationRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ClaimsFilterComposer extends Composer<_$ContentDatabase, Claims> {
  $ClaimsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get claimId => $composableBuilder(
    column: $table.claimId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceLevel => $composableBuilder(
    column: $table.evidenceLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preferred => $composableBuilder(
    column: $table.preferred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferenceReason => $composableBuilder(
    column: $table.preferenceReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get knowledgeLayer => $composableBuilder(
    column: $table.knowledgeLayer,
    builder: (column) => ColumnFilters(column),
  );

  $ClaimGroupsFilterComposer get groupId {
    final $ClaimGroupsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.claimGroups,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimGroupsFilterComposer(
            $db: $db,
            $table: $db.claimGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $JurisdictionsFilterComposer get jurisdictionId {
    final $JurisdictionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsFilterComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $JurisdictionalInstrumentsFilterComposer get instrumentId {
    final $JurisdictionalInstrumentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.jurisdictionalInstruments,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionalInstrumentsFilterComposer(
            $db: $db,
            $table: $db.jurisdictionalInstruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> citationsRefs(
    Expression<bool> Function($CitationsFilterComposer f) f,
  ) {
    final $CitationsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.citations,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CitationsFilterComposer(
            $db: $db,
            $table: $db.citations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> concentrationRecordsRefs(
    Expression<bool> Function($ConcentrationRecordsFilterComposer f) f,
  ) {
    final $ConcentrationRecordsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.concentrationRecords,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConcentrationRecordsFilterComposer(
            $db: $db,
            $table: $db.concentrationRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ClaimsOrderingComposer extends Composer<_$ContentDatabase, Claims> {
  $ClaimsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get claimId => $composableBuilder(
    column: $table.claimId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceLevel => $composableBuilder(
    column: $table.evidenceLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preferred => $composableBuilder(
    column: $table.preferred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferenceReason => $composableBuilder(
    column: $table.preferenceReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get knowledgeLayer => $composableBuilder(
    column: $table.knowledgeLayer,
    builder: (column) => ColumnOrderings(column),
  );

  $ClaimGroupsOrderingComposer get groupId {
    final $ClaimGroupsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.claimGroups,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimGroupsOrderingComposer(
            $db: $db,
            $table: $db.claimGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $JurisdictionsOrderingComposer get jurisdictionId {
    final $JurisdictionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsOrderingComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $JurisdictionalInstrumentsOrderingComposer get instrumentId {
    final $JurisdictionalInstrumentsOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.instrumentId,
          referencedTable: $db.jurisdictionalInstruments,
          getReferencedColumn: (t) => t.instrumentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $JurisdictionalInstrumentsOrderingComposer(
                $db: $db,
                $table: $db.jurisdictionalInstruments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $ClaimsAnnotationComposer extends Composer<_$ContentDatabase, Claims> {
  $ClaimsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get claimId =>
      $composableBuilder(column: $table.claimId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidenceLevel => $composableBuilder(
    column: $table.evidenceLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preferred =>
      $composableBuilder(column: $table.preferred, builder: (column) => column);

  GeneratedColumn<String> get preferenceReason => $composableBuilder(
    column: $table.preferenceReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get knowledgeLayer => $composableBuilder(
    column: $table.knowledgeLayer,
    builder: (column) => column,
  );

  $ClaimGroupsAnnotationComposer get groupId {
    final $ClaimGroupsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.claimGroups,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimGroupsAnnotationComposer(
            $db: $db,
            $table: $db.claimGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $JurisdictionsAnnotationComposer get jurisdictionId {
    final $JurisdictionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurisdictionId,
      referencedTable: $db.jurisdictions,
      getReferencedColumn: (t) => t.jurisdictionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $JurisdictionsAnnotationComposer(
            $db: $db,
            $table: $db.jurisdictions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $JurisdictionalInstrumentsAnnotationComposer get instrumentId {
    final $JurisdictionalInstrumentsAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.instrumentId,
          referencedTable: $db.jurisdictionalInstruments,
          getReferencedColumn: (t) => t.instrumentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $JurisdictionalInstrumentsAnnotationComposer(
                $db: $db,
                $table: $db.jurisdictionalInstruments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> citationsRefs<T extends Object>(
    Expression<T> Function($CitationsAnnotationComposer a) f,
  ) {
    final $CitationsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.citations,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CitationsAnnotationComposer(
            $db: $db,
            $table: $db.citations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> concentrationRecordsRefs<T extends Object>(
    Expression<T> Function($ConcentrationRecordsAnnotationComposer a) f,
  ) {
    final $ConcentrationRecordsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.concentrationRecords,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConcentrationRecordsAnnotationComposer(
            $db: $db,
            $table: $db.concentrationRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ClaimsTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          Claims,
          Claim,
          $ClaimsFilterComposer,
          $ClaimsOrderingComposer,
          $ClaimsAnnotationComposer,
          $ClaimsCreateCompanionBuilder,
          $ClaimsUpdateCompanionBuilder,
          (Claim, $ClaimsReferences),
          Claim,
          PrefetchHooks Function({
            bool groupId,
            bool jurisdictionId,
            bool instrumentId,
            bool citationsRefs,
            bool concentrationRecordsRefs,
          })
        > {
  $ClaimsTableManager(_$ContentDatabase db, Claims table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ClaimsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ClaimsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ClaimsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> claimId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<String> evidenceLevel = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<int> preferred = const Value.absent(),
                Value<String?> preferenceReason = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> isTestData = const Value.absent(),
                Value<String> knowledgeLayer = const Value.absent(),
                Value<String?> jurisdictionId = const Value.absent(),
                Value<String?> instrumentId = const Value.absent(),
              }) => ClaimsCompanion(
                claimId: claimId,
                entityType: entityType,
                entityId: entityId,
                field: field,
                valueJson: valueJson,
                domain: domain,
                reviewStatus: reviewStatus,
                evidenceLevel: evidenceLevel,
                groupId: groupId,
                preferred: preferred,
                preferenceReason: preferenceReason,
                version: version,
                updatedAt: updatedAt,
                isTestData: isTestData,
                knowledgeLayer: knowledgeLayer,
                jurisdictionId: jurisdictionId,
                instrumentId: instrumentId,
              ),
          createCompanionCallback:
              ({
                required String claimId,
                required String entityType,
                required String entityId,
                required String field,
                required String valueJson,
                required String domain,
                required String reviewStatus,
                required String evidenceLevel,
                Value<String?> groupId = const Value.absent(),
                Value<int> preferred = const Value.absent(),
                Value<String?> preferenceReason = const Value.absent(),
                Value<int> version = const Value.absent(),
                required String updatedAt,
                Value<int> isTestData = const Value.absent(),
                Value<String> knowledgeLayer = const Value.absent(),
                Value<String?> jurisdictionId = const Value.absent(),
                Value<String?> instrumentId = const Value.absent(),
              }) => ClaimsCompanion.insert(
                claimId: claimId,
                entityType: entityType,
                entityId: entityId,
                field: field,
                valueJson: valueJson,
                domain: domain,
                reviewStatus: reviewStatus,
                evidenceLevel: evidenceLevel,
                groupId: groupId,
                preferred: preferred,
                preferenceReason: preferenceReason,
                version: version,
                updatedAt: updatedAt,
                isTestData: isTestData,
                knowledgeLayer: knowledgeLayer,
                jurisdictionId: jurisdictionId,
                instrumentId: instrumentId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Claims, Claim>(table),
                  $ClaimsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupId = false,
                jurisdictionId = false,
                instrumentId = false,
                citationsRefs = false,
                concentrationRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (citationsRefs) db.citations,
                    if (concentrationRecordsRefs) db.concentrationRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (groupId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $ClaimsReferences._groupIdTable(
                              db,
                            ),
                            referencedColumn: $ClaimsReferences
                                ._groupIdTable(db)
                                .groupId,
                          ) as T;
                        }
                        if (jurisdictionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.jurisdictionId,
                            referencedTable: $ClaimsReferences
                                ._jurisdictionIdTable(db),
                            referencedColumn: $ClaimsReferences
                                ._jurisdictionIdTable(db)
                                .jurisdictionId,
                          ) as T;
                        }
                        if (instrumentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.instrumentId,
                            referencedTable: $ClaimsReferences
                                ._instrumentIdTable(db),
                            referencedColumn: $ClaimsReferences
                                ._instrumentIdTable(db)
                                .instrumentId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (citationsRefs)
                        await $_getPrefetchedData<Claim, Claims, Citation>(
                          currentTable: table,
                          referencedTable: $ClaimsReferences
                              ._citationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ClaimsReferences(db, table, p0).citationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.claimId == item.claimId,
                              ),
                          typedResults: items,
                        ),
                      if (concentrationRecordsRefs)
                        await $_getPrefetchedData<
                          Claim,
                          Claims,
                          ConcentrationRecord
                        >(
                          currentTable: table,
                          referencedTable: $ClaimsReferences
                              ._concentrationRecordsRefsTable(db),
                          managerFromTypedResult: (p0) => $ClaimsReferences(
                            db,
                            table,
                            p0,
                          ).concentrationRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.claimId == item.claimId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $ClaimsProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      Claims,
      Claim,
      $ClaimsFilterComposer,
      $ClaimsOrderingComposer,
      $ClaimsAnnotationComposer,
      $ClaimsCreateCompanionBuilder,
      $ClaimsUpdateCompanionBuilder,
      (Claim, $ClaimsReferences),
      Claim,
      PrefetchHooks Function({
        bool groupId,
        bool jurisdictionId,
        bool instrumentId,
        bool citationsRefs,
        bool concentrationRecordsRefs,
      })
    >;
typedef $CitationsCreateCompanionBuilder = CitationsCompanion Function({
  required String claimId,
  required String sourceId,
  Value<String?> locator,
});
typedef $CitationsUpdateCompanionBuilder = CitationsCompanion Function({
  Value<String> claimId,
  Value<String> sourceId,
  Value<String?> locator,
});

final class $CitationsReferences
    extends BaseReferences<_$ContentDatabase, Citations, Citation> {
  $CitationsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Claims _claimIdTable(_$ContentDatabase db) =>
      db.claims.createAlias('citations__claim_id__claims__claim_id');

  $ClaimsProcessedTableManager get claimId {
    final $_column = $_itemColumn<String>('claim_id')!;

    final manager = $ClaimsTableManager(
      $_db,
      $_db.claims,
    ).filter((f) => f.claimId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_claimIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Sources _sourceIdTable(_$ContentDatabase db) =>
      db.sources.createAlias('citations__source_id__sources__source_id');

  $SourcesProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $SourcesTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.sourceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $CitationsFilterComposer extends Composer<_$ContentDatabase, Citations> {
  $CitationsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnFilters(column),
  );

  $ClaimsFilterComposer get claimId {
    final $ClaimsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimsFilterComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SourcesFilterComposer get sourceId {
    final $SourcesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SourcesFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CitationsOrderingComposer
    extends Composer<_$ContentDatabase, Citations> {
  $CitationsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnOrderings(column),
  );

  $ClaimsOrderingComposer get claimId {
    final $ClaimsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimsOrderingComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SourcesOrderingComposer get sourceId {
    final $SourcesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SourcesOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CitationsAnnotationComposer
    extends Composer<_$ContentDatabase, Citations> {
  $CitationsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get locator =>
      $composableBuilder(column: $table.locator, builder: (column) => column);

  $ClaimsAnnotationComposer get claimId {
    final $ClaimsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimsAnnotationComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SourcesAnnotationComposer get sourceId {
    final $SourcesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SourcesAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CitationsTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          Citations,
          Citation,
          $CitationsFilterComposer,
          $CitationsOrderingComposer,
          $CitationsAnnotationComposer,
          $CitationsCreateCompanionBuilder,
          $CitationsUpdateCompanionBuilder,
          (Citation, $CitationsReferences),
          Citation,
          PrefetchHooks Function({bool claimId, bool sourceId})
        > {
  $CitationsTableManager(_$ContentDatabase db, Citations table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CitationsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CitationsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CitationsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> claimId = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String?> locator = const Value.absent(),
              }) => CitationsCompanion(
                claimId: claimId,
                sourceId: sourceId,
                locator: locator,
              ),
          createCompanionCallback:
              ({
                required String claimId,
                required String sourceId,
                Value<String?> locator = const Value.absent(),
              }) => CitationsCompanion.insert(
                claimId: claimId,
                sourceId: sourceId,
                locator: locator,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Citations, Citation>(table),
                  $CitationsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({claimId = false, sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (claimId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.claimId,
                        referencedTable: $CitationsReferences._claimIdTable(db),
                        referencedColumn: $CitationsReferences
                            ._claimIdTable(db)
                            .claimId,
                      ) as T;
                    }
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $CitationsReferences._sourceIdTable(
                          db,
                        ),
                        referencedColumn: $CitationsReferences
                            ._sourceIdTable(db)
                            .sourceId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $CitationsProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      Citations,
      Citation,
      $CitationsFilterComposer,
      $CitationsOrderingComposer,
      $CitationsAnnotationComposer,
      $CitationsCreateCompanionBuilder,
      $CitationsUpdateCompanionBuilder,
      (Citation, $CitationsReferences),
      Citation,
      PrefetchHooks Function({bool claimId, bool sourceId})
    >;
typedef $ReviewersCreateCompanionBuilder = ReviewersCompanion Function({
  required String reviewerId,
  required String displayName,
  Value<String?> qualification,
  Value<int> active,
});
typedef $ReviewersUpdateCompanionBuilder = ReviewersCompanion Function({
  Value<String> reviewerId,
  Value<String> displayName,
  Value<String?> qualification,
  Value<int> active,
});

final class $ReviewersReferences
    extends BaseReferences<_$ContentDatabase, Reviewers, Reviewer> {
  $ReviewersReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<ReviewerDomains, List<ReviewerDomain>>
  _reviewerDomainsRefsTable(_$ContentDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reviewerDomains,
        aliasName: 'reviewers__reviewer_id__reviewer_domains__reviewer_id',
      );

  $ReviewerDomainsProcessedTableManager get reviewerDomainsRefs {
    final manager = $ReviewerDomainsTableManager($_db, $_db.reviewerDomains)
        .filter(
          (f) => f.reviewerId.reviewerId.sqlEquals(
            $_itemColumn<String>('reviewer_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _reviewerDomainsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Reviews, List<Review>> _reviewsRefsTable(
    _$ContentDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.reviews,
    aliasName: 'reviewers__reviewer_id__reviews__reviewer_id',
  );

  $ReviewsProcessedTableManager get reviewsRefs {
    final manager = $ReviewsTableManager($_db, $_db.reviews).filter(
      (f) => f.reviewerId.reviewerId.sqlEquals(
        $_itemColumn<String>('reviewer_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_reviewsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ReviewersFilterComposer extends Composer<_$ContentDatabase, Reviewers> {
  $ReviewersFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get reviewerId => $composableBuilder(
    column: $table.reviewerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qualification => $composableBuilder(
    column: $table.qualification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> reviewerDomainsRefs(
    Expression<bool> Function($ReviewerDomainsFilterComposer f) f,
  ) {
    final $ReviewerDomainsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewerId,
      referencedTable: $db.reviewerDomains,
      getReferencedColumn: (t) => t.reviewerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReviewerDomainsFilterComposer(
            $db: $db,
            $table: $db.reviewerDomains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reviewsRefs(
    Expression<bool> Function($ReviewsFilterComposer f) f,
  ) {
    final $ReviewsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewerId,
      referencedTable: $db.reviews,
      getReferencedColumn: (t) => t.reviewerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReviewsFilterComposer(
            $db: $db,
            $table: $db.reviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ReviewersOrderingComposer
    extends Composer<_$ContentDatabase, Reviewers> {
  $ReviewersOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get reviewerId => $composableBuilder(
    column: $table.reviewerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qualification => $composableBuilder(
    column: $table.qualification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ReviewersAnnotationComposer
    extends Composer<_$ContentDatabase, Reviewers> {
  $ReviewersAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get reviewerId => $composableBuilder(
    column: $table.reviewerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qualification => $composableBuilder(
    column: $table.qualification,
    builder: (column) => column,
  );

  GeneratedColumn<int> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  Expression<T> reviewerDomainsRefs<T extends Object>(
    Expression<T> Function($ReviewerDomainsAnnotationComposer a) f,
  ) {
    final $ReviewerDomainsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewerId,
      referencedTable: $db.reviewerDomains,
      getReferencedColumn: (t) => t.reviewerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReviewerDomainsAnnotationComposer(
            $db: $db,
            $table: $db.reviewerDomains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reviewsRefs<T extends Object>(
    Expression<T> Function($ReviewsAnnotationComposer a) f,
  ) {
    final $ReviewsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewerId,
      referencedTable: $db.reviews,
      getReferencedColumn: (t) => t.reviewerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReviewsAnnotationComposer(
            $db: $db,
            $table: $db.reviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ReviewersTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          Reviewers,
          Reviewer,
          $ReviewersFilterComposer,
          $ReviewersOrderingComposer,
          $ReviewersAnnotationComposer,
          $ReviewersCreateCompanionBuilder,
          $ReviewersUpdateCompanionBuilder,
          (Reviewer, $ReviewersReferences),
          Reviewer,
          PrefetchHooks Function({bool reviewerDomainsRefs, bool reviewsRefs})
        > {
  $ReviewersTableManager(_$ContentDatabase db, Reviewers table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ReviewersFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ReviewersOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ReviewersAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> reviewerId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> qualification = const Value.absent(),
                Value<int> active = const Value.absent(),
              }) => ReviewersCompanion(
                reviewerId: reviewerId,
                displayName: displayName,
                qualification: qualification,
                active: active,
              ),
          createCompanionCallback:
              ({
                required String reviewerId,
                required String displayName,
                Value<String?> qualification = const Value.absent(),
                Value<int> active = const Value.absent(),
              }) => ReviewersCompanion.insert(
                reviewerId: reviewerId,
                displayName: displayName,
                qualification: qualification,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Reviewers, Reviewer>(table),
                  $ReviewersReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({reviewerDomainsRefs = false, reviewsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (reviewerDomainsRefs) db.reviewerDomains,
                    if (reviewsRefs) db.reviews,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reviewerDomainsRefs)
                        await $_getPrefetchedData<
                          Reviewer,
                          Reviewers,
                          ReviewerDomain
                        >(
                          currentTable: table,
                          referencedTable: $ReviewersReferences
                              ._reviewerDomainsRefsTable(db),
                          managerFromTypedResult: (p0) => $ReviewersReferences(
                            db,
                            table,
                            p0,
                          ).reviewerDomainsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reviewerId == item.reviewerId,
                              ),
                          typedResults: items,
                        ),
                      if (reviewsRefs)
                        await $_getPrefetchedData<Reviewer, Reviewers, Review>(
                          currentTable: table,
                          referencedTable: $ReviewersReferences
                              ._reviewsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ReviewersReferences(db, table, p0).reviewsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reviewerId == item.reviewerId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $ReviewersProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      Reviewers,
      Reviewer,
      $ReviewersFilterComposer,
      $ReviewersOrderingComposer,
      $ReviewersAnnotationComposer,
      $ReviewersCreateCompanionBuilder,
      $ReviewersUpdateCompanionBuilder,
      (Reviewer, $ReviewersReferences),
      Reviewer,
      PrefetchHooks Function({bool reviewerDomainsRefs, bool reviewsRefs})
    >;
typedef $ReviewerDomainsCreateCompanionBuilder =
    ReviewerDomainsCompanion Function({
      required String reviewerId,
      required String domain,
      Value<int> canVerify,
    });
typedef $ReviewerDomainsUpdateCompanionBuilder =
    ReviewerDomainsCompanion Function({
      Value<String> reviewerId,
      Value<String> domain,
      Value<int> canVerify,
    });

final class $ReviewerDomainsReferences
    extends BaseReferences<_$ContentDatabase, ReviewerDomains, ReviewerDomain> {
  $ReviewerDomainsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Reviewers _reviewerIdTable(_$ContentDatabase db) => db.reviewers
      .createAlias('reviewer_domains__reviewer_id__reviewers__reviewer_id');

  $ReviewersProcessedTableManager get reviewerId {
    final $_column = $_itemColumn<String>('reviewer_id')!;

    final manager = $ReviewersTableManager(
      $_db,
      $_db.reviewers,
    ).filter((f) => f.reviewerId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reviewerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ReviewerDomainsFilterComposer
    extends Composer<_$ContentDatabase, ReviewerDomains> {
  $ReviewerDomainsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get canVerify => $composableBuilder(
    column: $table.canVerify,
    builder: (column) => ColumnFilters(column),
  );

  $ReviewersFilterComposer get reviewerId {
    final $ReviewersFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewerId,
      referencedTable: $db.reviewers,
      getReferencedColumn: (t) => t.reviewerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReviewersFilterComposer(
            $db: $db,
            $table: $db.reviewers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ReviewerDomainsOrderingComposer
    extends Composer<_$ContentDatabase, ReviewerDomains> {
  $ReviewerDomainsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get canVerify => $composableBuilder(
    column: $table.canVerify,
    builder: (column) => ColumnOrderings(column),
  );

  $ReviewersOrderingComposer get reviewerId {
    final $ReviewersOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewerId,
      referencedTable: $db.reviewers,
      getReferencedColumn: (t) => t.reviewerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReviewersOrderingComposer(
            $db: $db,
            $table: $db.reviewers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ReviewerDomainsAnnotationComposer
    extends Composer<_$ContentDatabase, ReviewerDomains> {
  $ReviewerDomainsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<int> get canVerify =>
      $composableBuilder(column: $table.canVerify, builder: (column) => column);

  $ReviewersAnnotationComposer get reviewerId {
    final $ReviewersAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewerId,
      referencedTable: $db.reviewers,
      getReferencedColumn: (t) => t.reviewerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReviewersAnnotationComposer(
            $db: $db,
            $table: $db.reviewers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ReviewerDomainsTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          ReviewerDomains,
          ReviewerDomain,
          $ReviewerDomainsFilterComposer,
          $ReviewerDomainsOrderingComposer,
          $ReviewerDomainsAnnotationComposer,
          $ReviewerDomainsCreateCompanionBuilder,
          $ReviewerDomainsUpdateCompanionBuilder,
          (ReviewerDomain, $ReviewerDomainsReferences),
          ReviewerDomain,
          PrefetchHooks Function({bool reviewerId})
        > {
  $ReviewerDomainsTableManager(_$ContentDatabase db, ReviewerDomains table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ReviewerDomainsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ReviewerDomainsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ReviewerDomainsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> reviewerId = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<int> canVerify = const Value.absent(),
              }) => ReviewerDomainsCompanion(
                reviewerId: reviewerId,
                domain: domain,
                canVerify: canVerify,
              ),
          createCompanionCallback:
              ({
                required String reviewerId,
                required String domain,
                Value<int> canVerify = const Value.absent(),
              }) => ReviewerDomainsCompanion.insert(
                reviewerId: reviewerId,
                domain: domain,
                canVerify: canVerify,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ReviewerDomains, ReviewerDomain>(table),
                  $ReviewerDomainsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reviewerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (reviewerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.reviewerId,
                        referencedTable: $ReviewerDomainsReferences
                            ._reviewerIdTable(db),
                        referencedColumn: $ReviewerDomainsReferences
                            ._reviewerIdTable(db)
                            .reviewerId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $ReviewerDomainsProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      ReviewerDomains,
      ReviewerDomain,
      $ReviewerDomainsFilterComposer,
      $ReviewerDomainsOrderingComposer,
      $ReviewerDomainsAnnotationComposer,
      $ReviewerDomainsCreateCompanionBuilder,
      $ReviewerDomainsUpdateCompanionBuilder,
      (ReviewerDomain, $ReviewerDomainsReferences),
      ReviewerDomain,
      PrefetchHooks Function({bool reviewerId})
    >;
typedef $ReviewsCreateCompanionBuilder = ReviewsCompanion Function({
  required String reviewId,
  required String targetType,
  required String targetId,
  required int targetVersion,
  required String domain,
  required String reviewerId,
  required String decision,
  required String createdAt,
});
typedef $ReviewsUpdateCompanionBuilder = ReviewsCompanion Function({
  Value<String> reviewId,
  Value<String> targetType,
  Value<String> targetId,
  Value<int> targetVersion,
  Value<String> domain,
  Value<String> reviewerId,
  Value<String> decision,
  Value<String> createdAt,
});

final class $ReviewsReferences
    extends BaseReferences<_$ContentDatabase, Reviews, Review> {
  $ReviewsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Reviewers _reviewerIdTable(_$ContentDatabase db) =>
      db.reviewers.createAlias('reviews__reviewer_id__reviewers__reviewer_id');

  $ReviewersProcessedTableManager get reviewerId {
    final $_column = $_itemColumn<String>('reviewer_id')!;

    final manager = $ReviewersTableManager(
      $_db,
      $_db.reviewers,
    ).filter((f) => f.reviewerId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reviewerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ReviewsFilterComposer extends Composer<_$ContentDatabase, Reviews> {
  $ReviewsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get reviewId => $composableBuilder(
    column: $table.reviewId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetVersion => $composableBuilder(
    column: $table.targetVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $ReviewersFilterComposer get reviewerId {
    final $ReviewersFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewerId,
      referencedTable: $db.reviewers,
      getReferencedColumn: (t) => t.reviewerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReviewersFilterComposer(
            $db: $db,
            $table: $db.reviewers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ReviewsOrderingComposer extends Composer<_$ContentDatabase, Reviews> {
  $ReviewsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get reviewId => $composableBuilder(
    column: $table.reviewId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetVersion => $composableBuilder(
    column: $table.targetVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ReviewersOrderingComposer get reviewerId {
    final $ReviewersOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewerId,
      referencedTable: $db.reviewers,
      getReferencedColumn: (t) => t.reviewerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReviewersOrderingComposer(
            $db: $db,
            $table: $db.reviewers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ReviewsAnnotationComposer extends Composer<_$ContentDatabase, Reviews> {
  $ReviewsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get reviewId =>
      $composableBuilder(column: $table.reviewId, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<int> get targetVersion => $composableBuilder(
    column: $table.targetVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get decision =>
      $composableBuilder(column: $table.decision, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $ReviewersAnnotationComposer get reviewerId {
    final $ReviewersAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewerId,
      referencedTable: $db.reviewers,
      getReferencedColumn: (t) => t.reviewerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReviewersAnnotationComposer(
            $db: $db,
            $table: $db.reviewers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ReviewsTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          Reviews,
          Review,
          $ReviewsFilterComposer,
          $ReviewsOrderingComposer,
          $ReviewsAnnotationComposer,
          $ReviewsCreateCompanionBuilder,
          $ReviewsUpdateCompanionBuilder,
          (Review, $ReviewsReferences),
          Review,
          PrefetchHooks Function({bool reviewerId})
        > {
  $ReviewsTableManager(_$ContentDatabase db, Reviews table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ReviewsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ReviewsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ReviewsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> reviewId = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<int> targetVersion = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> reviewerId = const Value.absent(),
                Value<String> decision = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => ReviewsCompanion(
                reviewId: reviewId,
                targetType: targetType,
                targetId: targetId,
                targetVersion: targetVersion,
                domain: domain,
                reviewerId: reviewerId,
                decision: decision,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                required String reviewId,
                required String targetType,
                required String targetId,
                required int targetVersion,
                required String domain,
                required String reviewerId,
                required String decision,
                required String createdAt,
              }) => ReviewsCompanion.insert(
                reviewId: reviewId,
                targetType: targetType,
                targetId: targetId,
                targetVersion: targetVersion,
                domain: domain,
                reviewerId: reviewerId,
                decision: decision,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Reviews, Review>(table),
                  $ReviewsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reviewerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (reviewerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.reviewerId,
                        referencedTable: $ReviewsReferences._reviewerIdTable(
                          db,
                        ),
                        referencedColumn: $ReviewsReferences
                            ._reviewerIdTable(db)
                            .reviewerId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $ReviewsProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      Reviews,
      Review,
      $ReviewsFilterComposer,
      $ReviewsOrderingComposer,
      $ReviewsAnnotationComposer,
      $ReviewsCreateCompanionBuilder,
      $ReviewsUpdateCompanionBuilder,
      (Review, $ReviewsReferences),
      Review,
      PrefetchHooks Function({bool reviewerId})
    >;
typedef $SubstancesCreateCompanionBuilder = SubstancesCompanion Function({
  required String substanceId,
  required String canonicalName,
  required String entityKind,
  Value<String?> molecularFormula,
  required String tierAccess,
  required String reviewStatus,
  Value<String?> lastReviewedAt,
  required String contentVersion,
  Value<int> isTestData,
  Value<String?> substanceGroup,
});
typedef $SubstancesUpdateCompanionBuilder = SubstancesCompanion Function({
  Value<String> substanceId,
  Value<String> canonicalName,
  Value<String> entityKind,
  Value<String?> molecularFormula,
  Value<String> tierAccess,
  Value<String> reviewStatus,
  Value<String?> lastReviewedAt,
  Value<String> contentVersion,
  Value<int> isTestData,
  Value<String?> substanceGroup,
});

final class $SubstancesReferences
    extends BaseReferences<_$ContentDatabase, Substances, Substance> {
  $SubstancesReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<SubstanceI18n, List<SubstanceI18nData>>
  _substanceI18nRefsTable(_$ContentDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.substanceI18n,
        aliasName: 'substances__substance_id__substance_i18n__substance_id',
      );

  $SubstanceI18nProcessedTableManager get substanceI18nRefs {
    final manager = $SubstanceI18nTableManager($_db, $_db.substanceI18n).filter(
      (f) => f.substanceId.substanceId.sqlEquals(
        $_itemColumn<String>('substance_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_substanceI18nRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<ConcentrationRecords, List<ConcentrationRecord>>
  _concentrationRecordsRefsTable(_$ContentDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.concentrationRecords,
        aliasName:
            'substances__substance_id__concentration_records__substance_id',
      );

  $ConcentrationRecordsProcessedTableManager get concentrationRecordsRefs {
    final manager =
        $ConcentrationRecordsTableManager(
          $_db,
          $_db.concentrationRecords,
        ).filter(
          (f) => f.substanceId.substanceId.sqlEquals(
            $_itemColumn<String>('substance_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _concentrationRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $SubstancesFilterComposer
    extends Composer<_$ContentDatabase, Substances> {
  $SubstancesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get substanceId => $composableBuilder(
    column: $table.substanceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityKind => $composableBuilder(
    column: $table.entityKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get molecularFormula => $composableBuilder(
    column: $table.molecularFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tierAccess => $composableBuilder(
    column: $table.tierAccess,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get substanceGroup => $composableBuilder(
    column: $table.substanceGroup,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> substanceI18nRefs(
    Expression<bool> Function($SubstanceI18nFilterComposer f) f,
  ) {
    final $SubstanceI18nFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.substanceId,
      referencedTable: $db.substanceI18n,
      getReferencedColumn: (t) => t.substanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SubstanceI18nFilterComposer(
            $db: $db,
            $table: $db.substanceI18n,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> concentrationRecordsRefs(
    Expression<bool> Function($ConcentrationRecordsFilterComposer f) f,
  ) {
    final $ConcentrationRecordsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.substanceId,
      referencedTable: $db.concentrationRecords,
      getReferencedColumn: (t) => t.substanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConcentrationRecordsFilterComposer(
            $db: $db,
            $table: $db.concentrationRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SubstancesOrderingComposer
    extends Composer<_$ContentDatabase, Substances> {
  $SubstancesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get substanceId => $composableBuilder(
    column: $table.substanceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityKind => $composableBuilder(
    column: $table.entityKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get molecularFormula => $composableBuilder(
    column: $table.molecularFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tierAccess => $composableBuilder(
    column: $table.tierAccess,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get substanceGroup => $composableBuilder(
    column: $table.substanceGroup,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SubstancesAnnotationComposer
    extends Composer<_$ContentDatabase, Substances> {
  $SubstancesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get substanceId => $composableBuilder(
    column: $table.substanceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityKind => $composableBuilder(
    column: $table.entityKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get molecularFormula => $composableBuilder(
    column: $table.molecularFormula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tierAccess => $composableBuilder(
    column: $table.tierAccess,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get substanceGroup => $composableBuilder(
    column: $table.substanceGroup,
    builder: (column) => column,
  );

  Expression<T> substanceI18nRefs<T extends Object>(
    Expression<T> Function($SubstanceI18nAnnotationComposer a) f,
  ) {
    final $SubstanceI18nAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.substanceId,
      referencedTable: $db.substanceI18n,
      getReferencedColumn: (t) => t.substanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SubstanceI18nAnnotationComposer(
            $db: $db,
            $table: $db.substanceI18n,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> concentrationRecordsRefs<T extends Object>(
    Expression<T> Function($ConcentrationRecordsAnnotationComposer a) f,
  ) {
    final $ConcentrationRecordsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.substanceId,
      referencedTable: $db.concentrationRecords,
      getReferencedColumn: (t) => t.substanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConcentrationRecordsAnnotationComposer(
            $db: $db,
            $table: $db.concentrationRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SubstancesTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          Substances,
          Substance,
          $SubstancesFilterComposer,
          $SubstancesOrderingComposer,
          $SubstancesAnnotationComposer,
          $SubstancesCreateCompanionBuilder,
          $SubstancesUpdateCompanionBuilder,
          (Substance, $SubstancesReferences),
          Substance,
          PrefetchHooks Function({
            bool substanceI18nRefs,
            bool concentrationRecordsRefs,
          })
        > {
  $SubstancesTableManager(_$ContentDatabase db, Substances table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SubstancesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SubstancesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SubstancesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> substanceId = const Value.absent(),
                Value<String> canonicalName = const Value.absent(),
                Value<String> entityKind = const Value.absent(),
                Value<String?> molecularFormula = const Value.absent(),
                Value<String> tierAccess = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<String?> lastReviewedAt = const Value.absent(),
                Value<String> contentVersion = const Value.absent(),
                Value<int> isTestData = const Value.absent(),
                Value<String?> substanceGroup = const Value.absent(),
              }) => SubstancesCompanion(
                substanceId: substanceId,
                canonicalName: canonicalName,
                entityKind: entityKind,
                molecularFormula: molecularFormula,
                tierAccess: tierAccess,
                reviewStatus: reviewStatus,
                lastReviewedAt: lastReviewedAt,
                contentVersion: contentVersion,
                isTestData: isTestData,
                substanceGroup: substanceGroup,
              ),
          createCompanionCallback:
              ({
                required String substanceId,
                required String canonicalName,
                required String entityKind,
                Value<String?> molecularFormula = const Value.absent(),
                required String tierAccess,
                required String reviewStatus,
                Value<String?> lastReviewedAt = const Value.absent(),
                required String contentVersion,
                Value<int> isTestData = const Value.absent(),
                Value<String?> substanceGroup = const Value.absent(),
              }) => SubstancesCompanion.insert(
                substanceId: substanceId,
                canonicalName: canonicalName,
                entityKind: entityKind,
                molecularFormula: molecularFormula,
                tierAccess: tierAccess,
                reviewStatus: reviewStatus,
                lastReviewedAt: lastReviewedAt,
                contentVersion: contentVersion,
                isTestData: isTestData,
                substanceGroup: substanceGroup,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Substances, Substance>(table),
                  $SubstancesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({substanceI18nRefs = false, concentrationRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (substanceI18nRefs) db.substanceI18n,
                    if (concentrationRecordsRefs) db.concentrationRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (substanceI18nRefs)
                        await $_getPrefetchedData<
                          Substance,
                          Substances,
                          SubstanceI18nData
                        >(
                          currentTable: table,
                          referencedTable: $SubstancesReferences
                              ._substanceI18nRefsTable(db),
                          managerFromTypedResult: (p0) => $SubstancesReferences(
                            db,
                            table,
                            p0,
                          ).substanceI18nRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.substanceId == item.substanceId,
                              ),
                          typedResults: items,
                        ),
                      if (concentrationRecordsRefs)
                        await $_getPrefetchedData<
                          Substance,
                          Substances,
                          ConcentrationRecord
                        >(
                          currentTable: table,
                          referencedTable: $SubstancesReferences
                              ._concentrationRecordsRefsTable(db),
                          managerFromTypedResult: (p0) => $SubstancesReferences(
                            db,
                            table,
                            p0,
                          ).concentrationRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.substanceId == item.substanceId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $SubstancesProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      Substances,
      Substance,
      $SubstancesFilterComposer,
      $SubstancesOrderingComposer,
      $SubstancesAnnotationComposer,
      $SubstancesCreateCompanionBuilder,
      $SubstancesUpdateCompanionBuilder,
      (Substance, $SubstancesReferences),
      Substance,
      PrefetchHooks Function({
        bool substanceI18nRefs,
        bool concentrationRecordsRefs,
      })
    >;
typedef $SubstanceI18nCreateCompanionBuilder = SubstanceI18nCompanion Function({
  required String substanceId,
  required String lang,
  required String name,
  Value<String?> descriptionMd,
  required String translationStatus,
});
typedef $SubstanceI18nUpdateCompanionBuilder = SubstanceI18nCompanion Function({
  Value<String> substanceId,
  Value<String> lang,
  Value<String> name,
  Value<String?> descriptionMd,
  Value<String> translationStatus,
});

final class $SubstanceI18nReferences
    extends
        BaseReferences<_$ContentDatabase, SubstanceI18n, SubstanceI18nData> {
  $SubstanceI18nReferences(super.$_db, super.$_table, super.$_typedResult);

  static Substances _substanceIdTable(_$ContentDatabase db) => db.substances
      .createAlias('substance_i18n__substance_id__substances__substance_id');

  $SubstancesProcessedTableManager get substanceId {
    final $_column = $_itemColumn<String>('substance_id')!;

    final manager = $SubstancesTableManager(
      $_db,
      $_db.substances,
    ).filter((f) => f.substanceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_substanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $SubstanceI18nFilterComposer
    extends Composer<_$ContentDatabase, SubstanceI18n> {
  $SubstanceI18nFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionMd => $composableBuilder(
    column: $table.descriptionMd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationStatus => $composableBuilder(
    column: $table.translationStatus,
    builder: (column) => ColumnFilters(column),
  );

  $SubstancesFilterComposer get substanceId {
    final $SubstancesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.substanceId,
      referencedTable: $db.substances,
      getReferencedColumn: (t) => t.substanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SubstancesFilterComposer(
            $db: $db,
            $table: $db.substances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SubstanceI18nOrderingComposer
    extends Composer<_$ContentDatabase, SubstanceI18n> {
  $SubstanceI18nOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionMd => $composableBuilder(
    column: $table.descriptionMd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationStatus => $composableBuilder(
    column: $table.translationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $SubstancesOrderingComposer get substanceId {
    final $SubstancesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.substanceId,
      referencedTable: $db.substances,
      getReferencedColumn: (t) => t.substanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SubstancesOrderingComposer(
            $db: $db,
            $table: $db.substances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SubstanceI18nAnnotationComposer
    extends Composer<_$ContentDatabase, SubstanceI18n> {
  $SubstanceI18nAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get descriptionMd => $composableBuilder(
    column: $table.descriptionMd,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translationStatus => $composableBuilder(
    column: $table.translationStatus,
    builder: (column) => column,
  );

  $SubstancesAnnotationComposer get substanceId {
    final $SubstancesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.substanceId,
      referencedTable: $db.substances,
      getReferencedColumn: (t) => t.substanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SubstancesAnnotationComposer(
            $db: $db,
            $table: $db.substances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SubstanceI18nTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          SubstanceI18n,
          SubstanceI18nData,
          $SubstanceI18nFilterComposer,
          $SubstanceI18nOrderingComposer,
          $SubstanceI18nAnnotationComposer,
          $SubstanceI18nCreateCompanionBuilder,
          $SubstanceI18nUpdateCompanionBuilder,
          (SubstanceI18nData, $SubstanceI18nReferences),
          SubstanceI18nData,
          PrefetchHooks Function({bool substanceId})
        > {
  $SubstanceI18nTableManager(_$ContentDatabase db, SubstanceI18n table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SubstanceI18nFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SubstanceI18nOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SubstanceI18nAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> substanceId = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> descriptionMd = const Value.absent(),
                Value<String> translationStatus = const Value.absent(),
              }) => SubstanceI18nCompanion(
                substanceId: substanceId,
                lang: lang,
                name: name,
                descriptionMd: descriptionMd,
                translationStatus: translationStatus,
              ),
          createCompanionCallback:
              ({
                required String substanceId,
                required String lang,
                required String name,
                Value<String?> descriptionMd = const Value.absent(),
                required String translationStatus,
              }) => SubstanceI18nCompanion.insert(
                substanceId: substanceId,
                lang: lang,
                name: name,
                descriptionMd: descriptionMd,
                translationStatus: translationStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SubstanceI18n, SubstanceI18nData>(table),
                  $SubstanceI18nReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({substanceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (substanceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.substanceId,
                        referencedTable: $SubstanceI18nReferences
                            ._substanceIdTable(db),
                        referencedColumn: $SubstanceI18nReferences
                            ._substanceIdTable(db)
                            .substanceId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $SubstanceI18nProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      SubstanceI18n,
      SubstanceI18nData,
      $SubstanceI18nFilterComposer,
      $SubstanceI18nOrderingComposer,
      $SubstanceI18nAnnotationComposer,
      $SubstanceI18nCreateCompanionBuilder,
      $SubstanceI18nUpdateCompanionBuilder,
      (SubstanceI18nData, $SubstanceI18nReferences),
      SubstanceI18nData,
      PrefetchHooks Function({bool substanceId})
    >;
typedef $ExternalIdentifiersCreateCompanionBuilder =
    ExternalIdentifiersCompanion Function({
      required String entityType,
      required String entityId,
      required String scheme,
      required String identifierValue,
      required String sourceId,
    });
typedef $ExternalIdentifiersUpdateCompanionBuilder =
    ExternalIdentifiersCompanion Function({
      Value<String> entityType,
      Value<String> entityId,
      Value<String> scheme,
      Value<String> identifierValue,
      Value<String> sourceId,
    });

final class $ExternalIdentifiersReferences
    extends
        BaseReferences<
          _$ContentDatabase,
          ExternalIdentifiers,
          ExternalIdentifier
        > {
  $ExternalIdentifiersReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static Sources _sourceIdTable(_$ContentDatabase db) => db.sources.createAlias(
    'external_identifiers__source_id__sources__source_id',
  );

  $SourcesProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $SourcesTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.sourceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ExternalIdentifiersFilterComposer
    extends Composer<_$ContentDatabase, ExternalIdentifiers> {
  $ExternalIdentifiersFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheme => $composableBuilder(
    column: $table.scheme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identifierValue => $composableBuilder(
    column: $table.identifierValue,
    builder: (column) => ColumnFilters(column),
  );

  $SourcesFilterComposer get sourceId {
    final $SourcesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SourcesFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ExternalIdentifiersOrderingComposer
    extends Composer<_$ContentDatabase, ExternalIdentifiers> {
  $ExternalIdentifiersOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheme => $composableBuilder(
    column: $table.scheme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identifierValue => $composableBuilder(
    column: $table.identifierValue,
    builder: (column) => ColumnOrderings(column),
  );

  $SourcesOrderingComposer get sourceId {
    final $SourcesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SourcesOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ExternalIdentifiersAnnotationComposer
    extends Composer<_$ContentDatabase, ExternalIdentifiers> {
  $ExternalIdentifiersAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get scheme =>
      $composableBuilder(column: $table.scheme, builder: (column) => column);

  GeneratedColumn<String> get identifierValue => $composableBuilder(
    column: $table.identifierValue,
    builder: (column) => column,
  );

  $SourcesAnnotationComposer get sourceId {
    final $SourcesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SourcesAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ExternalIdentifiersTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          ExternalIdentifiers,
          ExternalIdentifier,
          $ExternalIdentifiersFilterComposer,
          $ExternalIdentifiersOrderingComposer,
          $ExternalIdentifiersAnnotationComposer,
          $ExternalIdentifiersCreateCompanionBuilder,
          $ExternalIdentifiersUpdateCompanionBuilder,
          (ExternalIdentifier, $ExternalIdentifiersReferences),
          ExternalIdentifier,
          PrefetchHooks Function({bool sourceId})
        > {
  $ExternalIdentifiersTableManager(
    _$ContentDatabase db,
    ExternalIdentifiers table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ExternalIdentifiersFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ExternalIdentifiersOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ExternalIdentifiersAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> scheme = const Value.absent(),
                Value<String> identifierValue = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
              }) => ExternalIdentifiersCompanion(
                entityType: entityType,
                entityId: entityId,
                scheme: scheme,
                identifierValue: identifierValue,
                sourceId: sourceId,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required String entityId,
                required String scheme,
                required String identifierValue,
                required String sourceId,
              }) => ExternalIdentifiersCompanion.insert(
                entityType: entityType,
                entityId: entityId,
                scheme: scheme,
                identifierValue: identifierValue,
                sourceId: sourceId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ExternalIdentifiers, ExternalIdentifier>(table),
                  $ExternalIdentifiersReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $ExternalIdentifiersReferences
                            ._sourceIdTable(db),
                        referencedColumn: $ExternalIdentifiersReferences
                            ._sourceIdTable(db)
                            .sourceId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $ExternalIdentifiersProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      ExternalIdentifiers,
      ExternalIdentifier,
      $ExternalIdentifiersFilterComposer,
      $ExternalIdentifiersOrderingComposer,
      $ExternalIdentifiersAnnotationComposer,
      $ExternalIdentifiersCreateCompanionBuilder,
      $ExternalIdentifiersUpdateCompanionBuilder,
      (ExternalIdentifier, $ExternalIdentifiersReferences),
      ExternalIdentifier,
      PrefetchHooks Function({bool sourceId})
    >;
typedef $ConcentrationRecordsCreateCompanionBuilder =
    ConcentrationRecordsCompanion Function({
      required String recordId,
      required String substanceId,
      required String category,
      required String specimenCode,
      required String population,
      required String valueType,
      Value<double?> valueLow,
      Value<double?> valueHigh,
      Value<double?> valueCentral,
      required String unit,
      Value<int?> nCases,
      required String claimId,
      Value<int> isTestData,
    });
typedef $ConcentrationRecordsUpdateCompanionBuilder =
    ConcentrationRecordsCompanion Function({
      Value<String> recordId,
      Value<String> substanceId,
      Value<String> category,
      Value<String> specimenCode,
      Value<String> population,
      Value<String> valueType,
      Value<double?> valueLow,
      Value<double?> valueHigh,
      Value<double?> valueCentral,
      Value<String> unit,
      Value<int?> nCases,
      Value<String> claimId,
      Value<int> isTestData,
    });

final class $ConcentrationRecordsReferences
    extends
        BaseReferences<
          _$ContentDatabase,
          ConcentrationRecords,
          ConcentrationRecord
        > {
  $ConcentrationRecordsReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static Substances _substanceIdTable(_$ContentDatabase db) =>
      db.substances.createAlias(
        'concentration_records__substance_id__substances__substance_id',
      );

  $SubstancesProcessedTableManager get substanceId {
    final $_column = $_itemColumn<String>('substance_id')!;

    final manager = $SubstancesTableManager(
      $_db,
      $_db.substances,
    ).filter((f) => f.substanceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_substanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Claims _claimIdTable(_$ContentDatabase db) => db.claims.createAlias(
    'concentration_records__claim_id__claims__claim_id',
  );

  $ClaimsProcessedTableManager get claimId {
    final $_column = $_itemColumn<String>('claim_id')!;

    final manager = $ClaimsTableManager(
      $_db,
      $_db.claims,
    ).filter((f) => f.claimId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_claimIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ConcentrationRecordsFilterComposer
    extends Composer<_$ContentDatabase, ConcentrationRecords> {
  $ConcentrationRecordsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specimenCode => $composableBuilder(
    column: $table.specimenCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valueLow => $composableBuilder(
    column: $table.valueLow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valueHigh => $composableBuilder(
    column: $table.valueHigh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valueCentral => $composableBuilder(
    column: $table.valueCentral,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nCases => $composableBuilder(
    column: $table.nCases,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnFilters(column),
  );

  $SubstancesFilterComposer get substanceId {
    final $SubstancesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.substanceId,
      referencedTable: $db.substances,
      getReferencedColumn: (t) => t.substanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SubstancesFilterComposer(
            $db: $db,
            $table: $db.substances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ClaimsFilterComposer get claimId {
    final $ClaimsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimsFilterComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ConcentrationRecordsOrderingComposer
    extends Composer<_$ContentDatabase, ConcentrationRecords> {
  $ConcentrationRecordsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specimenCode => $composableBuilder(
    column: $table.specimenCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueLow => $composableBuilder(
    column: $table.valueLow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueHigh => $composableBuilder(
    column: $table.valueHigh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueCentral => $composableBuilder(
    column: $table.valueCentral,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nCases => $composableBuilder(
    column: $table.nCases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnOrderings(column),
  );

  $SubstancesOrderingComposer get substanceId {
    final $SubstancesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.substanceId,
      referencedTable: $db.substances,
      getReferencedColumn: (t) => t.substanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SubstancesOrderingComposer(
            $db: $db,
            $table: $db.substances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ClaimsOrderingComposer get claimId {
    final $ClaimsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimsOrderingComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ConcentrationRecordsAnnotationComposer
    extends Composer<_$ContentDatabase, ConcentrationRecords> {
  $ConcentrationRecordsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get specimenCode => $composableBuilder(
    column: $table.specimenCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valueType =>
      $composableBuilder(column: $table.valueType, builder: (column) => column);

  GeneratedColumn<double> get valueLow =>
      $composableBuilder(column: $table.valueLow, builder: (column) => column);

  GeneratedColumn<double> get valueHigh =>
      $composableBuilder(column: $table.valueHigh, builder: (column) => column);

  GeneratedColumn<double> get valueCentral => $composableBuilder(
    column: $table.valueCentral,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get nCases =>
      $composableBuilder(column: $table.nCases, builder: (column) => column);

  GeneratedColumn<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => column,
  );

  $SubstancesAnnotationComposer get substanceId {
    final $SubstancesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.substanceId,
      referencedTable: $db.substances,
      getReferencedColumn: (t) => t.substanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SubstancesAnnotationComposer(
            $db: $db,
            $table: $db.substances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ClaimsAnnotationComposer get claimId {
    final $ClaimsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClaimsAnnotationComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ConcentrationRecordsTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          ConcentrationRecords,
          ConcentrationRecord,
          $ConcentrationRecordsFilterComposer,
          $ConcentrationRecordsOrderingComposer,
          $ConcentrationRecordsAnnotationComposer,
          $ConcentrationRecordsCreateCompanionBuilder,
          $ConcentrationRecordsUpdateCompanionBuilder,
          (ConcentrationRecord, $ConcentrationRecordsReferences),
          ConcentrationRecord,
          PrefetchHooks Function({bool substanceId, bool claimId})
        > {
  $ConcentrationRecordsTableManager(
    _$ContentDatabase db,
    ConcentrationRecords table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ConcentrationRecordsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ConcentrationRecordsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ConcentrationRecordsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> recordId = const Value.absent(),
                Value<String> substanceId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> specimenCode = const Value.absent(),
                Value<String> population = const Value.absent(),
                Value<String> valueType = const Value.absent(),
                Value<double?> valueLow = const Value.absent(),
                Value<double?> valueHigh = const Value.absent(),
                Value<double?> valueCentral = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int?> nCases = const Value.absent(),
                Value<String> claimId = const Value.absent(),
                Value<int> isTestData = const Value.absent(),
              }) => ConcentrationRecordsCompanion(
                recordId: recordId,
                substanceId: substanceId,
                category: category,
                specimenCode: specimenCode,
                population: population,
                valueType: valueType,
                valueLow: valueLow,
                valueHigh: valueHigh,
                valueCentral: valueCentral,
                unit: unit,
                nCases: nCases,
                claimId: claimId,
                isTestData: isTestData,
              ),
          createCompanionCallback:
              ({
                required String recordId,
                required String substanceId,
                required String category,
                required String specimenCode,
                required String population,
                required String valueType,
                Value<double?> valueLow = const Value.absent(),
                Value<double?> valueHigh = const Value.absent(),
                Value<double?> valueCentral = const Value.absent(),
                required String unit,
                Value<int?> nCases = const Value.absent(),
                required String claimId,
                Value<int> isTestData = const Value.absent(),
              }) => ConcentrationRecordsCompanion.insert(
                recordId: recordId,
                substanceId: substanceId,
                category: category,
                specimenCode: specimenCode,
                population: population,
                valueType: valueType,
                valueLow: valueLow,
                valueHigh: valueHigh,
                valueCentral: valueCentral,
                unit: unit,
                nCases: nCases,
                claimId: claimId,
                isTestData: isTestData,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ConcentrationRecords, ConcentrationRecord>(table),
                  $ConcentrationRecordsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({substanceId = false, claimId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (substanceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.substanceId,
                        referencedTable: $ConcentrationRecordsReferences
                            ._substanceIdTable(db),
                        referencedColumn: $ConcentrationRecordsReferences
                            ._substanceIdTable(db)
                            .substanceId,
                      ) as T;
                    }
                    if (claimId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.claimId,
                        referencedTable: $ConcentrationRecordsReferences
                            ._claimIdTable(db),
                        referencedColumn: $ConcentrationRecordsReferences
                            ._claimIdTable(db)
                            .claimId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $ConcentrationRecordsProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      ConcentrationRecords,
      ConcentrationRecord,
      $ConcentrationRecordsFilterComposer,
      $ConcentrationRecordsOrderingComposer,
      $ConcentrationRecordsAnnotationComposer,
      $ConcentrationRecordsCreateCompanionBuilder,
      $ConcentrationRecordsUpdateCompanionBuilder,
      (ConcentrationRecord, $ConcentrationRecordsReferences),
      ConcentrationRecord,
      PrefetchHooks Function({bool substanceId, bool claimId})
    >;
typedef $SearchTermsCreateCompanionBuilder = SearchTermsCompanion Function({
  Value<int> termId,
  required String entityType,
  required String entityId,
  required String category,
  Value<String?> lang,
  required String term,
  required String searchKey,
  required String termKind,
  Value<double> weight,
});
typedef $SearchTermsUpdateCompanionBuilder = SearchTermsCompanion Function({
  Value<int> termId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> category,
  Value<String?> lang,
  Value<String> term,
  Value<String> searchKey,
  Value<String> termKind,
  Value<double> weight,
});

class $SearchTermsFilterComposer
    extends Composer<_$ContentDatabase, SearchTerms> {
  $SearchTermsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get termId => $composableBuilder(
    column: $table.termId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get termKind => $composableBuilder(
    column: $table.termKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );
}

class $SearchTermsOrderingComposer
    extends Composer<_$ContentDatabase, SearchTerms> {
  $SearchTermsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get termId => $composableBuilder(
    column: $table.termId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get termKind => $composableBuilder(
    column: $table.termKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SearchTermsAnnotationComposer
    extends Composer<_$ContentDatabase, SearchTerms> {
  $SearchTermsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get termId =>
      $composableBuilder(column: $table.termId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<String> get searchKey =>
      $composableBuilder(column: $table.searchKey, builder: (column) => column);

  GeneratedColumn<String> get termKind =>
      $composableBuilder(column: $table.termKind, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);
}

class $SearchTermsTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          SearchTerms,
          SearchTermRow,
          $SearchTermsFilterComposer,
          $SearchTermsOrderingComposer,
          $SearchTermsAnnotationComposer,
          $SearchTermsCreateCompanionBuilder,
          $SearchTermsUpdateCompanionBuilder,
          (
            SearchTermRow,
            BaseReferences<_$ContentDatabase, SearchTerms, SearchTermRow>,
          ),
          SearchTermRow,
          PrefetchHooks Function()
        > {
  $SearchTermsTableManager(_$ContentDatabase db, SearchTerms table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SearchTermsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SearchTermsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SearchTermsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> termId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<String> searchKey = const Value.absent(),
                Value<String> termKind = const Value.absent(),
                Value<double> weight = const Value.absent(),
              }) => SearchTermsCompanion(
                termId: termId,
                entityType: entityType,
                entityId: entityId,
                category: category,
                lang: lang,
                term: term,
                searchKey: searchKey,
                termKind: termKind,
                weight: weight,
              ),
          createCompanionCallback:
              ({
                Value<int> termId = const Value.absent(),
                required String entityType,
                required String entityId,
                required String category,
                Value<String?> lang = const Value.absent(),
                required String term,
                required String searchKey,
                required String termKind,
                Value<double> weight = const Value.absent(),
              }) => SearchTermsCompanion.insert(
                termId: termId,
                entityType: entityType,
                entityId: entityId,
                category: category,
                lang: lang,
                term: term,
                searchKey: searchKey,
                termKind: termKind,
                weight: weight,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SearchTerms, SearchTermRow>(table),
                  BaseReferences<_$ContentDatabase, SearchTerms, SearchTermRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SearchTermsProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      SearchTerms,
      SearchTermRow,
      $SearchTermsFilterComposer,
      $SearchTermsOrderingComposer,
      $SearchTermsAnnotationComposer,
      $SearchTermsCreateCompanionBuilder,
      $SearchTermsUpdateCompanionBuilder,
      (
        SearchTermRow,
        BaseReferences<_$ContentDatabase, SearchTerms, SearchTermRow>,
      ),
      SearchTermRow,
      PrefetchHooks Function()
    >;
typedef $SearchFtsTriCreateCompanionBuilder = SearchFtsTriCompanion Function({
  required String searchKey,
  Value<int> rowid,
});
typedef $SearchFtsTriUpdateCompanionBuilder = SearchFtsTriCompanion Function({
  Value<String> searchKey,
  Value<int> rowid,
});

class $SearchFtsTriFilterComposer
    extends Composer<_$ContentDatabase, SearchFtsTri> {
  $SearchFtsTriFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $SearchFtsTriOrderingComposer
    extends Composer<_$ContentDatabase, SearchFtsTri> {
  $SearchFtsTriOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SearchFtsTriAnnotationComposer
    extends Composer<_$ContentDatabase, SearchFtsTri> {
  $SearchFtsTriAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get searchKey =>
      $composableBuilder(column: $table.searchKey, builder: (column) => column);
}

class $SearchFtsTriTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          SearchFtsTri,
          SearchFtsTriData,
          $SearchFtsTriFilterComposer,
          $SearchFtsTriOrderingComposer,
          $SearchFtsTriAnnotationComposer,
          $SearchFtsTriCreateCompanionBuilder,
          $SearchFtsTriUpdateCompanionBuilder,
          (
            SearchFtsTriData,
            BaseReferences<_$ContentDatabase, SearchFtsTri, SearchFtsTriData>,
          ),
          SearchFtsTriData,
          PrefetchHooks Function()
        > {
  $SearchFtsTriTableManager(_$ContentDatabase db, SearchFtsTri table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SearchFtsTriFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SearchFtsTriOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SearchFtsTriAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> searchKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SearchFtsTriCompanion(searchKey: searchKey, rowid: rowid),
          createCompanionCallback:
              ({
                required String searchKey,
                Value<int> rowid = const Value.absent(),
              }) => SearchFtsTriCompanion.insert(
                searchKey: searchKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SearchFtsTri, SearchFtsTriData>(table),
                  BaseReferences<
                    _$ContentDatabase,
                    SearchFtsTri,
                    SearchFtsTriData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SearchFtsTriProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      SearchFtsTri,
      SearchFtsTriData,
      $SearchFtsTriFilterComposer,
      $SearchFtsTriOrderingComposer,
      $SearchFtsTriAnnotationComposer,
      $SearchFtsTriCreateCompanionBuilder,
      $SearchFtsTriUpdateCompanionBuilder,
      (
        SearchFtsTriData,
        BaseReferences<_$ContentDatabase, SearchFtsTri, SearchFtsTriData>,
      ),
      SearchFtsTriData,
      PrefetchHooks Function()
    >;
typedef $ResearchRecordsCreateCompanionBuilder =
    ResearchRecordsCompanion Function({
      required String researchId,
      required String kind,
      required String title,
      Value<String> authorsJson,
      Value<String?> organization,
      Value<String?> container,
      Value<String?> pubYear,
      Value<String?> doi,
      Value<String?> pmid,
      Value<String?> pmcid,
      Value<String?> handle,
      Value<String?> url,
      Value<String?> degree,
      Value<String?> openAccess,
      Value<String?> sourceApi,
      Value<String?> accessedDate,
      required String evidenceLevel,
      required int peerReviewed,
      required String reviewStatus,
      Value<int> isTestData,
      Value<String> forensicRelevance,
      Value<String?> language,
    });
typedef $ResearchRecordsUpdateCompanionBuilder =
    ResearchRecordsCompanion Function({
      Value<String> researchId,
      Value<String> kind,
      Value<String> title,
      Value<String> authorsJson,
      Value<String?> organization,
      Value<String?> container,
      Value<String?> pubYear,
      Value<String?> doi,
      Value<String?> pmid,
      Value<String?> pmcid,
      Value<String?> handle,
      Value<String?> url,
      Value<String?> degree,
      Value<String?> openAccess,
      Value<String?> sourceApi,
      Value<String?> accessedDate,
      Value<String> evidenceLevel,
      Value<int> peerReviewed,
      Value<String> reviewStatus,
      Value<int> isTestData,
      Value<String> forensicRelevance,
      Value<String?> language,
    });

class $ResearchRecordsFilterComposer
    extends Composer<_$ContentDatabase, ResearchRecords> {
  $ResearchRecordsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get researchId => $composableBuilder(
    column: $table.researchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorsJson => $composableBuilder(
    column: $table.authorsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get container => $composableBuilder(
    column: $table.container,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pubYear => $composableBuilder(
    column: $table.pubYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doi => $composableBuilder(
    column: $table.doi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pmid => $composableBuilder(
    column: $table.pmid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pmcid => $composableBuilder(
    column: $table.pmcid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handle => $composableBuilder(
    column: $table.handle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get degree => $composableBuilder(
    column: $table.degree,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openAccess => $composableBuilder(
    column: $table.openAccess,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceApi => $composableBuilder(
    column: $table.sourceApi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessedDate => $composableBuilder(
    column: $table.accessedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceLevel => $composableBuilder(
    column: $table.evidenceLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get peerReviewed => $composableBuilder(
    column: $table.peerReviewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get forensicRelevance => $composableBuilder(
    column: $table.forensicRelevance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );
}

class $ResearchRecordsOrderingComposer
    extends Composer<_$ContentDatabase, ResearchRecords> {
  $ResearchRecordsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get researchId => $composableBuilder(
    column: $table.researchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorsJson => $composableBuilder(
    column: $table.authorsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get container => $composableBuilder(
    column: $table.container,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pubYear => $composableBuilder(
    column: $table.pubYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doi => $composableBuilder(
    column: $table.doi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pmid => $composableBuilder(
    column: $table.pmid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pmcid => $composableBuilder(
    column: $table.pmcid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handle => $composableBuilder(
    column: $table.handle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get degree => $composableBuilder(
    column: $table.degree,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openAccess => $composableBuilder(
    column: $table.openAccess,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceApi => $composableBuilder(
    column: $table.sourceApi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessedDate => $composableBuilder(
    column: $table.accessedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceLevel => $composableBuilder(
    column: $table.evidenceLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get peerReviewed => $composableBuilder(
    column: $table.peerReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forensicRelevance => $composableBuilder(
    column: $table.forensicRelevance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ResearchRecordsAnnotationComposer
    extends Composer<_$ContentDatabase, ResearchRecords> {
  $ResearchRecordsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get researchId => $composableBuilder(
    column: $table.researchId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get authorsJson => $composableBuilder(
    column: $table.authorsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => column,
  );

  GeneratedColumn<String> get container =>
      $composableBuilder(column: $table.container, builder: (column) => column);

  GeneratedColumn<String> get pubYear =>
      $composableBuilder(column: $table.pubYear, builder: (column) => column);

  GeneratedColumn<String> get doi =>
      $composableBuilder(column: $table.doi, builder: (column) => column);

  GeneratedColumn<String> get pmid =>
      $composableBuilder(column: $table.pmid, builder: (column) => column);

  GeneratedColumn<String> get pmcid =>
      $composableBuilder(column: $table.pmcid, builder: (column) => column);

  GeneratedColumn<String> get handle =>
      $composableBuilder(column: $table.handle, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get degree =>
      $composableBuilder(column: $table.degree, builder: (column) => column);

  GeneratedColumn<String> get openAccess => $composableBuilder(
    column: $table.openAccess,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceApi =>
      $composableBuilder(column: $table.sourceApi, builder: (column) => column);

  GeneratedColumn<String> get accessedDate => $composableBuilder(
    column: $table.accessedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidenceLevel => $composableBuilder(
    column: $table.evidenceLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get peerReviewed => $composableBuilder(
    column: $table.peerReviewed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isTestData => $composableBuilder(
    column: $table.isTestData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get forensicRelevance => $composableBuilder(
    column: $table.forensicRelevance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);
}

class $ResearchRecordsTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          ResearchRecords,
          ResearchRecord,
          $ResearchRecordsFilterComposer,
          $ResearchRecordsOrderingComposer,
          $ResearchRecordsAnnotationComposer,
          $ResearchRecordsCreateCompanionBuilder,
          $ResearchRecordsUpdateCompanionBuilder,
          (
            ResearchRecord,
            BaseReferences<_$ContentDatabase, ResearchRecords, ResearchRecord>,
          ),
          ResearchRecord,
          PrefetchHooks Function()
        > {
  $ResearchRecordsTableManager(_$ContentDatabase db, ResearchRecords table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ResearchRecordsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ResearchRecordsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ResearchRecordsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> researchId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> authorsJson = const Value.absent(),
                Value<String?> organization = const Value.absent(),
                Value<String?> container = const Value.absent(),
                Value<String?> pubYear = const Value.absent(),
                Value<String?> doi = const Value.absent(),
                Value<String?> pmid = const Value.absent(),
                Value<String?> pmcid = const Value.absent(),
                Value<String?> handle = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> degree = const Value.absent(),
                Value<String?> openAccess = const Value.absent(),
                Value<String?> sourceApi = const Value.absent(),
                Value<String?> accessedDate = const Value.absent(),
                Value<String> evidenceLevel = const Value.absent(),
                Value<int> peerReviewed = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<int> isTestData = const Value.absent(),
                Value<String> forensicRelevance = const Value.absent(),
                Value<String?> language = const Value.absent(),
              }) => ResearchRecordsCompanion(
                researchId: researchId,
                kind: kind,
                title: title,
                authorsJson: authorsJson,
                organization: organization,
                container: container,
                pubYear: pubYear,
                doi: doi,
                pmid: pmid,
                pmcid: pmcid,
                handle: handle,
                url: url,
                degree: degree,
                openAccess: openAccess,
                sourceApi: sourceApi,
                accessedDate: accessedDate,
                evidenceLevel: evidenceLevel,
                peerReviewed: peerReviewed,
                reviewStatus: reviewStatus,
                isTestData: isTestData,
                forensicRelevance: forensicRelevance,
                language: language,
              ),
          createCompanionCallback:
              ({
                required String researchId,
                required String kind,
                required String title,
                Value<String> authorsJson = const Value.absent(),
                Value<String?> organization = const Value.absent(),
                Value<String?> container = const Value.absent(),
                Value<String?> pubYear = const Value.absent(),
                Value<String?> doi = const Value.absent(),
                Value<String?> pmid = const Value.absent(),
                Value<String?> pmcid = const Value.absent(),
                Value<String?> handle = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> degree = const Value.absent(),
                Value<String?> openAccess = const Value.absent(),
                Value<String?> sourceApi = const Value.absent(),
                Value<String?> accessedDate = const Value.absent(),
                required String evidenceLevel,
                required int peerReviewed,
                required String reviewStatus,
                Value<int> isTestData = const Value.absent(),
                Value<String> forensicRelevance = const Value.absent(),
                Value<String?> language = const Value.absent(),
              }) => ResearchRecordsCompanion.insert(
                researchId: researchId,
                kind: kind,
                title: title,
                authorsJson: authorsJson,
                organization: organization,
                container: container,
                pubYear: pubYear,
                doi: doi,
                pmid: pmid,
                pmcid: pmcid,
                handle: handle,
                url: url,
                degree: degree,
                openAccess: openAccess,
                sourceApi: sourceApi,
                accessedDate: accessedDate,
                evidenceLevel: evidenceLevel,
                peerReviewed: peerReviewed,
                reviewStatus: reviewStatus,
                isTestData: isTestData,
                forensicRelevance: forensicRelevance,
                language: language,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ResearchRecords, ResearchRecord>(table),
                  BaseReferences<
                    _$ContentDatabase,
                    ResearchRecords,
                    ResearchRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ResearchRecordsProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      ResearchRecords,
      ResearchRecord,
      $ResearchRecordsFilterComposer,
      $ResearchRecordsOrderingComposer,
      $ResearchRecordsAnnotationComposer,
      $ResearchRecordsCreateCompanionBuilder,
      $ResearchRecordsUpdateCompanionBuilder,
      (
        ResearchRecord,
        BaseReferences<_$ContentDatabase, ResearchRecords, ResearchRecord>,
      ),
      ResearchRecord,
      PrefetchHooks Function()
    >;
typedef $EntityLinksCreateCompanionBuilder = EntityLinksCompanion Function({
  required String fromId,
  required String toId,
  required String relation,
  required String basis,
});
typedef $EntityLinksUpdateCompanionBuilder = EntityLinksCompanion Function({
  Value<String> fromId,
  Value<String> toId,
  Value<String> relation,
  Value<String> basis,
});

class $EntityLinksFilterComposer
    extends Composer<_$ContentDatabase, EntityLinks> {
  $EntityLinksFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fromId => $composableBuilder(
    column: $table.fromId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toId => $composableBuilder(
    column: $table.toId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get basis => $composableBuilder(
    column: $table.basis,
    builder: (column) => ColumnFilters(column),
  );
}

class $EntityLinksOrderingComposer
    extends Composer<_$ContentDatabase, EntityLinks> {
  $EntityLinksOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fromId => $composableBuilder(
    column: $table.fromId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toId => $composableBuilder(
    column: $table.toId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basis => $composableBuilder(
    column: $table.basis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $EntityLinksAnnotationComposer
    extends Composer<_$ContentDatabase, EntityLinks> {
  $EntityLinksAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fromId =>
      $composableBuilder(column: $table.fromId, builder: (column) => column);

  GeneratedColumn<String> get toId =>
      $composableBuilder(column: $table.toId, builder: (column) => column);

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);

  GeneratedColumn<String> get basis =>
      $composableBuilder(column: $table.basis, builder: (column) => column);
}

class $EntityLinksTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          EntityLinks,
          EntityLink,
          $EntityLinksFilterComposer,
          $EntityLinksOrderingComposer,
          $EntityLinksAnnotationComposer,
          $EntityLinksCreateCompanionBuilder,
          $EntityLinksUpdateCompanionBuilder,
          (
            EntityLink,
            BaseReferences<_$ContentDatabase, EntityLinks, EntityLink>,
          ),
          EntityLink,
          PrefetchHooks Function()
        > {
  $EntityLinksTableManager(_$ContentDatabase db, EntityLinks table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $EntityLinksFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $EntityLinksOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $EntityLinksAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> fromId = const Value.absent(),
                Value<String> toId = const Value.absent(),
                Value<String> relation = const Value.absent(),
                Value<String> basis = const Value.absent(),
              }) => EntityLinksCompanion(
                fromId: fromId,
                toId: toId,
                relation: relation,
                basis: basis,
              ),
          createCompanionCallback:
              ({
                required String fromId,
                required String toId,
                required String relation,
                required String basis,
              }) => EntityLinksCompanion.insert(
                fromId: fromId,
                toId: toId,
                relation: relation,
                basis: basis,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<EntityLinks, EntityLink>(table),
                  BaseReferences<_$ContentDatabase, EntityLinks, EntityLink>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $EntityLinksProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      EntityLinks,
      EntityLink,
      $EntityLinksFilterComposer,
      $EntityLinksOrderingComposer,
      $EntityLinksAnnotationComposer,
      $EntityLinksCreateCompanionBuilder,
      $EntityLinksUpdateCompanionBuilder,
      (EntityLink, BaseReferences<_$ContentDatabase, EntityLinks, EntityLink>),
      EntityLink,
      PrefetchHooks Function()
    >;
typedef $ImagesCreateCompanionBuilder = ImagesCompanion Function({
  required String imageId,
  required String kind,
  required String entityId,
  required String mimeType,
  required Uint8List bytes,
  Value<int?> width,
  Value<int?> height,
  required String sha256,
  required String titleJson,
  required String altJson,
  Value<String?> captionOriginal,
  Value<String?> creator,
  Value<String?> sourceName,
  Value<String?> sourceUrl,
  Value<String?> doi,
  required String license,
  required String attribution,
  required int isOriginalDiagram,
  required int representsRealData,
  Value<int> graphic,
  Value<String?> accessedDate,
  Value<int> rowid,
});
typedef $ImagesUpdateCompanionBuilder = ImagesCompanion Function({
  Value<String> imageId,
  Value<String> kind,
  Value<String> entityId,
  Value<String> mimeType,
  Value<Uint8List> bytes,
  Value<int?> width,
  Value<int?> height,
  Value<String> sha256,
  Value<String> titleJson,
  Value<String> altJson,
  Value<String?> captionOriginal,
  Value<String?> creator,
  Value<String?> sourceName,
  Value<String?> sourceUrl,
  Value<String?> doi,
  Value<String> license,
  Value<String> attribution,
  Value<int> isOriginalDiagram,
  Value<int> representsRealData,
  Value<int> graphic,
  Value<String?> accessedDate,
  Value<int> rowid,
});

class $ImagesFilterComposer extends Composer<_$ContentDatabase, Images> {
  $ImagesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get imageId => $composableBuilder(
    column: $table.imageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleJson => $composableBuilder(
    column: $table.titleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get altJson => $composableBuilder(
    column: $table.altJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get captionOriginal => $composableBuilder(
    column: $table.captionOriginal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creator => $composableBuilder(
    column: $table.creator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doi => $composableBuilder(
    column: $table.doi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isOriginalDiagram => $composableBuilder(
    column: $table.isOriginalDiagram,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get representsRealData => $composableBuilder(
    column: $table.representsRealData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get graphic => $composableBuilder(
    column: $table.graphic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessedDate => $composableBuilder(
    column: $table.accessedDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $ImagesOrderingComposer extends Composer<_$ContentDatabase, Images> {
  $ImagesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get imageId => $composableBuilder(
    column: $table.imageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleJson => $composableBuilder(
    column: $table.titleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get altJson => $composableBuilder(
    column: $table.altJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get captionOriginal => $composableBuilder(
    column: $table.captionOriginal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creator => $composableBuilder(
    column: $table.creator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doi => $composableBuilder(
    column: $table.doi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isOriginalDiagram => $composableBuilder(
    column: $table.isOriginalDiagram,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get representsRealData => $composableBuilder(
    column: $table.representsRealData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get graphic => $composableBuilder(
    column: $table.graphic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessedDate => $composableBuilder(
    column: $table.accessedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ImagesAnnotationComposer extends Composer<_$ContentDatabase, Images> {
  $ImagesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get imageId =>
      $composableBuilder(column: $table.imageId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get titleJson =>
      $composableBuilder(column: $table.titleJson, builder: (column) => column);

  GeneratedColumn<String> get altJson =>
      $composableBuilder(column: $table.altJson, builder: (column) => column);

  GeneratedColumn<String> get captionOriginal => $composableBuilder(
    column: $table.captionOriginal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get creator =>
      $composableBuilder(column: $table.creator, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get doi =>
      $composableBuilder(column: $table.doi, builder: (column) => column);

  GeneratedColumn<String> get license =>
      $composableBuilder(column: $table.license, builder: (column) => column);

  GeneratedColumn<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isOriginalDiagram => $composableBuilder(
    column: $table.isOriginalDiagram,
    builder: (column) => column,
  );

  GeneratedColumn<int> get representsRealData => $composableBuilder(
    column: $table.representsRealData,
    builder: (column) => column,
  );

  GeneratedColumn<int> get graphic =>
      $composableBuilder(column: $table.graphic, builder: (column) => column);

  GeneratedColumn<String> get accessedDate => $composableBuilder(
    column: $table.accessedDate,
    builder: (column) => column,
  );
}

class $ImagesTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          Images,
          Image,
          $ImagesFilterComposer,
          $ImagesOrderingComposer,
          $ImagesAnnotationComposer,
          $ImagesCreateCompanionBuilder,
          $ImagesUpdateCompanionBuilder,
          (Image, BaseReferences<_$ContentDatabase, Images, Image>),
          Image,
          PrefetchHooks Function()
        > {
  $ImagesTableManager(_$ContentDatabase db, Images table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ImagesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ImagesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ImagesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> imageId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String> titleJson = const Value.absent(),
                Value<String> altJson = const Value.absent(),
                Value<String?> captionOriginal = const Value.absent(),
                Value<String?> creator = const Value.absent(),
                Value<String?> sourceName = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> doi = const Value.absent(),
                Value<String> license = const Value.absent(),
                Value<String> attribution = const Value.absent(),
                Value<int> isOriginalDiagram = const Value.absent(),
                Value<int> representsRealData = const Value.absent(),
                Value<int> graphic = const Value.absent(),
                Value<String?> accessedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImagesCompanion(
                imageId: imageId,
                kind: kind,
                entityId: entityId,
                mimeType: mimeType,
                bytes: bytes,
                width: width,
                height: height,
                sha256: sha256,
                titleJson: titleJson,
                altJson: altJson,
                captionOriginal: captionOriginal,
                creator: creator,
                sourceName: sourceName,
                sourceUrl: sourceUrl,
                doi: doi,
                license: license,
                attribution: attribution,
                isOriginalDiagram: isOriginalDiagram,
                representsRealData: representsRealData,
                graphic: graphic,
                accessedDate: accessedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String imageId,
                required String kind,
                required String entityId,
                required String mimeType,
                required Uint8List bytes,
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required String sha256,
                required String titleJson,
                required String altJson,
                Value<String?> captionOriginal = const Value.absent(),
                Value<String?> creator = const Value.absent(),
                Value<String?> sourceName = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> doi = const Value.absent(),
                required String license,
                required String attribution,
                required int isOriginalDiagram,
                required int representsRealData,
                Value<int> graphic = const Value.absent(),
                Value<String?> accessedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImagesCompanion.insert(
                imageId: imageId,
                kind: kind,
                entityId: entityId,
                mimeType: mimeType,
                bytes: bytes,
                width: width,
                height: height,
                sha256: sha256,
                titleJson: titleJson,
                altJson: altJson,
                captionOriginal: captionOriginal,
                creator: creator,
                sourceName: sourceName,
                sourceUrl: sourceUrl,
                doi: doi,
                license: license,
                attribution: attribution,
                isOriginalDiagram: isOriginalDiagram,
                representsRealData: representsRealData,
                graphic: graphic,
                accessedDate: accessedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Images, Image>(table),
                  BaseReferences<_$ContentDatabase, Images, Image>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ImagesProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      Images,
      Image,
      $ImagesFilterComposer,
      $ImagesOrderingComposer,
      $ImagesAnnotationComposer,
      $ImagesCreateCompanionBuilder,
      $ImagesUpdateCompanionBuilder,
      (Image, BaseReferences<_$ContentDatabase, Images, Image>),
      Image,
      PrefetchHooks Function()
    >;

class $ContentDatabaseManager {
  final _$ContentDatabase _db;
  $ContentDatabaseManager(this._db);
  $ContentMetaTableManager get contentMeta =>
      $ContentMetaTableManager(_db, _db.contentMeta);
  $SourcesTableManager get sources => $SourcesTableManager(_db, _db.sources);
  $JurisdictionsTableManager get jurisdictions =>
      $JurisdictionsTableManager(_db, _db.jurisdictions);
  $AuthoritiesTableManager get authorities =>
      $AuthoritiesTableManager(_db, _db.authorities);
  $JurisdictionalInstrumentsTableManager get jurisdictionalInstruments =>
      $JurisdictionalInstrumentsTableManager(
        _db,
        _db.jurisdictionalInstruments,
      );
  $JurisdictionalRulesTableManager get jurisdictionalRules =>
      $JurisdictionalRulesTableManager(_db, _db.jurisdictionalRules);
  $KnowledgeEntitiesTableManager get knowledgeEntities =>
      $KnowledgeEntitiesTableManager(_db, _db.knowledgeEntities);
  $EntitySourcesTableManager get entitySources =>
      $EntitySourcesTableManager(_db, _db.entitySources);
  $ClaimGroupsTableManager get claimGroups =>
      $ClaimGroupsTableManager(_db, _db.claimGroups);
  $ClaimsTableManager get claims => $ClaimsTableManager(_db, _db.claims);
  $CitationsTableManager get citations =>
      $CitationsTableManager(_db, _db.citations);
  $ReviewersTableManager get reviewers =>
      $ReviewersTableManager(_db, _db.reviewers);
  $ReviewerDomainsTableManager get reviewerDomains =>
      $ReviewerDomainsTableManager(_db, _db.reviewerDomains);
  $ReviewsTableManager get reviews => $ReviewsTableManager(_db, _db.reviews);
  $SubstancesTableManager get substances =>
      $SubstancesTableManager(_db, _db.substances);
  $SubstanceI18nTableManager get substanceI18n =>
      $SubstanceI18nTableManager(_db, _db.substanceI18n);
  $ExternalIdentifiersTableManager get externalIdentifiers =>
      $ExternalIdentifiersTableManager(_db, _db.externalIdentifiers);
  $ConcentrationRecordsTableManager get concentrationRecords =>
      $ConcentrationRecordsTableManager(_db, _db.concentrationRecords);
  $SearchTermsTableManager get searchTerms =>
      $SearchTermsTableManager(_db, _db.searchTerms);
  $SearchFtsTriTableManager get searchFtsTri =>
      $SearchFtsTriTableManager(_db, _db.searchFtsTri);
  $ResearchRecordsTableManager get researchRecords =>
      $ResearchRecordsTableManager(_db, _db.researchRecords);
  $EntityLinksTableManager get entityLinks =>
      $EntityLinksTableManager(_db, _db.entityLinks);
  $ImagesTableManager get images => $ImagesTableManager(_db, _db.images);
}
