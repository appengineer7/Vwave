import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/presentation/club/widgets/popup.dart';

import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';

class ChatMessagePopupMenu extends StatefulWidget {
  const ChatMessagePopupMenu(this.controller,
      {super.key,
      required this.onSelectedMenuItem,
      required this.showUnSend,
      required this.child});

  final OverlayPortalController controller;
  final bool showUnSend;
  final Widget child;
  final Function(String selectedMenuItem) onSelectedMenuItem;

  @override
  State<StatefulWidget> createState() => _ChatMessagePopupMenuState();
}

class _ChatMessagePopupMenuState extends State<ChatMessagePopupMenu> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Popup(
      follower: ChatMessagePopupMenuOverlay(
        widget.controller.hide,
        widget.showUnSend,
        onSelectedMenuItem: (val) {
          widget.onSelectedMenuItem(val);
        },
      ),
      followerAnchor:
          widget.showUnSend ? Alignment.bottomRight : Alignment.topLeft,
      targetAnchor: widget.showUnSend ? Alignment.topRight : Alignment.topLeft,
      controller: widget.controller,
      child: GestureDetector(
        onTap: widget.controller.show,
        child: widget.child,
      ),
    );
  }
}

class ChatMessagePopupMenuOverlay extends StatefulWidget {
  const ChatMessagePopupMenuOverlay(this.hide, this.showUnSend,
      {super.key, required this.onSelectedMenuItem});

  final VoidCallback hide;
  final bool showUnSend;
  final Function(String selectedMenuItem) onSelectedMenuItem;

  @override
  State<StatefulWidget> createState() => _ChatMessagePopupMenuOverlay();
}

class _ChatMessagePopupMenuOverlay extends State<ChatMessagePopupMenuOverlay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () {
                widget.onSelectedMenuItem("copy");
                widget.hide();
              },
              label: Text(
                "Copy",
                style: bodyStyle.copyWith(color: AppColors.titleTextColor),
                textAlign: TextAlign.left,
              ),
              icon: const Icon(
                Icons.copy,
                color: AppColors.titleTextColor,
              ),
            ),
            // TextButton.icon(onPressed: (){widget.onSelectedMenuItem("delete for you");widget.hide();}, label: Text("Delete for you", style: bodyStyle.copyWith(color: AppColors.titleTextColor), textAlign: TextAlign.left,), icon: const Icon(Icons.delete, color: AppColors.titleTextColor,),),
            if (widget.showUnSend)
              TextButton.icon(
                onPressed: () {
                  widget.onSelectedMenuItem("unsend");
                  widget.hide();
                },
                label: Text(
                  "Unsend",
                  style: bodyStyle.copyWith(color: AppColors.titleTextColor),
                  textAlign: TextAlign.left,
                ),
                icon: const Icon(
                  Icons.backspace_outlined,
                  color: AppColors.errorColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
