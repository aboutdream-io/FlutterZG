import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gowedo/util/my_colors.dart';
import 'package:gowedo/util/my_images.dart';
import 'package:gowedo/util/my_localization.dart';

/// Dialog where [title] is placed above the dialog, dialog body
/// is wrapped with material design card where another widget [child] can
/// be added
class InfoDialog extends StatelessWidget {
  /// Creates a dialog.
  ///
  /// Typically used in conjunction with [showDialog].
  const InfoDialog({Key key, @required this.title, this.message, this.showConfirmButton = false, this.confirmButtonTitle}) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget title;
  final Widget message;
  final bool showConfirmButton;
  final String confirmButtonTitle;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black.withOpacity(0.45),
      body: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
        child: SafeArea(
          child: OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) {
              return Stack(
                children: <Widget>[
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    margin: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
                          child: Image.asset(MyImages.closeIcon, height: 28, color: MyColors.goWeDoWhite),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: orientation == Orientation.portrait ? 200.0 : 100, left: 20.0, right: 20.0),
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 34.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).dialogBackgroundColor,
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        direction: Axis.horizontal,
                        runSpacing: 10.0,
                        children: <Widget>[
                          title,
                          SizedBox(width: MediaQuery.of(context).size.width),
                          message ?? const SizedBox()
                        ],
                      )
                    ),
                  ),
                  _getConfirmWidget(context)
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _getConfirmWidget(BuildContext context) {
    if (!showConfirmButton) {
      return const SizedBox();
    }
    return Container(
      alignment: Alignment.bottomCenter,
      child: FlatButton(
        child: Text(confirmButtonTitle ?? MyLocalization.of(context).confirm),
        onPressed: () => Navigator.of(context).pop(true),
      )
    );
  }
}
