import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/providers/auth_provider.dart';
import 'package:client_flutter/screens/tab/home_tab.dart';
import 'package:client_flutter/screens/tab/profile_tab.dart';
import 'package:client_flutter/screens/tab/search_tab.dart';
import 'package:client_flutter/screens/tab/team_tab.dart';
import 'package:client_flutter/services/project/project_service.dart';
import 'package:client_flutter/services/team/team_service.dart';
import 'package:client_flutter/widgets/network_status_overlay.dart';

class MainScreen extends StatefulWidget {
  static final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget?> _pages = [
    null, null, null, null
  ];

  @override
  void initState() {
    super.initState();

    final authProvider = context.read<AuthProvider>();
    authProvider.onLogin = getTeamList;
    authProvider.onLogout = updateIndexAfterLogout;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectService = context.read<ProjectService>();
      final teamService = context.read<TeamService>();

      projectService.getProjectList();

      if (authProvider.isAuthenticated) {
        teamService.getTeamList();
      }
    });

    _pages[0] = _createPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NetworkStatusOverlay(),
          IndexedStack(
            index: _selectedIndex,
            children: _pages.map((page) => page ?? const SizedBox.shrink()).toList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: _navItems.map((item) {
          return BottomNavigationBarItem(
            icon: item.icon(_selectedIndex),
            label: '',
          );
        }).toList(),
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
      ),
    );
  }

  Future<void> _onTabTapped(int index) async {
    /* if (index == 0) {
      final projectService = context.read<ProjectService>();
      projectService.getProjectList();
    } */
    final authProvider = context.read<AuthProvider>();
    final bool isAuth = await authProvider.verifyToken();

    if (!isAuth) {
      if ([0, 1].contains(index)) {
        authProvider.logoutCurrentDevice();
        return;
      }

      if ([2, 3].contains(index)) {
        context.push('/auth/social/login');
        return;
      }

      if (index == 2) {
        final teamService = context.read<TeamService>();
        teamService.getTeamList();
      }
    }

    if (_pages[index] == null) {
      _pages[index] = _createPage(index);
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  void getTeamList() {
    final teamService = context.read<TeamService>();
    teamService.getTeamList();
  }
  
  void updateIndexAfterLogout() {
    final teamService = context.read<TeamService>();

    teamService.clearTeamList();
    teamService.clearTeamTaskList();
    teamService.clearTeamApplicationList();

    setState(() {
      _selectedIndex = 0;
      _pages[0] = const HomeTab();
      _pages[1] = null;
      _pages[2] = null;
      _pages[3] = null;
    });

    context.go('/');
  }

  void switchToSearchTab(String searchKeyword) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _selectedIndex = 1;
      _pages[1] = SearchTab(
        key: ValueKey('searchTab_$searchKeyword-$timestamp'),
        searchType: '태그',
        searchKeyword: searchKeyword,
      );
    });
  }

  Widget _createPage(int index) {
    switch (index) {
      case 0:
        return const HomeTab();
      case 1:
        return const SearchTab(searchType: '', searchKeyword: '');
      case 2:
        return TeamTab();
      case 3:
        return const ProfileTab();
      default:
        return const SizedBox.shrink();
    }
  }
}

class NavItem {
  final int index;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const NavItem({
    required this.index,
    required this.activeIcon,
    required this.inactiveIcon,
  });

  Icon icon(int selectedIndex) {
    return Icon(
      selectedIndex == index ? activeIcon : inactiveIcon,
    );
  }
}

const _navItems = [
  NavItem(
    index: 0,
    activeIcon: Icons.home,
    inactiveIcon: Icons.home_outlined,
  ),
  NavItem(
    index: 1,
    activeIcon: Icons.search,
    inactiveIcon: Icons.search_outlined,
  ),
  NavItem(
    index: 2,
    activeIcon: Icons.people,
    inactiveIcon: Icons.people_outlined,
  ),
  NavItem(
    index: 3,
    activeIcon: Icons.person,
    inactiveIcon: Icons.person,
  ),
];
