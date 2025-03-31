import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:intl_phone_field2/country_picker_dialog.dart';
import 'package:intl_phone_field2/intl_phone_field.dart';
import 'package:intl_phone_field2/phone_number.dart';
import 'package:vwave/widgets/action_button.dart';

import '../../../../common/providers/firebase.dart';
import '../../../../constants.dart';
import '../../../../library/google_autocomplete_places.dart';
import '../../../../services/dynamic_link.dart';
import '../../../../utils/general.dart';
import '../../../../utils/storage.dart';
import '../../../../utils/validators.dart';
import '../../../../widgets/bottom_sheet_multiple_responses.dart';
import '../../../../widgets/custom_input_field.dart';
import '../../../../widgets/nav_back_button.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../../../../widgets/upload_dialog_view.dart';
import '../../../club/models/club.dart';

class ClubOwnerAccountSetupPage extends ConsumerStatefulWidget {
  const ClubOwnerAccountSetupPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ClubOwnerAccountSetupPageState();
}

class _ClubOwnerAccountSetupPageState
    extends ConsumerState<ClubOwnerAccountSetupPage> {
  final _formKey = GlobalKey<FormState>();
  List<dynamic> coverImages = [];
  List<dynamic> galleryImages = [];

  StorageSystem ss = StorageSystem();

  bool isLoading = false;
  bool isAccountSetup = false;
  double locationLatitude = 0, locationLongitude = 0;
  Prediction? locationDetail;

  String? userLocation;
  String? userLocationMainText;
  String? userLocationSecondaryText;
  String? userInitialCountryCode = "US";
  // Map<String, dynamic> userLocationDetails = {};
  Map<String, dynamic> userData = {};

  String openingTimes = "", openingDays = "";

  String selectionOption1 = "", selectionOption2 = "";

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late PhoneNumber phoneNumber;

  // Map<String, dynamic> userClubDetails = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      bool acctSetup = await GeneralUtils().isClubOwnerAccountVerified();
      setState(() {
        isAccountSetup = acctSetup;
      });
      await getUserData();
      await getUserClubData();
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _clubNameController.dispose();
    _phoneNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> getUserData() async {
    String? user = await ss.getItem("user");
    if (user == null) {
      return;
    }
    Map<String, dynamic>? userData = jsonDecode(user);
    if (!mounted) return;
    this.userData = userData ?? {};
    setState(() {
      if (userData!["location_details"] != null) {
        if (userData["location_details"]["address"] == null) {
          return;
        }
        userLocation = userData["location"];
        // userLocationDetails = GeneralUtils().getLocationDetailsData(userData["location_details"]);
        // _locationController.text = userLocationDetails["address"];
        // locationLatitude = userLocationDetails["latitude"];
        // locationLongitude = userLocationDetails["longitude"];
      }
    });
  }

  Future<void> getUserClubData() async {
    String? getUserClub = (await ss.getItem("club"));
    if (getUserClub == null) {
      return;
    }
    Map<String, dynamic> clubDetails = jsonDecode(getUserClub);
    // print("Club name is $clubDetails");
    clubDetails["user_uid"] = GeneralUtils().userUid;
    clubDetails["total_reviews"] = 0;
    clubDetails["rating_count"] = 0;
    final club = Club.fromJson(clubDetails);
    for (var images in club.coverImages) {
      coverImages.add(images);
    }
    for (var images in club.gallery) {
      galleryImages.add(images);
    }
    setState(() {
      _locationController.text = club.locationDetails["address"];
      locationLatitude = club.locationDetails["latitude"];
      locationLongitude = club.locationDetails["longitude"];
      _countryController.text = club.country;
      _stateController.text = club.state;
      _clubNameController.text = club.clubName;
      _phoneNumberController.text = club.phoneNumber["number"];
      _descriptionController.text = club.description;
      userInitialCountryCode = club.phoneNumber["country_ISOCode"];

      phoneNumber = PhoneNumber.fromCompleteNumber(
          completeNumber: club.phoneNumber["complete_number"]);
      openingTimes = club.openingTimes;
      openingDays = club.openingDays;
      userLocationMainText = club.location["main_text"];
      userLocationSecondaryText = club.location["secondary_text"];
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(coverImages);
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
        title: Text(
          "Account Setup",
          style: titleStyle.copyWith(
              color: AppColors.grey900, fontWeight: FontWeight.w700),
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
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UploadDialogView(
                          allowCropAndCompress: true,
                          uploadMessageText: "Tap to upload cover images",
                          uploadMessageBodyText:
                              "PNG, JPG, or JPEG (max. 1920x1080px)",
                          allowedExtensions: "jpg,jpeg,gif,png",
                          folderName: "cover-images",
                          autoRestart: true,
                          onUploadDone: (fileUpload) {
                            setState(() {
                              if (fileUpload.isNotEmpty) {
                                coverImages.add(fileUpload);
                              }
                            });
                            print(coverImages);
                          }),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          previewImageLayout(
                              false,
                              coverImages.isNotEmpty ? coverImages[0] : {},
                              "cover", true),
                          previewImageLayout(
                              false,
                              coverImages.length >= 2 ? coverImages[1] : {},
                              "cover", true),
                          previewImageLayout(
                              true,
                              coverImages.length == 3 ? coverImages[2] : {},
                              "cover", true),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                              AppColors.dividerColor.withOpacity(0),
                              AppColors.dividerColor.withOpacity(0.2),
                              AppColors.dividerColor.withOpacity(0)
                            ],
                                stops: const [
                              0,
                              0.5,
                              1
                            ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight)),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Club Details",
                        textAlign: TextAlign.start,
                        style: titleStyle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomInputField(
                        labelText: "Club Name",
                        controller: _clubNameController,
                        obscureText: false,
                        validator: textValidator,
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {displayOpeningDialog("days");},
                        child: containerWrapper(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Text(
                              openingDays.isNotEmpty
                                  ? openingDays
                                  : "Select Opening Days",
                              style: bodyStyle.copyWith(
                                color: AppColors.grey500,
                              ),
                            )),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {displayOpeningDialog("times");},
                        child: containerWrapper(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Text(
                              openingTimes.isNotEmpty
                                  ? openingTimes
                                  : "Select Opening Times",
                              style: bodyStyle.copyWith(
                                color: AppColors.grey500,
                              ),
                            )),
                      ),
                      const SizedBox(height: 10),
                      GooglePlaceAutoCompleteTextField(
                        textEditingController: _locationController,
                        googleAPIKey: googleApiKey,
                        inputDecoration: InputDecoration(
                            alignLabelWithHint: true,
                            // focusedBorder: OutlineInputBorder(
                            //   borderRadius: BorderRadius.circular(8.0),
                            //   borderSide: const BorderSide(
                            //     color: AppColors.grey400,
                            //   ),
                            // ),
                            labelText: "Address",
                            labelStyle: titleStyle.copyWith(
                              color: AppColors.grey500,
                            ),
                            filled: true,
                            hintText: "Type your address",
                            hintStyle: captionStyle.copyWith(
                              color: AppColors.grey500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: AppColors.grey400,
                              ),
                            ),
                            fillColor: Colors.white,
                            floatingLabelBehavior: FloatingLabelBehavior.never),
                        debounceTime: 800, // default 600 ms,
                        // countries: const [
                        //   "us",
                        // ], // optional by default null is set
                        isLatLngRequired:
                            true, // if you required coordinates from place detail
                        getPlaceDetailWithLatLng: (Prediction prediction) {
                          locationLatitude = double.parse(prediction.lat!);
                          locationLongitude = double.parse(prediction.lng!);
                          // this method will return latlng with place detail
                          // print("placeDetails" + prediction.lng.toString());
                        }, // this callback is called when isLatLngRequired is true
                        itemClick: (Prediction prediction) {
                          _locationController.text = prediction.description!;
                          _locationController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: prediction.description!.length));
                          locationDetail = prediction;
                          _stateController.text = prediction.structuredFormatting!.secondaryText!.split(",").length == 2 ? prediction
                              .structuredFormatting!.secondaryText!
                              .split(",").first : prediction
                              .structuredFormatting!.secondaryText!
                              .split(",").elementAt(prediction
                              .structuredFormatting!.secondaryText!
                              .split(",").length - 2);
                          _countryController.text = prediction
                              .structuredFormatting!.secondaryText!
                              .split(",")
                              .last;
                          userLocationMainText =
                              prediction.structuredFormatting!.mainText;
                          userLocationSecondaryText =
                              prediction.structuredFormatting!.secondaryText;
                        },
                        // if we want to make custom list item builder
                        itemBuilder: (context, index, Prediction prediction) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                // const Icon(Icons.location_on),
                                SvgPicture.asset(
                                    "assets/svg/location_gray.svg"),
                                const SizedBox(
                                  width: 7,
                                ),
                                Expanded(
                                    child: Text(prediction.description ?? ""))
                              ],
                            ),
                          );
                        },
                        // if you want to add seperator between list items
                        seperatedBuilder: const Divider(),
                        // want to show close icon
                        isCrossBtnShown: true,
                        showError: true,
                        // boxDecoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(8.0),
                        //     border: Border.all(
                        //       color: AppColors.grey400,
                        //     )
                        // ),
                      ),
                      const SizedBox(height: 10),
                      CustomInputField(
                        labelText: "State",
                        controller: _stateController,
                        obscureText: false,
                        validator: textValidator,
                      ),
                      const SizedBox(height: 10),
                      CustomInputField(
                        labelText: "Country",
                        controller: _countryController,
                        obscureText: false,
                        validator: textValidator,
                      ),
                      const SizedBox(height: 10),
                      containerWrapper(
                        height: 60,
                        padding: const EdgeInsets.only(left: 12, top: 8),
                        child: IntlPhoneField(
                          pickerDialogStyle: PickerDialogStyle(
                            width: MediaQuery.of(context).size.width,
                          ),
                          positionedPopup: false,
                          disableLengthCheck: true,
                          textFieldIsDense: true,
                          prefixHeight: 10,
                          flagWidth: 20,
                          textFieldPadding: const EdgeInsets.all(0),
                          autovalidateMode: AutovalidateMode.disabled,
                          popupWidth: MediaQuery.sizeOf(context).width,
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelStyle: bodyStyle.copyWith(
                              color: AppColors.grey500,
                            ),
                            hintText: "Phone Number",
                            hintStyle: bodyStyle.copyWith(
                              color: AppColors.grey500,
                            ),
                            fillColor: Colors.white,
                          ),
                          languageCode: "en",
                          initialCountryCode: userInitialCountryCode,
                          onChanged: (phone) {},
                          onCountryChanged: (country) {},
                          onSaved: (n) {
                            phoneNumber = n!;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      containerWrapper(
                        height: 140,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          controller: _descriptionController,
                          validator: textValidator,
                          maxLines: 10,
                          minLines: 3,
                          maxLength: 600,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (t) {
                            setState(() {});
                          },
                          maxLengthEnforcement:
                              MaxLengthEnforcement.truncateAfterCompositionEnds,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "In a few sentences, describe your club",
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
                      const SizedBox(height: 40),
                      UploadDialogView(
                          allowCropAndCompress: true,
                          allowImagesAndVideos: true,
                          uploadMessageText: "Tap to upload gallery images or videos",
                          uploadMessageBodyText:
                              "PNG, JPG, MP4, or JPEG",
                          allowedExtensions: "jpg,jpeg,gif,png,mp4,mov,avi",
                          folderName: "gallery", //cover-images
                          autoRestart: true,
                          onUploadDone: (fileUpload) {
                            setState(() {
                              if (fileUpload.isNotEmpty) {
                                galleryImages.add(fileUpload);
                              }
                            });
                          }),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 70.0,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: galleryImages
                              .map((e) =>
                                  previewImageLayout(false, e, "gallery", true))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ActionButton(
                          text: "Save",
                          loading: isLoading,
                          onPressed: () async {
                            try {
                              _formKey.currentState!.save();

                              if (coverImages.isEmpty) {
                                displaySnackBarErrorMessage(
                                    "Please add at least one cover image");
                                return;
                              }
                              if (galleryImages.isEmpty) {
                                displaySnackBarErrorMessage(
                                    "Please add at least one gallery image");
                                return;
                              }
                              if (openingTimes.isEmpty || openingDays.isEmpty) {
                                displaySnackBarErrorMessage(
                                    "Enter your opening days and times");
                                return;
                              }

                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });

                                String clubName =
                                    _clubNameController.text.trim();
                                String address =
                                    _locationController.text.trim();
                                String state = _stateController.text.trim();
                                String country = _countryController.text.trim();
                                String description =
                                    _descriptionController.text.trim();
                                if (!phoneNumber.isValidNumber()) {
                                  displaySnackBarErrorMessage(
                                      "Phone number is not valid");
                                  return;
                                }

                                Map<String, dynamic> pn = {
                                  "complete_number": phoneNumber.completeNumber,
                                  "country_code": phoneNumber.countryCode,
                                  "country_ISOCode": phoneNumber.countryISOCode,
                                  "number": phoneNumber.number,
                                  "valid": phoneNumber.isValidNumber(),
                                };

                                Map<String, dynamic> ld = {
                                  "address": address,
                                  "latitude": locationLatitude,
                                  "longitude": locationLongitude,
                                };

                                Map<String, dynamic> loc = {
                                  "main_text": userLocationMainText ?? "",
                                  "secondary_text":
                                      userLocationSecondaryText ?? "",
                                };

                                Map<String, dynamic> cd = {
                                  "id": GeneralUtils().userUid,
                                  "user_uid": GeneralUtils().userUid,
                                  "club_name": clubName,
                                  "opening_days": openingDays,
                                  "opening_times": openingTimes,
                                  "phone_number": pn,
                                  "link": "",
                                  "description": description,
                                  "country": country,
                                  "state": state,
                                  "location": loc,
                                  "total_reviews": 0,
                                  "rating_count": 0,
                                  "total_rating": 0,
                                  "rating_count_object": {
                                    "1": 0,
                                    "2": 0,
                                    "3": 0,
                                    "4": 0,
                                    "5": 0,
                                  },
                                  "gallery": galleryImages,
                                  "cover_images": coverImages,
                                  "recent_reviews": [],
                                  "msgId": userData["msgId"],
                                  "email": userData["email"],
                                  "location_details": ld,
                                  "timestamp": "",
                                  "verified": false,
                                  "created_date": DateTime.now().toString(),
                                  "modified_date": DateTime.now().toString(),
                                };

                                Map<String, dynamic> locDetails = {
                                  "address": address,
                                  "latitude": locationLatitude,
                                  "longitude": locationLongitude,
                                  "position": {
                                    "geohash": GeneralUtils().encodeGeoHash(
                                        locationLatitude, locationLongitude, 9),
                                    "geopoint": GeoPoint(
                                        locationLatitude, locationLongitude)
                                  }
                                };

                                // create dynamic link
                                final dynamicLinkData = GeneralUtils()
                                    .encodeValue(jsonEncode(cd));
                                String dynamicLink =
                                await WaveDynamicLink.createDynamicLink(
                                    cd["id"],
                                    clubName,
                                    description,
                                    coverImages.first["url"],
                                    "club",
                                    dynamicLinkData);

                                if (isAccountSetup) {
                                  final updateClubDetails = {
                                    "club_name": clubName,
                                    "opening_days": openingDays,
                                    "opening_times": openingTimes,
                                    "phone_number": pn,
                                    "description": description,
                                    "country": country,
                                    "state": state,
                                    "location": loc,
                                    "location_details": locDetails,
                                    "gallery": galleryImages,
                                    "cover_images": coverImages,
                                    "link": dynamicLink,
                                    "modified_date": DateTime.now().toString()
                                  };
                                  await ref
                                      .read(firebaseFirestoreProvider)
                                      .collection("clubs")
                                      .doc(GeneralUtils().userUid)
                                      .update(updateClubDetails);
                                } else {

                                  final clubDetails = Club(
                                      id: GeneralUtils().userUid,
                                      userUid: GeneralUtils().userUid ?? "",
                                      clubName: clubName,
                                      openingDays: openingDays,
                                      openingTimes: openingTimes,
                                      phoneNumber: pn,
                                      link: dynamicLink,
                                      description: description,
                                      country: country,
                                      state: state,
                                      location: loc,
                                      locationDetails: locDetails,
                                      totalReviews: 0,
                                      totalRating: 0,
                                      ratingCount: 0,
                                      ratingCountObject: {
                                        "1": 0,
                                        "2": 0,
                                        "3": 0,
                                        "4": 0,
                                        "5": 0,
                                      },
                                      gallery: galleryImages,
                                      recentReviews: [],
                                      coverImages: coverImages,
                                      msgId: userData["msgId"],
                                      email: userData["email"],
                                      verified: false,
                                      timestamp: FieldValue.serverTimestamp(),
                                      createdDate: DateTime.now().toString(),
                                      modifiedDate: DateTime.now().toString());
                                  await ref
                                      .read(firebaseFirestoreProvider)
                                      .collection("clubs")
                                      .doc(clubDetails.userUid)
                                      .set(clubDetails.toJson());
                                }

                                await ref
                                    .read(firebaseFirestoreProvider)
                                    .collection("users")
                                    .doc(GeneralUtils().userUid)
                                    .update({
                                  "account_setup": true,
                                  // "verified": true,
                                  "location": _locationController.text
                                              .split(",")
                                              .length ==
                                          4
                                      ? _locationController.text.split(",")[1]
                                      : _locationController.text.split(",")[0],
                                  "location_details": locDetails,
                                  "modified_date": DateTime.now().toString(),
                                });
                                // update local data
                                await updateLocalData(cd, clubName);
                                setState(() {
                                  isLoading = false;
                                });
                                GeneralUtils().showResponseBottomSheet(
                                    context,
                                    "success",
                                    "Success",
                                    "Changes saved successfully",
                                    "Done", () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                });
                              }
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              displaySnackBarErrorMessage("$e");
                            }
                          })
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }

  Widget containerWrapper({required Widget child, double height = 60, required EdgeInsets padding}) {
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

  Widget previewImageLayout(bool lastItem, Map<String, dynamic> item, String type, bool allowTap) {
    return GestureDetector(
      onTap: () async {
        if(!allowTap) {
          return;
        }
        if(type == "cover") {
          if(coverImages.isEmpty || item.isEmpty) {
            return;
          }
        }
        if(type == "gallery") {
          if(galleryImages.isEmpty) {
            return;
          }
        }
        await showModalBottomSheet(
            context: context,
            builder: (context) {
              return BottomSheetMultipleResponses(
                  imageName: "",
                  title: item["fileType"] == "video" ? "Delete Video Item" :  "Delete Image Item",
                  subtitle: "Are you sure you want to delete the ${item["fileType"] == "video" ? "video" : "image"}?",
                  buttonTitle: "Yes, Delete",
                  cancelTitle: "No",
                  onPress: () async {
                    setState(() {
                      if (type == "cover") {
                        coverImages.remove(item);
                      }
                      if (type == "gallery") {
                        galleryImages.remove(item);
                      }
                    });
                    Navigator.of(context).pop();
                  },
                  titleStyle: subHeadingStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryBase));
            },
            isDismissible: false,
            showDragHandle: true,
            enableDrag: false);
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 98) / 3,
        height: 70.0,
        margin: EdgeInsets.only(right: lastItem ? 0 : 20),
        decoration: item.isEmpty
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey400))
            : BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                    image: NetworkImage(item["fileType"] == "video" ? item["thumbnailUrl"] : item["url"]), fit: BoxFit.fitWidth)),
        child: Center(
          child: item.isEmpty
              ? SvgPicture.asset("assets/svg/plus_sign.svg")
              : allowTap ? SvgPicture.asset("assets/svg/delete.svg") : const SizedBox(),
        ),
      ),
    );
  }

  Future<void> displayOpeningDialog(String tag) async {
    List<String> days = ["Sundays", "Mondays", "Tuesdays","Wednesdays","Thursdays","Fridays","Saturdays"];
    List<String> times = ["12AM","1AM","2AM","3AM","4AM","5AM","6AM","7AM","8AM","9AM","10AM","11AM","12PM","1PM","2PM","3PM","4PM","5PM","6PM","7PM","8PM","9PM","10PM","11PM"];

    List<String> list = tag == "days" ? days : times;

    await showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, StateSetter setState) {
        return Container(
          height: 500,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tag == "days" ? "Opening Days" : "Opening Times",
                        style: titleStyle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                ),
                const Divider(
                  color: AppColors.grey200,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("From", textAlign: TextAlign.start, style: subHeadingStyle.copyWith(color: AppColors.grey900, fontSize: 20),),
                        Text("To", textAlign: TextAlign.start, style: subHeadingStyle.copyWith(color: AppColors.grey900, fontSize: 20),),
                      ],)
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 350,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.2,
                        height: 300,
                        child: ListView.builder(itemBuilder: (context, index) {
                          String selection = list[index];
                          return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectionOption1 = selection;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 24, right: 0, bottom: 24),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: selectionOption1 == selection ? AppColors.primaryBase : AppColors.grey200),
                                  ),
                                  child: Text(selection,textAlign: TextAlign.center, style: titleStyle.copyWith(color: selectionOption1 == selection ? AppColors.primaryBase : AppColors.grey900),),
                                ),
                              )
                          );
                        },
                          scrollDirection: Axis.vertical,
                          itemCount: list.length,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.2,
                        height: 300,
                        child: ListView.builder(itemBuilder: (context, index) {
                          String selection = list[index];
                          return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectionOption2 = selection;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0, right: 24, bottom: 24),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: selectionOption2 == selection ? AppColors.primaryBase : AppColors.grey200),
                                  ),
                                  child: Text(selection, textAlign: TextAlign.center, style: titleStyle.copyWith(color: selectionOption2 == selection ? AppColors.primaryBase : AppColors.grey900),),
                                ),
                              )
                          );
                        },
                          scrollDirection: Axis.vertical,
                          itemCount: list.length,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: ActionButton(text: "Done", onPressed: (){
                  Navigator.of(context).pop();
                }),),
                const SizedBox(height: 24,),
              ],
            ),
          ),
        );
      });
    },
    isDismissible: false,
    showDragHandle: true,
    enableDrag: false);

    if(selectionOption1.isNotEmpty && selectionOption2.isNotEmpty) {
      if(tag == "days") {
        openingDays = "$selectionOption1 - $selectionOption2";
      } else {
        openingTimes = "$selectionOption1 - $selectionOption2";
      }
    }

    setState(() {
      selectionOption1 = "";
      selectionOption2 = "";
    });
  }

  Future<void> updateLocalData(Map<String, dynamic> clubDetails, String clubName) async {
    String getUser = (await ss.getItem("user"))!;
    dynamic user = jsonDecode(getUser);
    user["club_name"] = clubName; //_clubNameController.text.trim();
    user["account_setup"] = "true";
    user['location'] = _locationController.text.split(",").length == 4
        ? _locationController.text.split(",")[1]
        : _locationController.text.split(",")[0];
    user['location_details'] = clubDetails["location_details"];
    await ss.setPrefItem("user", jsonEncode(user));
    await ss.setPrefItem("club", jsonEncode(clubDetails), isStoreOnline: true);
  }

  void displaySnackBarErrorMessage(String? message) {
    message ??= "Action could not be completed. Please try again.";
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 10),
      backgroundColor: AppColors.errorColor,
      action: SnackBarAction(
        textColor: Colors.white,
        label: 'Close',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
