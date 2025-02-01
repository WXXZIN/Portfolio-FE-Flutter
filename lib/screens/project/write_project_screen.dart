import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/models/team.dart';
import 'package:client_flutter/services/project/project_service.dart';
import 'package:client_flutter/widgets/custom_submit_button.dart';

class WriteProjectScreen extends StatefulWidget {
  final List<Team> teamList;

  const WriteProjectScreen({
    super.key,
    required this.teamList,
  });

  @override
  State<WriteProjectScreen> createState() => _WriteProjectScreenState();
}

class _WriteProjectScreenState extends State<WriteProjectScreen> {
  Team? _selectedTeam;
  DateTime? _deadLine;
  int _charCount = 0;
  bool _isButtonEnabled = false;

  final List<Team> _teamList = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _memberCountController = TextEditingController(text: '1');
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _teamList.addAll(widget.teamList);

    if (_teamList.isNotEmpty) {
      _selectedTeam = _teamList.first;
    }

    _contentController.addListener(_updateCharCount);
    _contentFocusNode.addListener(_scrollToContent);
  }

  @override
  void dispose() {
    _contentController.removeListener(_updateCharCount);
    _contentFocusNode.removeListener(_scrollToContent);
    _titleController.dispose();
    _memberCountController.dispose();
    _tagsController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateCharCount() {
    setState(() {
       _charCount = _contentController.text.length;
    });
  }

  void _scrollToContent() {
    if (_contentFocusNode.hasFocus) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _scrollController,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: const Text(
                                  '모집글 작성',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            DropdownButtonFormField<Team>(
                              decoration: const InputDecoration(
                                hintText: '팀 선택',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedTeam,
                              items: _buildDropdownItems(),
                              onChanged: (Team? newValue) {
                                setState(() {
                                  _selectedTeam = newValue;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  width: 90,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(239, 242, 244, 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '프로젝트명',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromRGBO(147, 152, 165, 1),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _titleController,
                                    decoration: const InputDecoration(
                                      hintText: '프로젝트명',
                                      hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: Color.fromRGBO(147, 152, 165, 1),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onChanged: (_) {
                                      _checkButtonEnabled();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 90,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(239, 242, 244, 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '모집 인원',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromRGBO(147, 152, 165, 1),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    final currentValue = int.tryParse(_memberCountController.text) ?? 1;
                                    if (currentValue > 1) {
                                      setState(() {
                                        _memberCountController.text = (currentValue - 1).toString();
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.remove),
                                  splashRadius: 20,
                                  color: (int.tryParse(_memberCountController.text) ?? 1) > 1 ? Colors.black : Colors.grey,
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    _memberCountController.text,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    final currentValue = int.tryParse(_memberCountController.text) ?? 1;
                                    if (currentValue < 10) {
                                      setState(() {
                                        _memberCountController.text = (currentValue + 1).toString();
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  splashRadius: 20,
                                  color: (int.tryParse(_memberCountController.text) ?? 1) < 10 ? Colors.black : Colors.grey,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 90,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(239, 242, 244, 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '태그',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromRGBO(147, 152, 165, 1),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _tagsController,
                                    decoration: const InputDecoration(
                                      hintText: '태그 (쉼표로 구분)',
                                      hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: Color.fromRGBO(147, 152, 165, 1),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 90,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(239, 242, 244, 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '마감일',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromRGBO(147, 152, 165, 1),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _deadLine == null
                                        ? '마감일을 선택하세요'
                                        : DateFormat('yyyy-MM-dd').format(_deadLine!),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color.fromRGBO(147, 152, 165, 1)
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: _deadLine ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null && picked != _deadLine) {
                                      setState(() {
                                        _deadLine = picked;
                                      });
                                    }

                                    _checkButtonEnabled();
                                  },
                                  child: const Text('마감일 선택'),
                                ),
                              ],
                            ),
                            Divider(),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 200,
                              child: TextField(
                                controller: _contentController,
                                focusNode: _contentFocusNode,
                                decoration: const InputDecoration(
                                  hintText: '내용을 입력하세요',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Color.fromRGBO(147, 152, 165, 1),
                                  ),
                                  border: InputBorder.none,
                                ),
                                maxLines: null,
                                maxLength: 1000,
                                expands: true,
                                onChanged: (_) {
                                  _checkButtonEnabled();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CustomSubmitButton(
                          text: '작성 완료',
                          isButtonEnabled: _isButtonEnabled,
                          onPressed: _handleWriteProject,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleWriteProject() async {
    final title = _titleController.text;
    final content = _contentController.text;
    final requireMemberCount = int.tryParse(_memberCountController.text) ?? 1;
    final tags = _tagsController.text.isEmpty
      ? null
      : _tagsController.text.split(',').map((tag) => tag.trim()).toList();
    final formattedDeadLine = DateFormat('yyyy-MM-dd').format(_deadLine!);

    final projectService = context.read<ProjectService>();

    try {
      await projectService.writeProject(
        title: title,
        content: content,
        requireMemberCount: requireMemberCount,
        deadline: formattedDeadLine,
        teamId: _selectedTeam!.id,
        tags: tags,
      );

      Navigator.of(context).pop(true);
    } on DioException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message!)),
      );
    }
  }

  List<DropdownMenuItem<Team>> _buildDropdownItems() {
    return [
      const DropdownMenuItem<Team>(
        value: null,
        child: Text('팀 선택'),
      ),
      ..._teamList.map((Team team) {
        return DropdownMenuItem<Team>(
          value: team,
          child: Text(team.name),
        );
      }),
    ];
  }

  void _checkButtonEnabled() {
    setState(() {
      _isButtonEnabled = _selectedTeam != null &&
          _titleController.text.isNotEmpty &&
          _deadLine != null &&
          _charCount > 0 && _charCount <= 1000;
    });
  }
}
