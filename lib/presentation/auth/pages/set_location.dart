
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../../../constants.dart';
import '../../../library/google_autocomplete_places.dart';
import '../../../utils/general.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/map_utils.dart';
import '../../../widgets/nav_back_button.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../providers/auth_state.dart';
import '../providers/auth_state_notifier.dart';

class SetClubOwnerLocation extends ConsumerStatefulWidget {
  final Map<String, dynamic> userData;
  const SetClubOwnerLocation(this.userData, {super.key});

  @override
  ConsumerState<SetClubOwnerLocation> createState() => _SetClubOwnerLocation();
}

class _SetClubOwnerLocation extends ConsumerState<SetClubOwnerLocation> {

  final TextEditingController _locationController = TextEditingController();
  var mLocation = Location();
  geo.Position? userCurrentPosition;

  bool loading = false;

  double locationLatitude = 0, locationLongitude = 0;
  Prediction? locationDetail;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? selectedMarker;

  late BitmapDescriptor pinLocationIcon;

  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller = Completer();

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    controller.setMapStyle(Utils.mapStyles);
    if (_controller.isCompleted) return;
    _controller.complete(controller);
  }

  bool _serviceEnabled = false, mapToggle = true;
  geo.LocationPermission? _permissionGranted;

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/location_pin.png');
  }

  Future<void> locationSetup() async {
    if(Platform.isIOS) {
      var status = await Permission.locationWhenInUse.status;
      if (status.isGranted) {
        initPlatformState();
      }
      return;
    }
    final allowPermission = (await GeneralUtils().requestPermission(context, "Location", "VWave App collects location data to determine your establishment to other users for visibility case even when the app is closed or not in use."))!;
    if (allowPermission) {
      var status = await Permission.locationWhenInUse.status;
      if (status.isGranted) {
        initPlatformState();
        return;
      }
    }
  }

  Future<void> initPlatformState() async {
    try {
      // _serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      _serviceEnabled = await mLocation.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await mLocation.requestService();
        if (!_serviceEnabled) {
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
          return;
        }
      }
      if (_permissionGranted == geo.LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        GeneralUtils().displayAlertDialog(context, "Permission", "Location permissions are permanently denied, we cannot request permissions. Go to your phone settings to allow Location for VWaveApp.");
        return;
      }
      userCurrentPosition = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.best, timeLimit: const Duration(seconds: 15));
      if (!mounted) return;
      setState(() {
        mapToggle = true;
      });
      if(userCurrentPosition == null) {
        return;
      }
      updateMapCamera(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      fetchCoordinateAddress();
    } catch(e, s) {
      userCurrentPosition = await geo.Geolocator.getLastKnownPosition();
      if(userCurrentPosition == null) {
        return;
      }
      updateMapCamera(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      fetchCoordinateAddress();
    }
  }

  void updateMapCamera(double lat, double lng) {
    locationLatitude = lat;
    locationLongitude = lng;
    markers.clear();
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 90.0,
        target: LatLng(lat, lng),
        tilt: 30.0,
        zoom: 17.0,
      ),
    ));
    const MarkerId markerId = MarkerId('user');
    final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(lat, lng),
        infoWindow: const InfoWindow(title: "Current Location", snippet: ''),
        icon: pinLocationIcon,
        alpha: 1.0,
        draggable: false);
    markers[markerId] = marker;
  }

  Future<void> fetchCoordinateAddress() async {
    print("Fetching address....");
    final res = await GeneralUtils().makeRequest(
        "fetchaddress?latitude=${userCurrentPosition!.latitude}&longitude=${userCurrentPosition!.longitude}",
        {
          "latitude": "${userCurrentPosition!.latitude}",
          "longitude": "${userCurrentPosition!.longitude}",
        },
        addUserCheck: false, method: "get");
    if(res.statusCode != 200) {
      // GeneralUtils.showToast("Cou");
      return;
    }
    final resp = jsonDecode(res.body);
    setState(() {
      _locationController.text = resp["formatted_address"];
    });
  }

  Future<void> displayLocationBottomSheet() async {

    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            height: 500,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20,),
                  Text(
                    "Location",
                    style: subHeadingStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.grey900),
                  ),
                  const SizedBox(height: 20,),
                  const Divider(color: AppColors.grey200,),
                  const SizedBox(height: 20,),
                  GooglePlaceAutoCompleteTextField(
                    textEditingController: _locationController,
                    googleAPIKey: googleApiKey,
                    inputDecoration: InputDecoration(
                      alignLabelWithHint: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: AppColors.secondaryBase,
                        ),
                      ),
                      labelText: "Location",
                      labelStyle: titleStyle.copyWith(
                        color: AppColors.grey400,
                      ),
                      filled: true,
                      hintText: "Type your address",
                      hintStyle: captionStyle.copyWith(
                        color: AppColors.grey400,
                      ),
                      border: InputBorder.none,
                      fillColor: AppColors.grey50,
                    ),
                    debounceTime: 800, // default 600 ms,
                    // countries: const [
                    //   "us",
                    // ], // optional by default null is set
                    isLatLngRequired: true, // if you required coordinates from place detail
                    getPlaceDetailWithLatLng: (Prediction prediction) {
                      locationLatitude = double.parse(prediction.lat!);
                      locationLongitude = double.parse(prediction.lng!);
                      updateMapCamera(locationLatitude, locationLongitude);
                      // this method will return latlng with place detail
                      // print("placeDetails" + prediction.lng.toString());
                    }, // this callback is called when isLatLngRequired is true
                    itemClick: (Prediction prediction) {
                      _locationController.text = prediction.description!;
                      _locationController.selection = TextSelection.fromPosition(
                          TextPosition(offset: prediction.description!.length));
                      locationDetail = prediction;
                    },
                    // if we want to make custom list item builder
                    itemBuilder: (context, index, Prediction prediction) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            // const Icon(Icons.location_on),
                            SvgPicture.asset("assets/svg/location_gray.svg"),
                            const SizedBox(
                              width: 7,
                            ),
                            Expanded(child: Text(prediction.description ?? ""))
                          ],
                        ),
                      );
                    },
                    // if you want to add seperator between list items
                    seperatedBuilder: const Divider(),
                    // want to show close icon
                    isCrossBtnShown: true,
                    showError: true,
                    boxDecoration: const BoxDecoration(),
                  ),
                  const SizedBox(height: 20,),
                  Text(
                    "Use Location",
                    style: bodyStyle.copyWith(color: AppColors.primaryBase),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  ActionButton(
                    loading: loading,
                    text: "Continue",
                    onPressed: createAccount,
                  )
                ],
              ),
            ),
          );
        },
        isDismissible: false,
        showDragHandle: true,
        enableDrag: false);
  }

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    locationSetup();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider,
            (AuthState? previousState, AuthState newState) {
          if (newState is AuthLoadedState) {
            // GeneralUtils().showResponseBottomSheet(
            //     context, "success", "Success",
            //     widget.userData["user_type"] == "user" ? "Your account is ready to use" : "You have successfully verified your account",
            //     "Proceed to dashboard", () {
            //   Navigator.of(context).pop();
            //   Navigator.of(context).pushReplacementNamed('/home');
            // });
            Navigator.of(context).pushReplacementNamed('/home');
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

    final authState = ref.watch(authNotifierProvider);
    loading = authState is AuthLoadingState;

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
        title: Text("Set Your Location", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
      ),
      body: Stack(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: !mapToggle ? const SizedBox() : GoogleMap(
                initialCameraPosition:
                const CameraPosition(
                    target:
                    LatLng(0.0, 0.0)),
                onMapCreated: _onMapCreated,
                compassEnabled: false,
                // mapType: MapType.normal,
                myLocationEnabled: true,
                rotateGesturesEnabled: false,
                scrollGesturesEnabled: true,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: Set<Marker>.of(
                    markers.values),
              )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 400,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40),),
                color: Colors.white
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width - 48) / 5,
                      height: 5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.grey200
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Text(
                      widget.userData["user_type"] == "club_owner" ? "Club Location" : "Location",
                      style: subHeadingStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.grey900),
                    ),
                    const SizedBox(height: 20,),
                    const Divider(color: AppColors.grey200,),
                    const SizedBox(height: 20,),
                    GooglePlaceAutoCompleteTextField(
                      textEditingController: _locationController,
                      googleAPIKey: googleApiKey,
                      inputDecoration: InputDecoration(
                        alignLabelWithHint: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBase,
                          ),
                        ),
                        labelText: widget.userData["user_type"] == "club_owner" ? "Club Location" : "Location",
                        labelStyle: titleStyle.copyWith(
                          color: AppColors.grey400,
                        ),
                        filled: true,
                        hintText: widget.userData["user_type"] == "club_owner" ? "Type your club address" : "Type your address",
                        hintStyle: captionStyle.copyWith(
                          color: AppColors.grey400,
                        ),
                        border: InputBorder.none,
                        fillColor: AppColors.grey50,
                      ),
                      debounceTime: 800, // default 600 ms,
                      // countries: const [
                      //   "us",
                      // ], // optional by default null is set
                      isLatLngRequired: true, // if you required coordinates from place detail
                      getPlaceDetailWithLatLng: (Prediction prediction) {
                        locationLatitude = double.parse(prediction.lat!);
                        locationLongitude = double.parse(prediction.lng!);
                        updateMapCamera(locationLatitude, locationLongitude);
                        // this method will return latlng with place detail
                        // print("placeDetails" + prediction.lng.toString());
                      }, // this callback is called when isLatLngRequired is true
                      itemClick: (Prediction prediction) {
                        _locationController.text = prediction.description!;
                        _locationController.selection = TextSelection.fromPosition(
                            TextPosition(offset: prediction.description!.length));
                        locationDetail = prediction;
                      },
                      // if we want to make custom list item builder
                      itemBuilder: (context, index, Prediction prediction) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              // const Icon(Icons.location_on),
                              SvgPicture.asset("assets/svg/location_gray.svg"),
                              const SizedBox(
                                width: 7,
                              ),
                              Expanded(child: Text(prediction.description ?? ""))
                            ],
                          ),
                        );
                      },
                      // if you want to add seperator between list items
                      seperatedBuilder: const Divider(),
                      // want to show close icon
                      isCrossBtnShown: true,
                      showError: true,
                      boxDecoration: const BoxDecoration(),
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        Text(
                          "Use Location",
                          style: bodyStyle.copyWith(color: AppColors.primaryBase),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ActionButton(
                      loading: loading,
                      text: "Continue",
                      onPressed: createAccount,
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      )
    );
  }

  Future<void> createAccount() async {
    if(_locationController.text.isEmpty) {
      GeneralUtils.showToast("Please enter location address");
      return;
    }
    Map<String, dynamic> mUserData = {
      "location": _locationController.text
          .split(",")
          .length == 4
          ? _locationController.text.split(",")[1]
          : _locationController.text.split(",")[0],
      "location_details": {
        "address": _locationController.text,
        "latitude": locationLatitude,
        "longitude": locationLongitude,
        "position": {
          "geohash": GeneralUtils().encodeGeoHash(
              locationLatitude, locationLongitude, 9),
          "geopoint": GeoPoint(locationLatitude, locationLongitude)
        }
      },
      ...widget.userData,
    };

    if(widget.userData["user_type"] == "club_owner") {
      ref.read(authNotifierProvider.notifier).createClubOwnerAccount(
          userData: mUserData
      );
      return;
    }

    if(widget.userData["user_type"] == "user" && widget.userData.containsKey("method")) {
      ref.read(authNotifierProvider.notifier).createUserAccountBySocialLogin(
          userData: mUserData
      );
      return;
    }

    if(widget.userData["user_type"] == "user") {
      ref.read(authNotifierProvider.notifier).createAccount(
          firstName: widget.userData["firstName"],
          lastName: widget.userData["lastName"],
          email: widget.userData["email"],
          password: widget.userData["password"],
          deviceToken: widget.userData["deviceToken"],
          deviceInfo: widget.userData["deviceInfo"],
        location: mUserData["location"],
        locationDetails: mUserData["location_details"]
      );
    }
  }
}

