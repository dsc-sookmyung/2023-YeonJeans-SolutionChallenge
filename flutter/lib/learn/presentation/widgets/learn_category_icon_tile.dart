import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saera/learn/search_learn/presentation/search_learn_screen.dart';

import '../../../style/color.dart';
import '../../../style/font.dart';

class CategoryIconTile extends StatelessWidget {
  const CategoryIconTile(this._data);

  final CategoryData _data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(_data.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => SearchPage(value: _data.text),
                ));
              },
              icon: Icon(
                _data.icon,
                size: 40,
                color: _data.iconColor,
              )
          ),
          Text(
            "  ${_data.text}",
            style: TextStyles.regularBlueTextStyle,
            //글씨는 어떻게 할지.. 고민
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

class CategoryData {
  final IconData icon;
  final String text;
  final Color iconColor;
  final double padding;

  CategoryData(this.icon, this.text, this.iconColor, this.padding);
}