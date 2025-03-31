
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vwave_new/utils/general.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageSystem {

  StorageSystem() {
  }

  Future<void> setPrefItem(String key, String item,
      {bool isStoreOnline = false, bool isUserData = false}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      await preferences.setString(key, item);
      if (isStoreOnline) {
        String? user = await getItem("user");
        if (user != null) {
          Map<String, dynamic> setupData = {};
          setupData[key] = item;
          await FirebaseFirestore.instance.collection("users").doc(GeneralUtils().userUid).collection("setups").doc("user-data")
              .update(setupData);
          if(isUserData) {
            await FirebaseFirestore.instance.collection("users").doc(GeneralUtils().userUid)
                .update(setupData);
          }
        }
      }
    } catch (e) {
    }
  }

  Future<String?> getItem(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String item = preferences.getString(key) ?? "";
    if (item == "") {
      return null;
    }
    return item;
  }

  Future<void> clearPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  Future<void> deletePref(String key) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final getK = preferences.getString(key);
      if (getK != "" || getK != null || getK != "null") {
        await preferences.remove(key);
      }
    } catch (e) {}
  }
}
