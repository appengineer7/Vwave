import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vwave_new/utils/storage.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as Math;

import '../constants.dart';
import '../size_config.dart';
import '../widgets/bottom_sheet_response.dart';
import '../widgets/styles/text_styles.dart';
import 'package:intl/intl.dart';

class GeneralUtils {
  GeneralUtils();

  static void showToast(String msg, {int length = 0, double fontSize = 16}) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: (length == 0) ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: AppColors.primaryBase,
        textColor: Colors.white,
        fontSize: fontSize);
  }

  String returnFormattedNumber(int number) {
    if (number < 10) {
      return "0$number";
    }
    return "$number";
  }

  Future<String> currentTimeZone() async {
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      return currentTimeZone;
    } catch (e) {
      return "America/Chicago";
    }
  }

  // getUserTimeZone() async {
  //   try {
  //     String tz = await GeneralUtils().currentTimeZone();
  //     userCurrentTimeZone.add(tz);
  //   } catch (e) {}
  // }

  getCurrentDateTime() {
    List<String> months = [
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
    DateTime date = DateTime.now();
    return "${rewriteTimeValue(date.day)} ${months[date.month - 1]} ${date.year}, ${rewriteTimeValue(date.hour)}:${rewriteTimeValue(date.minute)}";
  }

  rewriteTimeValue(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  Future<void> saveNotification(String title, Map<String, dynamic> payload) async {
    if(payload["notification_type"] == null || payload["notification_type"] != "livestream") {
      return;
    }

    if(payload["document"] == null) {
      return;
    }

    if (GeneralUtils().userUid == null) {
      return;
    }

    final document = jsonDecode(payload["document"]);

    List<dynamic> coverImage = document["images"];

    String id = FirebaseFirestore.instance.collection("notifications").doc().id;

    String timeZone = await GeneralUtils().currentTimeZone();

    final notificationPayload = {
    "id": id,
    "title": "New Follower Alert",
    "message": "${document["club_name"]} just started a new livestream. Click to view",
    "notification_type": "livestream",
    "header": "",
    "dynamic_link": "",
      "payload": {
        "profile_image": coverImage.first["url"],
        "profile_uid": document["user_uid"],
        "profile_username": document["club_name"],
        "following_user_uid": "",
        "following_username": "",
        "is_following": false,
        "livestream_data": document,
      },
      "read": false,
      "time_zone": timeZone,
      "user_uid": GeneralUtils().userUid,
      "created_date": DateTime.now().toString(),
      "modified_date": DateTime.now().toString(),
      "timestamp": FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection("notifications")
        .doc(id)
        .set(notificationPayload);
  }

  String? getUserUid() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    return user.uid;
  }

  String? get userUid => getUserUid();

  String getConvertedDateTime(String date, String timeZone) {
    return returnFormattedDate(date, timeZone, returnAgo: false);
  }

  tz.TZDateTime convertFireBaseTimeToLocal(tz.TZDateTime tzDateTime) {
    DateTime nowLocal = DateTime.parse(tzDateTime.toString());
    tz.TZDateTime newTzDateTime =
        tz.TZDateTime.from(nowLocal, tz.getLocation(userCurrentTimeZone.last));
    return newTzDateTime;
  }

  String returnFormattedDate(String createdDate, String timeZone, {bool returnAgo = true}) {
    try {
      if (timeZone == null) {
        return (!returnAgo)
            ? createdDate
            : returnFormattedDateWithoutTimeZone(createdDate);
      }
      if (timeZone == "") {
        return (!returnAgo)
            ? createdDate
            : returnFormattedDateWithoutTimeZone(createdDate);
      }
      if (timeZone == "null") {
        return (!returnAgo)
            ? createdDate
            : returnFormattedDateWithoutTimeZone(createdDate);
      }

      if (timeZone == userCurrentTimeZone.last) {
        if (returnAgo) {
          return returnFormattedDateWithoutTimeZone(createdDate);
        } else {
          return createdDate;
        }
      }
      tz.initializeTimeZones();
      DateTime myDT = DateTime.parse(createdDate);

      tz.TZDateTime cDT = tz.TZDateTime(tz.getLocation(timeZone), myDT.year,
          myDT.month, myDT.day, myDT.hour, myDT.minute, myDT.second);
      tz.TZDateTime newDT = convertFireBaseTimeToLocal(cDT);
      if (!returnAgo) {
        return newDT.toString();
      }
      return returnFormattedDateWithoutTimeZone(newDT.toString()); //newDT2
    } catch (e) {
      return (!returnAgo)
          ? createdDate
          : returnFormattedDateWithoutTimeZone(createdDate);
    }
  }

  String returnFormattedDateWithoutTimeZone(String createdDate) {
    var secs = DateTime.now().difference(DateTime.parse(createdDate)).inSeconds;
    if (secs > 60) {
      var mins =
          DateTime.now().difference(DateTime.parse(createdDate)).inMinutes;
      if (mins > 60) {
        var hrs =
            DateTime.now().difference(DateTime.parse(createdDate)).inHours;
        if (hrs > 24) {
          var days =
              DateTime.now().difference(DateTime.parse(createdDate)).inDays;
          return (days > 1) ? '$days days ago' : '$days day ago';
        } else {
          return (hrs > 1) ? '$hrs hrs ago' : '$hrs hr ago';
        }
      } else {
        return (mins > 1) ? '$mins mins ago' : '$mins min ago';
      }
    } else {
      return '$secs secs ago';
    }
  }

  String returnFormattedDateDuration(int secs) {
    // var secs = DateTime.now().difference(DateTime.parse(createdDate)).inSeconds;
    if (secs > 60) {
      var mins = (secs / 60).ceil();//DateTime.now().difference(DateTime.parse(createdDate)).inMinutes;
      if (mins > 60) {
        var hrs = (secs / 3600).ceil(); // DateTime.now().difference(DateTime.parse(createdDate)).inHours;
        // if (hrs > 24) {
        //   var days = (hrs / 24).ceil(); //DateTime.now().difference(DateTime.parse(createdDate)).inDays;
        //   return (days > 1) ? '$days days' : '$days day';
        // } else {
        //   return (hrs > 1) ? '${hrs}hrs' : '${hrs}hrs';
        // }
        return (hrs > 1) ? '${hrs}hr' : '${hrs}hr';
      } else {
        return (mins > 1) ? '${mins}m' : '${mins}m';
      }
    } else {
      return '$secs secs';
    }
  }

  Future<void> displayAlertDialog(
      BuildContext context, String? title, String? body) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title!,
            textAlign: TextAlign.center,
            style: titleStyle.copyWith(
              color: AppColors.titleTextColor,
              fontSize: getProportionateScreenWidth(20),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  height: getProportionateScreenHeight(50),
                  width: getProportionateScreenWidth(50),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F6F9),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/images/logo.png'),
                ),
                Padding(
                    padding:
                        const EdgeInsets.only(left: 0.0, right: 0.0, top: 30.0),
                    child: Text(
                      body!,
                      textAlign: TextAlign.center,
                      style: titleStyle.copyWith(
                        color: AppColors.titleTextColor,
                        fontSize: getProportionateScreenWidth(15),
                      ),
                    )),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Ok",
                style: titleStyle.copyWith(color: AppColors.primaryBase),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> requestPermission(BuildContext context, String title, String body) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Permission Request - $title",
            textAlign: TextAlign.center,
            style: titleStyle.copyWith(
              color: AppColors.titleTextColor,
              fontSize: getProportionateScreenWidth(20),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  height: getProportionateScreenHeight(50),
                  width: getProportionateScreenWidth(50),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F6F9),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/images/logo.png'),
                ),
                Padding(
                    padding: const EdgeInsets.only(
                        left: 0.0, right: 0.0, top: 30.0),
                    child: Text(
                      body,
                      textAlign: TextAlign.center,
                      style: titleStyle.copyWith(
                        color: AppColors.titleTextColor,
                        fontSize: getProportionateScreenWidth(15),
                      ),
                    )),
              ],
            ),
          ),
          actions: <Widget>[
            // TextButton(
            //   child: Text(
            //     "Deny",
            //     style: titleStyle.copyWith(color: AppColors.secondaryBase),
            //   ),
            //   onPressed: () {
            //     Navigator.of(context).pop(false);
            //   },
            // ),
            TextButton(
              child: Text(
                "Continue",
                style: titleStyle.copyWith(color: AppColors.primaryBase),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> displayReturnedValueAlertDialog(BuildContext context,
      String title, String body, String confirmText, String cancelText,
      {String icon = "assets/images/logo.png"}) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: titleStyle.copyWith(
              color: AppColors.titleTextColor,
              fontSize: getProportionateScreenWidth(20),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  height: getProportionateScreenHeight(50),
                  width: getProportionateScreenWidth(50),
                  decoration: const BoxDecoration(
                    color: Colors.white, //0xFFF5F6F9
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(icon),
                ),
                Padding(
                    padding:
                        const EdgeInsets.only(left: 0.0, right: 0.0, top: 30.0),
                    child: Text(
                      body,
                      textAlign: TextAlign.center,
                      style: titleStyle.copyWith(
                        color: AppColors.titleTextColor,
                        fontSize: getProportionateScreenWidth(15),
                      ),
                    )),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                cancelText,
                style: titleStyle.copyWith(color: AppColors.errorColor),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                confirmText,
                style: titleStyle.copyWith(color: AppColors.primaryBase),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  dynamic formatCurrencyAmount(dynamic number) {
    final currencyFormat = NumberFormat("#,##0.00", "en_US");
    return currencyFormat.format(number);
  }

  String encodeGeoHash(double latitude, double longitude, int precision) {
    final BITS = [16, 8, 4, 2, 1];
    const BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz";
    bool is_even = true;
    var i = 0;
    List<double> lat = [0,0];
    List<double> lon = [0,0];
    int bit = 0;
    int ch = 0;
    String geohash = "";

    lat[0] = -90.0;
    lat[1] = 90.0;
    lon[0] = -180.0;
    lon[1] = 180.0;

    while (geohash.length < precision) {
      if (is_even) {
        double mid = (lon[0] + lon[1]) / 2;
        if (longitude > mid) {
          ch |= BITS[bit];
          lon[0] = mid;
        } else {
          lon[1] = mid;
        }
      } else {
        double mid = (lat[0] + lat[1]) / 2;
        if (latitude > mid) {
          ch |= BITS[bit];
          lat[0] = mid;
        } else {
          lat[1] = mid;
        }
      }

      is_even = !is_even;
      if (bit < 4) {
        bit++;
      } else {
        geohash += BASE32[ch];
        bit = 0;
        ch = 0;
      }
    }
    return geohash;
  }

  Map<String, dynamic> getLocationDetailsData(Map<String, dynamic> location) {
    return {
      "address": location["address"],
      "latitude": location["latitude"],
      "longitude": location["longitude"],
      "position": {
        "geohash": encodeGeoHash(location["latitude"], location["longitude"], 9),
        "geopoint": GeoPoint(location["latitude"], location["longitude"])
      }
    };
  }

  String encodeValue(String data) {
    final encoded = base64.encode(utf8.encode(data));
    return encoded;
  }

  String decodeValue(String data) {
    final decoded = base64.decode(data);
    return utf8.decode(decoded);
  }

  Future<void> launchInWebViewOrVC(String url) async {
    if(!url.startsWith("http")) {
      url = "https://$url";
    }
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView)) {
      showToast('Could not launch $url');
    }
  }
  Future<void> launchExternalApplication(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      showToast('Could not launch $url');
    }
  }

  Future<http.Response> makeRequest(String endpoint, Map<String, dynamic> data, {bool addUserCheck = true, String method = "post"}) async {
    StorageSystem ss = StorageSystem();
    if(endpoint == "getuserdata") {
      // GeneralUtils.showToast("Fetching user details");
    }
    String? appToken = await ss.getItem("app_token");
    // appToken ??= await FirebaseAppCheck.instance.getToken();

    final requestHeader = {
      "X-Firebase-AppCheck": appToken ?? "",
      "Authorization": dotenv.env['AUTHORIZATION_KEY'] ?? "",
    };

    if(addUserCheck) {
      String? accessToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      requestHeader["X-Firebase-UserCheck"] = accessToken ?? "";
    }

    // https://verifyclub-6pqdaea4zq-uc.a.run.app
    // Uri url = Uri.parse("https://$endpoint-6pqdaea4zq-uc.a.run.app");
    Uri url = Uri.parse("https://us-central1-getvwaveapp.cloudfunctions.net/$endpoint");
    if(method == "post") {
      final res = await http.post(url, headers: requestHeader, body: jsonEncode(data));
      return res;
    }

    final res = await http.get(url, headers: requestHeader);
    return res;
  }

  Future<void> showResponseBottomSheet(BuildContext context, String imageName, String title, String subtitle, String buttonTitle, Function() onPress) async {
    await showModalBottomSheet(
    context: context,
    builder: (context) {
      return BottomSheetResponse(imageName: imageName, title: title, subtitle: subtitle, buttonTitle: buttonTitle, onPress: onPress,);
    },
    isDismissible: false,
    showDragHandle: true,
    enableDrag: false);
  }

  Future<bool> isClubOwnerAccountSetupComplete() async {
    if (GeneralUtils().userUid == null || GeneralUtils().userUid == "") return false;
    StorageSystem ss = StorageSystem();
    String? user = await ss.getItem("user");
    if(user == null) {
      return false;
    }
    dynamic json = jsonDecode(user);
    if(json["account_setup"] == null) {
      return false;
    }
    String accountSetup = json["account_setup"];
    return accountSetup == "true";
  }

  Future<bool> isClubOwnerAccountVerified() async {
    if (GeneralUtils().userUid == null || GeneralUtils().userUid == "") return false;
    StorageSystem ss = StorageSystem();
    String? user = await ss.getItem("user");
    if(user == null) {
      return false;
    }
    dynamic json = jsonDecode(user);
    if(json["account_verified"] == null || json["account_verified"] == "false") {
      final checkVerification = await FirebaseFirestore.instance.collection("clubs").doc(GeneralUtils().userUid).get();
      if(checkVerification.exists) {
        final dt = checkVerification.data();
        if(dt == null) {
          return false;
        }
        json["account_verified"] = "${dt["verified"]}";
        await ss.setPrefItem("user", jsonEncode(json));
        return dt["verified"];
      }
      return false;
    }
    String accountSetup = json["account_verified"];
    return accountSetup == "true";
  }

  Future<dynamic> getUserProfile() async {
    StorageSystem ss = StorageSystem();
    String? user = await ss.getItem("user");
    if(user == null) {
      return null;
    }
    dynamic json = jsonDecode(user);
    return json;
  }

  String shortenLargeNumber({double num = 0, int digits = 2}) {
    const units = ['K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'];
    double decimal = 0.0;

    for (int i = units.length - 1; i >= 0; i--) {
      decimal = Math.pow(1000, i + 1).toDouble();

      if (num <= -decimal || num >= decimal) {
        return "${(num / decimal).toStringAsFixed(digits)}${units[i]}";
      }
    }

    return "${num.ceil()}";
  }

  Future<void> requestStoragePermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        await Permission.photos.request();
      } else {
        await Permission.storage.request();
      }
    } else {
      await Permission.photos.request();
    }
  }
}
