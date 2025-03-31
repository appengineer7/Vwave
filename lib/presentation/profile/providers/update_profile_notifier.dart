import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vwave_new/presentation/profile/repositories/profile_repository.dart';

import '../../auth/models/user.dart';

class UpdateProfileNotifier extends AsyncNotifier<User?> {
  Future<void> updateProfile({
    required Map<String, dynamic> userData
    // required String firstName,
    // required String lastName,
    // required String id,
    // required String bio,
  }) async {
    state = const AsyncValue.loading();

    final user = await ref.read(profileRepositoryProvider).updateProfile(userData: userData);
    // id: id, firstName: firstName, lastName: lastName, bio: bio);
    state = AsyncValue.data(user);
    // print(products);
  }

  @override
  Future<User?> build() async {
    return null;
  }
}

final updateProfileNotifier =
AsyncNotifierProvider<UpdateProfileNotifier, User?>(() {
  return UpdateProfileNotifier();
});
