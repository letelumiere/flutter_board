import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_board/models/board.dart';
import 'package:http/http.dart' as http;

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Board> _boardList = [];

  @override
  void initState() {
    super.initState();
    getBoardList().then((result) {
      setState(() {
        _boardList = result;
      });
    });
  }

  Future<List<Board>> getBoardList() async {
    var url = "http://10.0.2.2:8080/board";
    List<Board> list = [];

    try {
      var response = await http.get(Uri.parse(url));
      print("::::: response - body :::::");
      print(response.body);

      //UTF-8 decoding
      var utf8Decoded = utf8.decode(response.bodyBytes);
      //Json decoding
      var boardList = jsonDecode(utf8Decoded);

      for (var i = 0; i < boardList.length; i++) {
        list.add(Board(
          no: boardList[i]['no'],
          title: boardList[i]['title'],
          writer: boardList[i]['writer'],
          content: boardList[i]['content'],
        ));
      }
      print(list);
    } catch (e) {
      print(e);
    }
    return list;
  }

  final List<PopupMenuEntry<String>> _popupMenuitems = [
    const PopupMenuItem<String>(
      value: 'update',
      child: Row(
        children: [
          Icon(Icons.edit, color: Colors.black),
          SizedBox(width: 8),
          Text('수정하기')
        ],
      ),
    ),
    const PopupMenuItem<String>(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.edit, color: Colors.black),
          SizedBox(width: 8),
          Text('수정하기')
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("게시글 목록")),
      body: Container(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
        child: ListView.builder(
          itemCount: _boardList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                child: Card(
                  child: ListTile(
                      leading: Text(_boardList[index].no.toString() ?? '0'),
                      title: Text(_boardList[index].title ?? '제목없음'),
                      subtitle: Text(_boardList[index].writer ?? '-'),
                      trailing: PopupMenuButton<String>(
                        itemBuilder: (BuildContext context) {
                          return _popupMenuitems;
                        },
                        onSelected: (String value) async {
                          if (value == 'update') {
                            Navigator.pushNamed(
                              context,
                              "/board/update",
                              arguments: _boardList[index].no,
                            );
                          } else if (value == 'delete') {
                            bool check = await _showDeleteConfirmDialog();
                            if (check) {
                              deleteBoard(_boardList[index].no).then((result) {
                                if (result) {
                                  setState(() {
                                    _boardList.removeAt(index);
                                  });
                                }
                              });
                            }
                          }
                        },
                      )),
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/board/read",
                    arguments: _boardList[index].no,
                  );
                });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/board/insert");
          },
          child: const Icon(Icons.create)),
    );
  }

  Future<bool> deleteBoard(int? no) async {
    var url = " http://10.0.2.2:8080/board/$no";
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
    return false;
  }

  Future<bool> _showDeleteConfirmDialog() async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('정말로 이 게시글을 삭제하겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('취소'),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('삭제')),
          ],
        );
      },
    ).then((value) {
      result = value ?? false;
    });
    return result;
  }
}
