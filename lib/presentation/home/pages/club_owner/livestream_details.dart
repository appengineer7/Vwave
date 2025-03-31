
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave_new/presentation/livestream/models/livestream.dart';
import 'package:vwave_new/utils/general.dart';
import 'package:vwave_new/utils/storage.dart';
import 'package:vwave_new/widgets/nav_back_button.dart';
import 'package:vwave_new/widgets/user_avatar.dart';

import '../../../../widgets/search_field.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../../../livestream/widgets/livestream_horizontal_display.dart';

class LivestreamDetailsPage extends ConsumerStatefulWidget {
  final Livestream livestream;
  const LivestreamDetailsPage(this.livestream, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LivestreamDetailsPage();
}

class _LivestreamDetailsPage extends ConsumerState<LivestreamDetailsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: NavBackButton(
            color: AppColors.titleTextColor,
            onPress: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Text("Details", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 180,
                  child: CachedNetworkImage(
                    fit: BoxFit.fitWidth,
                    height: 180.0,
                    // width: (MediaQuery.of(context).size.width - 66) / 1.5,
                    imageUrl: widget.livestream.images[0]["url"],
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                    imageBuilder: (c, i) {
                      return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            image: DecorationImage(image: i, fit: BoxFit.cover)
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20,),
                Text(
                  widget.livestream.title,
                  textAlign: TextAlign.start,
                  style: subHeadingStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey900,
                    fontSize: 20
                  ),
                ),
                const SizedBox(height: 20,),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.dividerColor.withOpacity(0), AppColors.dividerColor.withOpacity(0.2), AppColors.dividerColor.withOpacity(0)], stops: const [0,0.5,1],begin: Alignment.centerLeft, end: Alignment.centerRight)
                  ),
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          returnDate(),
                          textAlign: TextAlign.center,
                          style: subHeadingStyle.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey900,
                              fontSize: 20
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Text(
                          "Date",
                          textAlign: TextAlign.center,
                          style: bodyStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey600
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          GeneralUtils().returnFormattedDateDuration(widget.livestream.duration),
                          textAlign: TextAlign.center,
                          style: subHeadingStyle.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey900,
                              fontSize: 20
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Text(
                          "Duration",
                          textAlign: TextAlign.center,
                          style: bodyStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey600
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          GeneralUtils().shortenLargeNumber(num: widget.livestream.views.toDouble()),
                          textAlign: TextAlign.center,
                          style: subHeadingStyle.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey900,
                              fontSize: 20
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Text(
                          "Total Viewers",
                          textAlign: TextAlign.center,
                          style: bodyStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey600
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30,),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.dividerColor.withOpacity(0), AppColors.dividerColor.withOpacity(0.2), AppColors.dividerColor.withOpacity(0)], stops: const [0,0.5,1],begin: Alignment.centerLeft, end: Alignment.centerRight)
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }

  String returnDate() {
    DateTime dateTime = DateTime.parse(widget.livestream.createdDate!);
    return "${GeneralUtils().rewriteTimeValue(dateTime.day)}/${GeneralUtils().rewriteTimeValue(dateTime.month)}/${dateTime.year.toString().substring(2)}";
  }
}