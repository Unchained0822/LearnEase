import 'package:flutter/material.dart';
import '../services/openai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _openAI = OpenAIService();
  String _response = '';

  void _sendMessage() async {
    String message = _controller.text;
    String reply = await _openAI.getChatResponse(message);
    setState(() {
      _response = reply;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Chatbot")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Ask me anything'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _sendMessage, child: const Text('Send')),
            const SizedBox(height: 20),
            Text(_response),
          ],
        ),
      ),
    );
  }
}
