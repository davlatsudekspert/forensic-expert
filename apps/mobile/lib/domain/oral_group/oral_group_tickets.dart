/// Guruh og‘zaki imtihoni: savollar havzasidan N ta bilet tuzish (sof Dart).
///
/// Qoida: savollar biletlar orasida takrorlanmaydi (havza yetguncha),
/// mavzular bo‘yicha aralashadi (navbat bilan har mavzudan). Havza tugasa —
/// yangi aylanish (takror mumkin), lekin bitta bilet ichida savol
/// takrorlanmaydi. Oldindan ogohlantirish: [OralTicketPlan.repeats].
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'oral_group_models.dart';

@immutable
class OralTicketPlan {
  const OralTicketPlan({
    required this.tickets,
    required this.repeats,
    required this.available,
  });

  /// Har bilet — savol id’lari (tartib bilan).
  final List<List<String>> tickets;

  /// Ba’zi savollar biletlarda takrorlandi (havza yetmadi).
  final bool repeats;

  /// Havzadagi noyob savollar soni.
  final int available;
}

/// Havza `count * size` dan kam bo‘lsa — takror bo‘ladi (UI oldindan aytadi).
bool oralTicketsWillRepeat({
  required int available,
  required int count,
  int size = OralGroupRules.questionsPerTicket,
}) => available < count * size;

/// [pools] — mavzu id → savol id’lari. [count] ta bilet, har biri [size]
/// savolli (havza [size] dan kichik bo‘lsa — hammasi).
OralTicketPlan buildOralGroupTickets({
  required Map<String, List<String>> pools,
  required int count,
  required math.Random rng,
  int size = OralGroupRules.questionsPerTicket,
}) {
  final topics = [
    for (final k in pools.keys.toList()..sort())
      [
        for (final id in pools[k]!.toSet()) id, // noyob
      ],
  ].where((l) => l.isNotEmpty).toList();
  final available = topics.fold<int>(0, (a, l) => a + l.length);
  if (available == 0 || count <= 0) {
    return const OralTicketPlan(tickets: [], repeats: false, available: 0);
  }

  /// Bitta aylanish: har mavzu aralashtirilgan, mavzular tasodifiy tartibda
  /// navbat bilan (1-qator: har mavzudan bittadan, …).
  List<String> round() {
    final lists = [
      for (final l in topics) [...l]..shuffle(rng),
    ]..shuffle(rng);
    final out = <String>[];
    var i = 0;
    while (lists.any((l) => i < l.length)) {
      for (final l in lists) {
        if (i < l.length) out.add(l[i]);
      }
      i++;
    }
    return out;
  }

  final want = math.min(size, available);
  final queue = round();
  var rounds = 1;
  final tickets = <List<String>>[];
  for (var n = 0; n < count; n++) {
    final ticket = <String>[];
    while (ticket.length < want) {
      var j = queue.indexWhere((id) => !ticket.contains(id));
      if (j < 0) {
        queue.addAll(round());
        rounds++;
        j = queue.indexWhere((id) => !ticket.contains(id));
        if (j < 0) break; // mumkin emas (want <= available)
      }
      ticket.add(queue.removeAt(j));
    }
    tickets.add(ticket);
  }
  final repeats = rounds > 1 && (tickets.length * want > available);
  return OralTicketPlan(
    tickets: tickets,
    repeats: repeats,
    available: available,
  );
}
