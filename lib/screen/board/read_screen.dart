import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_board/models/board.dart';
import 'package:http/http.dart' as http;

class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  late int no;
  late Future<Board> _board;

  final List<PopupMenuEntry<String>> _popupMenuItems = [
    const PopupMenuItem<String>(
      value: 'update',
      child: Row(
        children: [
          Icon(Icons.edit, color: Colors.black),
          SizedBox(width: 8),
          Text('수정하기'),
        ],
      ),
    ),
    const PopupMenuItem<String>(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.edit, color: Colors.black),
          SizedBox(width: 8),
          Text('삭제하기'),
        ],
      ),
    ),
  ];

  Future<Board> getBoard(int no) async {
    var url = "http://10.0.2.2:8080/board/$no";
    try {
      var response = await http.get(Uri.parse(url));
      print("::::: response - body :::::");
      print(response.body);

      var utf8Decoded = utf8.decode(response.bodyBytes);
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

  Future<bool> deleteBoard(int no) async {
    var url = "http://10.0.2.2:8080/board/$no";
    try {
      var response = await http.delete(Uri.parse(url));
      print("::::: response - statusCode :::::");
      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("게시글 삭제 성공");
        return true;
      } else {
        throw Exception(
            'Failed to delete board. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _showDeleteConfirmDialog() async {
    bool result = false;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('삭제 확인'),
            content: Text('정말로 이 게시글을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('삭제'),
              )
            ],
          );
        }).then((value) {
      result = value ?? false;
    });
    return false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments;
    if (arguments != null) {
      no = arguments as int;
      _board = getBoard(no);
    } else {
      no = 0;
      _board = Future.error('No board number provided');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("게시글 조회"),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return _popupMenuItems;
            },
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) async {
              if (value == 'update') {
                Navigator.pushReplacementNamed(context, "/board/update",
                    arguments: no);
              } else if (value == 'delete') {
                bool check = await _showDeleteConfirmDialog();
                if (check) {
                  deleteBoard(no).then((result) {
                    if (result) {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, "/board/list");
                    }
                  });
                }
              }
            },
          )
        ],
      ),
      body: FutureBuilder<Board>(
        future: _board,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          } else {
            var board = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.article),
                      title: Text(board.title ?? '제목'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(board.writer ?? '작성자'),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    width: double.infinity,
                    height: 320.0,
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(4, 4),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(8)),
                    child: SingleChildScrollView(
                        child: Text(board.content ?? '내용')),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
