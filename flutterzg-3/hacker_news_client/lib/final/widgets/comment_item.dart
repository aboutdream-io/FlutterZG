import 'package:flutter/material.dart';
import 'package:hnpwa_client/hnpwa_client.dart';
import 'package:html/parser.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({Key key, this.depth = 0, this.comment}) : super(key: key);

  final int depth;
  final Item comment;

  Color _getCommentColor(){
    return (Colors.accents.length - 1) <= depth ? Colors.red : Colors.accents[depth] ?? Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    const double _indicatorSize = 10.0;
    final double _moveLeft = _indicatorSize * depth;

    return Container(
      color: _getCommentColor().withOpacity(0.06),
      margin: EdgeInsets.only(left: _moveLeft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  width: _indicatorSize,
                  color: _getCommentColor(),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(parse(comment.content).body.text),
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(comment.user ?? '[deleted]'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - _moveLeft,
            height: _indicatorSize * 0.1,
            color: _getCommentColor(),
          ),
        ],
      ),
    );
  }
}