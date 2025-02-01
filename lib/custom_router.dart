import 'package:go_router/go_router.dart';

import 'package:client_flutter/models/device.dart';
import 'package:client_flutter/models/project.dart';
import 'package:client_flutter/models/team.dart';
import 'package:client_flutter/screens/main/main_screen.dart';
import 'package:client_flutter/screens/auth/change_password_screen.dart';
import 'package:client_flutter/screens/auth/device_list_screen.dart';
import 'package:client_flutter/screens/auth/device_detail_screen.dart';
import 'package:client_flutter/screens/auth/find_id_screen.dart';
import 'package:client_flutter/screens/auth/find_id_result_screen.dart';
import 'package:client_flutter/screens/auth/initial_screen.dart';
import 'package:client_flutter/screens/auth/local_login_screen.dart';
import 'package:client_flutter/screens/auth/register_user_screen.dart';
import 'package:client_flutter/screens/auth/social_login_screen.dart';
import 'package:client_flutter/screens/auth/temp_password_screen.dart';
import 'package:client_flutter/screens/project/project_activity_screen.dart';
import 'package:client_flutter/screens/project/project_info_screen.dart';
import 'package:client_flutter/screens/team/team_info_screen.dart';


class CustomRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/initial',
    routes: [
      GoRoute(
        path: '/initial',
        builder: (_, __) => const InitialScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => MainScreen(key: MainScreen.mainScreenKey),
      ),
      GoRoute(
        path: '/auth/social/login',
        builder: (_, __) => const SocialLoginScreen(),
      ),
      GoRoute(
        path: '/auth/local/login',
        builder: (_, __) => const LocalLoginScreen(),
      ),
      GoRoute(
        path: '/auth/local/register',
        builder: (_, __) => const RegisterUserScreen()
      ),
      GoRoute(
        path: '/auth/account/findId',
        builder: (_, __) => const FindIdScreen()
      ),
      GoRoute(
        path: '/auth/account/findIdResult',
        builder: (_, state) {
          final data = state.extra as Map<String, String>?;
          final username = data!['username'];

          return FindIdResultScreen(username: username!);
        }
      ),
      GoRoute(
        path: '/auth/account/tempPassword',
        builder: (_, __) => const TempPasswordScreen()
      ),
      GoRoute(
        path: '/auth/account/changePassword',
        builder: (_, __) => const ChangePasswordScreen()
      ),
      GoRoute(
        path: '/auth/account/deviceList',
        builder: (_, state) {
          final data = state.extra as Map<String, Map<String, List<Device>>>;
          final deviceList = data['deviceList'];

          return DeviceListScreen(deviceList: deviceList!);
        }
      ),
      GoRoute(
        path: '/auth/account/deviceDetail',
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>;
          final deviceDetail = data['deviceDetail'] as Device;
          final isCurrentSession = data['isCurrentSession'] as String;

          return DeviceDetailScreen(deviceDetail: deviceDetail, isCurrentSession: isCurrentSession == 'true');
        }
      ),
      GoRoute(
        path: '/team/:teamId',
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>;
          final teamInfo = data['teamInfo'] as Team;
          final isTeamLeader = teamInfo.isTeamLeader;

          return TeamInfoScreen(teamInfo: teamInfo, isTeamLeader: isTeamLeader);
        }
      ),
      GoRoute(
        path: '/project/activity',
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>;
          final title = data['title'] as String;
          final projectList = data['projectList'] as List<Project>;

          return ProjectActivityScreen(title: title, projectList: projectList);
        }
      ),

      GoRoute(
        path: '/project/:projectId',
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>;
          final projectInfo = data['projectInfo'] as Project;
          final isTeamMember = projectInfo.isTeamMember;

          return ProjectInfoScreen(projectInfo: projectInfo, isTeamMember: isTeamMember);
        }
      )
    ],
  );
}
