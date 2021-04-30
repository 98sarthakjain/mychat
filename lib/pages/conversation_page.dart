
import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mychat/modals/message.dart';
import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';
import '../modals/conversation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../modals/message.dart';
import '../services/media_service.dart';

class ConversationPage extends StatefulWidget {
  String _conversationID;
  String _receiverID;
  String _receiverImage;
  String _receiverName;

  ConversationPage(this._conversationID, this._receiverID, this._receiverName,
      this._receiverImage);

  @override
  State<StatefulWidget> createState() {
    return _ConversationPageState();
  }
}

class _ConversationPageState extends State<ConversationPage> {

  double _deviceHeight;
  double _deviceWidth;

  ScrollController _listViewController;
  GlobalKey<FormState> _formKey;

  String _messageText;

  _ConversationPageState(){
    _formKey = GlobalKey<FormState>();
    _listViewController = ScrollController();
    _messageText ='';
  }

  AuthProvider _auth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(31, 31, 31, 1.0),
        title: Transform(
          transform: Matrix4.translationValues(-25, 0.0, 0.0),
          child: new Row(

          mainAxisAlignment: MainAxisAlignment.start,
          children:
          [
            _userAppbarImageWidget(),
            Container(padding: const EdgeInsets.all(8.0), child: Text(this.widget._receiverName))
          ],
      ),
        ),
      ),
      body: Container(
      decoration: BoxDecoration(
    image: DecorationImage(
      image : new AssetImage('images/background.png'),
    fit: BoxFit.cover,
    ),
    ),
        child: ChangeNotifierProvider<AuthProvider>.value(
            value: AuthProvider.instance,
        child: _conversationPageUI(),
        ),
    )
    );
  }

  Widget _conversationPageUI(){
    return Builder(builder: (BuildContext _context){
      _auth = Provider.of<AuthProvider>(_context);
      return Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          _messageListView(),
          Align(
              alignment: Alignment.bottomCenter,
              child: _messageField(_context)),
        ],
      );
    }
    );
  }

  Widget _messageListView(){
    return Container(
      height: _deviceHeight*0.75,
      width: _deviceWidth,
      child: StreamBuilder<Conversation>(
        stream: DBService.instance.getConversation(this.widget._conversationID),
          builder: (BuildContext _context, _snapshot){
          Timer(Duration(milliseconds: 50), () => {
            _listViewController.jumpTo(_listViewController.position.maxScrollExtent),
          });
        var _conversationData = _snapshot.data;
        if (_conversationData != null) {
          return ListView.builder(
            controller: _listViewController,
              itemCount: _conversationData.messages.length,
              itemBuilder: (BuildContext _context, int _index) {
                var _message = _conversationData.messages[_index];
                bool _isOwnMessage = _message.senderID == _auth.user.uid;
                return _messageListViewChild(_isOwnMessage, _message);
              }
          );
        }
        else {
          return SpinKitWanderingCubes(color: Colors.blue,
            size: 50.0,);
        }
      })
    );
  }

  Widget _messageListViewChild(bool _isOwnMessage,Message _message){
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: _isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
         _message.type == MessageType.Text ? _textMessageBubble(_isOwnMessage, _message.content,_message.timestamp)
          : _imageMessageBubble(_isOwnMessage, _message.content,_message.timestamp)
          ,
        ],
      ),
    );
  }


  Widget _userImageWidget(){
    double _imaageRadius = _deviceHeight*0.024;
    return Container(
      height: _imaageRadius,
      width: _imaageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(this.widget._receiverImage),
        )
      ),
    );
  }
  Widget _userAppbarImageWidget(){
    double _imaageRadius = _deviceHeight*0.03;
    return Container(
      height: _imaageRadius,
      width: _imaageRadius,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(500),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(this.widget._receiverImage),
          )
      ),
    );
  }
  // Widget _textMessageBubble(bool _isOwnMessage,String _message, Timestamp _timestamp){
  //   List<Color> _colorScheme = _isOwnMessage
  //       ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
  //       : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
  //   return Container(
  //     height: _deviceHeight*0.10,
  //     width: _deviceWidth*0.75,
  //     padding: EdgeInsets.symmetric(horizontal: 10),
  //     decoration:
  //     BoxDecoration(
  //       borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(30.0),
  //           bottomLeft: Radius.circular(30.0),
  //           bottomRight: Radius.circular(30.0)),
  //       gradient: LinearGradient(
  //         colors: _colorScheme,
  //         stops: [0.30, 0.70],
  //         begin: Alignment.bottomLeft,
  //         end: Alignment.topRight,
  //       ),
  //     ),
  //
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       mainAxisSize: MainAxisSize.max,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children:<Widget> [
  //         Text(_message,
  //         ),
  //         Text(
  //           timeago.format(_timestamp.toDate()) ,
  //           style: TextStyle(
  //           color: Colors.white70,
  //         ),)
  //       ],
  //     ),
  //   );
  // }


  Widget _textMessageBubble(bool _isOwnMessage,String _message, Timestamp _timestamp){
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        _isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only( bottom: 3.0,top: 2.0),
            child:
            Row(
              children: <Widget>[
                ! _isOwnMessage ? _userImageWidget() : Container(),
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    timeago.format(_timestamp.toDate()),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Material(
            borderRadius: _isOwnMessage
                ? BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            elevation: 5.0,
            color: _isOwnMessage ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                _message,
                style: TextStyle(
                  color: _isOwnMessage ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(bool _isOwnMessage,String _imageURL,Timestamp _timestamp){
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        _isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only( bottom: 3.0,top: 2.0),
            child:
            Row(
              children: <Widget>[
                ! _isOwnMessage ? _userImageWidget() : Container(),
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    timeago.format(_timestamp.toDate()),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
         Container(
           height: _deviceHeight * 0.2 + (_imageURL.length / 20 * 5.0),
           width: _deviceWidth * 0.75,
           decoration: BoxDecoration(
             borderRadius: _isOwnMessage
                 ? BorderRadius.only(
                 topLeft: Radius.circular(15.0),
                 bottomLeft: Radius.circular(15.0),
                 bottomRight: Radius.circular(15.0))
                 : BorderRadius.only(
               bottomLeft: Radius.circular(15.0),
               bottomRight: Radius.circular(15.0),
               topRight: Radius.circular(15.0),
             ),
             boxShadow: [
               BoxShadow(
                 color: Colors.black,
                 blurRadius: 2.0,
                 spreadRadius: 0.0,
                 offset: Offset(2.0, 2.0), // shadow direction: bottom right
               )
             ],
             color: _isOwnMessage ? Colors.lightBlueAccent : Colors.white,
           ),

            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              child:  Container(
                height: _deviceHeight * 0.30,
                width: _deviceWidth * 0.40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(_imageURL),
                    fit: BoxFit.cover
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageField(BuildContext _context) {
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.04, vertical: _deviceHeight * 0.03),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _messageTextField(),
            // _imageMessageButton(),
            _sendMessageButton(_context),

          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        validator: (_input) {
          if (_input.length == 0) {
            return "Please enter a message";
          }
          return null;
        },
        onChanged: (_input) {
          _formKey.currentState.save();
        },
        onSaved: (_input) {
          setState(() {
            _messageText = _input;
          });
        },
        cursorColor: Colors.white,
        decoration: InputDecoration(
            border: InputBorder.none, hintText: "Type a message"),
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton(BuildContext _context) {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.11,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.image,
              color: Colors.white,
            ),
            onPressed: () async {
              var _image = await MediaService.instance.getImageFromLibrary();
              if (_image != null) {
                var _result = await CloudStorageService.instance
                    .uploadMediaMessage(_auth.user.uid, _image);
                var _imageURL = await _result.ref.getDownloadURL();
                await DBService.instance.sendMessage(
                  this.widget._conversationID,
                  Message(
                      content: _imageURL,
                      senderID: _auth.user.uid,
                      timestamp: Timestamp.now(),
                      type: MessageType.Image),
                );
              }
            },
          ),
        IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.white,
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                DBService.instance.sendMessage(
                  this.widget._conversationID,
                  Message(
                      content: _messageText,
                      timestamp: Timestamp.now(),
                      senderID: _auth.user.uid,
                      type: MessageType.Text),
                );
                _formKey.currentState.reset();
                FocusScope.of(_context).unfocus();
              }
            }
            ),
    ]
      ),
    );
  }


  // Widget _imageMessageButton() {
  //   return Container(
  //     height: _deviceHeight * 0.05,
  //     width: _deviceHeight * 0.05,
  //     child:
  //
  //   );
  // }

}
