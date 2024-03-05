import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:midholiday/secapi.dart';

class OpenAiService {
  final List<Map<String, String>> messages = [];
  Future<String> decideCorrectApi(String msg) async {
    try {
      final result = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $secretApi'
        },
        body: jsonEncode(
          {
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                'role': 'user',
                'content':
                    'if the folowing  massage require display of an image say yes else say no the massage is $msg .'
              }
            ]
          },
        ),
      );
      log(result.body);
      if (result.statusCode == 200) {
        String content =
            jsonDecode(result.body)['choices'][0]['message']['content'];
        content = content.trim();
        content = content.toLowerCase();
        switch (content) {
          case 'yes':
          case 'yes.':
            final res = await dallE(msg);
            return res;
          default:
            final res = await chatGpt(msg);
            return res;
        }
      }
      return 'Internal Erorr';
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }

  Future<String> chatGpt(String msg) async {
    // print(msg);
    messages.add(
      {'role': 'user', 'content': msg},
    );
    try {
      final result = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $secretApi'
        },
        body: jsonEncode(
          {
            "model": "gpt-3.5-turbo",
            "messages": messages,
          },
        ),
      );
      if (result.statusCode == 200) {
        String content =
            jsonDecode(result.body)['choices'][0]['message']['content'];
        content = content.trim();
        content = content.toLowerCase();
        messages.add(
          {
            'role': 'assistant',
            'content': content,
          },
        );
        return content;
      }
      return 'unexcpected error';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallE(String msg) async {
    messages.add(
      {'role': 'user', 'content': msg},
    );
    try {
      final result = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $secretApi'
        },
        body: jsonEncode(
          {
            'prompt': msg,
            'n': 1,
          },
        ),
      );

      if (result.statusCode == 200) {
        String imageUrl = jsonDecode(result.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        return imageUrl;
      }
      return 'unexcpected error ';
    } catch (e) {
      return e.toString();
    }
  }
}
