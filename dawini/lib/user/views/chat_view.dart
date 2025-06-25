import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawini/theme/app_colors.dart';
import 'package:dawini/user/controllers/user_auth_controller.dart';
import 'package:flutter/material.dart';
import '../controllers/chat_controller.dart';
import 'package:dawini/user/controllers/chat_history_controller.dart';
import 'chat_history_view.dart';

class ChatView extends StatefulWidget {
  final String? chatID;
  const ChatView({super.key, this.chatID});

  @override
  ChatViewState createState() => ChatViewState();
}

class ChatViewState extends State<ChatView> {
  final ChatController _controller = ChatController();
  final TextEditingController _messageController = TextEditingController();
  final ChatHistoryController _chatHistoryController = ChatHistoryController();
  final UserAuthController _authController = UserAuthController();
  bool _isChatInitialized = false;
  String _username = "User";
  @override
  void initState() {
    super.initState();
    _initChat();
    _loadUserName();
  }

  Future<void> _initChat() async {
    print("Initializing chat...");
    if (widget.chatID == null) {
      print("ChatID is null, creating new chat.");
      String newChatID = await _controller.initializeChat();
      print("New chat initialized with ID: $newChatID");
      _chatHistoryController.getCurrentChatID(newChatID);
    } else {
      print("Using existing ChatID: ${widget.chatID}");
      _controller.setCurrentChatID(widget.chatID!);
      _chatHistoryController.getCurrentChatID(widget.chatID!);
    }

    setState(() {
      _isChatInitialized = true;
    });
  }

  /// Load the user's name from Firestore via ChatController.
  Future<void> _loadUserName() async {
    String? name = await _authController.getUserName();
    if (name != null && name.isNotEmpty) {
      setState(() {
        _username = name;
      });
    }
  }

  Future<void> _sendMessage() async {
    String userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    await _controller.addMessage(userMessage, "User");
    _messageController.clear();

    String aiResponse = await _controller.getAIResponse(userMessage);
    await _controller.addMessage(aiResponse, "AI");
  }

  @override
  Widget build(BuildContext context) {
    if (!_isChatInitialized) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          Image.asset('assets/images/f.png', scale: 2.9),
          TextButton(
            onPressed: () {
              //TODO: add page for the app description and information
              //Navigator.pushReplacementNamed(context, 'DoctorAI/');
            },
            child: const Text(
              'Doctor AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Anton',
              ),
            ),
          ),
          const SizedBox(width: 50),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'Dawini/User/ChatScreen');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'Dawini/User/Profile');
            },
          ),
        ],
      ),
      drawer: const ChatHistoryView(),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _controller.getMessages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated greeting text using the username.
                      AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'welcome, $_username..',
                            textStyle: const TextStyle(
                              color: AppColors.softLilac,
                              fontSize: 30,
                              fontFamily: 'Kanit',
                              //fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 5.0,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                            speed: const Duration(milliseconds: 50),
                            cursor: '',
                          ),
                          TypewriterAnimatedText(
                            'Your AI health partner\n    is ready to help!',
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kanit',
                              shadows: [
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 5.0,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                            speed: const Duration(milliseconds: 25),
                            cursor: '',
                          ),
                        ],
                        totalRepeatCount: 1,
                        pause: const Duration(milliseconds: 400),
                        displayFullTextOnTap: true,
                        stopPauseOnTap: true,
                      ),
                      const SizedBox(height: 10),
                      Image.asset('assets/images/c.gif', height: 180),
                    ],
                  ),
                );
              }
              List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  String sender = data['sender'] ?? 'Unknown';
                  String text = data['text'] ?? '';
                  Color bgColor =
                      sender == "User"
                          ? AppColors.deepPurple
                          : AppColors.darkPlum;
                  return Align(
                    alignment:
                        sender == "User"
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        text,
                        textDirection:
                            TextDirection
                                .rtl, // 👈 This makes it display right-to-left
                        textAlign:
                            TextAlign
                                .right, // 👈 Optional: aligns text to the right
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.deepPurple,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(100, 0, 0, 0),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type something...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
