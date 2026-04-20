import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';

class ChatInputEditor extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback? onAttach;
  final VoidCallback? onCamera;
  final VoidCallback? onVoice;

  const ChatInputEditor({
    super.key,
    required this.onSend,
    this.onAttach,
    this.onCamera,
    this.onVoice,
  });

  @override
  State<ChatInputEditor> createState() => _ChatInputEditorState();
}

class _ChatInputEditorState extends State<ChatInputEditor> {
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final isTyping = _controller.text.trim().isNotEmpty;
    if (isTyping != _isTyping) {
      setState(() {
        _isTyping = isTyping;
      });
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            _buildActionButton(Icons.add_circle_rounded, widget.onAttach),
            _buildActionButton(Icons.camera_alt_rounded, widget.onCamera),
            
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 5,
                  minLines: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Soạn tin nhắn...',
                    hintStyle: TextStyle(color: AppColors.darkTextHint, fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            if (_isTyping)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.darkAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              )
            else
              _buildActionButton(Icons.mic_rounded, widget.onVoice),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback? onTap) {
    return IconButton(
      icon: Icon(icon, color: AppColors.darkAccent, size: 24),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}
