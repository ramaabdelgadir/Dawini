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
  bool _isWaiting = false;
  String _username = "User";

  @override
  void initState() {
    super.initState();
    _initChat();
    _loadUserName();
  }

  Future<void> _initChat() async {
    if (widget.chatID == null) {
      String newChatID = await _controller.initializeChat();
      _chatHistoryController.getCurrentChatID(newChatID);
    } else {
      _controller.setCurrentChatID(widget.chatID!);
      _chatHistoryController.getCurrentChatID(widget.chatID!);
    }

    setState(() {
      _isChatInitialized = true;
    });
  }

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

    setState(() {
      _isWaiting = true;
    });

    String aiResponse = await _controller.getAIResponse(userMessage);
    await _controller.addMessage(aiResponse, "AI");

    setState(() {
      _isWaiting = false;
    });
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
            Image.asset('assets/images/Dawinii.png', height: 33, width: 33),
            TextButton(
              onPressed: () {},
              child: const Text(
                'داويني',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'YaModernPro',
                ),
              ),
            ),
            const SizedBox(width: 50),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  'Dawini/User/ChatScreen',
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'Dawini/User/Profile');
              },
            ),
            const SizedBox(width: 5),
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
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'مرحباً، $_username ..',
                              textStyle: const TextStyle(
                                color: AppColors.softLilac,
                                fontSize: 30,
                                fontFamily: 'Kanit',
                                shadows: [
                                  Shadow(
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 5.0,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                              speed: Duration(milliseconds: 50),
                              cursor: '',
                            ),
                            TypewriterAnimatedText(
                              'شريكك الصحي الذكي\n     جاهز لمساعدتك!',
                              textStyle: TextStyle(
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
                              speed: Duration(milliseconds: 25),
                              cursor: '',
                            ),
                          ],
                          totalRepeatCount: 1,
                          pause: Duration(milliseconds: 400),
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
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100, top: 20),
                        itemCount: docs.length + (_isWaiting ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isWaiting && index == docs.length) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 15,
                                ),
                                child: Image.asset(
                                  'assets/images/loading.gif',
                                  height: 60,
                                ),
                              ),
                            );
                          }

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
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                text,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Din',
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0.5, 0.5),
                                      blurRadius: 0.5,
                                      color: Color.fromARGB(22, 0, 0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: AppColors.deepPurple,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x63000000),
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
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: const InputDecoration(
                            hintText: 'بماذا تشعر؟',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(167, 158, 158, 158),
                              fontFamily: 'Din',
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Din',
                          ),
                          maxLines: null,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_circle_up_rounded,
                        color: Colors.white,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
