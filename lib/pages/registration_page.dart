import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mychat/constants.dart';

import '../services/navigation_service.dart';
import '../services/media_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../services/snackbar_service.dart';
class RegistrationPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return _RegistrationPageState();
  }
}

class _RegistrationPageState extends State<RegistrationPage>{

  double _deviceHeight;
  double _deviceWidth;

  File _image;
  GlobalKey<FormState> _formKey;
  AuthProvider _auth;

  String _name;
  String _email;
  String _password;
  _RegistrationPageState(){
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(alignment: Alignment.center,
      child: ChangeNotifierProvider<AuthProvider>.value(value: AuthProvider.instance,
      child: signupPageUI(),
      ),
      ),
    );
  }

  Widget signupPageUI(){
    return Builder(
      builder :(BuildContext _context) {
        SnackBarService.instance.buildContext = _context;
        _auth = Provider.of<AuthProvider>(_context);
    return Container(
    height: _deviceHeight*0.75,
    padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.05),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 20.0,
      ),
    _headingWidget(),
    _inputForm(),
    _registerButton(),
      SizedBox(
        height: 20.0,
      ),
    _loginButton(),
    ],
    ),
    );
  });
  }
  Widget _headingWidget() {
    return Expanded(
      child: Container(
        height: _deviceHeight * 0.12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Welcome aboard!",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
            ),

            Text(
              "Lets get you set up.",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState.save();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _imageSelectorWidget(),
            SizedBox(
              height: 5.0,
            ),
            Center(child: Text("Add Profile Image",style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),)),
            SizedBox(
              height: 10.0,
            ),
            _nameTextField(),
            SizedBox(
              height: 10.0,
            ),
            _emailTextField(),
            SizedBox(
              height: 10.0,
            ),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }


  Widget _imageSelectorWidget() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          File _imageFile = await MediaService.instance.getImageFromLibrary();
          setState(() {
            _image = _imageFile;
          });
        },
        child: Container(
          height: _deviceHeight * 0.10,
          width: _deviceHeight * 0.10,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(500),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: _image != null
                  ? FileImage(_image)
                  : NetworkImage(
                  "https://cdn0.iconfinder.com/data/icons/occupation-002/64/programmer-programming-occupation-avatar-512.png"),
            ),
          ),
        ),
      ),
    );
  }

Widget _nameTextField() {
  return TextFormField(
    autocorrect: false,
    style: TextStyle(color: Colors.white),
    validator: (_input) {
      return _input.length != 0
          ? null
          : "Please enter a name";
    },
    onSaved: (_input) {
      setState(() {
        _name = _input;
      });
    },
    cursorColor: Colors.white,
    decoration: kTextFieldDecoration.copyWith(labelText: 'Enter your name'),
  );
}

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      validator: (_input) {
        return _input.length != 0 && _input.contains("@")
            ? null
            : "Please enter a valid email";
      },
      onSaved: (_input) {
        setState(() {
          _email = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: kTextFieldDecoration.copyWith(labelText: 'Enter your email'),
    );
  }
  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      validator: (_input) {
        return _input.length != 0 ? null : "Please enter a password";
      },
      onSaved: (_input) {
        setState(() {
          _password = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: kTextFieldDecoration.copyWith(labelText: 'Enter your Password'),
    );
  }

  Widget _registerButton() {
    return _auth.status != AuthStatus.Authenticating? Container(
      height: _deviceHeight * 0.06,
      width: _deviceWidth,
      child: MaterialButton(
        onPressed: () {
          if(_formKey.currentState.validate() && _image != null){
            _auth.registerUserWithEmailAndPassword(_email, _password, (String _uid) async{
              var _result = await CloudStorageService.instance.uploadUserImage(_uid, _image);
              var _imageURL = await _result.ref.getDownloadURL();
              await DBService.instance.createUserInDB(_uid, _name, _email, _imageURL);
            } );
          }
        },
        color: Colors.blue,
        child: Text(
          "Register",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    ) : Align(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }

  Widget _loginButton() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.goBack();
      },
      child: Container(
        height: _deviceHeight * 0.06,
        width: _deviceWidth,
        child: Text(
          "Already have an account? Login",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white60),
        ),
      ),
    );
  }

}
