import 'package:flutter/material.dart';
import 'package:maroc_teachers/modals/education.dart';

class EducationItem extends StatelessWidget {
  final Education education;
  final Function(String id) deleteEd;
  final bool isProfilePage;
  EducationItem({this.education, this.deleteEd, this.isProfilePage = false});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (isProfilePage) _dotButtonWidget(),
            _columnWidget(),
            isProfilePage
                ? Container()
                : IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteEd(education.id);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Column _columnWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 290,
          child: Text(
            education.diploma,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 3),
        Text(
          education.schoolOrUniversity,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          '${education.startYear} – ${education.endYear}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  Container _dotButtonWidget() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
