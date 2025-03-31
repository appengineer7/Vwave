import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:vwave/constants.dart';
import 'package:vwave/presentation/events/models/club_event.dart';
import 'package:vwave/presentation/events/providers/club_event_notifier_provider.dart';
import 'package:vwave/presentation/livestream/models/livestream.dart';
import 'package:vwave/utils/general.dart';
import 'package:vwave/widgets/action_button.dart';

import '../../../widgets/bottom_sheet_multiple_responses.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';

class ClubEventCardViewDisplay extends ConsumerStatefulWidget {
  final ClubEvent clubEvent;
  final double? viewWidth;
  final double? spaceBetween;
  final bool isInit;
  final bool allowRightMargin;
  final String userType;
  final Map<String, dynamic> locationDetails;
  const ClubEventCardViewDisplay(this.clubEvent,
      {super.key,
      this.viewWidth,
      this.spaceBetween = 4.7,
      this.isInit = false,
      this.allowRightMargin = true,
      required this.userType,
      required this.locationDetails});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClubEventCardViewDisplay();
}

class _ClubEventCardViewDisplay extends ConsumerState<ClubEventCardViewDisplay> {

  // late String timeZone;

  @override
  void initState() {
    super.initState();
    // timeZone = userCurrentTimeZone.last;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed("/event_details", arguments: widget.clubEvent);
      },
      onLongPress: () async {
        if(widget.userType == "user") {
          return;
        }
        await showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheetMultipleResponses(
              imageName: "",
              title: "Remove Club Event?",
              subtitle: "Are you sure you want to remove this event?",
              buttonTitle: "Yes, Remove",
              cancelTitle: "Cancel",
              onPress: () async {
                await ref.read(clubEventNotifierProvider.notifier).deleteClubEvent(widget.clubEvent);
                Navigator.of(context).pop();
                GeneralUtils.showToast("Event deleted!");
              },
              titleStyle: subHeadingStyle.copyWith(
                  fontWeight: FontWeight.w700, color: AppColors.secondaryBase));
        },
        isDismissible: false,
        showDragHandle: true,
        enableDrag: false);
      },
      child: Container(
        width: widget.viewWidth ?? (MediaQuery.of(context).size.width - 48) / 1.5,
        padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 12),
        margin: EdgeInsets.only(
            right: widget.allowRightMargin ? 24.0 : 0,
            top: widget.isInit ? 0 : 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(
            color: AppColors.grey200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  fit: BoxFit.fitWidth,
                  height: 180.0,
                  // width: (MediaQuery.of(context).size.width - 66) / 1.5,
                  imageUrl: widget.clubEvent.images[0]["url"],
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  imageBuilder: (c, i) {
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          image: DecorationImage(image: i, fit: BoxFit.cover)),
                    );
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: SvgPicture.asset("assets/svg/adult.svg"),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              widget.clubEvent.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: titleStyle.copyWith(
                  fontWeight: FontWeight.w700, color: AppColors.grey900),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SvgPicture.asset("assets/svg/navigation/event.svg"),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  getFormattedDate(widget.clubEvent.eventDate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: captionStyle.copyWith(
                      fontWeight: FontWeight.w400, color: AppColors.grey900),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset("assets/svg/location.svg"),
                    const SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      width: widget.userType == "club_owner"
                          ? null
                          : MediaQuery.of(context).size.width / widget.spaceBetween!,
                      child: Text(
                        widget.clubEvent.clubName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: captionStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey900),
                      ),
                    )
                  ],
                ),
                widget.userType == "club_owner"
                    ? const SizedBox()
                    : Text(
                  getDistanceAway(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: captionStyle.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey900),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  String getFormattedDate(String date) {
    final dateMonths = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    // DateTime evtDate = DateTime.parse(date);
    final mDate = GeneralUtils().getConvertedDateTime(date, widget.clubEvent.timeZone);
    DateTime evtDate = DateTime.parse(mDate);
    int day = evtDate.day;
    String month = dateMonths[evtDate.month - 1];
    int year = evtDate.year;
    int hour = evtDate.hour == 0 ? 12 : evtDate.hour > 12 ? evtDate.hour - 12 : evtDate.hour;
    int min = evtDate.minute;
    String period = evtDate.hour >= 12 ? "pm" : "am";
    return "$day $month, $year ${GeneralUtils().rewriteTimeValue(hour)}:${GeneralUtils().rewriteTimeValue(min)} $period";
  }

  String getDistanceAway() {
    String address = widget.locationDetails["address"];

    double distanceBetweenInKm =
        GeoFirePoint(widget.locationDetails["position"]["geopoint"])
            .distanceBetweenInKm(
                geopoint: widget.clubEvent.locationDetails["position"]
                    ["geopoint"]);

    if (address.toLowerCase().contains("usa") ||
        address.toLowerCase().contains("united states")) {
      double toMiles = distanceBetweenInKm / 1.609;
      return "${toMiles.ceil()}Miles Away";
    }

    return "${distanceBetweenInKm.ceil()}Km Away";
  }
}
