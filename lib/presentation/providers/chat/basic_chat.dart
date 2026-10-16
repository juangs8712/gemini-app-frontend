// import 'dart:developer';

import 'package:gemini_app/config/gemini/gemini_implementation.dart';
import 'package:gemini_app/presentation/providers/users/user_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

// import 'package:gemini_app/presentation/providers/chat/is_gemini_writing.dart';

part 'basic_chat.g.dart';

final uuid = Uuid();

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@riverpod
class BasicChat extends _$BasicChat {
  final gemini = GeminiImplementation();
  late final User geminiUser;

  @override
  List<Message> build() {
    geminiUser = ref.read(geminiUserProvider);
    return [];
  }

  // -----------------------------------------------------
  void addMessage({required PartialText partialText, required User user}) {
    // Todo: agregar condición cuando vengan imágenes
    // if ... else if switch

    _addTextMessage(partialText, user);
  }
  // -----------------------------------------------------
  void _addTextMessage(PartialText partialText, User author) {
    _createTextMessage(partialText.text, author);
    _geminiStreamResponse(partialText.text);
    // _geminiResponse(partialText.text);
  }
  // -----------------------------------------------------
  /*
  void _geminiTextResponse(String prompt) async {
    _setGeminiWritingStatus(true);

    final textResponse = await gemini.getResponse(prompt);

    _setGeminiWritingStatus(false);

    _createTextMessage(textResponse, geminiUser);
  }
  */
  // -----------------------------------------------------
  void _geminiStreamResponse(String prompt) async {
    final thinkingMessage = _createTextMessage('Gemini está pensando...', geminiUser);
    final messageId = thinkingMessage.id;

    DateTime lastUpdate = DateTime.now();
    const updateInterval = Duration(milliseconds: 150);
    String latestBuffer = '';

    gemini.getStreamResponse(prompt).listen(
      (buffer) {
        latestBuffer = buffer;
        final now = DateTime.now();

        if (now.difference(lastUpdate) > updateInterval) {
          _updateMessageText(messageId, buffer);
          lastUpdate = now;
        }
      },
      onDone: () {
        _updateMessageText(messageId, latestBuffer);
      },
      onError: (e) {
        _updateMessageText(messageId, 'Error: ${e.toString()}');
      },
    );
  }

  // -----------------------------------------------------
  void _updateMessageText(String messageId, String newText) {
    state = [
      for (final m in state)
        if (m.id == messageId && m is TextMessage)
          m.copyWith(text: newText)
        else
          m
    ];
  }
  // -----------------------------------------------------

  // Helper methods
  /*
  void _setGeminiWritingStatus(bool isWriting) {
    final isGeminiWriting = ref.read(isGeminiWritingProvider.notifier);

    isWriting ? isGeminiWriting.setIsWriting() : isGeminiWriting.setIsNotWriting();
  }
  */
  // -----------------------------------------------------
  Message _createTextMessage(
    String textResponse,
    User geminiUser
  ){
    final message = TextMessage(
      id: uuid.v4(),
      author: geminiUser,
      text: textResponse,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    state = [...state, message];
    // log('Creating message: $textResponse, length: ${state.length}');

    return message;
  }
  // -----------------------------------------------------
}
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~