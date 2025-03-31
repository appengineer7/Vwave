import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/presentation/events/models/club_event.dart';
import 'package:vwave/presentation/events/providers/club_event_notifier_provider.dart';

import '../../../common/providers/firebase.dart';
import '../../../services/dynamic_link.dart';
import '../../../utils/general.dart';
import '../../../utils/storage.dart';
import '../../../utils/validators.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../widgets/nav_back_button.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../../widgets/upload_dialog_view.dart';
import '../../club/models/club.dart';

class CreateEventPage extends ConsumerStatefulWidget {
  const CreateEventPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateEventPageState();
}

class _CreateEventPageState extends ConsumerState<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();

  String? userLocation;
  String clubName = "";
  Map<String, dynamic> userLocationDetails = {};
  Map<String, dynamic> eventImage = {};

  DateTime eventDateTime = DateTime.now();

  StorageSystem ss = StorageSystem();
  List<dynamic> coverImages = [];

  Future<void> getUserData() async {
    String? user = await ss.getItem("user");
    String? club = await ss.getItem("club");
    if (user == null) {
      return;
    }
    if (club == null) {
      return;
    }
    Map<String, dynamic> userData = jsonDecode(user);
    Map<String, dynamic> clubData = jsonDecode(club);
    if (!mounted) return;
    setState(() {
      clubName = clubData["club_name"] ?? "";
      if (userData["location_details"] != null) {
        if (userData["location_details"]["address"] == null) {
          return;
        }
        userLocation = userData["location"];
        userLocationDetails =
            GeneralUtils().getLocationDetailsData(userData["location_details"]);
      }
    });
    // print("Club name is $clubName");
  }

  Future<void> getUserClubData() async {
    String? getUserClub = (await ss.getItem("club"));
    if (getUserClub == null) {
      return;
    }
    Map<String, dynamic> clubDetails = jsonDecode(getUserClub);
    clubDetails["user_uid"] = GeneralUtils().userUid;
    clubDetails["total_reviews"] = 0;
    clubDetails["rating_count"] = 0;
    final club = Club.fromJson(clubDetails);
    coverImages = club.coverImages;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _eventDateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    getUserClubData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Create Events",
          style: titleStyle.copyWith(
              color: AppColors.grey900, fontWeight: FontWeight.w700),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: NavBackButton(
            color: AppColors.titleTextColor,
            onPress: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello 👋, $clubName",
                            style: subHeadingStyle.copyWith(
                                color: AppColors.grey900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Let your followers know about your upcoming events.",
                            style: bodyStyle.copyWith(color: AppColors.grey700),
                          ),
                          const SizedBox(height: 30),
                          CustomInputField(
                            labelText: "Event Title",
                            controller: _titleController,
                            validator: textValidator,
                            autofocus: false,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          containerWrapper(
                            height: 140,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              controller: _descriptionController,
                              maxLines: 10,
                              minLines: 3,
                              maxLength: 600,
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: (t) {
                                setState(() {});
                              },
                              maxLengthEnforcement: MaxLengthEnforcement
                                  .truncateAfterCompositionEnds,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter event description (optional)",
                                hintStyle: titleStyle.copyWith(
                                    color: AppColors.grey400,
                                    fontWeight: FontWeight.w400),
                                labelStyle: titleStyle.copyWith(
                                  color: AppColors.titleTextColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: showDateTimePicker,
                            child: CustomInputField(
                              labelText: "Event Date & Time",
                              controller: _eventDateController,
                              enableField: false,
                              validator: textValidator,
                              autofocus: false,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          UploadDialogView(
                              uploadMessageText:
                                  "Tap to upload an image (optional)",
                              uploadMessageBodyText:
                                  "PNG, JPG, or JPEG (max. 1920x1080px)",
                              allowedExtensions: "jpg,jpeg,png",
                              allowCropAndCompress: true,
                              folderName: "events-images",
                              onUploadDone: (fileUpload) {
                                if (fileUpload.isNotEmpty) {
                                  eventImage = fileUpload;
                                }
                              }),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Column(
                        children: [
                          ActionButton(
                            loading: loading,
                            text: "Create Event",
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                submitCreateEvent();
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Future<void> showDateTimePicker() async {
    DateTime? getDate = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        initialDate: DateTime.now(),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light(),
            child: child!,
          );
        });
    if (getDate == null) return;
    TimeOfDay? getTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        cancelText: "Cancel",
        confirmText: "Set Time",
        builder: (context, child) {
          return Theme(
            data: ThemeData.light(),
            child: child!,
          );
        });
    if (getTime == null) return;
    final today = DateTime.now();
    final eventDate = DateTime.parse(
        "${getDate.toString().split(" ")[0]} ${GeneralUtils().returnFormattedNumber(getTime.hour)}:${GeneralUtils().returnFormattedNumber(getTime.minute)}:00.000");
    if (eventDate.isBefore(today)) {
      GeneralUtils.showToast("Select a future date");
      return;
    }
    setState(() {
      eventDateTime = eventDate;
      _eventDateController.text =
          "${getDate.toString().split(" ")[0]} ${GeneralUtils().returnFormattedNumber(getTime.hourOfPeriod)}:${GeneralUtils().returnFormattedNumber(getTime.minute)} ${getTime.period.name}";
    });
  }

  Widget containerWrapper(
      {required Widget child,
      double height = 60,
      required EdgeInsets padding}) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: AppColors.grey400,
            )),
        child: child);
  }

  Future<void> submitCreateEvent() async {
    if (coverImages.isEmpty) {
      if (eventImage.isEmpty) {
        GeneralUtils.showToast("Upload the livestream image");
        return;
      }
    }

    setState(() {
      loading = true;
    });

    try {
      String title = _titleController.text.trim();
      String description = _descriptionController.text.trim();

      String timeZone = await GeneralUtils().currentTimeZone();

      String key = ref
          .read(firebaseFirestoreProvider)
          .collection("club_events")
          .doc()
          .id;
      Map<String, dynamic> ld = {
        "address": userLocationDetails["address"] ?? "",
        "latitude": userLocationDetails["latitude"] ?? 0,
        "longitude": userLocationDetails["longitude"] ?? 0,
      };

      final lv = {
        "id": key,
        "user_uid": GeneralUtils().userUid ?? "",
        "club_id": GeneralUtils().userUid ?? "",
        "title": title,
        "description": description,
        "club_name": clubName,
        "link": "",
        "created_timestamp": "",
        "event_date_timestamp": "",
        "event_date": eventDateTime.toString(),
        "time_zone": timeZone,
        "location_details": ld,
        "images": [eventImage.isEmpty ? coverImages.first : eventImage],
        "created_date": DateTime.now().toString(),
        "modified_date": DateTime.now().toString(),
      };

      // create dynamic link
      final dynamicLinkData = GeneralUtils().encodeValue(jsonEncode(lv));
      String dynamicLink = await WaveDynamicLink.createDynamicLink(
          key,
          _titleController.text,
          "$clubName is having a live event on the VWave app. Open to view details.",
          (eventImage.isEmpty ? coverImages.first["url"] : eventImage["url"]),
          "event",
          dynamicLinkData);

      final clubEvent = ClubEvent(
          id: key,
          userUid: GeneralUtils().userUid ?? "",
          clubId: GeneralUtils().userUid ?? "",
          title: title,
          description: description,
          clubName: clubName,
          link: dynamicLink,
          eventDate: eventDateTime.toString(),
          createdTimestamp: FieldValue.serverTimestamp(),
          eventDateTimestamp: Timestamp.fromDate(eventDateTime),
          timeZone: timeZone,
          locationDetails: userLocationDetails,
          images: [eventImage.isEmpty ? coverImages.first : eventImage],
          createdDate: DateTime.now().toString(),
          modifiedDate: DateTime.now().toString());

      await ref
          .read(firebaseFirestoreProvider)
          .collection("club_events")
          .doc(key)
          .set(clubEvent.toJson());
      await Future.delayed(Duration.zero, (){
        final getUpcomingEvents = ref.read(clubEventNotifierProvider).upcomingEvents;
        List<ClubEvent> listEvents = List.from(getUpcomingEvents);
        listEvents.add(clubEvent);
        ref.read(clubEventNotifierProvider.notifier).setUpcomingEvents(listEvents);
      });
      setState(() {
        loading = false;
      });
      GeneralUtils.showToast("Event created!");
      Navigator.of(context).pushReplacementNamed("/event_details", arguments: clubEvent);
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
      GeneralUtils.showToast("An error occurred. Try again.");
    }
  }
}
