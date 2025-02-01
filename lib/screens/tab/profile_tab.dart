import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/providers/auth_provider.dart';
import 'package:client_flutter/services/device/device_service.dart';
import 'package:client_flutter/services/project/project_service.dart';
import 'package:client_flutter/services/user/user_service.dart';
import 'package:client_flutter/widgets/change_nickname_dialog.dart';
import 'package:client_flutter/widgets/custom_dialog.dart';
import 'package:client_flutter/widgets/user_profile_info.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '마이 페이지',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserProfileInfo(
                nickname: authProvider.user?.nickname ?? '',
                onNicknameEdit: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ChangeNicknameDialog(
                        userService: _userService,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              const Divider(),
              _buildOption(
                text: '내가 작성한 글',
                onTap: () async {
                  final projectService = ProjectService();

                  try {
                    projectService.clearProjectList();
                    await projectService.getSearchedProjectList(
                      searchType: 'nickname',
                      searchKeyword: authProvider.user!.nickname,
                    );

                    final projectList = projectService.searchResults;

                    context.push(
                      '/project/activity',
                      extra : {
                        'title': '내가 작성한 글',
                        'projectList': projectList
                      }
                    );
                  } on DioException catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.message!)),
                    );
                  }
                },
                icon: Icons.article_outlined,
              ),
              _buildOption(
                text: '내가 좋아요한 글',
                onTap: () async {
                  final projectService = ProjectService();

                  try {
                    projectService.clearProjectList();
                    await projectService.getProjectListIsHearted();

                    final projectList = projectService.projectList;

                    context.push(
                      '/project/activity',
                      extra: {
                        'title': '내가 좋아요한 글',
                        'projectList': projectList,
                      },
                    );
                  } on DioException catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.message!)),
                    );
                  }
                },
                icon: Icons.favorite_border,
              ),
              const Divider(),

              _buildOption(
                text: '로그인 기기 관리',
                onTap: () async {
                  final deviceService = DeviceService();

                  try {
                    final deviceList = await deviceService.getDeviceList();
                    context.push(
                      '/auth/account/deviceList',
                      extra: {'deviceList': deviceList},
                    );
                  } on DioException catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.message!)),
                    );
                  }
                },
                icon: Icons.devices,
              ),
              if (authProvider.user?.provider == 'LOCAL')
                _buildOption(
                  text: '비밀번호 변경', 
                  onTap: () => {
                    context.push('/auth/account/changePassword'),
                  },
                  icon: Icons.lock_outline,
                ),
              _buildOption(
                text: '로그아웃',
                onTap: () => _logout(context, authProvider),
                icon: Icons.logout,
              ),
              _buildOption(
                text: '회원탈퇴',
                onTap: () => _withdraw(context, authProvider),
                icon: Icons.delete_forever,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    await _handleUserAction(
      context,
      authProvider.logoutCurrentDevice,
      '로그아웃하시겠습니까?',
      '로그아웃 실패',
    );
  }

  Future<void> _withdraw(BuildContext context, AuthProvider authProvider) async {
    await _handleUserAction(
      context,
      authProvider.deleteUser,
      '회원탈퇴하시겠습니까?',
      '회원탈퇴 실패',
    );
  }

  Future<void> _handleUserAction(
    BuildContext context,
    Future<void> Function() action,
    String dialogMessage,
    String errorMessage,
  ) async {
    final shouldProceed = await showCustomDialog(
      context,
      dialogMessage,
      () => Navigator.of(context).pop(false),
      () => Navigator.of(context).pop(true),
    );

    if (shouldProceed == true) {
      try {
        await action();
      } on DioException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message!)),
        );
      }
    }
  }

  Widget _buildOption({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 20, color: Colors.black54),
            if (icon != null) const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
