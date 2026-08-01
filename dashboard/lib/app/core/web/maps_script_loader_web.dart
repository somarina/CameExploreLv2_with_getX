// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;

/// Adds the Google Maps JavaScript <script> tag to the page at runtime,
/// using the key passed in via --dart-define=GOOGLE_MAPS_API_KEY=... (or
/// --dart-define-from-file=env.json). This keeps the key out of
/// web/index.html entirely.
///
/// Returns a Future that completes once the script has actually finished
/// loading (or immediately, with a printed warning, if there's no key, or
/// after a timeout if the network request hangs). Callers should `await`
/// this before mounting anything that uses GoogleMap — building a
/// GoogleMap widget before `google.maps` exists on `window` is what causes
/// the "Cannot read properties of undefined (reading 'MapTypeId')" crash.
Future<void> injectGoogleMapsScript(String apiKey) {
  if (apiKey.isEmpty) {
    // ignore: avoid_print
    print(
      'WARNING: GOOGLE_MAPS_API_KEY is empty. Run with '
      '--dart-define-from-file=env.json (or '
      '--dart-define=GOOGLE_MAPS_API_KEY=your_key) or the map will crash '
      'when opened.',
    );
    return Future.value();
  }

  // Already injected (e.g. hot restart) — don't add it twice.
  final existing = html.document.getElementById('google-maps-script');
  if (existing != null) return Future.value();

  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..id = 'google-maps-script'
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey'
    ..type = 'text/javascript';

  script.onLoad.first.then((_) {
    if (!completer.isCompleted) completer.complete();
  });
  script.onError.first.then((_) {
    // ignore: avoid_print
    print('ERROR: Failed to load the Google Maps script. Check the API '
        'key and that the Maps JavaScript API is enabled for it.');
    if (!completer.isCompleted) completer.complete();
  });

  html.document.head!.append(script);

  // Don't block app startup forever if the network is slow/offline.
  return completer.future.timeout(
    const Duration(seconds: 8),
    onTimeout: () {
      // ignore: avoid_print
      print('WARNING: Google Maps script did not confirm loading within '
          '8s; continuing anyway.');
    },
  );
}