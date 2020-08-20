import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:maroc_teachers/modals/education.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:maroc_teachers/services/media_service.dart';
import 'package:maroc_teachers/services/snackbar_service.dart';
import 'package:maroc_teachers/shared/constants.dart';
import 'package:maroc_teachers/widgets/education_item.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeNamed = '/edit-profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  double _deviceHeight;
  double _deviceWidth;
  List<Education> _educations = [];
  final _educationFormKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  File _pickedImage;
  Education _onEditEducation = Education(
    schoolOrUniversity: '',
    diploma: '',
    startYear: 0000,
    endYear: 0000,
    id: null,
  );
  var _userData = {
    'name': '',
    'phone': '',
    'email': '',
    'about': '',
  };

  AuthProvider _auth;
  bool _isListFilled = true;
  bool isload = false;
  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    //print('user profile uid : ${_auth.user.uid}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit your profile'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
          stream: DbService.instance.getUserData(_auth.user.uid),
          builder: (context, snapshot) {
            var data = snapshot.data;

            if (!snapshot.hasData) {
              return Center(
                child: SpinKitChasingDots(
                  color: Colors.blue,
                  size: _deviceHeight * 0.05,
                ),
              );
            } else {
              if (_isListFilled) {
                _educations = data['education'];
                _isListFilled = false;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 70,
                          backgroundImage: _pickedImage == null
                              ? NetworkImage(data['teacher'].teacherImageUrl)
                              : FileImage(_pickedImage),
                        ),
                        SizedBox(width: 15),
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.black54,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.white,
                            ),
                            onPressed: imagePicker,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 30),
                    buildFormProfile(data['teacher']),
                    SizedBox(height: 10),
                    buildRowProfil(),
                    _listViewEducationWidget(),
                    Divider(
                      thickness: 0.5,
                      color: Colors.white,
                    ),
                    isload
                        ? CircularProgressIndicator()
                        : _validerButton(context)
                  ],
                ),
              );
            }
          }),
    );
  }

  RaisedButton _validerButton(BuildContext context) {
    return RaisedButton(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      onPressed: () => valider(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.blueAccent,
      child: Text(
        'valider',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ListView _listViewEducationWidget() {
    return ListView.builder(
      itemCount: _educations.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) => EducationItem(
        education: _educations[index],
        deleteEd: deleteEducation,
      ),
    );
  }

  Form buildFormProfile(Teacher teacher) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: teacher.teaherName,
            style: TextStyle(color: Colors.white),
            decoration: kTextFieldProfileDecoration.copyWith(
              labelText: 'Name :',
            ),
            keyboardType: TextInputType.text,
            onSaved: (_input) {
              _userData = {
                'name': _input,
                'phone': _userData['phone'],
                'email': _userData['email'],
                'about': _userData['about'],
              };
            },
          ),
          SizedBox(height: 10),
          SizedBox(height: 10),
          TextFormField(
            initialValue: teacher.phoneNumber,
            style: TextStyle(color: Colors.white),
            decoration: kTextFieldProfileDecoration.copyWith(
              labelText: 'Phone :',
            ),
            keyboardType: TextInputType.number,
            onSaved: (_input) {
              _userData = {
                'name': _userData['name'],
                'phone': _input,
                'email': _userData['email'],
                'about': _userData['about'],
              };
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            initialValue: teacher.teacherEmaill,
            style: TextStyle(color: Colors.white),
            decoration: kTextFieldProfileDecoration.copyWith(
              labelText: 'Email Adresse :',
            ),
            keyboardType: TextInputType.emailAddress,
            onSaved: (_input) {
              _userData = {
                'name': _userData['name'],
                'phone': _userData['phone'],
                'email': _input,
                'about': _userData['about'],
              };
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            initialValue: teacher.teacherDescription,
            style: TextStyle(color: Colors.white),
            decoration: kTextFieldProfileDecoration.copyWith(
              labelText: 'About :',
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            onSaved: (_input) {
              _userData = {
                'name': _userData['name'],
                'phone': _userData['phone'],
                'email': _userData['email'],
                'about': _input,
              };
            },
          ),
        ],
      ),
    );
  }

  Row buildRowProfil() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Education',
          style: TextStyle(
            fontSize: 18,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add,
            size: 25,
            color: Colors.white,
          ),
          onPressed: () {
            showEditDialog();
          },
        ),
      ],
    );
  }

  showEditDialog() {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add your Education '),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Form(
              key: _educationFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      decoration: kTextFieldProfileDecoration.copyWith(
                          hintText: 'Diplome'),
                      validator: (value) => value.isEmpty
                          ? 'Enter a Diploma or certificate'
                          : null,
                      onSaved: (value) {
                        _onEditEducation = Education(
                          diploma: value,
                          schoolOrUniversity:
                              _onEditEducation.schoolOrUniversity,
                          startYear: _onEditEducation.startYear,
                          endYear: _onEditEducation.endYear,
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: kTextFieldProfileDecoration.copyWith(
                          hintText: 'Universtiy or School'),
                      validator: (value) =>
                          value.isEmpty ? 'Enter a university or school' : null,
                      onSaved: (value) {
                        _onEditEducation = Education(
                          diploma: _onEditEducation.diploma,
                          schoolOrUniversity: value,
                          startYear: _onEditEducation.startYear,
                          endYear: _onEditEducation.endYear,
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            decoration: kTextFieldProfileDecoration.copyWith(
                              hintText: 'Start Year',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => value.isEmpty
                                ? 'you must enter a year date YYYY'
                                : null,
                            onSaved: (value) {
                              _onEditEducation = Education(
                                diploma: _onEditEducation.diploma,
                                schoolOrUniversity:
                                    _onEditEducation.schoolOrUniversity,
                                startYear: int.parse(value),
                                endYear: _onEditEducation.endYear,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextFormField(
                            decoration: kTextFieldProfileDecoration.copyWith(
                              hintText: 'End Year',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => value.isEmpty
                                ? 'you must enter a year date YYYY'
                                : null,
                            onSaved: (value) {
                              _onEditEducation = Education(
                                diploma: _onEditEducation.diploma,
                                schoolOrUniversity:
                                    _onEditEducation.schoolOrUniversity,
                                startYear: _onEditEducation.startYear,
                                endYear: int.parse(value),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    RaisedButton(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      onPressed: validerEducationForm,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Text(
                        'valider',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  validerEducationForm() {
    bool isValidate = _educationFormKey.currentState.validate();

    if (!isValidate) {
      return;
    }
    _educationFormKey.currentState.save();
    FocusScope.of(context).unfocus();
    Education education = Education(
      diploma: _onEditEducation.diploma,
      schoolOrUniversity: _onEditEducation.schoolOrUniversity,
      startYear: _onEditEducation.startYear,
      endYear: _onEditEducation.endYear,
      id: DateTime.now().toString(),
    );
    //add to education list

    _educations.add(education);

    Navigator.pop(context);
  }

  void imagePicker() async {
    final pickedFile = await MediaService.instance.getImageFromLibrary();
    setState(() {
      _pickedImage = File(pickedFile.path);
    });
  }

  void deleteEducation(String id) {
    print('delete function is presset.');
    int educationIndex = _educations.indexWhere((ed) => ed.id == id);

    if (educationIndex >= 0) {
      setState(() {
        _educations.removeAt(educationIndex);
      });
    }
    print('education list lenght : ${_educations.length}');
  }

  void valider(BuildContext _context) async {
    setState(() {
      isload = true;
    });
    bool isValidate = _formKey.currentState.validate();
    if (!isValidate) {
      return;
    }
    _formKey.currentState.save();
    SnackBarServie.instance.buildcontext = _context;

    await DbService.instance
        .updateUserData(_auth.user.uid, _userData, _educations, _pickedImage);
    print(_userData.toString());
    print(_onEditEducation.toString());

    setState(() {
      isload = false;
    });
  }
}
