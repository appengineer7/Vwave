
import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vwave_new/presentation/club/models/club.dart';
import 'package:vwave_new/presentation/events/models/club_event.dart';
import 'package:vwave_new/utils/general.dart';

import '../../../constants.dart';
import '../../../utils/storage.dart';
import '../../../widgets/nav_back_button.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';

class EventDetailsPage extends ConsumerStatefulWidget {
  final ClubEvent clubEvent;
  const EventDetailsPage(this.clubEvent, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends ConsumerState<EventDetailsPage> {

  // late String timeZone;
  bool eventReminded = false;

  StorageSystem ss = StorageSystem();

  String userType = "";

  Club? club;

  @override
  void initState() {
    super.initState();
    // timeZone = userCurrentTimeZone.last;
    Future.delayed(Duration.zero, () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if(!mounted) return;
      setState(() {
        userType = prefs.getString("user_type") ?? "user";
      });
      String? isEventReminded = await ss.getItem("event_${widget.clubEvent.id}");
      if(!mounted) return;
      setState(() {
        eventReminded = isEventReminded == "true";
      });
    });
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
        title: Text("Event Details", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: GestureDetector(
                child: SvgPicture.asset("assets/svg/share.svg"),
                onTap: () {
                  String body =
                      "Check out this club event by clicking on this link.\n\n${widget.clubEvent.link}";
                  Share.share(body);
                },
              ))
        ],
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
                coverImageSection(),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  title: Text(
                    widget.clubEvent.title,
                    textAlign: TextAlign.start,
                    style: subHeadingStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                        fontSize: 20
                    ),
                  ),
                  subtitle: (userType == "club_owner") ? null : Row(
                    children: [
                      SizedBox(
                        height: 20,
                        child: TextButton.icon(
                          onPressed: () async {
                            if(club == null) {
                              final getClub = await FirebaseFirestore.instance
                                  .collection("clubs").doc(
                                  widget.clubEvent.clubId).get();
                              if (!getClub.exists) {
                                return;
                              }
                              club = Club.fromDocument(getClub);
                              Navigator.of(context).pushNamed("/club_details",
                                  arguments: Club.fromDocument(getClub));
                              return;
                            }
                            Navigator.of(context).pushNamed("/club_details",
                                arguments: club);
                          },
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                          ),
                          label: Text(widget.clubEvent.clubName,
                              textAlign: TextAlign.start,
                              style: captionStyle.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey900,
                              )),
                          icon: const Icon(Icons.arrow_circle_right_outlined, size: 18,), iconAlignment: IconAlignment.end,
                        ),
                      )
                    ],
                  )
                ),
                const SizedBox(height: 10,),
                Text(
                  widget.clubEvent.description,
                  textAlign: TextAlign.start,
                  style: captionStyle.copyWith(
                    fontWeight: FontWeight.w400,height: 1,
                    color: AppColors.grey900,
                  ),
                ),
                SizedBox(height: widget.clubEvent.description.isEmpty ? 0 : 20,),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.dividerColor.withOpacity(0), AppColors.dividerColor.withOpacity(0.2), AppColors.dividerColor.withOpacity(0)], stops: const [0,0.5,1],begin: Alignment.centerLeft, end: Alignment.centerRight)
                  ),
                ),
                const SizedBox(height: 20,),
                ListTile(
                  leading: SvgPicture.asset("assets/svg/calendar.svg", height: 32),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  title: Text(
                    formatEventDate(),
                    textAlign: TextAlign.start,
                    style: bodyStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey900,
                    ),
                  ),
                  subtitle: Text(
                    formatEventDateTime(),
                    textAlign: TextAlign.start,
                    style: captionStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey900,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      if(eventReminded) {
                        addToCalendar();
                        return;
                      }
                      await FirebaseMessaging.instance.subscribeToTopic("notification_event_${widget.clubEvent.id}");
                      await ss.setPrefItem("event_${widget.clubEvent.id}", "true");
                      GeneralUtils.showToast("Reminder notification turned on.");
                      if(!mounted) return;
                      setState(() {
                        eventReminded = true;
                      });
                    },
                    child: Text(eventReminded ? "Add to calendar" : "I'm interested", style: bodyStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      color: eventReminded ? AppColors.primaryBase : AppColors.secondaryBase,
                    ),),
                  ),
                ),
                ListTile(
                  leading: SvgPicture.asset("assets/svg/location_circle.svg", height: 32,),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  title: Text(
                    widget.clubEvent.locationDetails["address"],
                    textAlign: TextAlign.start,
                    style: bodyStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey900,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          MapsLauncher.launchCoordinates(widget.clubEvent.locationDetails["latitude"], widget.clubEvent.locationDetails["longitude"]);
                        },
                        child: SizedBox(
                          width: 190,
                          child: Wrap(
                            children: [
                              Chip(label: Row(children: [
                                SvgPicture.asset("assets/svg/map_pin.svg", color: Colors.white,),
                                const SizedBox(width: 5,),
                                Text("See location on maps", maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: captionStyle.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                              ],),
                                backgroundColor: AppColors.primaryBase,
                                side: BorderSide.none,
                                padding: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.dividerColor.withOpacity(0), AppColors.dividerColor.withOpacity(0.2), AppColors.dividerColor.withOpacity(0)], stops: const [0,0.5,1],begin: Alignment.centerLeft, end: Alignment.centerRight)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addToCalendar() {
    final date = GeneralUtils().getConvertedDateTime(widget.clubEvent.eventDate, widget.clubEvent.timeZone);
    DateTime evtDate = DateTime.parse(date);

    final Event event = Event(
      title: "${widget.clubEvent.clubName}: ${widget.clubEvent.title}",
      description: "${widget.clubEvent.description}\n\nLocation: ${widget.clubEvent.locationDetails["address"]}",
      location: Platform.isAndroid ? "${widget.clubEvent.locationDetails["address"]}" : null,
      startDate: evtDate,
      endDate: evtDate.add(const Duration(hours: 8)),
      iosParams: IOSParams(
        reminder: const Duration(hours: 1), // on iOS, you can set alarm notification after your event.
        url: widget.clubEvent.link, // on iOS, you can set url to your event.
      ),
      androidParams: const AndroidParams(
        emailInvites: [], // on Android, you can add invite emails to your event.
      ),
    );
    Add2Calendar.addEvent2Cal(event);
  }

  String formatEventDate() {
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
    final date = GeneralUtils().getConvertedDateTime(widget.clubEvent.eventDate, widget.clubEvent.timeZone);
    DateTime evtDate = DateTime.parse(date);
    int day = evtDate.day;
    String month = dateMonths[evtDate.month - 1];
    int year = evtDate.year;
    return "$day $month, $year";
  }

  String formatEventDateTime() {
    final date = GeneralUtils().getConvertedDateTime(widget.clubEvent.eventDate, widget.clubEvent.timeZone);
    DateTime evtDate = DateTime.parse(date);
    int hour = evtDate.hour == 0 ? 12 : evtDate.hour > 12 ? evtDate.hour - 12 : evtDate.hour;
    int min = evtDate.minute;
    String period = evtDate.hour >= 12 ? "PM" : "AM";
    return "${GeneralUtils().rewriteTimeValue(hour)}:${GeneralUtils().rewriteTimeValue(min)} $period";
  }

  Widget coverImageSection() {
    return Stack(
      children: [
        CachedNetworkImage(
          fit: BoxFit.fitWidth,
          height: 230.0,
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
    );
  }
}