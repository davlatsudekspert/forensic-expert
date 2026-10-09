import 'dart:typed_data';

import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/ports/account_ports.dart';
import 'package:forensic_expert/domain/support/support_models.dart';
import 'package:forensic_expert/features/support/support_image_picker.dart';

/// Server kirishini taqlid qiladi (admin roli faqat shu javobdan).
class FakeAccountService implements AccountService {
  FakeAccountService({this.access = ServerAccess.none});

  final ServerAccess access;

  @override
  bool get isConfigured => true;

  @override
  Future<ServerAccess?> myAccess() async => access;

  @override
  Future<void> registerDevice({
    required String platform,
    required String version,
    required String locale,
    String? region,
  }) async {}

  @override
  Future<AdminDashboard?> dashboard() async => access.isAdmin
      ? AdminDashboard.fromJson(const {
          'totals': {'users': 128, 'android': 90, 'ios': 31},
          'regions': [
            {'region': 'UZ', 'users': 101},
            {'region': 'KZ', 'users': 12},
          ],
        })
      : null;

  @override
  Future<AdminGrantResult> setAccess(String email, String? tier) async =>
      AdminGrantResult.failed;
}

/// Tanlangan «skrinshot» (haqiqiy fayl tanlagichsiz).
class FakeImagePicker implements SupportImagePicker {
  FakeImagePicker([this.result]);

  final PickedImage? result;

  @override
  Future<PickedImage?> pick() async =>
      result ??
      PickedImageOk(
        SupportAttachment(
          bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0, 0, 0, 0]),
          mimeType: 'image/jpeg',
        ),
      );
}

/// FIXTURE statistika (soxta; serverdagi haqiqiy ma’lumot emas).
final fixtureAdminStats = AdminStats.fromJson(const {
  'users': {'total': 128, 'new_today': 4, 'new_7d': 19, 'new_30d': 57},
  'modes': {
    'students': null,
    'experts': null,
    'professional_profiles': 23,
    'verified_professionals': 9,
  },
  'tiers': {'pro': 14, 'free': 114},
  'active': {'d7': 41, 'd30': 88},
  'support': {
    'awaiting': 3,
    'new': 2,
    'in_review': 1,
    'answered': 5,
    'closed': 7,
    'by_category': {
      'SUGGESTION': 6,
      'BUG': 4,
      'SCIENTIFIC_ERROR': 3,
      'FEATURE_REQUEST': 2,
      'TECH_SUPPORT': 1,
      'GENERAL': 1,
    },
  },
  'publications': {'awaiting_moderation': 2, 'open_reports': 0},
  'ai': {'total': 940, 'd7': 112},
  'daily': [
    {'day': '2026-09-26', 'signups': 2, 'ai': 5},
    {'day': '2026-09-27', 'signups': 1, 'ai': 8},
    {'day': '2026-09-28', 'signups': 0, 'ai': 4},
    {'day': '2026-09-29', 'signups': 3, 'ai': 9},
    {'day': '2026-09-30', 'signups': 5, 'ai': 12},
    {'day': '2026-10-01', 'signups': 2, 'ai': 7},
    {'day': '2026-10-02', 'signups': 1, 'ai': 6},
    {'day': '2026-10-03', 'signups': 4, 'ai': 10},
    {'day': '2026-10-04', 'signups': 6, 'ai': 15},
    {'day': '2026-10-05', 'signups': 3, 'ai': 9},
    {'day': '2026-10-06', 'signups': 2, 'ai': 11},
    {'day': '2026-10-07', 'signups': 7, 'ai': 14},
    {'day': '2026-10-08', 'signups': 5, 'ai': 13},
    {'day': '2026-10-09', 'signups': 4, 'ai': 6},
  ],
});

final fixtureAdminUsers = [
  AdminUserSummary.fromJson({
    'id': 'u1',
    'email': 'owner@forensic.test',
    'display_name': 'Owner',
    'created_at': '2026-09-01T09:00:00Z',
    'last_activity': '2026-10-09T08:00:00Z',
    'roles': ['identity_admin'],
    'tier': 'professionalPro',
    'locale': 'uz',
    'platforms': 'android',
    'status': 'ACTIVE',
  }),
  AdminUserSummary.fromJson({
    'id': 'u2',
    'email': 'student@univ.test',
    'created_at': '2026-10-02T09:00:00Z',
    'last_activity': '2026-10-08T18:00:00Z',
    'locale': 'ru',
    'platforms': 'ios',
    'status': 'ACTIVE',
  }),
  AdminUserSummary.fromJson({
    'id': 'u3',
    'email': 'expert@lab.test',
    'display_name': 'Expert',
    'specialty': 'forensicToxicology',
    'created_at': '2026-10-05T09:00:00Z',
    'tier': 'studentPro',
    'status': 'UNCONFIRMED',
  }),
];
