import 'package:flutter/material.dart';

/// Reytingdagi o‘rin: 1–3 — oltin, kumush, bronza medal (taqdirlash
/// ko‘rinishi), qolganlari — oddiy raqam ([fallbackStyle]). [textKey] har
/// ikki holatda ham raqam matniga beriladi (testlar va o‘qish uchun).
class RankMedal extends StatelessWidget {
  const RankMedal({
    super.key,
    required this.rank,
    this.size = 26,
    this.textKey,
    this.fallbackStyle,
  });

  final int rank;
  final double size;
  final Key? textKey;
  final TextStyle? fallbackStyle;

  static const _gold = [Color(0xFFF6DC8A), Color(0xFFC99A2E)];
  static const _silver = [Color(0xFFF1F3F6), Color(0xFFA3ABB6)];
  static const _bronze = [Color(0xFFF0C29C), Color(0xFFA9683A)];

  /// 1–3 uchun medal ranglari; boshqalar uchun `null`.
  static List<Color>? colorsFor(int rank) => switch (rank) {
    1 => _gold,
    2 => _silver,
    3 => _bronze,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final colors = colorsFor(rank);
    if (colors == null) {
      return Text(rank.toString(), key: textKey, style: fallbackStyle);
    }
    final ink = switch (rank) {
      1 => const Color(0xFF4A3400),
      2 => const Color(0xFF2E343C),
      _ => const Color(0xFF3E1F08),
    };
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.55),
            width: size / 18,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.45),
              blurRadius: size / 5,
              offset: Offset(0, size / 14),
            ),
          ],
        ),
        child: Text(
          rank.toString(),
          key: textKey,
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            color: ink,
            fontSize: size * 0.5,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}
