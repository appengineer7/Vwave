import 'package:flutter/material.dart';
import 'package:vwave_new/presentation/auth/pages/auth_intro_page.dart';
import 'package:vwave_new/presentation/auth/pages/create_account_page.dart';
import 'package:vwave_new/presentation/auth/pages/create_account_page_club_owner.dart';
import 'package:vwave_new/presentation/auth/pages/forgot_password_page.dart';
import 'package:vwave_new/presentation/auth/pages/login_page.dart';
import 'package:vwave_new/presentation/auth/pages/set_location.dart';
import 'package:vwave_new/presentation/club/models/club.dart';
import 'package:vwave_new/presentation/club/pages/club_details.dart';
import 'package:vwave_new/presentation/club/pages/clubs_near_page.dart';
import 'package:vwave_new/presentation/club/pages/gallery_page.dart';
import 'package:vwave_new/presentation/club/pages/reviews_list_page.dart';
import 'package:vwave_new/presentation/club/pages/search_club_page.dart';
import 'package:vwave_new/presentation/club/pages/view_all_clubs.dart';
import 'package:vwave_new/presentation/club/pages/view_image_page.dart';
import 'package:vwave_new/presentation/events/models/club_event.dart';
import 'package:vwave_new/presentation/events/pages/create_event.dart';
import 'package:vwave_new/presentation/events/pages/event_details.dart';
import 'package:vwave_new/presentation/home/pages/club_owner/livestream_details.dart';
import 'package:vwave_new/presentation/home/pages/club_owner/recent_activities.dart';
import 'package:vwave_new/presentation/home/pages/club_owner/top_followers.dart';
import 'package:vwave_new/presentation/home/pages/home_page.dart';
import 'package:vwave_new/presentation/home/pages/user/search_entire_users_page.dart';
import 'package:vwave_new/presentation/home/pages/user/suggest_club_page.dart';
import 'package:vwave_new/presentation/home/pages/user/user_events_page.dart';
import 'package:vwave_new/presentation/home/pages/user/user_livestream_page.dart';
import 'package:vwave_new/presentation/livestream/models/livestream.dart';
import 'package:vwave_new/presentation/livestream/pages/livestream_view_page.dart';
import 'package:vwave_new/presentation/messaging/models/conversation.dart';
import 'package:vwave_new/presentation/messaging/pages/chat_page.dart';
import 'package:vwave_new/presentation/messaging/pages/chat_settings.dart';
import 'package:vwave_new/presentation/messaging/pages/search_users_page.dart';
import 'package:vwave_new/presentation/notification/pages/notification_screen.dart';
import 'package:vwave_new/presentation/profile/pages/change_password_page.dart';
import 'package:vwave_new/presentation/profile/pages/club_owner/club_onwer_account_setup.dart';
import 'package:vwave_new/presentation/profile/pages/club_owner/club_reviews_page.dart';
import 'package:vwave_new/presentation/profile/pages/delete_account_page.dart';
import 'package:vwave_new/presentation/profile/pages/privacy_policy_page.dart';
import 'package:vwave_new/presentation/profile/pages/profile_page.dart';
import 'package:vwave_new/presentation/profile/pages/simple_user_profile_page.dart';
import 'package:vwave_new/presentation/profile/pages/terms_page.dart';
import 'package:vwave_new/presentation/profile/pages/user/edit_profile.dart';
import 'package:vwave_new/presentation/profile/pages/user/friends_list_page.dart';
import 'package:vwave_new/presentation/profile/pages/user/invite_friends_page.dart';
import 'package:vwave_new/presentation/profile/pages/user/privacy_settings.dart';
import 'package:vwave_new/presentation/profile/pages/user/saved_clubs_page.dart';
import 'package:vwave_new/presentation/splash/pages/intro_page.dart';
import 'package:vwave_new/presentation/splash/pages/splash_page.dart';
import 'package:vwave_new/presentation/stories/models/story.dart';
import 'package:vwave_new/presentation/stories/pages/add_to_story.dart';
import 'package:vwave_new/presentation/stories/pages/process_story_asset.dart';
import 'package:vwave_new/presentation/stories/pages/stories_swipe_view.dart';


import 'presentation/auth/models/user.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const SplashPage(),
        );
      case '/intro':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const IntroPage(),
        );
      case '/auth_intro':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const AuthIntroPage(),
        );
      case '/login':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const LoginPage(),
        );
      case '/register':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const CreateAccountPage(),
        );
      case '/register_club':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const CreateAccountClubOwnerPage(),
        );
      case '/set_location':
        final Map<String, dynamic> userData =
            settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => SetClubOwnerLocation(userData),
        );
      case '/home':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const HomePage(),
        );
      case '/club_owner_account_setup':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const ClubOwnerAccountSetupPage(),
        );
      case '/top_followers':
        final dynamic suggestedUsers = settings.arguments as dynamic;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => TopFollowersPage(suggestedUsers),
        );
      case '/recent_activities':
        final List<Livestream> livestreams =
            settings.arguments as List<Livestream>;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => RecentActivitiesPage(livestreams),
        );
      case '/livestreams':
        final List<Livestream> livestreams =
            settings.arguments as List<Livestream>;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => UserLivestreamPage(livestreams),
        );
      case '/livestream_details':
        final Livestream livestream = settings.arguments as Livestream;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => LivestreamDetailsPage(livestream),
        );
      case '/club_details':
        final Club club = settings.arguments as Club;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => ClubDetailsPage(club),
        );
        case '/search_club':
        final String query = settings.arguments as String;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => SearchClubPage(query),
        );
      case '/clubs_near':
        final List<Club> clubs = settings.arguments as List<Club>;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => ClubsNearPage(clubs),
        );
        case '/clubs':
        final List<Club> clubs = settings.arguments as List<Club>;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => AllClubsPage(clubs),
        );
      case '/livestream_view':
        final Livestream livestream = settings.arguments as Livestream;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => LivestreamViewPage(livestream),
        );

      case '/search_entire_users':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const SearchEntireUsersPage(),
        );
        case '/add_to_story':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const AddToStoryPage(),
        );
        case '/process_story':
          final Map<String, dynamic> storyAsset = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => ProcessStoryPage(storyAsset),
        );
        case '/view_story':
          final StoryFeed storyFeed = settings.arguments as StoryFeed;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => StoriesSwipeViewPage(storyFeed),
        );
      case '/user_profile':
        final Map<String, dynamic> user =
            settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => SimpleUserProfilePage(user),
        );
      case '/view_full_image':
        final Map<String, dynamic> galleryData = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => ViewImagePage(galleryData),
        );
      case '/gallery_view':
        final List<dynamic> images = settings.arguments as List<dynamic>;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => GalleryViewPage(images),
        );
      case '/club_reviews':
        final Club club = settings.arguments as Club;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => ReviewsListPage(club),
        );
      // case '/privacy_and_security':
      //   return MaterialPageRoute<bool>(
      //     builder: (BuildContext context) => const PrivacyAndSecurityPage(),
      //   );
      case '/invite_friends':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const InviteFriendsPage(),
        );
      case '/delete_account':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const DeleteAccountPage(),
        );
      case '/privacy_policy':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const PrivacyPolicyPage(),
        );
      case '/terms_and_conditions':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const TermsPage(),
        );

      case '/change_password':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const ChangePasswordPage(),
        );

      case '/forgot_password':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const ForgotPasswordPage(),
        );

      case '/notifications':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const NotificationScreen(),
        );
        case '/club_reviews_overview':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const ClubReviewsPage(),
        );
        case '/create_event':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const CreateEventPage(),
        );
        case '/event_details':
          final ClubEvent clubEvent = settings.arguments as ClubEvent;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => EventDetailsPage(clubEvent),
        );
        case '/user_events_list':
          final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
          final List<ClubEvent> clubEvent = args["club_event"] as List<ClubEvent>;
          final String userType = args["user_type"] as String;
          final Map<String, dynamic> userLocationDetails = args["location_details"] as Map<String, dynamic>;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => UserEventsPage(clubEvent, userType, userLocationDetails),
        );

      // case '/add_product':
      //   if (settings.arguments == null) {
      //     return MaterialPageRoute<bool>(
      //       builder: (BuildContext context) => const AddProductPage(null),
      //     );
      //   }
      //   final Product product = settings.arguments as Product;
      //   return MaterialPageRoute<bool>(
      //     builder: (BuildContext context) => AddProductPage(product),
      //   );
      // case '/add_product_price':
      //   return MaterialPageRoute<bool>(
      //     builder: (BuildContext context) => const AddProductPricePage(),
      //   );
      // case '/add_product_summary':
      //   return MaterialPageRoute<bool>(
      //     builder: (BuildContext context) => const AddProductPricePage(),
      //   );
      // case '/create_community_post':
      //   if (settings.arguments == null) {
      //     return MaterialPageRoute<bool>(
      //       builder: (BuildContext context) =>
      //           const CreateNewCommunityPost(null),
      //     );
      //   }
      //   final CommunityPost post = settings.arguments as CommunityPost;
      //   return MaterialPageRoute<bool>(
      //     builder: (BuildContext context) => CreateNewCommunityPost(post),
      //   );
      //
      case '/user_account':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const ProfilePage(),
        );

      case '/friends_list':
        final Map<String, dynamic> type = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => FriendsListPage(type),
        );
        case '/edit_profile':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const EditProfilePage(),
        );
        case '/privacy_settings':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const PrivacySettingsPage(),
        );
      case '/favourites':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const SavedClubsPage(),
        );
        case '/club_suggestion':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const ClubSuggestionPage(),
        );
      // case '/active_listings':
      //   final List<Product> products = settings.arguments as List<Product>;
      //   return MaterialPageRoute<bool>(
      //     builder: (BuildContext context) => ActiveListingsPage(products),
      //   );
      // case '/orders':
      //   return MaterialPageRoute<bool>(
      //     builder: (BuildContext context) => const OrdersPage(),
      //   );
      // case '/order_details':
      //   final Order order = settings.arguments as Order;
      //   return MaterialPageRoute<bool>(
      //     builder: (BuildContext context) => OrderDetailsPage(order),
      //   );
      // case '/account_settings':
      //   return MaterialPageRoute<bool>(
      //     builder: (BuildContext context) => const AccountSettingsPage(),
      //   );
      // case '/donation':
      //   return MaterialPageRoute<bool>(
      //     builder: (BuildContext context) => const DonationPage(),
      //   );
      // case '/items_activity':
      //   final NotificationModel notificationModel =
      //       settings.arguments as NotificationModel;
      //   return MaterialPageRoute<bool>(
      //     builder: (BuildContext context) =>
      //         ItemsActivityScreen(notificationModel),
      //   );
      //
      // case '/offer_details':
      //   final NotificationModel notificationModel =
      //       settings.arguments as NotificationModel;
      //   return MaterialPageRoute<bool>(
      //     builder: (BuildContext context) =>
      //         OfferDetailsScreen(notificationModel),
      //   );
      //
      case '/search_users':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const SearchUsersPage(),
        );
      case '/chat':
        final Conversation conversation = settings.arguments as Conversation;
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => ChatPage(conversation),
        );
        case '/chat_settings':
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const ChatSettingsPage(),
        );

      default:
        // return MaterialPageRoute<bool>(
        //   builder: (BuildContext context) => const Scaffold(
        //     body: Center(child: Text("Can't find this page")),
        //   ),
        // );
        return MaterialPageRoute<bool>(
          builder: (BuildContext context) => const SplashPage(),
        );
    }
  }
}
