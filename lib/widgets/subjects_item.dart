import 'package:flutter/material.dart';
import '../modals/category.dart';

class SubjectItem extends StatelessWidget {
  final Category category;
  final Color color;
  final bool isSubjectSelected;
  SubjectItem({@required this.category, this.color, this.isSubjectSelected});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        margin: EdgeInsets.all(5),
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: color != null
                ? LinearGradient(
                    colors: isSubjectSelected
                        ? [
                            const Color(0xFF3366FF),
                            const Color(0xFF00CCFF),
                          ]
                        : [
                            const Color(0xFF3700B3),
                            const Color(0xFF6200EE),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 1.0],
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(flex: 2, child: Image.asset(category.categoryImage)),
              SizedBox(height: 10),
              Expanded(
                flex: 1,
                child: Text(
                  category.subjectName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSubjectSelected ? Colors.white : Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
