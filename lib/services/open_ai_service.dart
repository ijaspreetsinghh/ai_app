import 'dart:convert';

import 'package:ai/secret.dart';
import 'package:http/http.dart' as http;

class OpenApiService {
  final List<Map<String, String>> messages = [];
  Future<String> isArtPromptAPI(String prompt) async {
    print('called api');
    try {
      final resp = await http.post(
          Uri.parse(
            "https://api.openai.com/v1/chat/completions",
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAPiKey'
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                'role': 'user',
                'content':
                    'Does this message want to generate an AI picture, image, art or anything similar? $prompt. Simply answer with yes or no'
              }
            ]
          }));

      if (resp.statusCode == 200) {
        String content =
            jsonDecode(resp.body)['choices'][0]['message']['content'];

        content = content.trim().toLowerCase();
        print(content);
        switch (content) {
          case 'yes':
          case 'yes.':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }

      return "An internal error occured";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({'role': 'user', 'content': prompt});
    try {
      final resp = await http.post(
          Uri.parse(
            "https://api.openai.com/v1/chat/completions",
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAPiKey'
          },
          body: jsonEncode({"model": "gpt-3.5-turbo", "messages": messages}));
      print(resp.body);
      if (resp.statusCode == 200) {
        String content =
            jsonDecode(resp.body)['choices'][0]['message']['content'];

        content = content.trim();

        messages.add({'role': 'assistant', 'content': content});
        return content;
      }
      return "An internal error occured";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({'role': 'user', 'content': prompt});
    try {
      final resp = await http.post(
          Uri.parse(
            "https://api.openai.com/v1/images/generations",
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAPiKey'
          },
          body: jsonEncode({
            'prompt': prompt,
            'n': 1,
          }));
      print(resp.body);
      if (resp.statusCode == 200) {
        String imageUrl = jsonDecode(resp.body)['data'][0]['url'];

        imageUrl = imageUrl.trim();

        messages.add({'role': 'assistant', 'content': imageUrl});
        return imageUrl;
      }
      return "An internal error occured";
    } catch (e) {
      return e.toString();
    }
  }
}
