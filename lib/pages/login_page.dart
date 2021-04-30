import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/snackbar_service.dart';
import 'package:mychat/constants.dart';
import '../services/navigation_service.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../services/navigation_service.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  double _deviceHeight;
  double _deviceWidth;

  GlobalKey<FormState> _formKey;
  AuthProvider _auth;

  String _email;
  String _password;

  _LoginPageState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Align(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _loginPageUI(),
        ),
      ),
    );
  }

  Widget _loginPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        SnackBarService.instance.buildContext = _context;
        _auth = Provider.of<AuthProvider>(_context);
        return Container(
          height: _deviceHeight * 0.60,
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: Hero(
                      tag: 'logo',
                      child: Container(
                        height: 100.0,
                        child: Image.asset('images/logo.png'),
                      ),
                    ),
                  ),
                  TypewriterAnimatedTextKit(
                    text: ['Meraki'],
                    textStyle: TextStyle(
                      fontSize: 45.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              _headingWidget(),
              _inputForm(),
              _loginButton(),
              SizedBox(
                height: 20.0,
              ),
              _registerButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _headingWidget() {
    return Container(
      height: _deviceHeight * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Welcome back!",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            "Please login to your account.",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceHeight * 0.16,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState.save();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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

  Widget _loginButton() {
    return _auth.status == AuthStatus.Authenticating
        ? Align(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    )
        : Container(
      height: _deviceHeight * 0.06,
      width: _deviceWidth,
      child: MaterialButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _auth.loginUserWithEmailAndPassword(_email, _password);
          }
        },
        color: Colors.blue,
        child: Text(
          "LOGIN",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.navigateTo("register");
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          height: _deviceHeight * 0.06,
          width: _deviceWidth,
          child: Text(
            "REGISTER",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white60),
          ),
        ),
      ),
    );
  }
}
