import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:maroc_teachers/widgets/search_item.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  static const String routeNamed = '/search-screen';
  const SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String userSearch = '';
  // GlobalKey<AutoCompleteTextFieldState<SearchItem>> key = GlobalKey();
  TextEditingController _textController = TextEditingController();

  // List<SearchItem> _suggestions = [];

  // @override
  // void initState() {
  //   _textController.addListener(
  //     () {
  //       print('listen work:${_textController.text}');
  //       // getSuggestions(_textController.text);
  //       // DbService.instance.searchForUsers(_textController.text).listen((event) {
  //       //   setState(() {
  //       //     _suggestions = event;
  //       //   });
  //       // });
  //       setState(() {
  //         userSearch = _textController.text;
  //       });

  //       // print('----->>>>---suggestions length :${_suggestions.length}');
  //     },
  //   );
  //   super.initState();
  // }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF3F3F3),
      appBar: AppBar(
        title: Text(
          'SEARCH',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2.0),
        ),
        centerTitle: true,
      ),
      body: Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              _textFieldSearch(),
              // if (_suggestions.isNotEmpty)
              //   Column(
              //     children: _suggestions,
              //   ),
              SizedBox(height: 20),
              userSearch.isEmpty
                  ? _buildSerachSplach()
                  : _searchedUsersContent()
            ],
          )),
    );
  }

  Widget _buildNoContent() {
    return Container(
      height: 350,
      child: Column(
        children: [
          Text(
            'Teacher Not Found',
            style: GoogleFonts.kaushanScript(
              textStyle: TextStyle(
                  fontSize: 30,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Image.asset(
            'assets/search_noContent.png',
          ),
        ],
      ),
    );
  }

  Widget _buildSerachSplach() {
    return Container(
      child: Column(
        children: [
          Text(
            'Search for Teachers',
            style: GoogleFonts.kaushanScript(
              textStyle: TextStyle(
                  fontSize: 30,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Image.asset(
            'assets/search_splash.png',
          ),
        ],
      ),
    );
  }

  Widget _searchedUsersContent() {
    return StreamBuilder(
        stream: DbService.instance.searchForUsers(userSearch),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<SearchItem> users = snapshot.data;
          if (users.isEmpty) {
            return _buildNoContent();
          }
          return ListView.builder(
            itemCount: users.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return users[index];
            },
          );
        });
  }

  Widget _textFieldSearch() {
    return Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(15),
      shadowColor: Colors.black,
      child: TextField(
        controller: _textController,
        // suggestions: _suggestions,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: 'search for a user...',
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(15),
          ),
          prefixIcon: Icon(Icons.search, color: Color(0xff2699FB)),
          suffixIcon: IconButton(
            icon: Icon(Icons.cancel, color: Color(0xff2699FB)),
            onPressed: () {
              _textController.clear();
            },
          ),
        ),
        onChanged: (_input) {
          setState(() {
            userSearch = _input.toLowerCase();
          });
        },
        // onSubmitted: (_input) {
        //   setState(() {
        //     userSearch = _input;
        //   });
        // },
        // itemFilter: (suggestion, query) {
        //   return suggestion.toLowerCase().startsWith(query.toLowerCase());
        // },
        // itemSorter: (a, b) {
        //   return a.compareTo(b);
        // },
        // key: key,
        // itemSubmitted: (data) {
        //   // setState(() {
        //   //   _textController.text = data;
        //   // });
        // },
        // itemBuilder: (context, item) {
        //   return Column(children: [item]);
        // },
      ),
    );
  }

  // ************************functions******************************

  // void getSuggestions(String _searchName) {
  //   print('-----------_searchName = $_searchName');
  //   DbService.instance.searchForUsers(_searchName).asyncExpand((event) );
  // }
}
