import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/core/services/gemini_service.dart';

class AIAdvisorPage extends StatefulWidget {
  const AIAdvisorPage({super.key});

  @override
  State<AIAdvisorPage> createState() => _AIAdvisorPageState();
}

class _AIAdvisorPageState extends State<AIAdvisorPage> {
  final TextEditingController _messageController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Xin chào! Tôi là chuyên gia dinh dưỡng ảo của Bếp Việt. Tôi có thể giúp bạn tư vấn về dinh dưỡng, sức khỏe và lập kế hoạch ăn uống phù hợp với gia đình.',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Chuyên gia ảo'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/premium'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          // AI Status Card
          Container(
            margin: const EdgeInsets.all(AppConfig.defaultPadding),
            padding: const EdgeInsets.all(AppConfig.defaultPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
              ),
              borderRadius: BorderRadius.circular(AppConfig.defaultPadding + 4),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConfig.smallPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConfig.smallPadding),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConfig.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chuyên gia dinh dưỡng AI',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppConfig.smallPadding / 2),
                      Text(
                        _isLoading ? 'Đang xử lý...' : 'Sẵn sàng tư vấn 24/7',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConfig.smallPadding,
                    vertical: AppConfig.smallPadding / 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConfig.smallPadding),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppConfig.smallPadding / 2),
                      Text(
                        'Online',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quick Questions
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.defaultPadding,
            ),
            child: Text(
              'Câu hỏi thường gặp',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: AppConfig.smallPadding),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.defaultPadding,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickQuestion('Tôi bị cao huyết áp, nên ăn gì?'),
                  const SizedBox(width: AppConfig.smallPadding),
                  _buildQuickQuestion('Cách giảm cân an toàn?'),
                  const SizedBox(width: AppConfig.smallPadding),
                  _buildQuickQuestion('Trẻ em cần dinh dưỡng gì?'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConfig.defaultPadding),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConfig.defaultPadding,
              ),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingIndicator();
                }
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(AppConfig.defaultPadding),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập câu hỏi của bạn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConfig.smallPadding + 4,
                        ),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConfig.smallPadding + 4,
                        ),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConfig.smallPadding + 4,
                        ),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConfig.defaultPadding,
                        vertical: AppConfig.smallPadding,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: AppConfig.smallPadding),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(
                      AppConfig.smallPadding + 4,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestion(String question) {
    return GestureDetector(
      onTap: () => _sendQuickQuestion(question),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConfig.defaultPadding,
          vertical: AppConfig.smallPadding,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConfig.smallPadding + 4),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          question,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConfig.smallPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: AppTheme.primaryGreen,
              size: 16,
            ),
          ),
          const SizedBox(width: AppConfig.smallPadding),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.defaultPadding,
              vertical: AppConfig.smallPadding,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConfig.smallPadding + 4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(width: AppConfig.smallPadding),
                Text(
                  'Đang suy nghĩ...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConfig.smallPadding),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppTheme.primaryGreen,
                size: 16,
              ),
            ),
            const SizedBox(width: AppConfig.smallPadding),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppConfig.smallPadding + 4),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryGreen
                    : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppConfig.smallPadding + 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: message.isUser
                          ? Colors.white
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConfig.smallPadding / 2),
                  Text(
                    _formatTime(message.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: AppConfig.smallPadding),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.primaryGreen,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(text: userMessage, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    try {
      // Gọi Gemini AI
      final aiResponse = await _geminiService.getNutritionAdvice(userMessage);

      setState(() {
        _messages.add(
          ChatMessage(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                'Xin lỗi, tôi gặp lỗi khi xử lý câu hỏi của bạn. Vui lòng thử lại sau.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }
  }

  void _sendQuickQuestion(String question) {
    _messageController.text = question;
    _sendMessage();
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add(
        ChatMessage(
          text:
              'Xin chào! Tôi là chuyên gia dinh dưỡng ảo của Bếp Việt. Tôi có thể giúp bạn tư vấn về dinh dưỡng, sức khỏe và lập kế hoạch ăn uống phù hợp với gia đình.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  String _generateAIResponse(String userMessage) {
    // Simple AI response simulation
    if (userMessage.toLowerCase().contains('cao huyết áp')) {
      return 'Để kiểm soát huyết áp, bạn nên:\n• Giảm muối trong thức ăn\n• Tăng cường rau xanh, trái cây\n• Hạn chế đồ chiên rán\n• Uống đủ nước\n• Tập thể dục đều đặn';
    } else if (userMessage.toLowerCase().contains('giảm cân')) {
      return 'Để giảm cân an toàn:\n• Ăn nhiều protein, ít carbs\n• Tăng cường rau củ\n• Uống đủ nước\n• Tập thể dục 30 phút/ngày\n• Ngủ đủ 7-8 tiếng';
    } else if (userMessage.toLowerCase().contains('trẻ em')) {
      return 'Dinh dưỡng cho trẻ em:\n• Đa dạng thực phẩm\n• Đủ 4 nhóm chất\n• Hạn chế đồ ngọt\n• Tăng cường sữa, trứng\n• Ăn đúng giờ';
    } else {
      return 'Cảm ơn bạn đã hỏi! Tôi đang phân tích câu hỏi của bạn và sẽ đưa ra lời khuyên phù hợp nhất. Bạn có thể chia sẻ thêm thông tin về tình trạng sức khỏe hiện tại không?';
    }
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
