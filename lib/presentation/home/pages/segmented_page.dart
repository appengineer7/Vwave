import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';

class SegmentedPage extends StatefulWidget {
  const SegmentedPage({super.key});

  @override
  State<SegmentedPage> createState() => _SegmentedPageState();
}

class _SegmentedPageState extends State<SegmentedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Current Index of tab
  int _currentIndex = 0;
  bool isCommunitySegment = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      vsync: this,
      length: 2,
      initialIndex: _currentIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Container(
            margin: const EdgeInsets.only(left: 8),
            width: 120,
            child: SvgPicture.asset("assets/images/logo.svg"),
          ),
          actions: isCommunitySegment ? [] : [
            Padding(
                padding: const EdgeInsets.only(right: 24),
                child: InkWell(
              child: SvgPicture.asset("assets/svg/home/search.svg"),
              onTap: () {
                Navigator.of(context).pushNamed("/search_products");
              },
            )),
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: InkWell(
                onTap: () {
                  // showBottomSheet(
                  //   context: context,
                  //   backgroundColor: Colors.white,
                  //   enableDrag: true,
                  //   builder: (context) {
                  //     return Card(
                  //       elevation: 2,
                  //       borderOnForeground: true,
                  //       shadowColor: Colors.black,
                  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(width: 5, color: Colors.white)),
                  //       child: const FilterBottomSheet(),
                  //     );
                  //   },
                  // );
                },
                child: SvgPicture.asset("assets/svg/home/filter.svg"),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: _currentIndex == 0
                            ? MaterialStateProperty.all<Color>(
                                AppColors.grey100)
                            : MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        _tabController.animateTo(0);
                        setState(() {
                          _currentIndex = 0;
                          isCommunitySegment = false;
                        });
                      },
                      child: Text("For Sale",
                          style: bodyStyle.copyWith(
                              fontWeight: _currentIndex == 0
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: _currentIndex == 0
                                  ? AppColors.secondaryBase
                                  : AppColors.grey400)),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: _currentIndex == 1
                            ? MaterialStateProperty.all<Color>(
                                AppColors.grey100)
                            : MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        _tabController.animateTo(1);
                        setState(() {
                          _currentIndex = 1;
                          isCommunitySegment = true;
                        });
                      },
                      child: Text(
                        "Community",
                        style: bodyStyle.copyWith(
                            fontWeight: _currentIndex == 1
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: _currentIndex == 1
                                ? AppColors.secondaryBase
                                : AppColors.grey400),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: const <Widget>[
                  // ProductList(),
                  // GChatTimelineScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
