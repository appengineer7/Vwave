import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/constants.dart';
import 'package:vwave/presentation/auth/providers/auth_state.dart';
import 'package:vwave/presentation/auth/providers/auth_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../size_config.dart';


class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  late PageController pageController;
  @override
  void initState() {
    super.initState();

    pageController = PageController(
      initialPage: 1,
    );

    Future.delayed(Duration.zero, () {
      ref.read(authNotifierProvider.notifier).appStarted();
    });
  }

  void navigate(bool seen) {
    if (seen) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      Navigator.of(context).pushReplacementNamed('/intro');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ref.listen<AuthState>(authNotifierProvider, (
      AuthState? previousState,
      AuthState newState,
    ) async {
      const d = Duration(seconds: 2);
      if (newState is AuthLoadedState) {
        Future.delayed(d, () {
          Navigator.of(context).pushReplacementNamed('/home');
        });
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        final seen = prefs.getBool(PrefKeys.intro) ?? false;
        Future.delayed(d, ()
        {
          navigate(seen);
        });
      }
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Container(
          //   decoration: const BoxDecoration(
          //     image: DecorationImage(
          //         image: AssetImage('assets/images/splash.png'),
          //         fit: BoxFit.cover),
          //   ),
          // ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SvgPicture.asset(
                        'assets/svg/logo.svg',
                        height: getProportionateScreenHeight(90.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
