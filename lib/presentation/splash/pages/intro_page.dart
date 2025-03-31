import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/constants.dart';
import 'package:vwave/widgets/action_button.dart';
import 'package:vwave/widgets/styles/app_colors.dart';
import 'package:vwave/widgets/styles/text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late PageController pageController;

  int currentPage = 0;

  final List<Map<String, String>> messages = [
    {
      "title": " Unique Virtual Experiences",
      "subtitle": "Immerse yourself in entertaining virtual spaces with live club feeds and engaging chat features to build connections with individuals."
    },
    {
      "title": " Safe and Secure Meetups",
      "subtitle": "Enjoy peace of mind as you plan and execute real-world meetups with individuals who share your interests."
    },
    {
      "title": " Local Club Directory",
      "subtitle": "Discover the hottest spots in your area and plan your next night out with VWave's comprehensive club directory."
    }
  ];

  @override
  void initState() {
    super.initState();

    pageController = PageController(
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void setSeenIntro(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool(PrefKeys.intro, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Image.asset(
          //   "assets/images/backdrop_1.png",
          //   width: MediaQuery.of(context).size.width,
          // ),
          // Image.asset(
          //   "assets/images/backdrop_2.png",
          //   width: MediaQuery.of(context).size.width,
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: PageView(
                  // physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: [
                    Image.asset(
                      "assets/images/intro_1.jpg",
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      "assets/images/intro_2.jpg",
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      "assets/images/intro_3.jpg",
                      fit: BoxFit.cover,
                    ),
                  ],
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        messages[currentPage]['title'] ?? "",
                        style: subHeadingStyle.copyWith(
                            fontWeight: FontWeight.w700, color: AppColors.primaryBase), textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        messages[currentPage]['subtitle'] ?? "",
                        style: bodyStyle.copyWith(color: AppColors.grey700),textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      sliderIntro(),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Visibility(
                              visible: currentPage == 1,
                              replacement: const SizedBox(),
                              child: SizedBox(
                                width: 100,
                                height: 50,
                                child: TextButton(
                                  onPressed: () {
                                    pageController.animateToPage(
                                      currentPage - 1,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Text('Back', style: subHeadingStyle.copyWith(
                                    fontWeight: FontWeight.w700, color: AppColors.primaryBase.withOpacity(0.6), fontSize: 16)),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: currentPage < 2,
                              replacement: SizedBox(
                                width: MediaQuery.of(context).size.width - 48,
                                height: 60.0,
                                child: ActionButton(
                                  onPressed: () {
                                    // has seen intro

                                    // Obtain shared preferences.

                                    setSeenIntro(true);

                                    Navigator.of(context)
                                        .pushReplacementNamed('/auth_intro');
                                  },
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColors.primaryBase,
                                  text: 'Get Started',
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  pageController.animateToPage(
                                    currentPage + 1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Text('Next', style: subHeadingStyle.copyWith(
                                    fontWeight: FontWeight.w700, color: AppColors.primaryBase, fontSize: 16)),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget sliderIntro() {
    return SizedBox(
      height: 8.0,
      width: 100,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          slidingIndicators(currentPage == 0),
          const SizedBox(width: 5,),
          slidingIndicators(currentPage == 1),
          const SizedBox(width: 5,),
          slidingIndicators(currentPage == 2),
        ],
      ),
    );
  }

  Widget slidingIndicators(bool active) {
    if(active) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.primaryBase,
          borderRadius: BorderRadius.circular(8)
        ),
      );
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
          color: AppColors.primaryBase.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8)
      ),
    );
  }
}
