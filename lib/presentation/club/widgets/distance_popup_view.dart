
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/presentation/club/widgets/popup.dart';

import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';

class DistanceSliderViewButton extends StatefulWidget {
  final double distance;
  final String siUnit;
  const DistanceSliderViewButton(this.controller, {super.key, required this.distance, required this.onSelectedDistance, required this.siUnit});

  final OverlayPortalController controller;
  final Function(double selectedDistance) onSelectedDistance;

  @override
  State<StatefulWidget> createState() => _DistanceSliderViewButton();
}

class _DistanceSliderViewButton extends State<DistanceSliderViewButton> {

  double dist = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      dist = widget.distance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Popup(
      follower: DistanceSliderViewButtonOverlay(widget.controller.hide, widget.distance.toDouble(), widget.siUnit, onSelectedDistance: (val) {
        setState(() {
          dist = val;
        });
        widget.onSelectedDistance(val);
      },),
      followerAnchor: Alignment.topRight,
      targetAnchor: Alignment.topRight,
      controller: widget.controller,
      child: GestureDetector(
        // style: OutlinedButton.styleFrom(
        //   padding: const EdgeInsets.symmetric(horizontal: 8),
        // ),
        onTap: widget.controller.show,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset("assets/svg/location.svg",),
            const SizedBox(width: 5,),
            Text("Location (within ${dist.ceil()} ${widget.siUnit})", maxLines: 1, overflow: TextOverflow.ellipsis,
              style: captionStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.grey600),
            ),
            const Icon(Icons.arrow_drop_down_rounded, color: AppColors.grey900,),
          ],
        ),
      ),
    );
  }
}

class DistanceSliderViewButtonOverlay extends StatefulWidget {
  const DistanceSliderViewButtonOverlay(this.hide, this.distance, this.unit, {super.key, required this.onSelectedDistance});

  final VoidCallback hide;
  final double distance;
  final String unit;
  final Function(double selectedDistance) onSelectedDistance;

  @override
  State<StatefulWidget> createState() => _DistanceSliderViewButtonOverlay();
}

class _DistanceSliderViewButtonOverlay extends State<DistanceSliderViewButtonOverlay> {

  double distance = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      distance = widget.distance;
    });
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
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change distance',
                    style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: widget.hide,
                    icon: const Icon(Icons.cancel, color: AppColors.alertDangerTextColor,),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: 200,
                height: 50,
                child: SliderTheme(
                    data: SliderThemeData(
                      showValueIndicator: ShowValueIndicator.always,
                      valueIndicatorColor: AppColors.alertSuccessBackgroundColors,
                      valueIndicatorTextStyle: bodyStyle.copyWith(color: AppColors.alertSuccessTextColor),
                    ),
                    child: Slider(value: distance, onChanged: (double value) {
                  setState(() {
                    distance = value;
                  });
                },
                      onChangeEnd: (double val) {
                      widget.onSelectedDistance(val);
                      widget.hide();
                      },
                  min: 1,
                  max: 1000,
                  label: "${distance.ceil()} ${widget.unit}",
                  thumbColor: AppColors.primaryBase,
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}