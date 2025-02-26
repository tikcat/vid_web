import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vid_web/util/my_logger.dart';

class ImageLoader {
  // 加载本地资源图片
  static Widget loadAssetImage(String assetName, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return Image.asset(
      assetName,
      width: width,
      height: height,
      fit: fit,
    );
  }

  /// 加载网络图片，有缓存
  static Widget loadNetImageCache(
    String imageUrl, {
    double? width,
    double? height,
    double ltCornerRadius = 0.0,
    double rtCornerRadius = 0.0,
    double lbCornerRadius = 0.0,
    double rbCornerRadius = 0.0,
    bool darkTheme = false,
    String errorImage = 'assets/images/error_placehoolder.png',
  }) {
    if (ltCornerRadius > 0 || rtCornerRadius > 0 || lbCornerRadius > 0 || rbCornerRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ltCornerRadius),
          topRight: Radius.circular(rtCornerRadius),
          bottomLeft: Radius.circular(lbCornerRadius),
          bottomRight: Radius.circular(rbCornerRadius),
        ),
        child: _loadNetworkImage(imageUrl, darkTheme: darkTheme, width: width, height: height),
      );
    } else {
      return _loadNetworkImage(imageUrl, darkTheme: darkTheme, width: width, height: height);
    }
  }

  static Widget _loadNetworkImage(
    String imageUrl, {
    double? width,
    double? height,
    bool darkTheme = false,
    String errorImage = 'assets/images/error_placehoolder.png',
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        );
      },
      placeholder: (context, url) {
        return _buildShimmerPlaceholder(width, height, darkTheme);
      },
      errorWidget: (context, url, error) {
        return Image.asset(
          errorImage,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      },
    );
  }

  // 加载网络图片
  static Widget loadNetworkImage(String url,
      {double? width,
      double? height,
      double cornerRadius = 0.0,
      bool isRound = false,
      BoxFit fit = BoxFit.cover,
      String placeholder = 'assets/images/default_image.png',
      String errorImage = 'assets/images/error_placehoolder.png'}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            mLogger.d("加载图片进度 cumulativeBytesLoaded:${loadingProgress.cumulativeBytesLoaded} - expectedTotalBytes:${loadingProgress.expectedTotalBytes}");
            return Center(
              child: LinearProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null,
              ),
            );
          }
        },
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return Image.asset(
            errorImage,
            width: width,
            height: height,
            fit: fit,
          );
        },
      ),
    );
  }

  static Widget loadIcon(String url, {double size = 48.0, Color? iconColor = Colors.blue}) {
    if (iconColor != null) {
      return ImageIcon(
        AssetImage(url),
        size: size,
        color: iconColor,
      );
    } else {
      return ImageIcon(
        AssetImage(url),
        size: size,
      );
    }
  }

  static Widget _buildShimmerPlaceholder(double? width, double? height, bool darkTheme) {
    return Shimmer.fromColors(
      baseColor: darkTheme ? Colors.grey[900]! : Colors.grey[300]!,
      highlightColor: darkTheme ? Colors.grey[850]! : Colors.grey[100]!,
      child: Container(color: darkTheme ? Colors.grey[900]! : Colors.grey[300], height: height, width: width),
    );
  }
}
