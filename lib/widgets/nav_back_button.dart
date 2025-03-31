import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';

import '../size_config.dart';

class NavBackButton extends StatelessWidget {
  const NavBackButton(
      {Key? key, this.icon, this.onPress, this.color = AppColors.grey400})
      : super(key: key);

  final Widget? icon;
  final Function? onPress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getProportionateScreenHeight(35),
      width: getProportionateScreenWidth(35),
      child: GestureDetector(
        onTap: (onPress == null)
            ? () {
                Navigator.of(context).pop(false);
              }
            : onPress as void Function()?,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: (icon == null)
                  ? SvgPicture.asset(
                      "assets/svg/back.svg",
                      color: color,
                    )
                  : icon,
            ),
          ],
        ),
      ),
    );
  }
}

/**
 * Icon(
    Icons.arrow_back_ios,
    color: color,
    )
 * */