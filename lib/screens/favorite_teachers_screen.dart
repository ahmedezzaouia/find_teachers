import 'package:flutter/material.dart';
import 'package:maroc_teachers/screens/subjects_screen.dart';
import '../providers/teacher.dart';
import '../providers/teacher_provider.dart';
import '../screens/teacher_management_screen.dart';
import '../widgets/favorite_item.dart';
import 'package:provider/provider.dart';

class FavoriteTeachersScreen extends StatefulWidget {
  static const routeNamed = '/favorite-teacher';

  @override
  _FavoriteTeachersScreenState createState() => _FavoriteTeachersScreenState();
}

class _FavoriteTeachersScreenState extends State<FavoriteTeachersScreen> {
  ontapTapped(index) {
    print(index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, SubjectsScreen.routeNamed);
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed(
          FavoriteTeachersScreen.routeNamed,
          arguments: ontapTapped);
    } else {
      Navigator.of(context)
          .pushReplacementNamed(TeacherManagementScreen.routeNamed);
    }
  }

  Consumer<TeacherProvider> buildConsumer() {
    return Consumer<TeacherProvider>(
      builder: (ctx, teach, _) => GridView.builder(
          itemCount: teach.getFavoriteList.length,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 1,
            mainAxisSpacing: 3,
          ),
          itemBuilder: (ctx, index) {
            Teacher teacher = teach.getFavoriteList[index];
            return ChangeNotifierProvider.value(
                value: teacher, child: FavoriteItem());
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('favorite screen build');
    final teachData = Provider.of<TeacherProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('favorite teachers'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 25),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            )),
        child: teachData.getFavoriteList.length != 0
            ? buildConsumer()
            : FutureBuilder<String>(
                future: teachData.checkFavorites(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  print('no favorite items ${snapshot.data}');

                  if (snapshot.data.contains('null')) {
                    print('no favorite items ${snapshot.data}');
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'add your Favorites teachers here.',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ));
                  }

                  return buildConsumer();
                }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: ontapTapped,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), title: Text('Favorite')),
          BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle),
              title: Text('Management')),
        ],
      ),
    );
  }
}
