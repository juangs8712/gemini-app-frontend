import 'package:flutter/material.dart';

import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_app/presentation/providers/chat/basic_chat.dart';

import 'package:gemini_app/presentation/providers/chat/is_gemini_writing.dart';
import 'package:gemini_app/presentation/providers/users/user_provider.dart';

import 'package:flutter_chat_core/flutter_chat_core.dart' as core;

class BasicPromptScreen extends ConsumerStatefulWidget {
  const BasicPromptScreen({super.key});

  @override
  ConsumerState<BasicPromptScreen> createState() => _BasicPromptScreenState();
}

class _BasicPromptScreenState extends ConsumerState<BasicPromptScreen> {
  late final core.InMemoryChatController _chatController;

  @override
  void initState() {
    super.initState();
    _chatController = core.InMemoryChatController();
    final initialMessages = ref.read(basicChatProvider);
    _updateMessages(initialMessages);
  }

  void _updateMessages(List<types.Message> messages) {
    // Convert types.Message to core.Message using JSON
    final coreMessages = messages.map((m) {
      final json = m.toJson();
      json['authorId'] = m.author.id;
      return core.Message.fromJson(json);
    }).toList();
    _chatController.setMessages(coreMessages);
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(basicChatProvider, (previous, next) {
      if (previous != next) {
        _updateMessages(next);
      }
    });

    final user = ref.watch(userProvider);
    // ignore: unused_local_variable
    final isGeminiWriting = ref.watch(isGeminiWritingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Prompt Básico')),
      body: Chat(
        chatController: _chatController,
        currentUserId: user.id,
        resolveUser: (userId) async {
          // Simple resolution for now. In real app, fetch from provider or API.
          if (userId == user.id) {
            return core.User.fromJson(user.toJson());
          }
          return core.User.fromJson(
            types.User(id: userId, firstName: 'Gemini', lastName: '').toJson(),
          );
        },
        onMessageSend: (message) {
           final basicChatNotifier = ref.read(basicChatProvider.notifier);
           basicChatNotifier.addMessage(
             partialText: types.PartialText(text: message), 
             user: user
           );
        },
      ),
    );
  }
}
