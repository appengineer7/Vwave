
class NotificationPayloadModel {
  String? profileImage, profileUid, profileUsername, followingUserUid, followingUsername;
  bool? isFollowing;
  dynamic livestreamData;

  NotificationPayloadModel(this.profileImage, this.profileUid, this.profileUsername, this.followingUserUid, this.followingUsername, this.isFollowing, this.livestreamData);

  Map<String, dynamic> toJSON() {
    return {
      'profile_image': profileImage,
      'profile_uid': profileUid,
      'profile_username': profileUsername,
      'following_user_uid': followingUserUid,
      'following_username': followingUsername,
      'is_following': isFollowing,
      "livestream_data": livestreamData,
    };
  }

  NotificationPayloadModel.fromSnapshot(dynamic data) {
    profileImage = data['profile_image'] ?? "";
    profileUid = data['profile_uid'] ?? "";
    profileUsername = data['profile_username'] ?? "";
    followingUserUid = data['following_user_uid'] ?? "";
    followingUsername = data['following_username'] ?? "";
    isFollowing = data['is_following'] ?? false;
    livestreamData = data['livestream_data'] ?? {};
  }
}
