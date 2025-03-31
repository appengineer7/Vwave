// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class ForgotPasswordLoadedState extends AuthState {
  const ForgotPasswordLoadedState();
}

class AuthLoadedState extends AuthState {
  final User? user;

  const AuthLoadedState(this.user);

  @override
  bool operator ==(covariant AuthLoadedState other) {
    if (identical(this, other)) return true;

    return other.user == user;
  }

  @override
  int get hashCode => user.hashCode;
}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);

  @override
  bool operator ==(covariant AuthErrorState other) {
    if (identical(this, other)) return true;

    return other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
