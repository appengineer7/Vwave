
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave_new/presentation/livestream/models/livestream.dart';
import 'package:vwave_new/utils/general.dart';
import 'package:vwave_new/widgets/action_button.dart';

import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';

class LivestreamHorizontalFullDisplay extends StatefulWidget {
  final Livestream livestream;
  final bool allowRightMargin;
  const LivestreamHorizontalFullDisplay(this.livestream, {super.key, this.allowRightMargin = true});

  @override
  State<StatefulWidget> createState() => _LivestreamHorizontalFullDisplay();
}

class _LivestreamHorizontalFullDisplay extends State<LivestreamHorizontalFullDisplay> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed("/livestream_view", arguments: widget.livestream);
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 80),
        height: 150,
        margin: EdgeInsets.only(top: 20, right: widget.allowRightMargin ? 20 : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.0),
          // border: Border.all(
          //   color: AppColors.grey900,
          // ),
        ),
        child: Stack(
          children: [
            CachedNetworkImage(
              fit: BoxFit.fitWidth,
              height: 150.0,
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
                      borderRadius: BorderRadius.circular(28),
                      image: DecorationImage(image: i, fit: BoxFit.fitWidth)
                  ),
                );
              },
            ),
            Positioned(top: 10, right: 10,child: SvgPicture.asset("assets/svg/adult.svg"),),
            // Padding(padding: const EdgeInsets.only(top: 10, left: 20), child: Text(
            //   widget.livestream.title,
            //   maxLines: 1,
            //   overflow: TextOverflow.ellipsis,
            //   textAlign: TextAlign.start,
            //   style: titleStyle.copyWith(
            //       fontWeight: FontWeight.w700,
            //       color: Colors.white
            //   ),
            // ),),
            Positioned(
              bottom: 10,
              right: 10,
              child: Row(
                children: [
                  Wrap(
                    runSpacing: 0,
                    spacing: 10,
                    children: [
                      Chip(
                        label: Text("LIVE", maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: captionStyle.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        backgroundColor: AppColors.secondaryBase,
                        side: BorderSide.none,
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}