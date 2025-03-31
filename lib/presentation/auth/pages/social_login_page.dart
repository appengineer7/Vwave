
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
// import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
// import 'package:flutter/material.dart';
//
// class MyCustomScreen extends StatelessWidget {
//   const MyCustomScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AuthStateListener<OAuthController>(
//       child: OAuthProviderButton(
//         // or any other OAuthProvider
//         provider: GoogleProvider(clientId: "GOOGLE_CLIENT_ID"),
//       ),
//       listener: (oldState, newState, ctrl) {
//         if (newState is SignedIn) {
//           Navigator.pushReplacementNamed(context, '/profile');
//         }
//         return null;
//       },
//     );
//   }
// }