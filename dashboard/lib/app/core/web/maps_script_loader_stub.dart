/// No-op on non-web platforms. Android/iOS/desktop configure the Google
/// Maps key natively (AndroidManifest.xml / AppDelegate.swift) instead of
/// injecting a <script> tag, so there's nothing to do here.
Future<void> injectGoogleMapsScript(String apiKey) async {}