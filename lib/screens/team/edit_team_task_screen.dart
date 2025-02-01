import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/models/team_task.dart';
import 'package:client_flutter/services/team/team_service.dart';
import 'package:client_flutter/widgets/custom_submit_button.dart';

class EditTeamTaskScreen extends StatefulWidget {
  final int teamId;
  final List<String> memberNameList;
  final TeamTask teamTask;

  const EditTeamTaskScreen({
    super.key,
    required this.teamId,
    required this.memberNameList,
    required this.teamTask,
  });

  @override
  State<EditTeamTaskScreen> createState() => _EditTeamTaskScreenState();
}

class _EditTeamTaskScreenState extends State<EditTeamTaskScreen> {
  DateTime? _deadLine;
  String? _selectedTaskStatus;
  int? _selectedPriority;
  String? _selectedMember;
  bool _isButtonEnabled = true;

  final List<String> _memberNameList = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _memberNameList.addAll(widget.memberNameList);
    
    _titleController.text = widget.teamTask.title;
    _descriptionController.text = widget.teamTask.description;
    _deadLine = DateFormat('yyyy-MM-dd').parse(widget.teamTask.deadline);
    _selectedTaskStatus = widget.teamTask.taskStatus;
    _selectedPriority = widget.teamTask.taskPriority;
    _selectedMember = widget.teamTask.assigneeMemberName;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight
                ),
                child: IntrinsicHeight(
                  child:Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: const Text(
                                  '작업 수정',
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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                hintText: '내용을 입력하세요',
                                hintStyle: TextStyle(
                                  fontSize: 32,
                                  color: Color.fromRGBO(147, 152, 165, 1),
                                ),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              maxLength: 20,
                              buildCounter: (
                                BuildContext context, 
                                {int? currentLength, int? maxLength, bool? isFocused}
                              ) => null,
                              onChanged: (_) {
                                _checkButtonEnabled();
                              },
                            ),
                            TextField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                hintText: '상세 내용을 입력하세요',
                                hintStyle: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromRGBO(147, 152, 165, 1),
                                ),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontSize: 20),
                              maxLines: 1,
                              maxLength: 50,
                              buildCounter: (
                                BuildContext context, 
                                {int? currentLength, int? maxLength, bool? isFocused}
                              ) => null,
                              onChanged: (_) {
                                _checkButtonEnabled();
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text('마감일: '),
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
                            Row(
                              children: [
                                const Text('상태: '),
                                DropdownButton<String>(
                                  value: _selectedTaskStatus,
                                  items: _buildStatusDropdownItems(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedTaskStatus = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('우선 순위: '),
                                DropdownButton<int>(
                                  value: _selectedPriority,
                                  items: _buildPriorityDropdownItems(),
                                  onChanged: (int? value) {
                                  setState(() {
                                    _selectedPriority = value!;
                                  });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('담당자: '),
                                DropdownButton<String>(
                                  value: _selectedMember,
                                  items: _buildMemberDropdownItems(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedMember = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      Spacer(),
                      
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CustomSubmitButton(
                          isButtonEnabled: _isButtonEnabled,
                          onPressed: _editTeamTask,
                          text: '수정 완료',
                        ),
                      ),
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
  
  Future<void> _editTeamTask() async {
    final teamService = context.read<TeamService>();
    final formattedDeadLine = DateFormat('yyyy-MM-dd').format(_deadLine!);
    final assignedMember = _selectedMember == '-' ? null : _selectedMember;

    try {
      await teamService.editTeamTask(
        teamId: widget.teamId,
        taskId: widget.teamTask.id,
        title: _titleController.text,
        description: _descriptionController.text,
        deadline: formattedDeadLine,
        taskStatus: _selectedTaskStatus!,
        taskPriority: _selectedPriority!,
        assigneeMemberName: assignedMember,
      );
      Navigator.of(context).pop(true);
    } on DioException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message!)),
      );
    }
  }

  List<DropdownMenuItem<String>> _buildStatusDropdownItems() {
    return [
      const DropdownMenuItem<String>(
        value: '할 일',
        child: Text('TODO'),
      ),
      const DropdownMenuItem<String>(
        value: '완료',
        child: Text('DONE'),
      ),
    ];
  }

  List<DropdownMenuItem<int>> _buildPriorityDropdownItems() {
    return [
      const DropdownMenuItem<int>(
        value: 1,
        child: Text('높음'),
      ),
      const DropdownMenuItem<int>(
        value: 2,
        child: Text('보통'),
      ),
      const DropdownMenuItem<int>(
        value: 3,
        child: Text('낮음'),
      ),
    ];
  }

  List<DropdownMenuItem<String>> _buildMemberDropdownItems() {
    return [
      const DropdownMenuItem<String>(
        value: '-',
        child: Text('미정'),
      ),
      ..._memberNameList.map((String member) {
        return DropdownMenuItem<String>(
          value: member,
          child: Text(member),
        );
      }),
    ];
  }

  void _checkButtonEnabled() {
    setState(() {
      _isButtonEnabled = _titleController.text.isNotEmpty &&
          _descriptionController.text.isNotEmpty &&
          _deadLine != null;
    });
  }
}
