import 'package:flutter/material.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/providers/teacher_provider.dart';
import 'package:provider/provider.dart';

class EditTeacherScreen extends StatefulWidget {
  static const routeNamed = 'edit-teacher';

  @override
  _EditTeacherScreenState createState() => _EditTeacherScreenState();
}

class _EditTeacherScreenState extends State<EditTeacherScreen> {
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedSubject;
  bool isNothingSelect = false;

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
    foundInCategoryName: '',
  );

  @override
  void dispose() {
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(updateImageUrl);
    super.dispose();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(updateImageUrl);
    super.initState();
  }

  updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    } else {
      return;
    }
  }

  onSaveForm() {
    final isValid = _formKey.currentState.validate();
    if (_selectedSubject == null) {
      setState(() {
        isNothingSelect = true;
      });
      return;
    }
    setState(() {
      isNothingSelect = false;
    });

    if (!isValid) {
      return;
    }

    _formKey.currentState.save();
    Provider.of<TeacherProvider>(context, listen: false)
        .addTeacher(_onEditeTeacher);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name :',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  keyboardType: TextInputType.text,
                  onSaved: (value) {
                    _onEditeTeacher = Teacher(
                      teaherName: value,
                      id: null,
                      teacherDescription: _onEditeTeacher.teacherDescription,
                      teacherImageUrl: _onEditeTeacher.teacherImageUrl,
                      foundInCategoryName: _onEditeTeacher.foundInCategoryName,
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
                        color: isNothingSelect ? Colors.red : Colors.white,
                        borderRadius: BorderRadius.circular(30)),
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
                  children: <Widget>[
                    Container(
                        height: 95,
                        width: 95,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: _imageUrlController.text.isEmpty
                            ? Text('profile')
                            : CircleAvatar(
                                radius: 45,
                                backgroundImage:
                                    NetworkImage(_imageUrlController.text),
                              )),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'ImageUrl :',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        keyboardType: TextInputType.text,
                        focusNode: _imageUrlFocusNode,
                        controller: _imageUrlController,
                        onSaved: (value) {
                          _onEditeTeacher = Teacher(
                            teaherName: _onEditeTeacher.teaherName,
                            id: null,
                            teacherDescription:
                                _onEditeTeacher.teacherDescription,
                            teacherImageUrl: value,
                            foundInCategoryName:
                                _onEditeTeacher.foundInCategoryName,
                          );
                        },
                        validator: (value) =>
                            value.isEmpty ? 'please enter a Url .' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'About :',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  maxLines: 8,
                  keyboardType: TextInputType.multiline,
                  onSaved: (value) {
                    _onEditeTeacher = Teacher(
                      teaherName: _onEditeTeacher.teaherName,
                      id: null,
                      teacherDescription: value,
                      teacherImageUrl: _onEditeTeacher.teacherImageUrl,
                      foundInCategoryName: _selectedSubject,
                    );
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'please enter a Description';
                    } else if (value.length <= 100) {
                      return 'should enter more than 3 lines .';
                    } else if (value.length >= 500) {
                      return 'you enter more than 5 lines,should enter less.';
                    }
                    return null;
                  },
                )
              ],
            )),
      ),
    );
  }
}
