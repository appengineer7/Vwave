
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';


class EmptyScreen extends StatelessWidget {
  final String text;
  final String image;
  final Color bgColor;
  final Color textColor;
  final Widget bottomChild;
  final TextStyle textStyle;
  final double imageHeight;
  final double bottomPadding;
  final double topPadding;
  final double? height;

  const EmptyScreen(this.text,
      {Key? key, this.bgColor = Colors.white, this.imageHeight = 300.0, this.bottomPadding = 40,
        this.image = "assets/images/empty_club_home.png", this.height, this.topPadding = 100.0,
        this.bottomChild = const Text(""), this.textStyle = bodyStyle, this.textColor = AppColors.grey600}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: height ?? MediaQuery.of(context).size.height,
      color: bgColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding:
                EdgeInsets.only(top: mediaQueryData.padding.top + topPadding)),
            (image.contains(".png"))
                ? Image.asset(
              image,
              height: imageHeight,
            )
                : SvgPicture.asset(
              image,
              height: imageHeight,
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10.0)),
            Text(
              text,
              style: textStyle.copyWith(color: textColor),
            ),
            Padding(padding: EdgeInsets.only(bottom: bottomPadding)),
            bottomChild
          ],
        ),
      ),
    );
  }
}
