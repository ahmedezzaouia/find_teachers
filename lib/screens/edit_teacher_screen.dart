import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/providers/teacher_provider.dart';
import 'package:provider/provider.dart';

class EditTeacherScreen extends StatefulWidget {
  static const routeNamed = '/edit-teacher';

  @override
  _EditTeacherScreenState createState() => _EditTeacherScreenState();
}

class _EditTeacherScreenState extends State<EditTeacherScreen> {
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isinit = true;
  String _selectedSubject;
  bool _isNothingSelect = false;
  bool _isloading = false;
  File _pickedImage;

  List<String> dropDownIteams = [
    'Physics',
    'Mathematics',
    'Informatique',
    'Languages'
  ];

  Teacher _onEditeTeacher = Teacher(
    teaherName: '',
    id: null,
    teacherDescription: '',
    teacherImageUrl: '',
    teachingSubject: '',
  );

  @override
  void didChangeDependencies() {
    if (_isinit) {
      final teacherId = ModalRoute.of(context).settings.arguments as String;
      if (teacherId != null) {
        _onEditeTeacher =
            Provider.of<TeacherProvider>(context).findByTeacherId(teacherId);
        _imageUrlController.text = _onEditeTeacher.teacherImageUrl;
        _selectedSubject = _onEditeTeacher.teachingSubject;
      }
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  // updateImageUrl() {
  //   if (!_imageUrlFocusNode.hasFocus) {
  //     setState(() {});
  //   } else {
  //     return;
  //   }
  // }

  void imagePicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    setState(() {
      _pickedImage = File(pickedFile.path);
      print('image path : ${_pickedImage.path.toString()}');
    });
  }

  onSaveForm() async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_selectedSubject == null) {
      setState(() {
        _isNothingSelect = true;
      });
      return;
    }
    setState(() {
      _isNothingSelect = false;
    });

    if (!isValid) {
      return;
    }
    setState(() {
      _isloading = true;
    });
    _formKey.currentState.save();
    if (_onEditeTeacher.id == null) {
      try {
        await Provider.of<TeacherProvider>(context, listen: false)
            .addTeacher(_onEditeTeacher);
        setState(() {
          _isloading = false;
        });
      } catch (error) {
        print('there is a problem with add teacher method');
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                  child: Text('okey'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  }),
            ],
          ),
        );
      }
    } else {
      try {
        await Provider.of<TeacherProvider>(context, listen: false)
            .updateTeacher(_onEditeTeacher, _onEditeTeacher.id);

        setState(() {
          _isloading = false;
        });
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                  child: Text('okey'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  }),
            ],
          ),
        );
      }
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Edite Teacher'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.swap_vertical_circle,
              size: 30,
            ),
            onPressed: () => onSaveForm(),
          )
        ],
      ),
      body: _isloading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                        initialValue: _onEditeTeacher.teaherName,
                        decoration: InputDecoration(
                          labelText: 'Name :',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        keyboardType: TextInputType.text,
                        onSaved: (value) {
                          _onEditeTeacher = Teacher(
                            teaherName: value,
                            id: _onEditeTeacher.id,
                            teacherDescription:
                                _onEditeTeacher.teacherDescription,
                            teacherImageUrl: _onEditeTeacher.teacherImageUrl,
                            teachingSubject: _onEditeTeacher.teachingSubject,
                          );
                        },
                        validator: (value) =>
                            value.isEmpty ? 'please enter a name .' : null,
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          alignment: Alignment.center,
                          height: 50,
                          decoration: BoxDecoration(
                              color:
                                  _isNothingSelect ? Colors.red : Colors.white,
                              borderRadius: BorderRadius.circular(15)),
                          child: DropdownButton<String>(
                            value: _selectedSubject,
                            elevation: 7,
                            hint: Text('Select a Subject'),
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                            items: dropDownIteams
                                .map(
                                  (sub) => DropdownMenuItem(
                                    child: Text(sub),
                                    value: sub,
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSubject = value;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 120,
                            width: 120,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: _pickedImage == null
                                ? Text(
                                    'add your profile ',
                                    textAlign: TextAlign.center,
                                  )
                                : CircleAvatar(
                                    radius: 70,
                                    backgroundImage: FileImage(_pickedImage),
                                  ),
                          ),
                          SizedBox(width: 10),
                          RaisedButton.icon(
                            color: Colors.amber,
                            onPressed: imagePicker,
                            icon: Icon(Icons.image),
                            label: Text('add image'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        initialValue: _onEditeTeacher.teacherDescription,
                        decoration: InputDecoration(
                          labelText: 'About :',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        maxLines: 8,
                        keyboardType: TextInputType.multiline,
                        onSaved: (value) {
                          _onEditeTeacher = Teacher(
                            teaherName: _onEditeTeacher.teaherName,
                            id: _onEditeTeacher.id,
                            teacherDescription: value,
                            teacherImageUrl: _imageUrlController.text,
                            teachingSubject: _selectedSubject,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter a Description';
                          } else if (value.length >= 500) {
                            return 'you enter more than 5 lines,should enter less.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        child: RaisedButton(
                          color: Colors.blueAccent,
                          onPressed: () {},
                          child: Text(
                            'valid',
                            style: TextStyle(
                              fontSize: 18,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
    );
  }
}
