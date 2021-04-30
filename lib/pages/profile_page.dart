import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../modals/contact.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class ProfilePageState extends StatelessWidget {

ProfilePageState();

double _deviceHeight;
double _deviceWidth;
AuthProvider _auth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        textTheme: TextTheme(
          title: TextStyle(
              fontSize: 20
          ),
        ),
        title: Text("Profile"),
      ),
      body: SafeArea(
child: Column(
  children: <Widget> [
    ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _profilePageUI()),
    ],
),
      ),
    );
  }

  Widget _profilePageUI(){
return Builder(builder: (BuildContext _context){
   _auth = Provider.of<AuthProvider>(_context);
  return StreamBuilder<Contact>(
    stream: DBService.instance.getUserData(_auth.user.uid),
    builder: (_context, _snapshot){
      var _userData = _snapshot.data;
      return _snapshot.hasData ? Align(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            _userImageWidget(_userData.image),
            SizedBox(
              height: 10.0,
            ),
            _userNameWidget(_userData.name),
            SizedBox(
              height: 10.0,
            ),
            _userEmailWidget(_userData.email),
            SizedBox(
              height: 10.0,
            ),
            _logoutButton(),
          ],
        ),
      ) : SpinKitWanderingCubes(color: Colors.blue,
      size: 50.0,);
    }
  );
}
);
  }


Widget _userImageWidget(String _image) {
  return Container(
    height: _deviceHeight*0.20,
    width: _deviceWidth*0.40,
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(500),
      image: DecorationImage(
        fit: BoxFit.cover,
        image: NetworkImage(_image),
      ),
    ),
  );
}

Widget _userNameWidget(String _userName) {
  return Container(
    child: Text(
      _userName,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontSize: 30),
    ),
  );
}


Widget _userEmailWidget(String _email) {
  return Container(
    child: Text(
      _email,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white24, fontSize: 15),
    ),
  );
}

Widget _logoutButton() {
  return Container(
    child: MaterialButton(
      onPressed: () {
        _auth.logoutUser(() {});
      },
      color: Colors.red,
      child: Text(
        "LOGOUT",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
}