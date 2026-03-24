import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Top-level function cho compute
List<dynamic> _parseJson(String responseBody) {
  return jsonDecode(responseBody);
}

Map<String, dynamic> _parseJsonMap(String responseBody) {
  return jsonDecode(responseBody);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  String? currentConversationId;
  String? currentUserId;
  List<Map<String, dynamic>> conversationsList = [];
  bool loading = false;
  bool isLoadingHistory = true;
  bool showSidebar = false;
  bool _isSending = false;

  // Cache cho history
  final Map<String, List<Map<String, dynamic>>> _chatCache = {};

  final String apiBase = 'https://chatbox-lor.onrender.com/api';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      final user = jsonDecode(userStr);
      currentUserId = user['id'] ?? user['_id'];
      await _loadConversationsList();
    }
  }

  Future<void> _loadConversationsList() async {
    if (currentUserId == null) return;

    try {
      final response = await http
          .get(
            Uri.parse('$apiBase/conversations/$currentUserId'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && mounted) {
        final List data = await compute(_parseJson, response.body);
        setState(() {
          conversationsList = data
              .map((conv) => {
                    '_id': conv['_id'],
                    'title': conv['title'] ?? 'New Chat',
                    'createdAt': conv['createdAt'],
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error loading conversations: $e');
    }
  }

  Future<void> _loadHistory(String convId) async {
    if (convId.isEmpty) return;

    // Kiểm tra cache
    if (_chatCache.containsKey(convId) && mounted) {
      setState(() {
        messages = _chatCache[convId]!;
        isLoadingHistory = false;
      });
      _scrollToBottom();
      return;
    }

    if (mounted) {
      setState(() => isLoadingHistory = true);
    }

    try {
      final response = await http
          .get(
            Uri.parse('$apiBase/history/$convId'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && mounted) {
        final List data = await compute(_parseJson, response.body);
        if (data.isNotEmpty) {
          final formatted = data
              .map((m) => ({
                    'text': m['content'],
                    'isUser': m['role'] == 'user',
                    'timestamp': _formatTime(DateTime.parse(m['timestamp'])),
                  }))
              .toList();

          // Lưu vào cache
          _chatCache[convId] = formatted;

          setState(() => messages = formatted);
        } else {
          setState(() => messages = []);
        }
      } else if (response.statusCode == 404 && mounted) {
        setState(() => messages = []);
      }
    } catch (e) {
      print('Error loading history: $e');
      if (mounted) setState(() => messages = []);
    } finally {
      if (mounted) setState(() => isLoadingHistory = false);
    }
  }

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty || loading || _isSending) return;

    final userMessage = controller.text.trim();
    final timestamp = _formatTime(DateTime.now());

    final newUserMessage = {
      'text': userMessage,
      'isUser': true,
      'timestamp': timestamp,
    };

    // Thêm message user và typing indicator ngay lập tức
    if (mounted) {
      setState(() {
        messages.add(newUserMessage);
        messages.add({
          'text': '...',
          'isUser': false,
          'timestamp': timestamp,
          'isTyping': true,
        });
        controller.clear();
        loading = true;
        _isSending = true;
      });
    }

    _scrollToBottom();

    try {
      String convId = currentConversationId ?? '';
      final isNewConversation = convId.isEmpty;

      if (isNewConversation) {
        convId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
      }

      final response = await http
          .post(
            Uri.parse('$apiBase/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': userMessage,
              'conversationId': convId,
              'userId': currentUserId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final Map<String, dynamic> data =
          await compute(_parseJsonMap, response.body);

      if (response.statusCode == 200 && mounted) {
        final botReply = data['reply'] ?? 'No response';
        final newBotMessage = {
          'text': botReply,
          'isUser': false,
          'timestamp': _formatTime(DateTime.now()),
        };

        // Xóa typing indicator và thêm message thật
        setState(() {
          messages.removeLast(); // Xóa typing indicator
          messages.add(newBotMessage);

          if (isNewConversation) {
            currentConversationId = convId;
          }
        });

        // Lưu vào cache
        if (_chatCache.containsKey(convId)) {
          _chatCache[convId] = List.from(_chatCache[convId]!)
            ..addAll([newUserMessage, newBotMessage]);
        } else {
          _chatCache[convId] = [newUserMessage, newBotMessage];
        }

        // Load lại conversations list nếu là conversation mới
        if (isNewConversation) {
          await _loadConversationsList();
        }

        _scrollToBottom();
      } else if (mounted) {
        // Xóa typing indicator và thêm message lỗi
        setState(() {
          messages.removeLast();
          messages.add({
            'text': data['error'] ?? 'Server error: ${response.statusCode}',
            'isUser': false,
            'timestamp': timestamp,
          });
        });
      }
    } catch (e) {
      print('Chat error: $e');
      if (mounted) {
        setState(() {
          messages.removeLast();
          messages.add({
            'text': '❌ Cannot connect to server. Please try again.',
            'isUser': false,
            'timestamp': timestamp,
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
          _isSending = false;
        });
      }
      _scrollToBottom();
    }
  }

  void _createNewConversation() {
    if (mounted) {
      setState(() {
        messages = [];
        currentConversationId = null;
        showSidebar = false;
      });
    }
  }

  void _loadConversation(Map<String, dynamic> conv) {
    if (mounted) {
      setState(() {
        currentConversationId = conv['_id'];
        showSidebar = false;
      });
    }
    _loadHistory(conv['_id']);
  }

  Future<void> _deleteConversation(String convId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content:
            const Text('Are you sure you want to delete this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http
          .delete(
            Uri.parse('$apiBase/conversations/$convId'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && mounted) {
        // Xóa cache
        _chatCache.remove(convId);

        await _loadConversationsList();

        if (convId == currentConversationId) {
          if (conversationsList.isNotEmpty) {
            final nextConv = conversationsList.firstWhere(
              (c) => c['_id'] != convId,
              orElse: () =>
                  conversationsList.isNotEmpty ? conversationsList.first : {},
            );
            if (nextConv.isNotEmpty) {
              _loadConversation(nextConv);
            } else {
              _createNewConversation();
            }
          } else {
            _createNewConversation();
          }
        }
      }
    } catch (e) {
      print('Error deleting conversation: $e');
    }
  }

  Future<void> _clearCurrentChat() async {
    if (currentConversationId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text(
            'Are you sure you want to clear all messages in this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http
          .delete(
            Uri.parse('$apiBase/history/$currentConversationId'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && mounted) {
        // Xóa cache
        if (currentConversationId != null) {
          _chatCache.remove(currentConversationId);
        }
        setState(() => messages = []);
      }
    } catch (e) {
      print('Error clearing chat: $e');
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  void _handleQuickAction(String action) {
    String message = "";
    switch (action) {
      case "accidents":
        message = "Show me accidents nearby";
        break;
      case "camera":
        message = "Show camera feed";
        break;
      case "charging":
        message = "Find charging stations near me";
        break;
    }
    controller.text = message;
    sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => showSidebar = !showSidebar),
                    child: const Icon(Icons.menu, color: Color(0xFF7B00FF)),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Traffic Assistant",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.green),
                            SizedBox(width: 6),
                            Text(
                              "ONLINE",
                              style: TextStyle(
                                color: Color(0xFF7B00FF),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _createNewConversation,
                    child: const Icon(Icons.add_comment, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  if (currentConversationId != null && messages.isNotEmpty)
                    GestureDetector(
                      onTap: _clearCurrentChat,
                      child: const Icon(Icons.delete_sweep, color: Colors.grey),
                    ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Stack(
                children: [
                  // Chat area
                  isLoadingHistory && currentConversationId != null
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF7B00FF)))
                      : messages.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                final isUser = msg['isUser'] == true;
                                final isTyping = msg['isTyping'] == true;

                                if (isTyping) {
                                  return _buildTypingIndicator();
                                }

                                return isUser
                                    ? _buildUserMessage(msg['text'])
                                    : _buildBotMessage(msg['text'], index == 0);
                              },
                            ),

                  // Sidebar
                  if (showSidebar)
                    GestureDetector(
                      onTap: () => setState(() => showSidebar = false),
                      child: Container(
                        color: Colors.black54,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 280,
                            height: double.infinity,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Color(0xFF7B00FF), width: 0.5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Chat History',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF7B00FF),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () =>
                                            setState(() => showSidebar = false),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: conversationsList.length,
                                    itemBuilder: (context, index) {
                                      final conv = conversationsList[index];
                                      final isActive =
                                          conv['_id'] == currentConversationId;
                                      return ListTile(
                                        leading: Icon(
                                          Icons.chat_bubble_outline,
                                          color: isActive
                                              ? const Color(0xFF7B00FF)
                                              : Colors.grey,
                                        ),
                                        title: Text(
                                          conv['title'] ?? 'New Chat',
                                          style: TextStyle(
                                            fontWeight: isActive
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isActive
                                                ? const Color(0xFF7B00FF)
                                                : Colors.black87,
                                          ),
                                        ),
                                        subtitle: Text(
                                          _formatTime(DateTime.parse(
                                              conv['createdAt'])),
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteConversation(conv['_id']),
                                        ),
                                        onTap: () => _loadConversation(conv),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom input
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.warning_amber_rounded,
                          label: "Accidents",
                          onTap: () => _handleQuickAction("accidents"),
                        ),
                        const SizedBox(width: 8),
                        _buildQuickActionButton(
                          icon: Icons.videocam,
                          label: "Cameras",
                          onTap: () => _handleQuickAction("camera"),
                        ),
                        const SizedBox(width: 8),
                        _buildQuickActionButton(
                          icon: Icons.ev_station,
                          label: "Charging",
                          onTap: () => _handleQuickAction("charging"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5F8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF7B00FF).withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: "Type a message...",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onSubmitted: (_) => sendMessage(),
                          ),
                        ),
                        GestureDetector(
                          onTap: sendMessage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7B00FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.send,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF7B00FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat, size: 40, color: Color(0xFF7B00FF)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to Traffic Assistant',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Ask me about traffic conditions, accidents, camera feeds, or anything traffic-related!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF7B00FF).withOpacity(0.1)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF7B00FF),
              ),
            ),
            SizedBox(width: 8),
            Text(
              "Thinking...",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7B00FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5F8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF7B00FF).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF7B00FF)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7B00FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 50),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF7B00FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildBotMessage(String text, bool isFirst) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 50),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF7B00FF).withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFirst)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  "TRAFFIC ASSISTANT",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B00FF),
                  ),
                ),
              ),
            Text(
              text,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
