import 'package:flutter/material.dart';
import 'package:saera/style/font.dart';

class SubTitleSection extends StatefulWidget {
  SubTitleSection({Key? key, required this.subtitle, required this.desc}) : super(key: key);

  String subtitle;
  String desc;

  @override
  State<SubTitleSection> createState() => _SubTitleSectionState();
}

class _SubTitleSectionState extends State<SubTitleSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.subtitle,
            style: TextStyles.medium00BoldTextStyle,

          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Text(
            widget.desc,
            style: TextStyles.small55TextStyle,
          ),
        )
      ],
    );
  }
}
