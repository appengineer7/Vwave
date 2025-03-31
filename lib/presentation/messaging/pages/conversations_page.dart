import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vwave_new/utils/storage.dart';
import 'package:vwave_new/widgets/search_field.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';
import 'package:vwave_new/widgets/user_avatar.dart';

import '../../../common/providers/firebase.dart';
import '../../../constants.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/general.dart';
import '../../../widgets/empty_screen.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../auth/repositories/auth_repository.dart';
import '../models/conversation.dart';
import '../widgets/filter_conversations_bottom_sheet.dart';

class ConversationsPage extends ConsumerStatefulWidget {
  const ConversationsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConversationsPage();
}

class _ConversationsPage extends ConsumerState<ConversationsPage> {
  final TextEditingController _controller = TextEditingController();

  List<Conversation> allConversations = [];
  List<Conversation> conversations = [];
  bool loadingData = true;
  Map<String, dynamic> userData = {};
  StorageSystem ss = StorageSystem();

  Future<void> getConversationsForUser() async {
    final user = ref.read(authRepositoryProvider).getCurrentUser();
    try {
      ref
          .read(firebaseFirestoreProvider)
          .collection('conversations')
          .where("participants", arrayContains: user!.uid)
          .where("latest_message", isNotEqualTo: "")
          .orderBy("latest_message_time", descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isEmpty) {
          setState(() {
            loadingData = false;
          });
          return;
        }
        if (!mounted) return;
        setState(() {
          allConversations = snapshot.docs
              .map((doc) => Conversation.fromDocument(doc))
              .toList();
          conversations = snapshot.docs
              .map((doc) => Conversation.fromDocument(doc))
              .toList();
          loadingData = false;
        });
      });
    } on FirebaseException catch (e) {
      setState(() {
        loadingData = false;
      });
      throw CustomException(message: e.message);
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    _controller.addListener(() {
      final text = _controller.text;
      onSearchingConversation(text);
    });
    getConversationsForUser();
  }

  Future<void> getUserData() async {
    String getUser = (await ss.getItem('user'))!;
    setState(() {
      userData = jsonDecode(getUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final asyncConversations = ref.watch(asyncConversationsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Chat",
          style: titleStyle.copyWith(
              color: AppColors.grey900, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("/chat_settings");
                },
                child: const Icon(
                  Icons.settings,
                  color: AppColors.grey600,
                  size: 24,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: GestureDetector(
                onTap: () async {
                  Navigator.of(context).pushNamed("/search_users");
                  // await FirebaseChatCore.instance.createUserInFirestore(
                  //   const types.User(
                  //     firstName: 'John',
                  //     id: "1LNPu9plcPkSLYm7efnO", // UID from Firebase Authentication
                  //     imageUrl: 'https://i.pravatar.cc/300',
                  //     lastName: 'Doe',
                  //   ),
                  // );
                  // print("created done");
                },
                child: SvgPicture.asset("assets/svg/add.svg")),
          )
        ],
      ),
      body: SafeArea(
          child: loadingData
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : (conversations.isEmpty)
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: searchHeaderLayout(),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 50,
                                ),
                                Image.asset(
                                  "assets/images/empty_message.png",
                                  height:
                                      MediaQuery.of(context).size.height / 4,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Empty",
                                  style: subHeadingStyle.copyWith(
                                      color: AppColors.grey900,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 60),
                                  child: Text(
                                    "You don't have any messages at this time",
                                    textAlign: TextAlign.center,
                                    style: titleStyle.copyWith(
                                        color: AppColors.grey700,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Tap on the ",
                                      style: titleStyle.copyWith(
                                          color: AppColors.grey700,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SvgPicture.asset("assets/svg/add.svg"),
                                    Text(
                                      " icon to create a message",
                                      style: titleStyle.copyWith(
                                          color: AppColors.grey700,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          )
                        ],
                      ))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            searchHeaderLayout(),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: (Platform.isAndroid)
                                  ? MediaQuery.of(context).size.height - 230
                                  : MediaQuery.of(context).size.height - 300,
                              child: ListView.builder(
                                itemCount: conversations.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  final Conversation conversation =
                                      conversations[index];
                                  // final participant = () ? conversation.participantNames[1];
                                  final participantId = conversation.participants.singleWhere((id) => id != GeneralUtils().userUid);
                                  Map<String, dynamic> pUserData = conversation.participantsUserData;
                                  Map<String, dynamic> otherUser = pUserData[participantId];

                                  final participant = otherUser["username"];
                                  final participantImage = otherUser["profile_picture"];

                                  // final participant =
                                  //     conversation.participantNames.firstWhere(
                                  //         (name) =>
                                  //             name !=
                                  //             "${userData["first_name"]} ${userData["last_name"]}",
                                  //         orElse: () => "");
                                  // final participantImage =
                                  //     conversation.participantImages.firstWhere(
                                  //         (image) =>
                                  //             image != "${userData["picture"]}",
                                  //         orElse: () => "");
                                  String date = "";
                                  DateTime dt =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          conversation
                                                  .latestMessageTime.seconds *
                                              1000);
                                  final createdDate = GeneralUtils()
                                      .returnFormattedDate(dt.toString(),
                                      "UTC",
                                          returnAgo: false); // conversation.participantTimeZone,
                                  DateTime dateTime =
                                      DateTime.parse(createdDate);
                                  DateTime today = DateTime.now();
                                  if (dateTime.year == today.year &&
                                      dateTime.month == today.month &&
                                      dateTime.day == today.day) {
                                    date =
                                        "${GeneralUtils().rewriteTimeValue(dateTime.hour <= 12 ? dateTime.hour : (dateTime.hour - 12))}:${GeneralUtils().rewriteTimeValue(dateTime.minute)} ${dateTime.hour < 12 ? "AM" : "PM"}";
                                  } else {
                                    date =
                                        "${months[dateTime.month - 1]} ${dateTime.day}";
                                  }
                                  bool isConversationBlocked =
                                      conversation.isConversationBlocked ??
                                          false;
                                  String conversationBlockedByUid =
                                      conversation.conversationBlockedByUid ??
                                          "";
                                  return Dismissible(
                                      key: UniqueKey(),
                                      confirmDismiss: (direction) async {
                                        if (direction ==
                                            DismissDirection.endToStart) {
                                          bool? resp = await GeneralUtils()
                                              .displayReturnedValueAlertDialog(
                                                  context,
                                                  "Delete Conversation",
                                                  "Are you sure you want to delete this conversation for both users?",
                                                  "Delete",
                                                  "Cancel");
                                          resp ??= false;
                                          if (resp) {
                                            await ref
                                                .read(firebaseFirestoreProvider)
                                                .collection('conversations')
                                                .doc(conversation.id).delete();
                                            //     .update({
                                            //   "participants":
                                            //       FieldValue.arrayRemove(
                                            //           [GeneralUtils().userUid]),
                                            // });
                                            return true;
                                          }
                                          return false;
                                        }
                                        return false;
                                      },
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) {
                                        GeneralUtils.showToast(
                                            "Conversation deleted");
                                        if (direction ==
                                            DismissDirection.endToStart) {

                                        }
                                      },
                                      child: Column(
                                        key: UniqueKey(),
                                        children: [
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                  '/chat',
                                                  arguments: conversation);
                                            },
                                            leading: SizedBox(
                                                width: 45,
                                                height: 45,
                                                child: GeneralUserAvatar(
                                                  45.0,
                                                  clickable: false,
                                                  avatarData:
                                                      participantImage, // (GeneralUtils().userUid == conversation.participants[0]) ? conversation.participantImages[1] : conversation.participantImages[0],
                                                )),
                                            title: Text(
                                              participant,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: bodyStyle.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      AppColors.dividerColor),
                                            ),
                                            subtitle: Text(
                                              (isConversationBlocked &&
                                                      conversationBlockedByUid ==
                                                          GeneralUtils()
                                                              .userUid)
                                                  ? "You blocked this user"
                                                  : conversation.latestMessage,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: bodyStyle.copyWith(
                                                  color: AppColors.grey600),
                                            ),
                                            trailing: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  date,
                                                  style: captionStyle.copyWith(
                                                      color: AppColors.grey900),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                conversation.unreadCounts > 0 &&
                                                        conversation
                                                                .latestMessageSender !=
                                                            GeneralUtils()
                                                                .userUid
                                                    ? Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration: BoxDecoration(
                                                            color: AppColors
                                                                .primaryBase,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child: Center(
                                                          child: Text(
                                                            conversation
                                                                .unreadCounts
                                                                .toString(),
                                                            style: captionStyle
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        10),
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox()
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 2,
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    colors: [
                                                  AppColors.dividerColor
                                                      .withOpacity(0),
                                                  AppColors.dividerColor
                                                      .withOpacity(0.2),
                                                  AppColors.dividerColor
                                                      .withOpacity(0)
                                                ],
                                                    stops: const [
                                                  0,
                                                  0.5,
                                                  1
                                                ],
                                                    begin: Alignment.centerLeft,
                                                    end:
                                                        Alignment.centerRight)),
                                          ),
                                          // const Divider(color: AppColors.grey100,)
                                        ],
                                      ));
                                },
                              ),
                            )
                          ],
                        ),
                      ))),
    );
  }

  Widget searchHeaderLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.35,
          child: SearchFieldWidget(
            _controller,
            width: MediaQuery.of(context).size.width / 1.35,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 0.0),
          child: GestureDetector(
            onTap: () async {
              await showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return FilterConversationBottomSheet((selection) {
                      filterConversationBySelection(selection);
                    });
                  },
                  isDismissible: false,
                  showDragHandle: true,
                  enableDrag: false,
                  backgroundColor: Colors.white);
            },
            child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/svg/filter.svg",
                    height: 20,
                    width: 20,
                  ),
                )),
          ),
        )
      ],
    );
  }

  void onSearchingConversation(String query) {
    if (query.isEmpty) {
      setState(() {
        conversations = allConversations;
      });
      return;
    }
    String q = query.toLowerCase();
    setState(() {
      conversations = allConversations
          .where((element) =>
              element.latestMessage.toLowerCase().contains(q) ||
              element.participantNames[0].toLowerCase().contains(q) ||
              element.participantNames[1].toLowerCase().contains(q))
          .toList();
    });
  }

  void filterConversationBySelection(String selection) {
    if (selection.isEmpty) {
      return;
    }

    if (selection == "all") {
      setState(() {
        conversations = allConversations;
      });
      return;
    }

    if (selection == "read") {
      setState(() {
        conversations = allConversations
            .where((element) =>
                element.unreadCounts == 0 ||
                element.latestMessageSender == GeneralUtils().userUid)
            .toList();
      });
      return;
    }

    if (selection == "unread") {
      setState(() {
        conversations = allConversations
            .where((element) =>
                element.unreadCounts > 0 &&
                element.latestMessageSender != GeneralUtils().userUid)
            .toList();
      });
      return;
    }
  }

  Widget ooo() {
    return AppBar(
      backgroundColor: Colors.white,
      toolbarHeight: 100.0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Container(
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
            color: AppColors.grey50, borderRadius: BorderRadius.circular(8.0)),
        width: MediaQuery.of(context).size.width,
        height: 45.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: SvgPicture.asset("assets/svg/home/search.svg"),
            ),
            const SizedBox(
              width: 10.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 170,
              height: 45,
              child: TextFormField(
                keyboardType: TextInputType.text,
                controller: _controller,
                maxLines: 1,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  onSearchingConversation(value);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search",
                  hintStyle: titleStyle.copyWith(color: AppColors.grey400),
                  labelStyle: titleStyle.copyWith(
                    color: AppColors.titleTextColor,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: InkWell(
            onTap: () async {
              await showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return FilterConversationBottomSheet((selection) {
                      filterConversationBySelection(selection);
                    });
                  },
                  isDismissible: false,
                  showDragHandle: true,
                  enableDrag: false,
                  backgroundColor: Colors.white);
            },
            child: SvgPicture.asset("assets/svg/filter.svg"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: InkWell(
            onTap: () async {
              Navigator.of(context).pushNamed("/search_users");
            },
            child: SvgPicture.asset("assets/svg/new_conversation.svg"),
          ),
        )
      ],
    );
  }
}
