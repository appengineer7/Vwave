
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageDisplayWidget extends StatelessWidget {
  final String postImage;

  const ImageDisplayWidget(this.postImage, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CachedNetworkImage(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.contain,
        imageUrl: postImage,
        //cancelToken: cancellationToken,
      ),
    );
  }
}