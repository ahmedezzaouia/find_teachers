import 'package:flutter/material.dart';
import 'package:maroc_teachers/modals/category.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/providers/teacher_provider.dart';
import 'package:maroc_teachers/services/snackbar_service.dart';
import 'package:maroc_teachers/shared/constants.dart';
import 'package:maroc_teachers/widgets/subjects_item.dart';
import 'package:provider/provider.dart';

class AddTeacherScreen extends StatefulWidget {
  static const routeNamed = '/edit-teacher';

  @override
  _AddTeacherScreenState createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  double _deviceHeight;
  double _deviceWidth;
  String _selectedSubject = '';
  Teacher _onEditeTeacher = Teacher(
    teaherName: '',
    id: null,
    teacherDescription: '',
    teacherImageUrl: '',
    teachingSubject: '',
  );
  bool _isLoading = false;
  String nonSelectedError = '';
  bool _isinit = true;
  @override
  void didChangeDependencies() {
    if (_isinit) {
      final id = ModalRoute.of(context).settings.arguments as String;
      if (id != null) {
        _onEditeTeacher =
            Provider.of<TeacherProvider>(context).findByTeacherId(id);
        _selectedSubject = _onEditeTeacher.teachingSubject;
      }
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Add Teacher'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _editeProfileUI(),
    );
  }

  Widget _editeProfileUI() {
    return Builder(builder: (BuildContext _context) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _topTextWidget(),
              _gridViewWidget(),
              _formWidget(),
              _isLoading
                  ? CircularProgressIndicator()
                  : _buttonWidget(_context),
            ],
          ),
        ),
      );
    });
  }

  Widget _buttonWidget(BuildContext _context) {
    return Container(
      height: _deviceHeight * 0.07,
      width: _deviceHeight * 0.3,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF3466FF),
              const Color(0xFF70CCAF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ]),
      child: FlatButton(
        onPressed: () => _valider(_context),
        child: Text(
          'valider',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Container _formWidget() {
    return Container(
      height: _deviceHeight * 0.3,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextFormField(
              initialValue: _onEditeTeacher.teaherName,
              style: TextStyle(color: Colors.white),
              decoration: kTextFieldProfileDecoration.copyWith(
                labelText: 'Name :',
                fillColor: Colors.white12,
              ),
              keyboardType: TextInputType.text,
              onSaved: (_input) {
                _onEditeTeacher = Teacher(
                  teaherName: _input,
                  id: _onEditeTeacher.id,
                  teacherDescription: _onEditeTeacher.teacherDescription,
                  teacherImageUrl: null,
                  teachingSubject: '',
                );
              },
              validator: (_input) {
                if (_input.isEmpty) {
                  return 'please enter your name.!';
                }
                if (_input.length > 25) {
                  return 'you should enter a short name !.';
                }
                if (_input.contains(RegExp(r'[0-9]'))) {
                  return 'your name should not have a number!.';
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: _onEditeTeacher.teacherDescription,
              style: TextStyle(color: Colors.white),
              decoration: kTextFieldProfileDecoration.copyWith(
                labelText: 'Your Short Description :',
                fillColor: Colors.white12,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              onSaved: (_input) {
                _onEditeTeacher = Teacher(
                  teaherName: _onEditeTeacher.teaherName,
                  id: _onEditeTeacher.id,
                  teacherDescription: _input,
                  teacherImageUrl: null,
                  teachingSubject: _selectedSubject,
                );
              },
              validator: (_input) {
                if (_input.isEmpty) {
                  return 'please enter your name.!';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Column _topTextWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'You want to become a Teacher ?',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        Text(
          'please select one subject you want to teach.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _gridViewWidget() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            height: _deviceHeight * 0.3,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 0.5,
                mainAxisSpacing: 0.5,
              ),
              itemBuilder: (ctx, index) => GestureDetector(
                onTap: () => _onSelected(categories[index].subjectName),
                child: SubjectItem(
                  category: categories[index],
                  color: Color(0XFF778cf8),
                  isSubjectSelected:
                      _selectedSubject == categories[index].subjectName,
                ),
              ),
            ),
          ),
          Text(
            nonSelectedError,
            style: TextStyle(
                color: Colors.red, fontSize: 15, fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }

  _onSelected(String _selSubject) {
    setState(() {
      _selectedSubject = _selSubject;
    });
    print('selected iteam\'index :$_selectedSubject');
  }

  _valider(BuildContext _context) async {
    bool isValidate = _formKey.currentState.validate();
    if (!isValidate) {
      return;
    }
    if (_selectedSubject.isEmpty) {
      setState(() {
        nonSelectedError = 'you should select one subject!';
      });

      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      SnackBarServie.instance.buildcontext = _context;
      if (_onEditeTeacher.id == null) {
        await Provider.of<TeacherProvider>(context, listen: false)
            .addTeacher(_onEditeTeacher);
      } else {
        await Provider.of<TeacherProvider>(context, listen: false)
            .updateTeacher(_onEditeTeacher, _onEditeTeacher.id);
      }

      setState(() {
        _isLoading = false;
      });

      // Navigator.pushReplacementNamed(
      //     context, TeacherManagementScreen.routeNamed);
      Navigator.pop(_context);
    } catch (e) {
      print('error to add a techare to database becouse of : ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }
}
