//
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../constants.dart';
//
// class HiveDb {
//
//   late Box<List<Map<dynamic, dynamic>>> vWaveBox;
//
//   HiveDb() {
//     vWaveBox = Hive.box(HIVE_BOX_NAME);
//   }
//
//   // get all data from the hive db
//   List<Map<String, dynamic>> fetchDataCollection(String id) {
//     List<Map<String, dynamic>> list = [];
//
//     List<Map<dynamic, dynamic>>? getList = vWaveBox.get(id, defaultValue: []);
//
//     if(getList == null) {
//       return list;
//     }
//
//     if(getList.isEmpty) {
//       return list;
//     }
//
//     for (var val in getList) {
//       Map<String, dynamic> item = {};
//       val.forEach((k,v) {
//         if("$k" == "timestamp") {
//           item["$k"] = convertMilliSecondsToTimestamp(v);
//         } else if("$k" == "created_timestamp") {
//           item["$k"] = convertMilliSecondsToTimestamp(v);
//         } else if("$k" == "event_date_timestamp") {
//           item["$k"] = convertMilliSecondsToTimestamp(v);
//         } else if ("$k" == "recent_reviews") {
//           item["$k"] = convertReviewsMilliSecondsToTimestamp(v);
//         } else if ("$k" == "location_details") {
//           Map<String, dynamic> loc = v;
//           Map<String, dynamic> pos = loc["position"];
//           pos["geopoint"] = GeoPoint(loc["latitude"], loc["longitude"]);
//           loc["position"] = pos;
//           item["$k"] = loc;
//         } else {
//           item["$k"] = v;
//         }
//       });
//       list.add(item);
//     }
//     return list;
//   }
//
//   Future<void> addNewDataCollection(String id, List<Map<String, dynamic>> dataCollection) async {
//     if(dataCollection.isEmpty) {
//       return;
//     }
//     final collection = cleanDataCollection(dataCollection);
//     await deleteDataCollection(id);
//     await vWaveBox.put(id, collection);
//     print("added $id");
//   }
//
//   Future<void> deleteDataCollection(String id) async {
//     await vWaveBox.delete(id);
//   }
//
//   List<Map<String, dynamic>> cleanDataCollection(List<Map<String, dynamic>> dataCollection) {
//     final collection = dataCollection.map((dc) {
//       if(dc["timestamp"] != null) {
//         dc["timestamp"] = convertTimestampToMilliSeconds(dc["timestamp"]);
//       }
//       if(dc["created_timestamp"] != null) {
//         dc["created_timestamp"] = convertTimestampToMilliSeconds(dc["created_timestamp"]);
//       }
//       if(dc["event_date_timestamp"] != null) {
//         dc["event_date_timestamp"] = convertTimestampToMilliSeconds(dc["event_date_timestamp"]);
//       }
//       if(dc["recent_reviews"] != null) {
//         dc["recent_reviews"] = convertReviewsTimestampToMilliSeconds(dc["recent_reviews"]);
//       }
//       if(dc["location_details"] != null) {
//         Map<String, dynamic> loc = dc["location_details"];
//         Map<String, dynamic> pos = loc["position"];
//         pos["geopoint"] = [0,0];
//         loc["position"] = pos;
//         dc["location_details"] = loc;
//       }
//       return dc;
//     }).toList();
//
//     return collection;
//   }
//
//   List<dynamic> convertReviewsTimestampToMilliSeconds(List<dynamic> reviews) {
//     return reviews.map((rev) {
//       if(rev["timestamp"] != null) {
//         rev["timestamp"] = convertTimestampToMilliSeconds(rev["timestamp"]);
//       }
//       return rev;
//     }).toList();
//   }
//
//   List<dynamic> convertReviewsMilliSecondsToTimestamp(List<dynamic> reviews) {
//     return reviews.map((rev) {
//       if(rev["timestamp"] != null) {
//         rev["timestamp"] = convertMilliSecondsToTimestamp(rev["timestamp"]);
//       }
//       return rev;
//     }).toList();
//   }
//
//   int convertTimestampToMilliSeconds(Timestamp timestamp) {
//     return timestamp.millisecondsSinceEpoch;
//   }
//
//   Timestamp convertMilliSecondsToTimestamp(int milliseconds) {
//     return Timestamp.fromMillisecondsSinceEpoch(milliseconds);
//   }
//
//   GeoPoint convertStringToGeopoints(dynamic locDetails){
//     return GeoPoint(locDetails["latitude"], locDetails["longitude"]);
//   }
//
// }