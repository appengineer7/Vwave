import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_screenshot_widget/share_screenshot_widget.dart';

import '../../../../services/dynamic_link.dart';
import '../../../../utils/general.dart';
import '../../../../utils/storage.dart';
import '../../../../widgets/nav_back_button.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';

class InviteFriendsPage extends ConsumerStatefulWidget {
  const InviteFriendsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InviteFriendsPageState();
}

class _InviteFriendsPageState extends ConsumerState<InviteFriendsPage> {

  StorageSystem ss = StorageSystem();
  GlobalKey key = GlobalKey();
  String? dynamicLink;

  Future<void> inviteFriends() async {
    String? getDL = await ss.getItem("user_dynamic_link");
    if(getDL != null && getDL != "") {
      setState(() {
        dynamicLink = getDL;
      });
      return;
    }
    String getUser = (await ss.getItem('user'))!;
    final user = jsonDecode(getUser);
    user["location_details"] = {};
    user["location"] = {};

    String data = GeneralUtils().encodeValue(jsonEncode(user));

    String link = await WaveDynamicLink.createDynamicLink(
        GeneralUtils().userUid ?? "",
        "${user["first_name"]} ${user["last_name"]}",
        user["bio"],
        user["picture"], "user", data);

    setState(() {
      dynamicLink = link;
    });

    await ss.setPrefItem("user_dynamic_link", dynamicLink ?? "");
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await inviteFriends();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
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
            "Invite Friends",
            style: titleStyle.copyWith(
                color: AppColors.grey900, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: (dynamicLink == null) ? const Center(
                  child: CircularProgressIndicator(),
                ) : Center(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShareScreenshotAsImage(
                        globalKey: key,
                        child: Container(
                          color: Colors.white,
                          child: PrettyQrView.data(
                            data: dynamicLink ?? "",
                            decoration: const PrettyQrDecoration(
                              image: PrettyQrDecorationImage(
                                image: AssetImage('assets/images/logo.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Center(
                        child: Wrap(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await Clipboard.setData(ClipboardData(text: "$dynamicLink"));
                                GeneralUtils.showToast("copied");
                              },
                              child: Chip(
                                label: Text("Copy", maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: captionStyle.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                                backgroundColor: AppColors.secondaryBase,
                                side: BorderSide.none,
                              ),
                            ),
                            const SizedBox(width: 20,),
                            // GestureDetector(
                            //   onTap: () async {
                            //     final qrCode = QrCode.fromData(
                            //       data: dynamicLink ?? "",
                            //       errorCorrectLevel: QrErrorCorrectLevel.H,
                            //     );
                            //
                            //     final qrImage = QrImage(qrCode);
                            //     final qrImageBytes = await qrImage.toImageAsBytes(
                            //       size: 512,
                            //       format: ImageByteFormat.png,
                            //       decoration: const PrettyQrDecoration(
                            //           image: PrettyQrDecorationImage(
                            //             image: AssetImage('assets/images/logo.png'),
                            //           )
                            //       ),
                            //     );
                            //     final tempDir = await getApplicationDocumentsDirectory();
                            //     File file = File("${tempDir.path}/vwave/invitation_${DateTime.now().millisecondsSinceEpoch}.png")
                            //       ..createSync(recursive: true)
                            //       ..writeAsBytesSync(qrImageBytes!.buffer.asUint8List(qrImageBytes.offsetInBytes, qrImageBytes.lengthInBytes));
                            //   },
                            //   child: Chip(
                            //     label: Text("Download", maxLines: 1, overflow: TextOverflow.ellipsis,
                            //       style: captionStyle.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
                            //     ),
                            //     backgroundColor: AppColors.secondaryBase,
                            //     side: BorderSide.none,
                            //   ),
                            // ),
                            // const SizedBox(width: 20,),
                            GestureDetector(
                              onTap: () async {
                                // String body = "View my user page on the VWave app with this link.\n\n$dynamicLink";
                                // Share.share(body);
                                await shareWidgets(globalKey: key);
                              },
                              child: Chip(
                                label: Text("Share", maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: captionStyle.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                                backgroundColor: AppColors.primaryBase,
                                side: BorderSide.none,
                              ),
                            ),
                          ],
                        ),
                      )
                    ]
                ))
            )
        )
    );
  }
}
