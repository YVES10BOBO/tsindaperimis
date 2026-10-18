import 'package:flutter/material.dart';

/// Amabara ya app.
/// Amabara y'ibanze (brand) ntahinduka. Amabara y'inyuma, inyandiko n'imirongo
/// ahinduka bitewe na Light / Dark mode (`isDark` ishyirwaho na app.dart).
class AppColors {
  AppColors._();

  static bool isDark = false;

  // ---------- Brand (kimwe muri modes zombi) ----------
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color purple = Color(0xFF1D4ED8); // ubu ni ubururu (aho hose hari move)

  static const Color signRed = Color(0xFFD32F2F);
  static const Color signBlue = Color(0xFF1565C0);
  static const Color signBlack = Color(0xFF111111);

  // ---------- Light ----------
  static const Color _lBackground = Color(0xFFF7F9FC);
  static const Color _lSurface = Color(0xFFFFFFFF);
  static const Color _lBorder = Color(0xFFE5E9F0);
  static const Color _lText = Color(0xFF111827);
  static const Color _lBody = Color(0xFF374151);
  static const Color _lMuted = Color(0xFF6B7280);

  // ---------- Dark ----------
  static const Color _dBackground = Color(0xFF0B1220);
  static const Color _dSurface = Color(0xFF151E2E);
  static const Color _dBorder = Color(0xFF263247);
  static const Color _dText = Color(0xFFF1F5F9);
  static const Color _dBody = Color(0xFFCBD5E1);
  static const Color _dMuted = Color(0xFF94A3B8);

  static Color get background => isDark ? _dBackground : _lBackground;
  static Color get surface => isDark ? _dSurface : _lSurface;
  static Color get border => isDark ? _dBorder : _lBorder;
  static Color get text => isDark ? _dText : _lText;
  static Color get bodyText => isDark ? _dBody : _lBody;
  static Color get muted => isDark ? _dMuted : _lMuted;

  static Color get primarySoft => isDark ? const Color(0xFF1B2B4F) : const Color(0xFFEAF1FF);
  static Color get successSoft => isDark ? const Color(0xFF12301F) : const Color(0xFFEAF8EE);
  static Color get errorSoft => isDark ? const Color(0xFF3A1717) : const Color(0xFFFDECEC);
  static Color get warningSoft => isDark ? const Color(0xFF3A2A0E) : const Color(0xFFFFF4E0);
  static Color get purpleSoft => isDark ? const Color(0xFF1B2B4F) : const Color(0xFFEAF1FF);

  static Color get successBorder => isDark ? const Color(0xFF1F5A35) : const Color(0xFFBBF7D0);
  static Color get errorBorder => isDark ? const Color(0xFF6B2323) : const Color(0xFFFBCACA);
  static Color get warningBorder => isDark ? const Color(0xFF6B4E14) : const Color(0xFFFDE2B3);
  static Color get purpleBorder => isDark ? const Color(0xFF2B4A8A) : const Color(0xFFBFD3FF);

  static Color get successText => isDark ? const Color(0xFF86EFAC) : const Color(0xFF14532D);
  static Color get errorText => isDark ? const Color(0xFFFCA5A5) : const Color(0xFF7F1D1D);
  static Color get warningText => isDark ? const Color(0xFFFCD34D) : const Color(0xFF78350F);
  static Color get warningIcon => isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);

  /// Ibara ryoroheje ry'icyiciro: pastel muri Light, ibara ry'umwijima rikeye muri Dark.
  static Color tint(Color color, Color soft) => isDark ? color.withAlpha(46) : soft;

  /// Amabara umukoresha ashobora guhitamo ku ishusho ye (avatar).
  static const List<Color> avatarColors = <Color>[
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFFDB2777),
    Color(0xFFD97706),
    Color(0xFF0284C7),
    Color(0xFF0F766E),
  ];

  // Byakoreshwa n'insanganyamatsiko (theme)
  static Color backgroundFor(bool dark) => dark ? _dBackground : _lBackground;
  static Color surfaceFor(bool dark) => dark ? _dSurface : _lSurface;
  static Color borderFor(bool dark) => dark ? _dBorder : _lBorder;
  static Color textFor(bool dark) => dark ? _dText : _lText;
}
