
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vwave/widgets/nav_back_button.dart';

import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';


class GalleryViewPage extends StatefulWidget {
  final List<dynamic> images;
  const GalleryViewPage(this.images, {super.key});

  @override
  State<StatefulWidget> createState() => _GalleryViewPage();
}

class _GalleryViewPage extends State<GalleryViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text("Gallery", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
        // title: Text(
        //   "Donate to us",
        //   style: titleStyle.copyWith(fontWeight: FontWeight.w700),
        // ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.all(24),
        child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 4 / 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ), itemBuilder: (context, index) {
          dynamic image = widget.images[index];
          return SizedBox(
            height: 100,
            child: GestureDetector(
              onTap: (){
                Navigator.of(context).pushNamed("/view_full_image", arguments: {"media": widget.images, "index": index});
              },
              child: Stack(
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: image["fileType"] == "video" ? image["thumbnailUrl"] : image["url"],
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(),
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
                  (image["fileType"] == "video") ? const Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.play_arrow_rounded, size: 64, color: AppColors.primaryBase, shadows: [Shadow(color: Colors.white, blurRadius: 10.5, offset: Offset(0, 0))],),
                  ) : const SizedBox()
                ],
              )
            ),
          );
        }, itemCount: widget.images.length,),
      ),
    );
  }
}