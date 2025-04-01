import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vwave/presentation/club/providers/club_notifier_provider.dart';
import 'package:vwave/presentation/events/providers/club_event_notifier_provider.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';

import '../../../constants.dart';
import '../../../utils/general.dart';
import '../../../utils/storage.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../auth/providers/auth_state.dart';
import '../../auth/providers/auth_state_notifier.dart';
import '../../livestream/providers/livestream_notifier_provider.dart';
import '../../stories/providers/story_notifier_provider.dart';
import '../widgets/bottom_navigation_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {

  StreamSubscription<DocumentSnapshot>? blockListen;
  StorageSystem ss = StorageSystem();
  String userType = "";
  dynamic userProfile;

  var mLocation = Location();
  geo.Position? userCurrentPosition;

  bool _serviceEnabled = false;
  geo.LocationPermission? _permissionGranted;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      dynamic profile = await GeneralUtils().getUserProfile();
      if(profile == null) {
        await ref.read(authNotifierProvider.notifier).signOut();
        return;
      }
      userProfile = profile;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userType = prefs.getString("user_type") ?? "user";
      });
      if(userType == "club_owner") {
        ref.read(livestreamNotifierProvider.notifier).getRecentLivestreamsAndClubFollowers();
        ref.read(clubEventNotifierProvider.notifier).getClubEvents();
      }
      if(userType == "user") {
        // setLoadingState();
        // await getUserCurrentLocation();
        fetchAllData();
      }
    });
    getUserTimeZone();
    listenForBlockedUser();
  }

  Future<void> getUserCurrentLocation() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      await initPlatformState();
      return;
    }
    final allowPermission = (await GeneralUtils().requestPermission(context, "Location", "VWave App collects location data to fetch clubs, events, and livestreams around you even when the app is closed or not in use."))!;
    if (allowPermission) {
      await initPlatformState();
      return;
    }
    fetchAllData();
  }

  Future<void> initPlatformState() async {
    try {
      _serviceEnabled = await mLocation.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await mLocation.requestService();
        if (!_serviceEnabled) {
          fetchAllData();
          return;
        }
      }
      _permissionGranted = await geo.Geolocator.checkPermission();
      // _permissionGranted = await mLocation.hasPermission();
      if (_permissionGranted == geo.LocationPermission.denied) {
        _permissionGranted = await geo.Geolocator.requestPermission();
        if (_permissionGranted == geo.LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          await geo.Geolocator.openAppSettings();
          fetchAllData();
          return;
        }
      }
      if (_permissionGranted == geo.LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        GeneralUtils().displayAlertDialog(context, "Permission", "Location permissions are permanently denied, we cannot request permissions. Go to your phone settings to allow Location for VWaveApp.");
        fetchAllData();
        return;
      }
      userCurrentPosition = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.best, timeLimit: const Duration(seconds: 15));
      if(userCurrentPosition == null) {
        await alternateUserLocation();
        return;
      }
      await updateUserLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    } catch(e, s) {
      await alternateUserLocation();
    }
  }

  Future<void> alternateUserLocation() async {
    userCurrentPosition = await geo.Geolocator.getLastKnownPosition();
    if(userCurrentPosition == null) {
      fetchAllData();
      return;
    }
    await updateUserLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
  }

  Future<void> updateUserLocation(double lat, double lng) async {
    String? user = await ss.getItem("user");
    if (user == null) {
      return;
    }
    Map<String, dynamic> userData = jsonDecode(user);
    final userLocationDetails = userData["location_details"];

    Map<String, dynamic> location =  {
      "address": userLocationDetails["address"],
      "latitude": lat,
      "longitude": lng,
    };
    userData["location_details"] = location;
    await ss.setPrefItem('user', jsonEncode(userData));
    fetchAllData();
  }

  void setLoadingState() {
    ref.read(livestreamNotifierProvider.notifier).setStateLoading(true);
    ref.read(clubEventNotifierProvider.notifier).setStateLoading(true);
    ref.read(clubNotifierProvider.notifier).setStateLoading(true);
  }

  void fetchAllData() {
    ref.read(livestreamNotifierProvider.notifier).getLivestreams();
    ref.read(clubEventNotifierProvider.notifier).getClubEventsForUsers();
    ref.read(clubNotifierProvider.notifier).getClubs();
    ref.read(storyNotifierProvider.notifier).getStoryFeeds();
    ref.read(authNotifierProvider.notifier).getCurrentUserData(userProfile["uid"]);
  }

  getUserTimeZone() async {
    try {
      String tz = await GeneralUtils().currentTimeZone();
      userCurrentTimeZone.add(tz);
    } catch (e) {}
  }

  Future<void> listenForBlockedUser() async {
    if (GeneralUtils().userUid == null || GeneralUtils().userUid == "") return;
    String? user = await ss.getItem("user");
    if (user != null) {
      dynamic json = jsonDecode(user);
      String? uid = json["uid"];

      blockListen = FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .snapshots()
          .listen((query) async {
        if (!query.exists) {
          await ss.clearPref();
          await ref.read(authNotifierProvider.notifier).signOut();
          return;
        }
        dynamic dt = query.data();
        bool isBlocked = dt["blocked"];
        if (isBlocked) {
          await ss.clearPref();
          await ref.read(authNotifierProvider.notifier).signOut();
        }
        // if(userType == "club_owner") {
        //   bool isVerified = dt["verified"];
        //   if(isVerified) {
        //     // update verify storage
        //
        //   }
        // }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (blockListen != null) {
      blockListen!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider,
            (AuthState? previousState, AuthState newState) {
          if (newState is UnauthenticatedState) {
            Navigator.of(context).pushReplacementNamed('/login');
          } else if (newState is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 4,
                backgroundColor: Colors.red,
                content: Text(
                  newState.message,
                  style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            );
          }
        });
    return BottomNavBar(userType);
  }
}
