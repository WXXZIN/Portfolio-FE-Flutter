import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:client_flutter/providers/auth_provider.dart';
import 'package:client_flutter/services/user/user_service.dart';
import 'package:client_flutter/widgets/custom_text_field.dart';

class ChangeNicknameDialog extends StatefulWidget {
  final UserService userService;

  const ChangeNicknameDialog({
    super.key,
    required this.userService,
  });

  @override
  State<ChangeNicknameDialog> createState() => _ChangeNicknameDialogState();
}

class _ChangeNicknameDialogState extends State<ChangeNicknameDialog> {
  late AuthProvider _authProvider;

  final _nicknameController = TextEditingController();
  bool isNicknameAvailable = false;
  String message = ' ';

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                '닉네임 변경',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _nicknameController, 
              keyboardType: TextInputType.text, 
              textInputAction: TextInputAction.done,
              hintText: '닉네임을 입력하세요',
              onButtonPressed: _checkNicknameAvailability,
            ),
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  message,
                  style: TextStyle(
                    color: message == '사용 가능한 닉네임입니다.'
                        ? Colors.green 
                        : Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, 
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, 
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isNicknameAvailable ? _changeNickname : null,
                    child: const Text('변경하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _checkNicknameAvailability() {
    final nickname = _nicknameController.text;

    if (nickname.isEmpty) {
      setState(() {
        isNicknameAvailable = false;
        message = '닉네임을 입력해주세요.';
      });
      return;
    } else if (nickname == _authProvider.user!.nickname) {
      setState(() {
        isNicknameAvailable = false;
        message = '현재 닉네임과 동일합니다.';
      });
      return;
    }

    widget.userService.isNicknameTaken(nickname: nickname).then((isTaken) {
      setState(() {
        isNicknameAvailable = !isTaken;
        message = isTaken ? '이미 사용중인 닉네임입니다.' : '사용 가능한 닉네임입니다.';
      });
    });
  }

  void _changeNickname() {
    final nickname = _nicknameController.text;

    if (isNicknameAvailable) {
      widget.userService.changeNickname(nickname: nickname).then((_) {
        _authProvider.updateUser(nickname: nickname);
        
        Navigator.of(context).pop();
      }).catchError((error) {
        setState(() {
            message = error.message!;
          });
      });
    }
  }
}
