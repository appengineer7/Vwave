import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../utils/exceptions.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  StreamSubscription<User?>? _authStateChangesSubscription;
  AuthStateNotifier(this.ref) : super(const AuthInitialState()) {
    _authStateChangesSubscription?.cancel();
    _authStateChangesSubscription =
        ref.read(authRepositoryProvider).authStateChanges.listen((user) {
      // if (user != null) {
      //   state = AuthLoadedState(user);
      // } else {
      //   state = const UnauthenticatedState();
      // }
          if(user == null) {
            state = const UnauthenticatedState();
          }
    });
  }

  @override
  void dispose() {
    _authStateChangesSubscription?.cancel();
    super.dispose();
  }

  void appStarted() {
    final user = ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = const UnauthenticatedState();
    } else {
      state = AuthLoadedState(user);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      state = const UnauthenticatedState();
    } on CustomException catch (e) {
      state = AuthErrorState(e.message!);
    }
  }

  Future<void> signOut() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const UnauthenticatedState();
    } on CustomException catch (e) {
      state = AuthErrorState(e.message!);
    }
  }

  Future<void> getCurrentUserData(String userId) async {
    try {
      await ref.read(authRepositoryProvider).getCurrentUserData(userId);
    } catch(e) {

    }
  }

  Future<void> signIn({
    required String email,
    required String password,
    required String deviceToken,
    required String deviceInfo,
  }) async {
    state = const AuthLoadingState();
    try {
      final user = await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          deviceToken: deviceToken,
          deviceInfo: deviceInfo,
        actionType: "login"
          );
      if(user != null) {
        state = AuthLoadedState(user);
      }
    } on CustomException catch (e) {
      state = AuthErrorState(e.message!);
    }
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = const UnauthenticatedState();
    }
    state = const AuthLoadingState();

    try {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
            email: user!.email!,
            password: oldPassword,
          deviceToken: "",
          deviceInfo: "",
        actionType: "updatePassword"
          );
      await ref
          .read(authRepositoryProvider)
          .updatePassword(password: newPassword);

      state = AuthLoadedState(user);
    } on CustomException catch (e) {
      state = AuthErrorState(e.message!);
    }
  }

  Future<void> createAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String deviceToken,
    required String deviceInfo,
    required String location,
    required Map<String, dynamic> locationDetails,
  }) async {
    state = const AuthLoadingState();
    try {
      final user = await ref.read(authRepositoryProvider).createUserWithEmailAndPassword(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            deviceToken: deviceToken,
        deviceInfo: deviceInfo,
        location: location,
        locationDetails: locationDetails,
          );
      if(user != null) {
        state = AuthLoadedState(user);
      }
    } on CustomException catch (e) {
      state = AuthErrorState(e.message!);
    }
  }

  Future<void> createClubOwnerAccount({
    required Map<String, dynamic> userData
  }) async {
    state = const AuthLoadingState();
    try {
      final user = await ref.read(authRepositoryProvider).createClubOwnerWithEmailAndPassword(
          mUserData: userData
          );
      if(user != null) {
        state = AuthLoadedState(user);
      }
    } on CustomException catch (e) {
      state = AuthErrorState(e.message!);
    }
  }

  Future<void> createUserAccountBySocialLogin({
    required Map<String, dynamic> userData
  }) async {
    state = const AuthLoadingState();
    try {
      final user = await ref.read(authRepositoryProvider).createUserAccountWithSocialLogin(
          mUserData: userData
          );
      if(user != null) {
        state = AuthLoadedState(user);
      }
    } on CustomException catch (e) {
      state = AuthErrorState(e.message!);
    }
  }

  Future<void> updateUserData({
    required Map<String, dynamic> userData
  }) async {
    try {
      await ref.read(authRepositoryProvider).updateUserData(
          data: userData
      );
    } on CustomException catch (e) {
    }
  }

  Future<void> forgotPassword({required String email}) async {
    // state = const AuthLoadingState();
    try {
      await ref.read(authRepositoryProvider).sendResetPasswordEmail(
            email: email,
          );
      // state = const ForgotPasswordLoadedState();
    } on CustomException catch (e) {
      // state = AuthErrorState(e.message!);
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) => AuthStateNotifier(ref),
);
