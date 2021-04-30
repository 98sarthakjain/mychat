import 'package:flutter/material.dart';
import 'package:mychat/constants.dart';
import '../services/database_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../modals/contact.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/navigation_service.dart';
import '../pages/conversation_page.dart';
class SearchPage extends StatefulWidget{


  @override
  State<StatefulWidget> createState(){
    return _SearchPageState();
  }
}


class _SearchPageState extends State<SearchPage> {
  double _height;
  double _width;

  String _searchText;

  _SearchPageState(){
    _searchText = '';
  }

  AuthProvider _auth;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery
        .of(context)
        .size
        .height;
    _width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(31, 31, 31, 1.0),
        title: Transform(
          transform: Matrix4.translationValues(-25, 0.0, 0.0),
          child: new Row(

            mainAxisAlignment: MainAxisAlignment.start,
            children:
            [
              Container(padding: const EdgeInsets.all(8.0), child: Text("this.widget._receiverName"))
            ],
          ),
        ),
      ),
      backgroundColor: Theme
          .of(context)
          .backgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              child: ChangeNotifierProvider<AuthProvider>.value(
                  value: AuthProvider.instance,
                  child: _searchPageUI()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchPageUI() {
    return Builder(
        builder: (BuildContext _context){
          _auth = Provider.of<AuthProvider>(_context);
          return Column(

            children: <Widget>[
              Container(
                  child: _userListView()),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: _userSeacrhField(),
              ),
            ],
          );
    }
    );
  }

  Widget _userSeacrhField() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: _height * 0.07,
        width: _width * 0.90,
        child: TextField(
          autocorrect: false,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: kSearchFieldDecoration.copyWith(
              labelText: 'Search name or email'),
          onSubmitted: (_input) {
            setState(() {
              _searchText = _input;
            });
          },
        ),
      ),
    );
  }

  Widget _userListView() {
    return Container(
      height: _height*0.39,
      width: _width,
      child: StreamBuilder<List<Contact>>(
        stream: DBService.instance.getUsersInDB(_searchText),
          builder: (_context,_snapshot){
          var _usersData = _snapshot.data;
          if(_usersData != null) {
            _usersData.removeWhere((_contact) => _contact.id == _auth.user.uid);
          }
        return _snapshot.hasData ?  ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Colors.black45,
          ),
          itemCount: _usersData.length,
          itemBuilder: (BuildContext _context, int _index) {
            var _userData = _usersData[_index];
            var _currentTime = DateTime.now();
            var _recipientID = _usersData[_index].id;
            var _isUserActive = !_userData.lastseen.toDate().isBefore(_currentTime.subtract(Duration(hours: 1),),);
            return ListTile(
              onTap: (){
                DBService.instance.createOrGetConversartion(
                    _auth.user.uid, _recipientID ,
                        (String _conversationID) {
                      NavigationService.instance.navigateToRoute(
                        MaterialPageRoute(builder: (_context) {
                          return ConversationPage(
                              _conversationID,
                              _recipientID,
                              _userData.name,
                              _userData.image);
                        }
                        ),
                      );
                    }
                    );
              },
              title: Text(_userData.name),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(_userData.image),
                  ),
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                 _isUserActive ? Text("Active now",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ): Text("Last seen",
                   style: TextStyle(
                     fontSize: 15,
                   ),
                 ),
                  _isUserActive ? Container(
                    height: 10,
                    width:10,
                    decoration : BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ) : Text(timeago.format(_userData.lastseen.toDate()),
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          },
        ) : SpinKitWanderingCubes(color: Colors.blue,
          size: 50.0,);;
      }
      ),
    );
  }
}