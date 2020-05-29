import 'package:flutter/material.dart';
import '../providers/teacher_provider.dart';
import 'package:provider/provider.dart';
import './favorite_teachers_screen.dart';
import './teacher_management_screen.dart';
import '../widgets/appdrawer.dart';
import '../widgets/subjects_item.dart';
import '../modals/category.dart';

class SubjectsScreen extends StatefulWidget {
  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  int currentIndex = 0;
  ontapTapped(index) {
    print(index);
    setState(() {
      currentIndex = index;
    });
    if (currentIndex == 0) {
      Navigator.of(context).pushReplacementNamed('/');
    } else if (currentIndex == 1) {
      Navigator.of(context)
          .pushReplacementNamed(FavoriteTeachersScreen.routeNamed);
    } else {
      Navigator.of(context)
          .pushReplacementNamed(TeacherManagementScreen.routeNamed);
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then(
      (_) {
        Provider.of<TeacherProvider>(context, listen: false).getAndSetdata();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('subjects screen build');
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Teachers'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.asset(
              'assets/appbar_image.png',
              fit: BoxFit.cover,
              height: 200,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              color: Colors.white,
              height: size.height / 2 + 100,
              width: size.width,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 2.5,
                  mainAxisSpacing: 2,
                ),
                itemBuilder: (ctx, index) =>
                    SubjectItem(category: categories[index]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
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
