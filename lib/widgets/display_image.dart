// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/svg.dart';

class DisplayNetworkImage extends StatefulWidget {
  const DisplayNetworkImage({
    Key? key,
    required this.imageUrl,
    required this.height, 
    required this.width,
    this.forPage, 
    this.isFromViewImage,
  }): super(key: key);
      
  final String imageUrl;
  final double? height;
  final double? width;
  final dynamic forPage;
  final bool? isFromViewImage;

  @override
  State<DisplayNetworkImage> createState() => _DisplayNetworkImageState();
}

class _DisplayNetworkImageState extends State<DisplayNetworkImage> {

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: widget.imageUrl != ''
        ? widget.imageUrl.split('.').last == "svg"
          ? SvgPicture.network(widget.imageUrl)
          : CachedNetworkImage(
            fit: BoxFit.contain,
            // fit: widget.isFromViewImage == true ? BoxFit.contain : BoxFit.cover,
            width: widget.width,
            height: widget.height,
            placeholder: (context, url) => const CustomShimmer(),
            imageUrl: widget.imageUrl,
            errorWidget: (context, url,_) => placeHolder(),
          )
        : placeHolder()
    );
  }

  placeHolder() {
    return Image.asset(
      'assets/img/splash.png',
      width: widget.width,
      height: widget.height,
      fit: BoxFit.contain,
    );
  }

}

class CustomShimmer extends StatelessWidget {
  const CustomShimmer({
    Key? key,
    this.height = 30.0,
    this.width = 200.0,
    this.isCircular = false,
    this.radius,
  }) : super(key: key);
  final double? height;
  final double? width;
  final bool? isCircular;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius ?? 0),
        ),
      ),
    );
  }
}