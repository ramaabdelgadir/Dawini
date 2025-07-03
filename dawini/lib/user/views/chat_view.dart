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

  late final Stream<QuerySnapshot> _messagesStream;

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
      _controller.setCurrentChatID(newChatID);
      _chatHistoryController.getCurrentChatID(newChatID);
    } else {
      _controller.setCurrentChatID(widget.chatID!);
      _chatHistoryController.getCurrentChatID(widget.chatID!);
    }
    _messagesStream = _controller.getMessages();
    setState(() => _isChatInitialized = true);
  }

  Future<void> _loadUserName() async {
    String? name = await _authController.getUserName();
    if (name != null && name.isNotEmpty) {
      setState(() => _username = name);
    }
  }

  Future<void> _sendMessage() async {
    String userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;
    await _controller.addMessage(userMessage, "User");
    _messageController.clear();
    setState(() => _isWaiting = true);
    String aiResponse = await _controller.getAIResponse(userMessage);
    await _controller.addMessage(aiResponse, "AI");
    setState(() => _isWaiting = false);
  }

  void onRecommendDoctorsPressed() {
    if (!mounted) return;
    Navigator.pushNamed(context, 'Dawini/User/MedicalForm');
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

    final Size s = MediaQuery.of(context).size;
    final double W = s.width;
    final double H = s.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/Dawinii.png', height: 33, width: 33),
              const SizedBox(width: 6),
              const Text(
                'داويني',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'YaModernPro',
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final newID = await _controller.startNewChat();
                if (!mounted) return;
                Navigator.pushNamed(
                  context,
                  'Dawini/User/ChatScreen',
                  arguments: newID,
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed:
                  () => Navigator.pushNamed(context, 'Dawini/User/Profile'),
            ),
            const SizedBox(width: 5),
          ],
        ),

        drawer: const ChatHistoryView(),

        body: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
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
                              'مرحباً $_username، يسعدني وجودك..',
                              textStyle: const TextStyle(
                                color: AppColors.softLilac,
                                fontSize: 18,
                                fontFamily: 'TIDO',
                                // shadows: [
                                //   Shadow(
                                //     offset: Offset(2.0, 2.0),
                                //     blurRadius: 2.0,
                                //     color: Color(0x2E000000),
                                //   ),
                                // ],
                              ),
                              speed: const Duration(milliseconds: 47),
                              cursor: '',
                            ),
                            TypewriterAnimatedText(
                              'أنا هنا دائماً في خدمتك!',
                              textStyle: const TextStyle(
                                color: AppColors.softLilac,
                                fontSize: 19,
                                //fontWeight: FontWeight.bold,
                                fontFamily: 'TIDO',
                                // shadows: [
                                //   Shadow(
                                //     offset: Offset(2.0, 2.0),
                                //     blurRadius: 5.0,
                                //     color: Color(0x2E000000),
                                //   ),
                                // ],
                              ),
                              speed: const Duration(milliseconds: 30),
                              cursor: '',
                            ),
                          ],
                          totalRepeatCount: 1,
                          pause: const Duration(milliseconds: 400),
                          displayFullTextOnTap: true,
                          stopPauseOnTap: true,
                        ),
                        const SizedBox(height: 7),
                        Image.asset('assets/images/c.gif', height: 180),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 110, top: 20),
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

                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final sender = data['sender'] ?? 'Unknown';
                          final text = data['text'] ?? '';

                          final bgColor =
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
              child: Row(
                children: [
                  Expanded(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: TextField(
                                controller: _messageController,
                                keyboardType: TextInputType.text,
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                              size: 28,
                            ),
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPlum,
                      padding: EdgeInsets.symmetric(
                        vertical: H * 0.0065,
                        horizontal: W * 0.01,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onRecommendDoctorsPressed,
                    icon: const Padding(
                      padding: EdgeInsets.only(right: 2, top: 2, bottom: 2),
                      child: Icon(
                        Icons.person_search,
                        size: 21.5,
                        color: Colors.white,
                      ),
                    ),
                    label: const Padding(
                      padding: EdgeInsets.only(
                        left: 3.0,
                        top: 2.0,
                        bottom: 2.0,
                      ),
                      child: Text(
                        'اقتراح\nطبيب',
                        style: TextStyle(
                          fontFamily: 'Jawadtaut',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
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
}
