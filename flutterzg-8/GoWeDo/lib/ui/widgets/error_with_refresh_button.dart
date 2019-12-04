import 'package:flutter/material.dart';
import 'package:gowedo/util/api_client.dart';
import 'package:gowedo/util/my_localization.dart';

class ErrorWithRefreshButton extends StatelessWidget {
  const ErrorWithRefreshButton({Key key, this.error, this.onRefreshClicked}) : super(key: key);

  final Object error;
  final VoidCallback onRefreshClicked;

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    if (error is GoWeDoError ) {
      if ((error as GoWeDoError).errorType == ErrorType.noConnection) {
        errorMessage = MyLocalization.of(context).noConnection;
      } else {
        errorMessage = MyLocalization.of(context).genericErrorMessage;
      }

    } else if (error is String) {
      errorMessage = error;

    } else {
      errorMessage = error.toString();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 36, vertical: 120),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(MyLocalization.of(context).genericErrorTitle,
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Text(errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(17.0),
              child: Icon(Icons.refresh, size: 36),
            ),
            borderRadius: BorderRadius.circular(24),
            onTap: () => onRefreshClicked(),
          )
        ],
      ),
    );
  }
}
