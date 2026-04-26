// ─── Landmark name parser ─────────────────────────────────────────────────────

/// Splits a raw landmark name like `"Vending Machine (CAS Building)"` into a
/// [title] and an optional [subtitle] extracted from the parentheses.
///
/// Example:
/// ```dart
/// final parsed = parseLandmarkName('Vending Machine (CAS Building)');
/// parsed.title    // "Vending Machine"
/// parsed.subtitle // "CAS Building"
/// ```
({String title, String? subtitle}) parseLandmarkName(String raw) {
  final parenStart = raw.indexOf('(');
  if (parenStart == -1) return (title: raw.trim(), subtitle: null);

  final title = raw.substring(0, parenStart).trim();
  final inner = raw.substring(parenStart + 1);
  final parenEnd = inner.indexOf(')');
  final subtitle = parenEnd == -1
      ? inner.trim()
      : inner.substring(0, parenEnd).trim();

  return (title: title, subtitle: subtitle.isEmpty ? null : subtitle);
}
