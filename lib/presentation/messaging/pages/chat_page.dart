import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/utils.dart';
import 'package:intl_phone_field2/countries.dart';
import 'package:vwave/common/providers/firebase.dart';
import 'package:vwave/presentation/messaging/models/conversation.dart';
import 'package:vwave/presentation/messaging/providers/messages_provider.dart';
import 'package:vwave/presentation/messaging/widgets/chat_meesage_popup.dart';
import 'package:vwave/widgets/styles/text_styles.dart';
import 'package:vwave/widgets/user_avatar.dart';

import '../../../utils/general.dart';
import '../../../utils/storage.dart';
import '../../../widgets/multiple_options_bottom_sheet.dart';
import '../../../widgets/report_dialog.dart';
import '../../../widgets/styles/app_colors.dart';

class ChatPage extends ConsumerStatefulWidget {
  final Conversation conversation;
  const ChatPage(this.conversation, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPage();
}

class _ChatPage extends ConsumerState<ChatPage> {

  bool displayCountry = false;
  String countryName = "";
  List<Country> lCountry = countries;
  Map<String, dynamic> userData = {};
  StorageSystem ss = StorageSystem();

  bool isConversationBlocked = false;
  String conversationBlockedByUid = "";

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? conversationStream;

  List<OverlayPortalController> _menuItemPopupController = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      isConversationBlocked = widget.conversation.isConversationBlocked ?? false;
      conversationBlockedByUid = widget.conversation.conversationBlockedByUid ?? "";
    });
    getUserData();
    updateConversation();
    getUserCountryData();
    listenToConversationDocument();
  }

  Future<void> getUserData() async {
    String getUser = (await ss.getItem('user'))!;
    setState(() {
      userData = jsonDecode(getUser);
    });
  }

  Future<void> updateConversation({bool forceUpdate = false}) async {
    if(forceUpdate) {
      await FirebaseFirestore.instance.collection("conversations").doc(widget.conversation.id).update(
          {
            "unread_counts": 0,
          });
      return;
    }
    if(widget.conversation.unreadCounts == 0) {
      return;
    }
    if(widget.conversation.latestMessageSender == GeneralUtils().userUid) {
      return;
    }
    await FirebaseFirestore.instance.collection("conversations").doc(widget.conversation.id).update(
        {
          "unread_counts": 0,
        });
  }

  Future<void> getUserCountryData() async {
    // Country uCountry = lCountry.firstWhere((country) => country.name == "Nigeria");
    // setState(() {
    //   displayCountry = true;
    //   countryName = "Nigeria ${uCountry.flag}";
    // });

    final userUid = (GeneralUtils().userUid == widget.conversation.participants[0]) ? widget.conversation.participants[1] : widget.conversation.participants[0];
    final getChatSettings = await FirebaseFirestore.instance.collection("users").doc(userUid).collection("settings").doc("chat").get();
    if(!getChatSettings.exists) {
      return;
    }
    final data = getChatSettings.data();
    if(data == null) {
      return;
    }
    bool dc = data["display_country"] as bool;
    String cName = data["country_name"] as String;
    if(dc) {
      Country? uCountry = lCountry.firstWhereOrNull((country) => country.name == cName.trim(),);
      if(uCountry == null) {
        return;
      }
      setState(() {
        displayCountry = true;
        countryName = "${cName.trim()} ${uCountry.flag}";
      });
    }
  }

  void listenToConversationDocument() {
    conversationStream = ref.read(firebaseFirestoreProvider).collection("conversations").doc(widget.conversation.id).snapshots().listen((event) {
      Map<String, dynamic>? dt = event.data();
      if(dt == null) return;
      setState(() {
        isConversationBlocked = dt["is_conversation_blocked"] ?? false;
        conversationBlockedByUid = dt["conversation_blocked_by_uid"] ?? "";
      });
      // if(dt["latest_message_sender"] == GeneralUtils().userUid) {
      //   updateConversation(forceUpdate: true);
      // }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if(conversationStream != null) {
      conversationStream!.cancel();
    }
  }

  Map<String, dynamic> getOtherUserUserData() {
    final participantId = widget.conversation.participants.singleWhere((id) => id != GeneralUtils().userUid);
    Map<String, dynamic> pUserData = widget.conversation.participantsUserData;
    Map<String, dynamic> otherUser = pUserData[participantId];
    otherUser["id"] = participantId;
    return otherUser;
  }

  Map<String, dynamic> get getParticipantUserData => getOtherUserUserData();

  @override
  Widget build(BuildContext context) {
    // asyncConversation.when(
    //   loading: () => const Center(
    //     child: CircularProgressIndicator(),
    //   ),
    //   data: (data) {

    //   }
    // );

    // final currentUser = ref.watch(authRepositoryProvider).getCurrentUser();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 80,
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  margin: const EdgeInsets.only(top: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GestureDetector(
                          onTap: () {
                            final fullName = getParticipantUserData["username"]; // (GeneralUtils().userUid == widget.conversation.participants[0]) ? widget.conversation.participantNames[1] : widget.conversation.participantNames[0];
                            Map<String, dynamic> user = {
                              "uid": getParticipantUserData["id"], //(GeneralUtils().userUid == widget.conversation.participants[0]) ? widget.conversation.participants[1] : widget.conversation.participants[0],
                              "first_name": fullName.split(" ")[0],
                              "last_name": fullName.split(" ").length > 1 ? fullName.split(" ")[1] : "",
                              "picture": getParticipantUserData["profile_picture"], //(GeneralUtils().userUid == widget.conversation.participants[0]) ? widget.conversation.participantImages[1] : widget.conversation.participantImages[0],
                              "allow_conversations": "allow",
                            };
                            Navigator.of(context).pushNamed("/user_profile", arguments: user);
                          },
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // CircleAvatar(
                          //   backgroundImage: widget.conversation.participantImage.isEmpty ? const NetworkImage(defaultAvatar) : NetworkImage(widget.conversation.participantImage),
                          // ),
                          GeneralUserAvatar(
                            40.0,
                            avatarData: getParticipantUserData["profile_picture"], //(GeneralUtils().userUid == widget.conversation.participants[0]) ? widget.conversation.participantImages[1] : widget.conversation.participantImages[0],
                            userUid: getParticipantUserData["id"], //(GeneralUtils().userUid == widget.conversation.participants[0]) ? widget.conversation.participants[1] : widget.conversation.participants[0], //widget.conversation.participants[1],
                            clickable: false,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getParticipantUserData["username"], //(GeneralUtils().userUid == widget.conversation.participants[0]) ? widget.conversation.participantNames[1] : widget.conversation.participantNames[0],
                                style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Row(
                                children: [
                                  if (isConversationBlocked)
                                    Text(GeneralUtils().userUid == conversationBlockedByUid ? "User Blocked " : "Cannot message user ",
                                      style: captionStyle.copyWith(fontWeight: FontWeight.w400,color: AppColors.errorColor),
                                    ),
                                  if (displayCountry)
                                    Text(countryName,
                                      style: captionStyle.copyWith(fontWeight: FontWeight.w400,color: AppColors.grey900),
                                    )
                                ],
                              )
                            ],
                          )
                        ],
                      )),
                      Row(
                        children: [
                          if((isConversationBlocked && GeneralUtils().userUid == conversationBlockedByUid) || !isConversationBlocked)
                            GestureDetector(
                              onTap: () async {
                                final res = await showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.white,
                                  builder: (BuildContext context) {
                                    return MultipleOptionsBottomSheet(isConversationBlocked ? "chat_unblock" : "chat_block", containerHeight: 250,);
                                  },
                                );
                                if(res == "Block user") {
                                  await performBlockOperation(true);
                                  return;
                                }
                                if(res == "Unblock user") {
                                  await performBlockOperation(false);
                                  return;
                                }
                                if(res == "Report user") {
                                  final reportDialog = ReportDialog(getParticipantUserData["id"], "user");
                                  await reportDialog.displayReportDialog(context, "Attention", "Please enter details about this report");
                                  return;
                                }
                              },
                              child: const Icon(Icons.more_vert_rounded, color: AppColors.grey600,),
                            ),
                          const SizedBox(width: 10,),
                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).pop();
                            },
                            child: const Icon(Icons.close, color: AppColors.errorColor,), //grey600
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                // const Divider(color: AppColors.grey200,)
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 70),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: ref
                      .read(firebaseFirestoreProvider)
                      .collection('messages')
                      .where('conversation', isEqualTo: widget.conversation.id)
                      .orderBy("firebaseTimestamp", descending: true)
                      .limit(100)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _menuItemPopupController = List.generate(snapshot.data!.size, (index) {
                        return OverlayPortalController();
                      });
                      final messages = snapshot.data!.docs
                          .map(
                            (e) {
                              DateTime dt = DateTime.fromMillisecondsSinceEpoch(e["timestamp"].seconds * 1000);
                              final createdDate = GeneralUtils().returnFormattedDate(dt.toString(), "UTC", returnAgo: false); // e["timeZone"]
                              // final d = e.data() as Map<String, dynamic>;
                              // List<dynamic> hideMessageForUsers = d["hideMessageForUsers"] ?? [];

                              return ChatMessage(
                                createdAt: DateTime.parse(createdDate), //e['timestamp']
                                user: ChatUser(
                                  id: e['sender'],
                                  firstName: "${e["senderName"]}".split(" ")[0],
                                  lastName: "${e["senderName"]}".split(" ").length >= 2 ? "${e["senderName"]}".split(" ")[1] : "",
                                  profileImage: e["image"]
                                ),
                                text: e['text'],
                                customProperties: {
                                  "id": e["id"],
                                  "index": snapshot.data!.docs.indexWhere((element) => element["id"] == e["id"]),
                                  "time": dt
                                  // "hideMessageForUsers": hideMessageForUsers,
                                },
                              );
                            }
                      )
                          .toList();
                      // final messages = preMessages.where((element) => !element.customProperties!["hideMessageForUsers"].contains(GeneralUtils().userUid)).toList();
                      return DashChat(
                        currentUser: ChatUser(
                          id: GeneralUtils().userUid!, // widget.conversation.participants.singleWhere((element) => element == GeneralUtils().userUid, orElse: () => GeneralUtils().userUid!), //currentUser?.uid
                        ),
                        messageOptions: MessageOptions(
                          showCurrentUserAvatar: false,
                          showOtherUsersAvatar: false,
                          showOtherUsersName: false,
                          borderRadius: 8,
                          messageDecorationBuilder: (ChatMessage message, m1, m2) {
                            return BoxDecoration(
                              color: message.user.id == GeneralUtils().userUid ? AppColors.primaryBase : AppColors.grey200,
                              borderRadius: BorderRadius.only(
                                bottomLeft: const Radius.circular(8),
                                bottomRight: const Radius.circular(8),
                                topRight: message.user.id == GeneralUtils().userUid ? const Radius.circular(0) : const Radius.circular(8),
                                topLeft: message.user.id == GeneralUtils().userUid ? const Radius.circular(8) : const Radius.circular(0),
                              )
                            );
                          },
                          messageTextBuilder: (ChatMessage message, m1, m2) {
                            return ChatMessagePopupMenu(_menuItemPopupController[message.customProperties!["index"]], onSelectedMenuItem: (menuItem) async {
                              if(menuItem == "copy") {
                                await Clipboard.setData(ClipboardData(text: message.text));
                                GeneralUtils.showToast("copied");
                              }
                              if(menuItem == "unsend") {
                                final msgIndex = messages.indexWhere((element) => element.customProperties!["id"] == message.customProperties!["id"]);
                                String newLatestMsg = "";
                                String newLatestSender = "";
                                DateTime newLatestTime = DateTime.now();
                                if(msgIndex > -1) {
                                  newLatestMsg = msgIndex == 0 ? ((msgIndex + 1) < (messages.length)) ? messages[msgIndex + 1].text : "" : messages[0].text;
                                  newLatestSender = msgIndex == 0 ? ((msgIndex + 1) < (messages.length)) ? messages[msgIndex + 1].user.id : "" : messages[0].user.id;
                                  newLatestTime = msgIndex == 0 ? ((msgIndex + 1) < (messages.length)) ? messages[msgIndex + 1].customProperties!["time"] : "" : messages[0].customProperties!["time"];
                                }
                                // print("msgIndex is ${messages.length}");
                                // print("msgIndex is $msgIndex");
                                // print("newLatestMsg is $newLatestMsg");
                                // print("newLatestSender is $newLatestSender");
                                // print("newLatestTime is $newLatestTime");
                                unSendUserMessage(message.customProperties!["id"], newLatestMsg, newLatestSender, newLatestTime);
                              }
                              // if(menuItem == "delete for you") {
                              //   deleteUserMessageForYou(message.customProperties!["id"]);
                              // }
                            }, showUnSend: message.user.id == GeneralUtils().userUid, child: Text(message.text, style: captionStyle.copyWith(
                              color: message.user.id == GeneralUtils().userUid ? Colors.white : AppColors.grey900,
                            ),));
                            // return Text(message.text, style: captionStyle.copyWith(
                            //   color: message.user.id == GeneralUtils().userUid ? Colors.white : AppColors.grey900,
                            // ),);
                          },
                        ),
                        readOnly: isConversationBlocked,
                        onSend: (ChatMessage message) async {
                          if(message.text.isEmpty) return;
                          // final sender = await ref.read(profileRepositoryProvider).fetchMe();

                          // final recipientId = widget.conversation.participants
                          //     .singleWhere((element) => element != GeneralUtils().userUid); //currentUser?.uid
                          //
                          // final recipientName = widget.conversation.participantNames
                          //     .singleWhere((element) =>
                          // element != "${userData["first_name"]} ${userData["last_name"]}"); //'${sender?.firstName} ${sender?.lastName}');

                          ref.read(asyncMessagesProvider.notifier).sendMessage(
                            conversationId: widget.conversation.id!,
                            sender: GeneralUtils().userUid ?? "", //sender!.id!,
                            recipient: getParticipantUserData["id"],
                            senderName: "${userData["first_name"]} ${userData["last_name"]}".trim(), //'${sender.firstName} ${sender.lastName}',
                            recipientName: getParticipantUserData["username"],
                            text: message.text.trim(),
                            timestamp: '${message.createdAt}',
                            image: userData["picture"]
                          );

                          // latest message and time

                          // ref
                          //     .read(asyncConversationsProvider.notifier)
                          //     .setLatestMessage(
                          //   conversation.id!,
                          //   message.text,
                          //   message.createdAt,
                          // );
                        },
                        messages: messages,
                      );
                    } else {
                      return const Center(
                        child: Text("No data"),
                      );
                    }
                  }),
            ),
          ],
        ),
      )
    );
  }

  List<Map<String, dynamic>> convos = [];
  List<Map<String, dynamic>> users = [];
  int startIndex = 0;

  Future<void> updateAllConversations() async {
    print("starting steps=================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    final convList = await FirebaseFirestore.instance.collection("conversations").get();
    for (var doc in convList.docs) {
      final conversation = doc.data();
      convos.add(conversation);
    }
    print("next steps=================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    await processConversations();
  }

  Future<void> processConversations() async {
    print("running at index $startIndex=================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    final conversation = convos[startIndex];
    List<dynamic> participants = conversation["participants"];
    if(participants.length == 2) {
      Map<String, dynamic> user1 = users.singleWhere((user) => user["id"] == participants[0], orElse: () => {});
      Map<String, dynamic> user2 = users.singleWhere((user) => user["id"] == participants[1], orElse: () => {});
      if(user1.isEmpty) {
        final u1 = await getUserDetails(participants[0]);
        user1 = u1 ?? {};
      }
      if(user2.isEmpty) {
        final u2 = await getUserDetails(participants[1]);
        user2 = u2 ?? {};
      }

      // update conversation
      if(user1.isNotEmpty && user2.isNotEmpty) {
        // await FirebaseFirestore.instance.collection("conversations").doc(conversation["id"]).update({
        //   "participants_userdata": {
        //     "${participants[0]}": {
        //       "profile_picture": "${user1["picture"]}",
        //       "username": "${user1["first_name"]} ${user1["last_name"]}".trim(),
        //       "time_zone": ""
        //     },
        //     "${participants[1]}": {
        //       "profile_picture": "${user2["picture"]}",
        //       "username": "${user2["first_name"]} ${user2["last_name"]}".trim(),
        //       "time_zone": ""
        //     },
        //   }
        // });
        await FirebaseFirestore.instance.collection("conversations").doc(conversation["id"]).update({
          "participant_images": ["${user1["picture"]}", "${user2["picture"]}"],
          "participant_names": ["${user1["first_name"]} ${user1["last_name"]}".trim(), "${user2["first_name"]} ${user2["last_name"]}".trim()],
        });
      } else {
        print("skipped this step for empty user data=================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      }



    } else {
      print("skipped this step=================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }


    startIndex = startIndex + 1;
    if(startIndex < convos.length) {
      processConversations();
      return;
    }
    print("finished all steps=================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
  }

  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    final getUser = await FirebaseFirestore.instance.collection("users").doc(userId).get();
    if(getUser.exists) {
      final dt = getUser.data();
      if(dt != null) {
        users.add(dt);
      }
    }
    return getUser.data();
  }

  Future<void> performBlockOperation(bool isBlockUser) async {
    await ref.read(firebaseFirestoreProvider).collection("conversations").doc(widget.conversation.id).update(
        {
          "is_conversation_blocked": isBlockUser,
          "conversation_blocked_by_uid": isBlockUser ? GeneralUtils().userUid : "",
        });
    setState(() {
      isConversationBlocked = isBlockUser;
      conversationBlockedByUid = isBlockUser ? GeneralUtils().userUid! : "";
    });
  }

  Future<void> unSendUserMessage(String messageId, String newLatestMessage, String newLatestSender, DateTime newLatestTime) async {
    await ref.read(firebaseFirestoreProvider).collection('messages').doc(messageId).delete();
    if(newLatestMessage == "") {
      await ref.read(firebaseFirestoreProvider).collection('conversations').doc(widget.conversation.id).update({
        "latest_message": newLatestMessage,
      });
    } else {
      await ref.read(firebaseFirestoreProvider).collection('conversations').doc(widget.conversation.id).update({
        "latest_message": newLatestMessage,
        "latest_message_sender": newLatestSender,
        "latest_message_time": Timestamp.fromDate(newLatestTime),
      });
    }
  }

  Future<void> deleteUserMessageForYou(String messageId) async {
    await ref.read(firebaseFirestoreProvider).collection('messages').doc(messageId).update({
      "hideMessageForUsers": FieldValue.arrayUnion([GeneralUtils().userUid]),
    });
  }
}
