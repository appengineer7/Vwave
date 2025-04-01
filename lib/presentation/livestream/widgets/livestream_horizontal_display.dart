
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/presentation/livestream/models/livestream.dart';
import 'package:vwave/widgets/action_button.dart';

import '../../../utils/general.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';

class LivestreamHorizontalDisplay extends StatefulWidget {
  final Livestream livestream;
  final bool userView;
  const LivestreamHorizontalDisplay(this.livestream, {super.key, this.userView = false});

  @override
  State<StatefulWidget> createState() => _LivestreamHorizontalDisplay();
}

class _LivestreamHorizontalDisplay extends State<LivestreamHorizontalDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48),
      height: 150,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(
          color: AppColors.grey200,
        ),
      ),
      child: buildLayout(),
    );
  }

  Widget buildLayout() {
    if(widget.userView) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                CachedNetworkImage(
                  fit: BoxFit.cover,
                  height: 120.0,
                  // width: (MediaQuery.of(context).size.width - 66) / 1.5,
                  imageUrl: widget.livestream.images[0]["url"],
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
                  imageBuilder: (c, i) {
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                          image: DecorationImage(image: i, fit: BoxFit.cover)
                      ),
                    );
                  },
                ),
                Positioned(top: 10, right: 10,child: SvgPicture.asset("assets/svg/adult.svg"),),
              ],
            ),
          ),
          const SizedBox(width: 15,),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 220),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.livestream.title,
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
                    title: Text(widget.livestream.locationDetails["address"], softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: captionStyle.copyWith(fontWeight: FontWeight.w400, color: AppColors.grey900),
                    ),
                    horizontalTitleGap: 5,
                    minLeadingWidth: 0,
                  ),
                  Row(
                    children: [
                      Wrap(
                        runSpacing: 0,
                        spacing: 10,
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).pushNamed("/livestream_view", arguments: widget.livestream);
                            },
                            child: Chip(
                              label: Text("Join Now", maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: captionStyle.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              backgroundColor: AppColors.primaryBase,
                              side: BorderSide.none,
                            ),
                          ),
                          Chip(
                            label: Row(
                              children: [
                                SvgPicture.asset("assets/svg/eye_on.svg", height: 12, color: Colors.white,),
                                const SizedBox(width: 5,),
                                Text(GeneralUtils().shortenLargeNumber(num: widget.livestream.liveViews == null ? 0 : widget.livestream.liveViews!.toDouble()), maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: captionStyle.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.grey600,
                            side: BorderSide.none,
                          )
                        ],
                      ),
                    ],
                  ),
                ]
            ),
          )
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            children: [
              CachedNetworkImage(
                fit: BoxFit.cover,
                height: 120.0,
                // width: (MediaQuery.of(context).size.width - 66) / 1.5,
                imageUrl: widget.livestream.images[0]["url"],
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) =>
                const Icon(Icons.error),
                imageBuilder: (c, i) {
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        image: DecorationImage(image: i, fit: BoxFit.cover)
                    ),
                  );
                },
              ),
              Positioned(top: 10, right: 10,child: SvgPicture.asset("assets/svg/adult.svg"),),
            ],
          ),
        ),
        const SizedBox(width: 15,),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 230),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10,),
                Text(
                  widget.livestream.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: titleStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey900
                  ),
                ),
                const SizedBox(height: 2,),
                Text(
                  widget.livestream.hasEnded ? "Your livestream just ended with ${GeneralUtils().shortenLargeNumber(num: widget.livestream.views.toDouble())} ${widget.livestream.views <= 1 ? "view" : "views"}" : "You are currently live",
                  maxLines: 2,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: captionStyle.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey900
                  ),
                ),
                const SizedBox(height: 3,),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 62) / 2.5,
                  height: 40,
                  child: ActionButton(
                    text: widget.livestream.hasEnded ? "View details" : "Resume live",
                    padding: const EdgeInsets.all(10),
                    textStyle: titleStyle.copyWith(color: Colors.white),
                    onPressed: (){
                      if(widget.livestream.hasEnded) {
                        Navigator.of(context).pushNamed(
                            "/livestream_details", arguments: widget.livestream);
                        return;
                      }
                      Navigator.of(context).pushNamed("/livestream_view", arguments: widget.livestream);
                    },
                  ),
                ),
                const SizedBox(height: 15,),
              ]
          ),
        )
      ],
    );
  }
}