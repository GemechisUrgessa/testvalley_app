import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initSendbird();
  }

  void initSendbird() {
    final sendbird = SendbirdSdk(appId: "BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF");

    // Assuming 'userId' and 'accessToken' are retrieved from a secure storage or service.
    String userId = "USER_ID"; // Replace with actual user ID
    String accessToken =
        "f93b05ff359245af400aa805bafd2a091a173064"; // Replace with actual access token if necessary

    // Connect to Sendbird
    connectToSendbird(userId, accessToken).then((user) {
      print('Connected to Sendbird as ${user.userId}');
      // Proceed to join the channel after successful connection
      joinChannel();
    }).catchError((error) {
      print('Failed to connect to Sendbird: $error');
    });
  }

  Future<User> connectToSendbird(String userId,
      [String accessToken = ""]) async {
    try {
      final user =
          await SendbirdSdk().connect(userId, accessToken: accessToken);
      return user;
    } catch (e) {
      print("Error connecting to Sendbird: $e");
      rethrow;
    }
  }

  void joinChannel() async {
    try {
      String channelUrl =
          "sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211";
      final openChannel = await OpenChannel.getChannel(channelUrl);
      await openChannel.enter();
      print('Joined channel: ${openChannel.name}');
    } catch (e) {
      print('Error joining channel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  late final GroupChannel channel;
  late List<BaseMessage> messages = [];

  @override
  void initState() {
    super.initState();
    // Replace with your user ID and access token
    _connectUserToChannel(
        "YOUR_USER_ID", "f93b05ff359245af400aa805bafd2a091a173064");
  }

  Future<void> _connectUserToChannel(String userId, String accessToken) async {
    try {
      final user =
          await SendbirdSdk().connect(userId, accessToken: accessToken);
      print("Connected as user: ${user.userId}");
      // Join the channel with URL (you can also join with a channel instance)
      final openChannel = await OpenChannel.getChannel(
          "sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211");
      await openChannel.enter();
      print("Entered channel: ${openChannel.name}");
    } catch (e) {
      print("Error connecting to channel: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // make <    Chat UI     menuIcon  texts
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(Icons.arrow_back_ios),
            Text('Chat UI'),
            Icon(Icons.menu)
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: <Widget>[
          // Your message list goes here
          Expanded(
            child: ListView(
              children: <Widget>[
                // Example message bubbles
                _buildMessageBubble('Hello! How are you?', true),
                _buildMessageBubble('I\'m fine, thanks! And you?', false),
                // Add more messages here
              ],
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isCurrentUser) {
    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.red[600] : Colors.grey[600],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).cardColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Add attachment button
            IconButton(
              icon: const Icon(Icons.add_outlined),
              onPressed: () {
                print("Attachment button pressed");
              },
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.grey),
              ),
              width: 320.0,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: _handleSubmitted,
                      decoration:
                          InputDecoration.collapsed(hintText: "Send a message"),
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(
                      // rounded up send button
                      icon: const Icon(Icons.arrow_circle_up_rounded),
                      color: Colors.red,
                      onPressed: () => _handleSubmitted(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    final messageParams = UserMessageParams(message: text);
    final message = channel.sendUserMessage(messageParams);
    print('Sent message: ${message.message}');
    setState(() {
      messages = channel.lastMessage as List<BaseMessage>;
      messages.add(message);
    });
  }
}
// }
