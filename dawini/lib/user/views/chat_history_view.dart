import 'dart:io';
import 'package:dawini/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dawini/user/controllers/chat_history_controller.dart';

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

  /* ───────── حوار تأكيد عام ───────── */
  Future<bool?> _showConfirmationDialog(String title, String content) {
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 25.0,
              ),
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('إضافة محادثة جديدة'),
                onPressed: () {
                  Navigator.pushNamed(context, 'Dawini/User/ChatScreen');
                },
              ),
            ),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _controller.chatHistoryNotifier,
                builder: (context, chats, _) {
                  if (chats.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.plum),
                    );
                  }

                  return ListView.builder(
                    itemCount: chats.length,
                    itemBuilder:
                        (context, index) => ChatTile(
                          chatTitle: 'محادثة ${index + 1}',
                          onDelete: () async {
                            bool? confirmed = await _showConfirmationDialog(
                              'حذف المحادثة',
                              'هل أنت متأكد أنك تريد حذف هذه المحادثة (محادثة ${index + 1})؟',
                            );
                            if (confirmed == true)
                              _controller.deleteChat(index);
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

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF302337),
                    foregroundColor: const Color(0xFFd5d4d6),
                  ),
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Color(0xFFd5d4d6),
                  ),
                  label: const Text('حذف الكل'),
                  onPressed: () async {
                    bool? confirmed = await _showConfirmationDialog(
                      'حذف جميع المحادثات',
                      'هل أنت متأكد أنك تريد حذف جميع المحادثات؟',
                    );
                    if (confirmed == true) _controller.deleteAllChats();
                  },
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
        kIsWeb || (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

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
        child: ListTile(
          title: Text(
            widget.chatTitle,
            style: const TextStyle(color: Colors.white),
          ),
          trailing:
              (isDesktop && isHovered) || (!isDesktop && showDelete)
                  ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: widget.onDelete,
                  )
                  : null,
        ),
      ),
    );
  }
}
