import 'package:flutter/material.dart';

class QRAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double appbarHeight;
  final Color? backgroundColor;

  final Widget? leftWidget;
  final Widget? leftSecondWidget;
  final Widget? centerWidget;
  final Widget? rightThirdWidget;
  final Widget? rightSecondWidget;
  final Widget? rightWidget;

  final double leftWidgetMargin;
  final double rightSecondWidgetMargin;
  final double rightSecondThirdWidgetMargin;
  final double rightWidgetMargin;

  const QRAppBar({
    super.key,
    required this.backgroundColor,
    this.appbarHeight = 75.0,
    this.rightWidgetMargin = 10.0,
    this.leftWidgetMargin = 5.0,
    this.rightSecondWidgetMargin = 5.0,
    this.rightSecondThirdWidgetMargin = 5.0,
    this.leftWidget,
    this.leftSecondWidget,
    this.centerWidget,
    this.rightThirdWidget,
    this.rightSecondWidget,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: appbarHeight,
      width: double.infinity,
      decoration: BoxDecoration(color: backgroundColor),
      padding: EdgeInsets.only(left: 10, top: 38, right: rightWidgetMargin, bottom: 12),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Row(
              children: [
                if (leftWidget != null) leftWidget!,
                if (leftWidget != null && leftSecondWidget != null) SizedBox(width: leftWidgetMargin),
                if (leftSecondWidget != null) leftSecondWidget!,
                const Spacer(),
                if (rightThirdWidget != null) rightThirdWidget!,
                if (rightThirdWidget != null && rightSecondWidget != null) SizedBox(width: rightSecondThirdWidgetMargin),
                if (rightSecondWidget != null) rightSecondWidget!,
                if (rightSecondWidget != null && rightWidget != null) SizedBox(width: rightSecondWidgetMargin),
                if (rightWidget != null) rightWidget!,
              ],
            ),
          ),
          if (centerWidget != null) Align(alignment: Alignment.center, child: centerWidget),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(75.0);
}
