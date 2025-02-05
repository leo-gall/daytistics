import 'package:url_launcher/url_launcher.dart';

Future<void> openUrl(String url) async {
  final Uri parsedUrl = Uri.parse(url);

  await launchUrl(parsedUrl);
}
