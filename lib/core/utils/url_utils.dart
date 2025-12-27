/// Normalize Firebase Storage URLs when the bucket domain is misconfigured.
///
/// Some stored URLs may contain `.firebasestorage.app` in the bucket portion
/// (e.g. `moneycharge-ebf19.firebasestorage.app`) which is invalid for public
/// access. The correct bucket host should end with `.appspot.com`.
String normalizeFirebaseStorageUrl(String url) {
  if (url.isEmpty) return url;
  if (url.contains('.firebasestorage.app')) {
    return url.replaceFirst('.firebasestorage.app', '.appspot.com');
  }
  return url;
}
