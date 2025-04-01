
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/presentation/club/models/club.dart';
import 'package:vwave/presentation/club/providers/club_notifier_provider.dart';
import 'package:vwave/presentation/livestream/models/livestream.dart';
import 'package:vwave/utils/general.dart';
import 'package:vwave/utils/storage.dart';
import 'package:vwave/widgets/action_button.dart';

import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../../widgets/user_avatar.dart';
import '../repositories/club_repository.dart';

class ClubVerticalDisplay extends ConsumerStatefulWidget {
  final Club club;
  final bool showReviews;
  final double width;
  final double marginRight;
  final double reviewsImageSize;
  final Function(Club club)? onLongPressed;
  final bool showFavIcon;
  const ClubVerticalDisplay(this.club, {super.key, required this.showReviews, required this.width, this.marginRight = 24.0, this.reviewsImageSize = 40, this.onLongPressed, this.showFavIcon = true});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClubVerticalDisplay();
}

class _ClubVerticalDisplay extends ConsumerState<ClubVerticalDisplay> {

  StorageSystem ss = StorageSystem();
  bool clubLiked = false;

  @override
  void initState() {
    super.initState();
    // isClubLiked();
  }

  void isClubLiked() {
    Future.delayed(Duration.zero, () async {
      String? isSaved = await ss.getItem("club_${widget.club.id}");
      if(!mounted) return;
      setState(() {
        clubLiked = isSaved == "true";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.club.recentReviews.length);
    isClubLiked();
    return Container(
      width: widget.width,
      height: 350,
      padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 12),
      margin: EdgeInsets.only(right: widget.marginRight, top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(
          color: AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed("/club_details", arguments: widget.club);
            },
            onLongPress: (){
              if(widget.onLongPressed != null) {
                widget.onLongPressed!(widget.club);
              }
            },
            child: Stack(
              children: [
                CachedNetworkImage(
                  fit: BoxFit.fitWidth,
                  height: 180.0,
                  // width: (MediaQuery.of(context).size.width - 66) / 1.5,
                  imageUrl: widget.club.coverImages[0]["url"],
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
                  imageBuilder: (c, i) {
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          image: DecorationImage(image: i, fit: BoxFit.cover)
                      ),
                    );
                  },
                ),
                Positioned(top: 10, right: 10,child: SvgPicture.asset("assets/svg/adult.svg"),),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Text(
            widget.club.clubName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: titleStyle.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.grey900
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            leading: SvgPicture.asset("assets/svg/location.svg", height: 15,),
            title: Text(widget.club.location["secondary_text"] == "" ? widget.club.locationDetails["address"].split(",")[0] : widget.club.location["secondary_text"], softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: captionStyle.copyWith(fontWeight: FontWeight.w400, color: AppColors.grey900),
            ),
            trailing: widget.showFavIcon ? GestureDetector(
              onTap: () async {
                String? isSaved = await ss.getItem("club_${widget.club.id}");
                if (isSaved == "true") {
                  // await ss.deletePref("club_${widget.club.id}");
                  setState(() {
                    clubLiked = false;
                  });
                } else {
                  setState(() {
                    clubLiked = true;
                  });
                }
                ref.read(clubNotifierProvider.notifier).saveFavoriteClubs(widget.club);
              },
              child: clubLiked ? SvgPicture.asset("assets/svg/heart.svg", height: 20,) : SvgPicture.asset("assets/svg/heart_outline.svg", height: 20,),
            ) : null,
            horizontalTitleGap: 5,
            minLeadingWidth: 0,
          ),
          (widget.showReviews && widget.club.recentReviews.isNotEmpty) ? Row(
            children: [
              Stack(
                  children: [
                    (widget.club.recentReviews.isNotEmpty)
                        ? GeneralUserAvatar(widget.reviewsImageSize, avatarData: widget.club.recentReviews.first["image"],)
                    // CircleAvatar(
                    //   radius: widget.reviewsImageSize / 2,
                    //     backgroundImage: getImageProviderWithUrl(widget.club.recentReviews.first["image"]))
                        : const SizedBox(),
                    (widget.club.recentReviews.length >= 2)
                        ? Container(
                      margin:
                      const EdgeInsets.only(left: 30.0),
                      child: GeneralUserAvatar(widget.reviewsImageSize, avatarData: widget.club.recentReviews[1]["image"],),
                      // CircleAvatar(
                      //     radius: widget.reviewsImageSize / 2,
                      //     backgroundImage: getImageProviderWithUrl(widget.club.recentReviews[1]["image"])),
                    )
                        : const SizedBox(),
                    (widget.club.totalReviews >= 4)
                        ?
                    Container(
                      width: widget.reviewsImageSize,
                      height: widget.reviewsImageSize,
                      margin:
                      const EdgeInsets.only(left: 60.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBase,
                        borderRadius: BorderRadius.circular(widget.reviewsImageSize,)
                      ),
                      child: Center(
                        child: Text("${GeneralUtils().shortenLargeNumber(num: (widget.club.totalReviews - 3).toDouble())}+", maxLines: 1, overflow: TextOverflow.fade, //members.length
                            style: captionStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 8)),
                      )
                    )
                        : const SizedBox(),
                    // (widget.club.recentReviews.length >= 3 && widget.club.totalReviews > 0) // remove =?
                    Container(
                      margin: EdgeInsets.only(
                          left: (widget.club.recentReviews.length == 1)
                              ? 50.0
                              : (widget.club.recentReviews.length == 2)
                              ? 80.0
                              : 110.0,
                          top: 10.0),
                      child: Text("", softWrap: true, maxLines: 1, overflow: TextOverflow.ellipsis, //members.length
                          style: captionStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w500)),
                    )
                  ]
              )
            ],
          ) : const SizedBox(),
          (widget.showReviews && widget.club.recentReviews.isEmpty) ? Text("0 Reviews", softWrap: true, maxLines: 1, overflow: TextOverflow.ellipsis, //members.length
            style: bodyStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w500)) : const SizedBox(),
          SizedBox(height: (widget.showReviews && widget.club.recentReviews.isNotEmpty) ? 15 : 0,),
        ],
      ),
    );
  }

  ImageProvider<Object> getImageProviderWithUrl(String? imageUrl) {
    if(imageUrl == null) {
      return const AssetImage("assets/images/default_avatar.png");
    }
    if(imageUrl.isEmpty) {
      return const AssetImage("assets/images/default_avatar.png");
    }
    return NetworkImage(imageUrl);
  }
}