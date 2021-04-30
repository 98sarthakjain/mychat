import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/navigation_service.dart';
import '../pages/profile_page.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../modals/conversation.dart';
import '../modals/contact.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../pages/conversation_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}
class _HomePageState extends State<HomePage> {
  double _height;
  double _width;
  AuthProvider _auth;

  String userPic ;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
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
              fontSize: 16
          ),
        ),
        title: Text("Meraki"),
        actions: <Widget>[
          Container(
            child: ChangeNotifierProvider<AuthProvider>.value(
                value: AuthProvider.instance,
                child:  _profileIcon()),
          ),

    ],
      ),

      body: Container(
        child: ChangeNotifierProvider<AuthProvider>.value(
            value: AuthProvider.instance,
            child: _conversationsListViewWidget()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         NavigationService.instance.navigateTo("searchpage");
        },
        child: const Icon(Icons.chat),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _conversationsListViewWidget() {
        return Builder(builder: (BuildContext _context ){
          _auth = Provider.of<AuthProvider>(_context);
          return Container(
            height: _height,
            width: _width,
            child: StreamBuilder<List<ConversationSnippet>>(
              stream: DBService.instance.getUserConversations(_auth.user.uid),
              builder: (_context, _snapshot){
                var _data = _snapshot.data;
                if(_data != null){
                return _data.length !=0 ? ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (_context, _index) {
                      return ListTile(
                        onTap: () {
                          NavigationService.instance.navigateToRoute(
                            MaterialPageRoute(
                              builder: (BuildContext _context) {
                                return ConversationPage(
                                    _data[_index].conversationID,
                                    _data[_index].id,
                                    _data[_index].name,
                                    _data[_index].image);
                              },
                            ),
                          );
                        },
                        title: Text(_data[_index].name),
                        subtitle: Text(_data[_index].lastMessage),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(_data[_index].image),
                            ),
                          ),
                        ),
                        trailing: _listTileTrailingWidgets(_data[_index].timestamp),
                      );
                    },
                  ) : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Hero(
                          tag: 'logo',
                          child: Container(
                            height: 200.0,
                            child: Image(
                            image: NetworkImage("https://i.imgur.com/SBvPCmN.png"),
                                color: Color.fromRGBO(255, 255, 255, 0.7),
                                colorBlendMode: BlendMode.modulate
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text("hmm, seens like you don't have any chats",
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 15.0,
                      ),
                      ),
                      GestureDetector(
                      onTap: () {
                        NavigationService.instance.navigateTo("searchpage");
                },
                child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                height: _height * 0.06,
                width: _width,
                child: Text(
                "Start a new Chat!",
                textAlign: TextAlign.center,
                style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.blueAccent),
                ),
                ),
                ),
                ),
                    ],
                  )
                ;
                }
                else{
                return SpinKitWanderingCubes(
                    color: Colors.blue,
                    size: 50.0,
                  );
                };
            },
            ),
          );
        }
        );
}
  Widget _listTileTrailingWidgets(Timestamp _lastMessageTimestamp ) {
    if(_lastMessageTimestamp != null){
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            timeago.format(_lastMessageTimestamp.toDate()),
            style: TextStyle(fontSize: 15),
          ),
        ],
      );
    }
    else{
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            "No New Message",
            style: TextStyle(fontSize: 15),
          ),
        ],
      );
    }

  }


  Widget _profileIcon() {
    return Builder(builder: (BuildContext _context )
    {
      _auth = Provider.of<AuthProvider>(_context);
      return Container(
          height: _height,
          width: _width,
          child: StreamBuilder<Contact>(
              stream: DBService.instance.getUserData(_auth.user.uid),
              builder: (_context, _snapshot) {
                var _userData = _snapshot.data;
                return _snapshot.hasData ? Row(
                  children: <Widget>[
                    Expanded(child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text("Meraki",
                      style: TextStyle(
                        fontSize: 25.0
                      ),),
                    )),
                    MaterialButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        NavigationService.instance.navigateTo("profile");
                      },
                      child: CircleAvatar(
                        radius: 16.0,
                        backgroundColor: Colors.brown.shade800,
                        backgroundImage:
                        NetworkImage(_userData.image),
                      ),
                    ),
                  ],
                ) : SpinKitWanderingCubes(
                color: Colors.blue,
                size: 50.0
                ,
                );
              }
          )
      );
    }
    );
  }

}
