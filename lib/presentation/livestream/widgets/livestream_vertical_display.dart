
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave_new/presentation/livestream/models/livestream.dart';
import 'package:vwave_new/widgets/action_button.dart';

import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';

class LivestreamVerticalDisplay extends StatefulWidget {
  final Livestream livestream;
  const LivestreamVerticalDisplay(this.livestream, {super.key,});

  @override
  State<StatefulWidget> createState() => _LivestreamVerticalDisplay();
}

class _LivestreamVerticalDisplay extends State<LivestreamVerticalDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48) / 1.5,
      padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 12),
      margin: const EdgeInsets.only(right: 24.0, top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(
          color: AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                fit: BoxFit.fitWidth,
                height: 180.0,
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
                        borderRadius: BorderRadius.circular(22),
                        image: DecorationImage(image: i, fit: BoxFit.cover)
                    ),
                  );
                },
              ),
              Positioned(top: 10, right: 10,child: SvgPicture.asset("assets/svg/adult.svg"),),
            ],
          ),
          const SizedBox(height: 5,),
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
          const SizedBox(height: 5,),
          Text(
            widget.livestream.hasEnded ? "Your livestream just ended" : "You are currently live",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: captionStyle.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.grey900
            ),
          ),
          const SizedBox(height: 10,),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 62) / 2.5,
            height: 45,
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
        ],
      ),
    );
  }
}