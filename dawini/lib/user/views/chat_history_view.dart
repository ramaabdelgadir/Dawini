import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dawini/theme/app_colors.dart';
import 'package:dawini/user/controllers/chat_history_controller.dart';
import 'package:dawini/user/controllers/chat_controller.dart';

class ChatHistoryView extends StatefulWidget {
  const ChatHistoryView({super.key});

  @override
  ChatHistoryViewState createState() => ChatHistoryViewState();
}

class ChatHistoryViewState extends State<ChatHistoryView> {
  final ChatHistoryController _controller = ChatHistoryController();

  @override
  void initState() {
    super.initState();
    _controller.loadChatHistory();
  }

  Future<bool?> _confirm(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: AppColors.darkBackground,
              title: Text(title, style: const TextStyle(color: Colors.white)),
              content: Text(
                content,
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'نعم',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: AppColors.darkBackground,
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final newID = await ChatController().startNewChat();
                  if (!context.mounted) return;
                  Navigator.pushNamed(
                    context,
                    'Dawini/User/ChatScreen',
                    arguments: newID,
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text(
                  'إضافة محادثة جديدة',
                  style: TextStyle(fontSize: 15, fontFamily: 'Jawadtaut'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPlum,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // list of chats ---------------------------------------------
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _controller.chatHistoryNotifier,
                builder: (context, chats, _) {
                  if (chats.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkPlum,
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    itemCount: chats.length,
                    separatorBuilder:
                        (_, __) => const Divider(
                          color: Colors.white10,
                          thickness: 0.2,
                        ),
                    itemBuilder:
                        (context, index) => ChatTile(
                          chatTitle: 'محادثة ${index + 1}',
                          onDelete: () async {
                            bool? ok = await _confirm(
                              'حذف المحادثة',
                              'هل أنت متأكد أنك تريد حذف هذه المحادثة؟',
                            );
                            if (ok == true) _controller.deleteChat(index);
                          },
                          onTap: () {
                            String chatID = _controller.openChat(index);
                            Navigator.pushNamed(
                              context,
                              'Dawini/User/ChatScreen',
                              arguments: chatID,
                            );
                          },
                        ),
                  );
                },
              ),
            ),
            // delete all -------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  bool? ok = await _confirm(
                    'حذف جميع المحادثات',
                    'هل أنت متأكد أنك تريد حذف جميع المحادثات؟',
                  );
                  if (ok == true) _controller.deleteAllChats();
                },
                icon: const Icon(Icons.delete_forever, size: 20),
                label: const Text(
                  'حذف الكل',
                  style: TextStyle(fontSize: 15, fontFamily: 'Jawadtaut'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38253C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatTile extends StatefulWidget {
  final String chatTitle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ChatTile({
    required this.chatTitle,
    required this.onDelete,
    required this.onTap,
    super.key,
  });

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  bool isHovered = false;
  bool showDelete = false;

  @override
  Widget build(BuildContext context) {
    bool isDesktop =
        kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    return GestureDetector(
      onLongPress: () {
        if (!isDesktop) setState(() => showDelete = true);
      },
      onTap: () {
        if (!isDesktop) setState(() => showDelete = false);
        widget.onTap();
      },
      child: MouseRegion(
        onEnter: (_) => isDesktop ? setState(() => isHovered = true) : null,
        onExit: (_) => isDesktop ? setState(() => isHovered = false) : null,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.deepPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.chatTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Din',
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if ((isDesktop && isHovered) || (!isDesktop && showDelete))
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: widget.onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
