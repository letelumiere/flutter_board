import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_board/models/board.dart';
import 'package:http/http.dart' as http;

class Service {
  var _formKey;
  var _titleController;
  var _writerController;
  var _contentController;
  var context;
  var no;

  Future<void> insert() async {
    if (_formKey.currentState!.validate()) {
//      var url = "http://10.0.2.2:8080/board/insert";
      var url = "http://localhost:8080/board/insert";

      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'title': _titleController.text,
            'writer': _writerController.text,
            'content': _contentController.text,
          }),
        );
        print("::::: response - body :::::");
        print(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('게시글 등록 성공!'),
              backgroundColor: Colors.blueAccent,
            ),
          );
          Navigator.pushReplacementNamed(context, "/board/list");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('게시글 등록 실패...'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('에러: $e')),
        );
      }
    }
  }

  Future<Board> getBoard(int no) async {
//    var url = "http://10.0.2.2:8080/board/read/$no";
    var url = "http://localhost:8080/board/read/$no";

    try {
      var response = await http.get(Uri.parse(url));
      print("::::: response - body :::::");
      print(response.body);
      // UTF-8 디코딩
      var utf8Decoded = utf8.decode(response.bodyBytes);
      // JSON 디코딩
      var boardJson = jsonDecode(utf8Decoded);
      print(boardJson);
      return Board(
        no: boardJson['no'],
        title: boardJson['title'],
        writer: boardJson['writer'],
        content: boardJson['content'],
      );
    } catch (e) {
      print(e);
      throw Exception('Failed to load board');
    }
  }

  /// 게시글 삭제 요청
  Future<bool> deleteBoard(int no) async {
//    var url = "http://10.0.2.2:8080/board/$no";
    var url = "http://localhost:8080/board/$no";

    try {
      var response = await http.delete(Uri.parse(url));
      print("::::: response - statusCode :::::");
      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 성공적으로 삭제됨
        print("게시글 삭제 성공");
        return true;
      } else {
        // 실패 시 오류 메시지
        print("삭제 실패");
        throw Exception(
            'Failed to delete board. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// 게시글 수정 요청
  Future<void> updateBoard() async {
    if (_formKey.currentState!.validate()) {
//      var url = "http://10.0.2.2:8080/board/update";
      var url = "http://localhost:8080/board/update";
      try {
        var response = await http.put(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'no': no,
            'title': _titleController.text,
            'writer': _writerController.text,
            'content': _contentController.text,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('게시글 수정 성공!'),
              backgroundColor: Colors.blueAccent,
            ),
          );
          Navigator.pushReplacementNamed(context, "/board/list");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('게시글 수정 실패...'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('에러: $e')),
        );
      }
    }
  }
}


/* chatGPT의 예시
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  /// 공통 HTTP 요청 메서드
  Future<http.Response> _sendRequest({
    required String endpoint,
    required String method,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    headers ??= {"Content-Type": "application/json"};
    http.Response response;

    try {
      switch (method) {
        case 'POST':
          response = await http.post(url, headers: headers, body: body);
          break;
        case 'PUT':
          response = await http.put(url, headers: headers, body: body);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        case 'GET':
        default:
          response = await http.get(url, headers: headers);
      }

      return response;
    } catch (e) {
      throw Exception('HTTP 요청 실패: $e');
    }
  }

  /// 공통 응답 처리
  T _handleResponse<T>(http.Response response, T Function(dynamic) parser) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final utf8Decoded = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(utf8Decoded);
      return parser(jsonData);
    } else {
      throw Exception('HTTP 요청 실패: ${response.statusCode}');
    }
  }

  /// 게시글 생성
  Future<void> createBoard({
    required BuildContext context,
    required String title,
    required String writer,
    required String content,
  }) async {
    final response = await _sendRequest(
      endpoint: '/board/insert',
      method: 'POST',
      body: jsonEncode({
        'title': title,
        'writer': writer,
        'content': content,
      }),
    );

    _handleResponse(response, (json) => json); // 파싱 불필요
    _showSnackBar(context, '게시글 등록 성공!', Colors.blueAccent);
    Navigator.pushReplacementNamed(context, '/board/list');
  }

  /// 게시글 조회
  Future<Board> fetchBoard(int no) async {
    final response = await _sendRequest(
      endpoint: '/board/read/$no',
      method: 'GET',
    );

    return _handleResponse(response, (json) => Board.fromJson(json));
  }

  /// 게시글 수정
  Future<void> updateBoard({
    required BuildContext context,
    required int no,
    required String title,
    required String writer,
    required String content,
  }) async {
    final response = await _sendRequest(
      endpoint: '/board/update',
      method: 'PUT',
      body: jsonEncode({
        'no': no,
        'title': title,
        'writer': writer,
        'content': content,
      }),
    );

    _handleResponse(response, (json) => json); // 파싱 불필요
    _showSnackBar(context, '게시글 수정 성공!', Colors.blueAccent);
    Navigator.pushReplacementNamed(context, '/board/list');
  }

  /// 게시글 삭제
  Future<bool> deleteBoard(int no) async {
    final response = await _sendRequest(
      endpoint: '/board/$no',
      method: 'DELETE',
    );

    _handleResponse(response, (json) => json); // 성공 여부만 체크
    return true;
  }

  /// 공통 Snackbar 출력 메서드
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}

/// 게시글 모델
class Board {
  final int no;
  final String title;
  final String writer;
  final String content;

  Board({
    required this.no,
    required this.title,
    required this.writer,
    required this.content,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      no: json['no'],
      title: json['title'],
      writer: json['writer'],
      content: json['content'],
    );
  }
}


주요 개선 사항
중복 로직 제거:

HTTP 요청 로직을 _sendRequest 메서드로 통합.
응답 처리 로직을 _handleResponse 메서드로 통합.
모듈화:

각 기능별 메서드는 공통 로직을 호출하도록 단순화.
Board 모델을 통해 JSON 파싱과 객체 생성을 분리.
에러 핸들링:

HTTP 요청과 응답에서 발생하는 에러를 명확히 처리.
에러 메시지는 사용자에게 직접 보여주는 대신 개발자용 로그로 제한.
코드 가독성 향상:

파라미터 명시와 BuildContext를 통해 메서드 호출 시 사용 방법을 명확히 함.
SnackBar와 네비게이션 처리 로직을 공통 메서드로 분리.
재사용성 강화:

HTTP 메서드와 엔드포인트 변경이 쉽도록 baseUrl과 메서드 통합.
이제 이 코드는 가독성과 유지보수성이 훨씬 높아졌으며, 새로운 기능 추가나 변경이 필요할 때 더 효율적으로 작업할 수 있습니다.
*/