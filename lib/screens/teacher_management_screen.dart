import 'package:flutter/material.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/screens/edit_teacher_screen.dart';
import 'package:maroc_teachers/widgets/appdrawer.dart';
import '../providers/teacher_provider.dart';
import '../widgets/teacher_management_item.dart';
import 'package:provider/provider.dart';

class TeacherManagementScreen extends StatelessWidget {
  static const routeNamed = '/teacher-management';
  Future<String> _refreshProducts(BuildContext context) async {
    return await Provider.of<TeacherProvider>(context, listen: false)
        .getAndSetdata(filterByUser: true);
  }

  @override
  Widget build(BuildContext context) {
    print('Teacher managment screen build');
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Teacher Management'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add_circle,
              size: 35,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(EditTeacherScreen.routeNamed);
            },
          ),
          SizedBox(width: 5),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      drawer: AppDrawer(),
      body: Container(
        margin: EdgeInsets.only(top: 25),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          child: FutureBuilder<String>(
              future: _refreshProducts(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data.contains('{}')) {
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'add your profile here to show what you able to teach',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ));
                }
                return Consumer<TeacherProvider>(
                  builder: (ctx, teach, child) => ListView.builder(
                    itemCount: teach.iteams.length,
                    itemBuilder: (BuildContext context, int index) =>
                        TeacherManagementItem(
                      teach: teach.iteams[index],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
