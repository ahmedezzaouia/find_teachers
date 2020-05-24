import 'package:flutter/material.dart';
import 'package:maroc_teachers/widgets/subjects_item.dart';
import '../modals/category.dart';

class SubjectsScreen extends StatefulWidget {
  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Teachers'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text('Home')),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), title: Text('Favorite')),
            BottomNavigationBarItem(
                icon: Icon(Icons.supervised_user_circle),
                title: Text('Management')),
          ]),
    );
  }
}
