import 'package:flutter/material.dart';
import 'package:maroc_teachers/http_exceptions/http_exception.dart';
import 'package:provider/provider.dart';
import 'package:maroc_teachers/providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  static const routeNamed = '/auth';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: deviceSize.height,
            width: deviceSize.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF030356), Color(0xFF6221ED)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/intro_auth.png',
                    height: 250,
                    width: 250,
                    fit: BoxFit.cover,
                  ),
                  Flexible(
                    child: AuthCard(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.Login;
  final _passwordController = TextEditingController();
  Map<String, String> _authdata = {
    'Email': '',
    'Password': '',
  };
  bool isloading = false;
  void _switchMode() {
    setState(() {
      if (_authMode == AuthMode.Login) {
        _authMode = AuthMode.Signup;
      } else {
        _authMode = AuthMode.Login;
      }
    });
  }

  Future _showMessageDialog(String errorMessage) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error occurred!'),
        content: Text(errorMessage),
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

  void _submit() async {
    final isValide = _formKey.currentState.validate();
    if (!isValide) {
      return;
    }
    setState(() {
      isloading = true;
    });
    _formKey.currentState.save();
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false)
            .login(_authdata['Email'], _authdata['Password']);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signUp(_authdata['Email'], _authdata['Password']);
      }
    } on HttpException catch (error) {
      var errorMessage = 'authenticate failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showMessageDialog(errorMessage);
    } catch (error) {
      print('catch error : ${error.toString()}');
      var errorMessage = 'could not authenticate you, please try again.';
      _showMessageDialog(errorMessage);
    }
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Login ? 270 : 320,
        width: 360,
        child: Form(
          key: _formKey,
          child: isloading
              ? Center(child: CircularProgressIndicator())
              : ListView(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  children: <Widget>[
                    Text(
                      _authMode == AuthMode.Login ? 'Sign In' : 'Register',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'E-Mail :',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.isEmpty || !value.contains('@')) {
                          return 'Invalid email';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _authdata['Email'] = value;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Passwod :',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'should enter a password';
                        }
                        if (value.length < 6) {
                          return 'password is too short';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _authdata['Password'] = value;
                      },
                    ),
                    SizedBox(height: 10),
                    _authMode == AuthMode.Login
                        ? Container()
                        : TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Confirme Password :',
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'empty field';
                              }
                              if (value != _passwordController.text) {
                                return 'password do not match .';
                              }
                              return null;
                            },
                          ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                            _authMode == AuthMode.Login
                                ? 'Register'
                                : 'Sign In',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueAccent),
                          ),
                          onPressed: () {
                            _switchMode();
                          },
                        ),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            _submit();
                          },
                          child: Container(
                            height: 40,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(15)),
                            child: Icon(Icons.navigate_next,
                                size: 30, color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
