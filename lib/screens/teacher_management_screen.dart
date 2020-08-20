import 'package:flutter/material.dart';
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
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 8,
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
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ));
                      }
                      return Consumer<TeacherProvider>(
                          builder: (ctx, teach, child) {
                        return ListView.builder(
                          itemCount: teach.iteams.length,
                          itemBuilder: (BuildContext context, int index) =>
                              TeacherManagementItem(
                            teach: teach.iteams[index],
                          ),
                        );
                      });
                    }),
              ),
            ),
            Consumer<TeacherProvider>(
              builder: (ctx, teach, child) {
                return Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(1),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3366FF),
                          const Color(0xFF6244FF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.0, 1.0],
                      ),
                    ),
                    child: FlatButton.icon(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(EditTeacherScreen.routeNamed);
                      },
                      icon: Icon(
                        Icons.dvr,
                        size: 30,
                        color: Colors.white,
                      ),
                      label: Text(
                        teach.iteams.length <= 0
                            ? 'become a teacher'
                            : 'add more',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
