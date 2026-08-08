/// Semver-style compare for `x.y.z` (missing parts treated as 0).
int compareAppVersions(String v1, String v2) {
  final a = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final b = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  for (var i = 0; i < 3; i++) {
    final ai = i < a.length ? a[i] : 0;
    final bi = i < b.length ? b[i] : 0;
    if (ai > bi) return 1;
    if (ai < bi) return -1;
  }
  return 0;
}

class AppVersionCheckResult {
  const AppVersionCheckResult({
    required this.shouldShowUpdate,
    required this.isForceUpdate,
    required this.latestVersion,
    required this.updateUrl,
  });

  final bool shouldShowUpdate;
  final bool isForceUpdate;
  final String latestVersion;
  final String updateUrl;
}
