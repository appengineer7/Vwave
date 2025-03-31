import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../widgets/styles/app_colors.dart';

class ShimmerEffectsUnused extends StatelessWidget {
  final Widget child;
  final double aspectRatio;

  const ShimmerEffectsUnused(this.child, this.aspectRatio, {super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 1,
      shrinkWrap: true,
      childAspectRatio: aspectRatio,
      primary: false,
      children: List.generate(
        10,
            (index) => child,
      ),
    );
  }
}

class ShimmerEffects extends StatelessWidget {
  final String type;

  const ShimmerEffects(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    if(type == "full") {
      return fullLoading();
    }
    if(type == "livestream") {
      return const LivestreamLoadingShimmer();
    }
    if(type == "event") {
      return const EventsLoadingShimmer();
    }
    if(type == "club") {
      return const ClubsLoadingShimmer();
    }
    return fullLoading();
  }

  Widget fullLoading() {
    return Column(
      children: List.generate(5, (index) => const FullLoadingShimmer()),
    );
  }
}



class FullLoadingShimmer extends StatelessWidget {
  final color = Colors.black38;

  const FullLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      margin: const EdgeInsets.all(0.0),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Shimmer.fromColors(
              baseColor: AppColors.grey400,
              highlightColor: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 10.0),
                    child: Container(
                      height: 120.0,
                      width: mediaQueryData.size.width - 48.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black12,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        height: 40.0,
                        width: 40.0,
                        margin: const EdgeInsets.only(left: 0, top: 10),
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(20.0)),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Container(
                        height: 40.0,
                        width: mediaQueryData.size.width - 98.0,
                        margin: const EdgeInsets.only(left: 0, top: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black12,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 8.0),
                    child: Container(
                      height: 10.0,
                      width: mediaQueryData.size.width / 3.1,
                      color: Colors.black12,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 10.0),
                    child: Container(
                      height: 8.0,
                      width: mediaQueryData.size.width / 4.0,
                      color: Colors.black12,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class LivestreamLoadingShimmer extends StatelessWidget {
  const LivestreamLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      margin: const EdgeInsets.all(0.0),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Shimmer.fromColors(
              baseColor: AppColors.grey400,
              highlightColor: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 10.0),
                    child: Container(
                      height: 120.0,
                      width: mediaQueryData.size.width - 48.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black12,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0, top: 8.0),
                      child: Container(
                        height: 10.0,
                        width: mediaQueryData.size.width / 3.1,
                        color: Colors.black12,
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 10.0),
                    child: Container(
                      height: 8.0,
                      width: mediaQueryData.size.width / 4.0,
                      color: Colors.black12,
                    ),
                  )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}

class ClubsLoadingShimmer extends StatelessWidget {
  final color = Colors.black38;

  const ClubsLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      margin: const EdgeInsets.all(0.0),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Shimmer.fromColors(
              baseColor: AppColors.grey400,
              highlightColor: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 10.0),
                    child: Container(
                      height: 120.0,
                      width: mediaQueryData.size.width - 48.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black12,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        height: 40.0,
                        width: 40.0,
                        margin: const EdgeInsets.only(left: 0, top: 10),
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(20.0)),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Container(
                        height: 40.0,
                        width: mediaQueryData.size.width - 98.0,
                        margin: const EdgeInsets.only(left: 0, top: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black12,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 10.0,
                          width: mediaQueryData.size.width / 3.1,
                          color: Colors.black12,
                        ),
                        Container(
                          height: 10.0,
                          width: mediaQueryData.size.width / 6.0,
                          color: Colors.black12,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 10.0),
                    child: Container(
                      height: 10.0,
                      width: mediaQueryData.size.width / 4.0,
                      color: Colors.black12,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class EventsLoadingShimmer extends StatelessWidget {
  final color = Colors.black38;

  const EventsLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      margin: const EdgeInsets.all(0.0),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Shimmer.fromColors(
              baseColor: AppColors.grey400,
              highlightColor: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 10.0),
                    child: Container(
                      height: 120.0,
                      width: mediaQueryData.size.width - 48.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black12,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        height: 40.0,
                        width: 40.0,
                        margin: const EdgeInsets.only(left: 0, top: 10),
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(20.0)),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Container(
                        height: 40.0,
                        width: mediaQueryData.size.width - 98.0,
                        margin: const EdgeInsets.only(left: 0, top: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black12,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 10.0),
                    child: Container(
                      height: 10.0,
                      width: mediaQueryData.size.width / 4.0,
                      color: Colors.black12,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 10.0,
                          width: mediaQueryData.size.width / 3.1,
                          color: Colors.black12,
                        ),
                        Container(
                          height: 10.0,
                          width: mediaQueryData.size.width / 6.0,
                          color: Colors.black12,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SingleLoadingShimmer extends StatelessWidget {
  final color = Colors.black38;

  const SingleLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      margin: const EdgeInsets.all(0.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Shimmer.fromColors(
                  baseColor: AppColors.grey400,
                  highlightColor: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Container(
                            height: 40.0,
                            width: 40.0,
                            margin: const EdgeInsets.only(left: 10, top: 20),
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Container(
                            height: 40.0,
                            width: mediaQueryData.size.width - 160.0,
                            margin: const EdgeInsets.only(left: 10, top: 20),
                            color: Colors.black12,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                        child: Container(
                          height: 60.0,
                          width: mediaQueryData.size.width - 80.0,
                          color: Colors.black12,
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 0.0, top: 8.0),
                      //   child: Container(
                      //     height: 10.0,
                      //     width: mediaQueryData.size.width / 4.1,
                      //     color: Colors.black12,
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 0.0, top: 10.0),
                      //   child: Container(
                      //     height: 8.0,
                      //     width: mediaQueryData.size.width / 6.0,
                      //     color: Colors.black12,
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, top: 10.0, bottom: 0.0),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.favorite_border_rounded,
                              size: 13.0,
                              color: Colors.black38,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Container(
                                height: 6.0,
                                width: 20.0,
                                color: Colors.black12,
                              ),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            const Icon(
                              Icons.mode_comment_outlined,
                              size: 13.0,
                              color: Colors.black38,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Container(
                                height: 6.0,
                                width: 20.0,
                                color: Colors.black12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
