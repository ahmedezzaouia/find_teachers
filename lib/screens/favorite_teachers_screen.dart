import 'package:flutter/material.dart';
import 'package:maroc_teachers/widgets/favorite_item.dart';

class FavoriteTeachersScreen extends StatefulWidget {
  static const routeNamed = 'favorite-teacher';

  @override
  _FavoriteTeachersScreenState createState() => _FavoriteTeachersScreenState();
}

class _FavoriteTeachersScreenState extends State<FavoriteTeachersScreen> {
  int currentIndex = 1;
  ontapTapped(index) {
    print(index);
    setState(() {
      currentIndex = index;
    });
    if (currentIndex == 0) {
      Navigator.of(context).pushReplacementNamed('/');
    } else if (currentIndex == 1) {
      Navigator.of(context).pushReplacementNamed(
          FavoriteTeachersScreen.routeNamed,
          arguments: ontapTapped);
    } else {
      print('index 2 is taped');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('favorite teachers'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 25),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            )),
        child: GridView.builder(
          itemCount: 5,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 1,
            mainAxisSpacing: 3,
          ),
          itemBuilder: (ctx, index) => FavoriteItem(),
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
