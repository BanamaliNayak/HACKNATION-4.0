import 'package:flutter/material.dart';

class ChatInputRow extends StatefulWidget {
  final Function(String) onSend;
  const ChatInputRow({super.key, required this.onSend});

  @override
  State<ChatInputRow> createState() => _ChatInputRowState();
}

class _ChatInputRowState extends State<ChatInputRow> {
  final TextEditingController _controller = TextEditingController();
  bool showMic = true;

  void _onTextChanged(String text) {
    setState(() {
      showMic = text.trim().isEmpty;
    });
  }

  void _submitMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSend(message);
      _controller.clear();
      _onTextChanged('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Text input field.
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onTextChanged,
              onSubmitted: (_) => _submitMessage(),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Type here...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Toggle mic or send button.
          IconButton(
            icon: Icon(
              showMic ? Icons.mic : Icons.send,
              color: Colors.white,
            ),
            onPressed: _submitMessage,
          ),
        ],
      ),
    );
  }
}
