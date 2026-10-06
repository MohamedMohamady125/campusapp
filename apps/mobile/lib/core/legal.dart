import 'package:url_launcher/url_launcher.dart';

/// Hosted legal pages (QA M-10): static HTML shipped with the web build on
/// Vercel, opened in the device browser from the app.
const kWebBaseUrl = 'https://campusconnect-web-livid.vercel.app';

final Uri kTermsUrl = Uri.parse('$kWebBaseUrl/terms.html');
final Uri kPrivacyUrl = Uri.parse('$kWebBaseUrl/privacy.html');

/// Opens a legal page in the external browser; returns false on failure so
/// callers can show a snackbar instead of silently doing nothing.
Future<bool> openLegalUrl(Uri url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);
