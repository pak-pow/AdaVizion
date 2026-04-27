/// Routes a scan error to the appropriate dialog callback.
///
/// Matching is performed against the error's string representation, which
/// contains the message field from the backend's JSON error response.
///
/// ### Backend messages matched
/// | Message contains      | Callback           |
/// |-----------------------|--------------------|
/// | `"already visited"`   | [onAlreadyVisited] |
/// | `"not found"`         | [onInvalidQr]      |
/// | `"invalid"`           | [onInvalidQr]      |
/// | anything else         | [onGenericError]   |
abstract final class ScanErrorHandler {
  /// Classifies [error] and invokes the matching callback.
  ///
  /// Priority order:
  /// 1. Message contains `"already visited"` → [onAlreadyVisited]
  /// 2. Message contains `"not found"` or `"invalid"` → [onInvalidQr]
  /// 3. Anything else → [onGenericError]
  static void handle(
    Object error, {
    required void Function() onAlreadyVisited,
    required void Function() onInvalidQr,
    required void Function() onGenericError,
  }) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('already visited')) return onAlreadyVisited();
    if (msg.contains('not found') || msg.contains('invalid')) {
      return onInvalidQr();
    }
    onGenericError();
  }
}
