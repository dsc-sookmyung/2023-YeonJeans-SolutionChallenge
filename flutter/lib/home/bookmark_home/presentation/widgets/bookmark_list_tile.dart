import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saera/style/color.dart';
import 'package:saera/style/font.dart';

class BookmarkListTile extends StatelessWidget {
  BookmarkListTile(this._data);

  final BookmarkListData _data;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 11),
      title: Transform.translate(
        offset: const Offset(0, 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _data.statement,
                  style: TextStyles.regular00TextStyle
                ),
                Row(
                  children: [
                    Chip(
                      backgroundColor: ColorStyles.saeraBeige,
                      label: Text(
                        _data.tag,
                        style: TextStyles.small00TextStyle
                        ),
                      ),
                  ],
                )
              ],
            ),
            IconButton(
                onPressed: null,
                icon: SvgPicture.asset('assets/icons/star_fill.svg')
            )
          ],
        ),
      )
    );
  }
}

class BookmarkListData {
  final String statement;
  final String tag;

  BookmarkListData(this.statement, this.tag);
}