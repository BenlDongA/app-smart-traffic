import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      "text":
          "Hello! I'm your SmartTraffic assistant. How can I help you navigate today?",
      "isUser": false
    },
  ];

  bool loading = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    final userText = controller.text.trim();

    setState(() {
      messages.add({"text": userText, "isUser": true});
      loading = true;
    });

    controller.clear();
    _scrollToBottom();

    try {
      final apiMessages = messages.map((m) {
        return {
          "role": m["isUser"] ? "user" : "assistant",
          "content": m["text"],
        };
      }).toList();

      final response = await http.post(
        Uri.parse("https://chatbox-lor.onrender.com/api/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"messages": apiMessages}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botReply =
            data["choices"][0]["message"]["content"] ?? "No response";

        setState(() {
          messages.add({"text": botReply, "isUser": false});
        });
      } else {
        setState(() {
          messages.add({
            "text": "Server error: ${response.statusCode}",
            "isUser": false
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          "text": "❌ Cannot connect to server. Please try again.",
          "isUser": false
        });
      });
    } finally {
      setState(() {
        loading = false;
      });
      _scrollToBottom();
    }
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5F8),
          border: Border(
            left: BorderSide(color: const Color(0xFF7B00FF).withOpacity(0.1)),
            right: BorderSide(color: const Color(0xFF7B00FF).withOpacity(0.1)),
          ),
        ),
        child: Column(
          children: [
            // Header - Giống HTML
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF7B00FF),
                            ),
                          ),
                        ),

                        // Title and status
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "Traffic Assistant",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "ONLINE",
                                    style: TextStyle(
                                      color: Color(0xFF7B00FF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // More button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Chat Area
            Expanded(
              child: Container(
                color: const Color(0xFFF7F5F8),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg["isUser"];

                    return isUser
                        ? _buildUserMessage(msg["text"])
                        : _buildBotMessage(msg["text"], index == 0);
                  },
                ),
              ),
            ),

            // Loading indicator
            if (loading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "Thinking...",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7B00FF),
                  ),
                ),
              ),

            // Bottom Controls
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // Quick Action Menu
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.warning_amber_rounded,
                          label: "Accidents nearby",
                          onTap: () => _handleQuickAction("accidents"),
                        ),
                        const SizedBox(width: 8),
                        _buildQuickActionButton(
                          icon: Icons.videocam,
                          label: "Camera feed",
                          onTap: () => _handleQuickAction("camera"),
                        ),
                        const SizedBox(width: 8),
                        _buildQuickActionButton(
                          icon: Icons.ev_station,
                          label: "Charging stations",
                          onTap: () => _handleQuickAction("charging"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Input Area
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5F8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF7B00FF).withOpacity(0.1),
                      ),
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
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF7B00FF).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
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
          border: Border.all(
            color: const Color(0xFF7B00FF).withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF7B00FF),
            ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7B00FF),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B00FF).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF7B00FF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B00FF).withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotMessage(String text, bool isFirst) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF7B00FF).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF7B00FF).withOpacity(0.2),
              ),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Color(0xFF7B00FF),
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFirst)
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      "TRAFFIC ASSISTANT",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B00FF),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF7B00FF).withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
