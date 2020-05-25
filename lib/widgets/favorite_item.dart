import 'package:flutter/material.dart';

class FavoriteItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(5),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(
                    'https://www.sprintcv.com/assets/sprintcv-helps-java-consultant-to-generate-amazing-cv-1228395647dab08deb54ccec4dd549db6477ded6803a1f00ac7fbc499b66555c.jpg'),
              ),
              IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 30,
                  ),
                  onPressed: () {})
            ],
          ),
          SizedBox(height: 5),
          Text(
            'Enrico Fermi',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          Text('Teach informatique',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: 5),
          Text(
            'is an American actor,producer, and environmentalist.He has often played unconventional parts',
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
