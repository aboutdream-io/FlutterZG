import 'package:flutter/material.dart';
import 'package:hnpwa_client/hnpwa_client.dart';
import 'package:html/parser.dart';

class CommentItem extends StatelessWidget {
  CommentItem({Key key, this.comment, this.depth = 0}) : super(key: key);

  Item comment;
  int depth;

  Color _getCommentColor(){
    return Colors.accents[depth % Colors.accents.length];
  }

  @override
  Widget build(BuildContext context) {
    const double _indicatorSize = 10.0;
    final double _moveLeft = _indicatorSize * depth;

    return Container(
      color: _getCommentColor().withOpacity(0.1),
      margin: EdgeInsets.only(left: _moveLeft),
      child: Column(
        children: <Widget>[
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Container(
                  color: _getCommentColor(),
                  width: _indicatorSize,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(parse(comment.content).body.text),
                        const SizedBox(height: 20.0),
                        Text(comment.user),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 2.0,
            color: _getCommentColor(),
          )
        ],
      ),
    );
  }
}
