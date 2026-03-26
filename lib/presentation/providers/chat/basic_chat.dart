import 'package:gemini_app/config/gemini/gemini_implementation.dart';
import 'package:gemini_app/presentation/providers/users/user_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

import 'package:gemini_app/presentation/providers/chat/is_gemini_writing.dart';

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
    _geminiTextResponse(partialText.text);
  }
  // -----------------------------------------------------
  void _geminiTextResponse(String prompt) async {
    _setGeminiWritingStatus(true);

    final textResponse = await gemini.getResponse(prompt);

    _setGeminiWritingStatus(false);

    _createTextMessage(textResponse, geminiUser);
  }
  // -----------------------------------------------------

  // Helper methods
  void _setGeminiWritingStatus(bool isWriting) {
    final isGeminiWriting = ref.read(isGeminiWritingProvider.notifier);

    isWriting ? isGeminiWriting.setIsWriting() : isGeminiWriting.setIsNotWriting();
  }
  // -----------------------------------------------------
  void _createTextMessage(
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
  }
  // -----------------------------------------------------
}
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~