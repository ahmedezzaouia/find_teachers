import 'package:cloud_firestore/cloud_firestore.dart';

class Education {
  final String schoolOrUniversity;
  final String diploma;
  final int startYear;
  final int endYear;
  final String id;

  Education({
    this.diploma,
    this.endYear,
    this.schoolOrUniversity,
    this.startYear,
    this.id,
  });

  factory Education.fromFireBase(DocumentSnapshot _snapshot) {
    var data = _snapshot.data;
    var education = data['education'];
    return Education(
      schoolOrUniversity: education['schoolOrUniversity'],
      diploma: education['diploma'],
      startYear: education['startYear'],
      endYear: education['endYear'],
    );
  }
}
