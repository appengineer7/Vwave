import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vwave_new/presentation/profile/repositories/profile_repository.dart';
import 'package:vwave_new/utils/exceptions.dart';

import '../../../services/image_upload.dart';
import '../../auth/models/user.dart';

class ProfileNotifierProvider extends AsyncNotifier<User?> {
  Future<void> fetchUserById(String id) async {
    state = const AsyncValue.loading();

    final User? user =
    await ref.read(profileRepositoryProvider).fetchUserById(id);
    state = AsyncValue.data(user);
  }

  Future<void> fetchMe() async {
    state = const AsyncValue.loading();

    final User? user = await ref.read(profileRepositoryProvider).fetchMe();
    state = AsyncValue.data(user);
  }

  Future<void> dummyFetchMe() async {
    state = const AsyncValue.loading();

    User? user = const User(firstName: "", lastName: "", email: "", allowConversations: '', allowSearchVisibility: false, blocked: false, verified: false, accountSetup: false); //await ref.read(profileRepositoryProvider).fetchMe();
    state = AsyncValue.data(user);
  }

  Future<String> uploadImage(File image, {String folder = "profile-images"}) async {
    // ref.read(uploadLoadingStateProvider.notifier).state = true;

    final String downloadUrl =
    await ref.read(imageUploadService).uploadFileToStorage(image, folder: folder);

    // state = state.copyWith(images: [...state.images, downloadUrl]);

    // ref.read(uploadLoadingStateProvider.notifier).state = false;

    return downloadUrl;
  }

  Future<void> performFriendRequest(bool isFollowingUser, String otherUserUid) async {
    try {
      await ref.read(profileRepositoryProvider).performFriendRequest(isFollowingUser, otherUserUid);
    } catch(e) {
      throw CustomException(message: "$e");
    }
  }

  Future<bool> checkConversationPrivacy(String allowConversation, String otherUserUid) async {
    try {
      return await ref.read(profileRepositoryProvider).checkConversationPrivacy(allowConversation, otherUserUid);
    } catch(e) {
      return false;
    }
  }

  @override
  Future<User?> build() async {
    return null;
  }
}

final profileNotifierProvider =
AsyncNotifierProvider<ProfileNotifierProvider, User?>(() {
  return ProfileNotifierProvider();
});
