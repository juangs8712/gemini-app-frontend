import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class GeminiImplementation {
  final Dio _http = Dio(BaseOptions(baseUrl: dotenv.env['ENDPOINT_API'] ?? ''));

  // -----------------------------------------------------
  Future<String> getResponse(String prompt) async {
    try {
      final body = jsonEncode({'prompt': prompt});

      final response = await _http.post('/basic-prompt', data: body);

      return response.data;
    } catch (e) {
      log(e.toString());
      throw Exception('Error al obtener respuesta de Gemini');
    }
  }
  // -----------------------------------------------------
  Stream<String> getStreamResponse(String prompt) async* {
    try {
      // TODO: Tener presente que enviaremos imagenes
      // ! Multipart
      final body = jsonEncode({'prompt': prompt});

      final response = await _http.post(
        '/basic-prompt-stream',
        data: body,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for ( final chunk in stream ) {
        final chunkString = utf8.decode(chunk, allowMalformed: true);

        buffer += chunkString;

        yield buffer;
      }

    } catch (e) {
      log(e.toString());
      throw Exception('Error al obtener respuesta de Gemini');
    }
  }
  // -----------------------------------------------------
}
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~