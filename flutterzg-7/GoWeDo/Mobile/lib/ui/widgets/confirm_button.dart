import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gowedo/util/my_colors.dart';

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({Key key, @required this.title, this.titleIcon, this.backgroundColor = MyColors.goWeDoBlue,
    this.titleColor = MyColors.goWeDoWhite, this.onTap, this.isEnabled = true})
    : super(key: key);

  final VoidCallback onTap;
  final Image titleIcon;
  final String title;
  final bool isEnabled;
  final Color backgroundColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      pressedOpacity: 0.9,
      onPressed: () {
        if (isEnabled && onTap != null) {
          onTap();
        }
      },
      child: Container(
        height: 48,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (titleIcon != null)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: titleIcon,
                ),
              Text(
                title,
                style: Theme.of(context).textTheme.title.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: titleColor)
              ),
            ],
          ),
        ),
        foregroundDecoration: BoxDecoration(
          color: isEnabled ? Colors.transparent : Colors.white.withOpacity(0.4)
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor,
        ),
      )
    );
  }
}
