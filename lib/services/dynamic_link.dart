
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class WaveDynamicLink {

  static Future<String> createDynamicLink(String id, String title, String desc, String thumbnailUrl, String type, String data) async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://vwave.page.link',
      link: Uri.parse('https://getvwave.com?type=$type&id=$id&data=$data'),
      androidParameters: const AndroidParameters(
        packageName: 'com.vwave.app.vwave',
        minimumVersion: 1,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.vwave.app',
        minimumVersion: '1.0.0',
        appStoreId: '6670310777',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'share-$type-link',
        medium: 'social',
        source: 'app',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: title, description: desc, imageUrl: Uri.parse(thumbnailUrl)),
    );
    final ShortDynamicLink shortLink =
    await dynamicLinks.buildShortLink(parameters);
    final shortUrl = shortLink.shortUrl;
    return shortUrl.toString();
  }
}