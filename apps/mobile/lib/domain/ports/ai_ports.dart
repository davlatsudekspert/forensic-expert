/// Forensic AI abstraksiyasi (`docs/00_ARXITEKTURA_REJASI.md`, 12-bo‘lim).
///
/// PHASE 1: real AI ulanmagan. Kontraktning asosiy talablari:
/// * Javobdagi har bir ilmiy da’vo [AiCitation] orqali ichki
///   `chunkId`/`sourceId` ga bog‘lanadi. Manbalar ro‘yxatini model emas,
///   server bazadan quradi — shuning uchun to‘qilgan manba ko‘rsatilmaydi.
/// * AI yakuniy ekspert xulosasini bermaydi (server validatori + eval).
/// * Savol yuborilishidan oldin qurilmada [PiiScanner] ishlaydi.
library;

import 'package:flutter/foundation.dart';

enum AiAvailability { notConfigured, offline, quotaExceeded, available }

@immutable
class AiQuestion {
  const AiQuestion({
    required this.text,
    required this.languageCode,
    this.jurisdictionId,
  });

  final String text;
  final String languageCode;

  /// Foydalanuvchi tanlagan yurisdiksiya (`INT` — tanlanmagan / xalqaro).
  /// Huquqiy savolda AI yurisdiksiyani **taxmin qilmaydi**.
  final String? jurisdictionId;
}

/// Javob qaysi bilim qatlamiga tayanadi (12.2 — ustuvorlik tartibi).
enum AiEvidenceTier { internalVerified, internalReviewed, externalUnverified }

@immutable
class AiCitation {
  const AiCitation({
    required this.chunkId,
    required this.sourceId,
    required this.tier,
  });

  final String chunkId;
  final String sourceId;
  final AiEvidenceTier tier;
}

@immutable
class AiAnswer {
  const AiAnswer({
    required this.text,
    required this.citations,
    required this.noReliableAnswer,
  });

  final String text;
  final List<AiCitation> citations;

  /// Ishonchli kontekst topilmadi — AI bilmasligini aytdi.
  final bool noReliableAnswer;

  /// Ilmiy javob manbasiz bo‘lishi mumkin emas.
  bool get isWellFormed => noReliableAnswer || citations.isNotEmpty;
}

abstract interface class AiAssistant {
  AiAvailability get availability;

  Future<AiAnswer> ask(AiQuestion question);
}

// ---------------------------------------------------------------------------
// PII
// ---------------------------------------------------------------------------

enum PiiKind { email, phone, passport, caseNumber, personalName, address }

@immutable
class PiiFinding {
  const PiiFinding(this.kind, this.start, this.end);

  final PiiKind kind;
  final int start;
  final int end;
}

/// Qurilmadagi PII detektori kontrakti.
abstract interface class PiiScanner {
  List<PiiFinding> scan(String text);
}
