import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:client_flutter/models/project.dart';
import 'package:client_flutter/services/project/project_service.dart';
import 'package:client_flutter/widgets/project_list.dart';

class SearchTab extends StatefulWidget {
  final String searchType;
  final String searchKeyword;

  const SearchTab({
    super.key,
    required this.searchType,
    required this.searchKeyword,
  });

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  late ProjectService _projectService;
  late TextEditingController _searchController;
  late String _selectedSearchType;
  String _selectedSortBy = 'latest';
  bool _hasSearched = false;

  final List<String> _searchTypes = ['제목', '내용', '작성자', '태그'];
  final Map<String, String> _searchTypeMap = {
    '제목': 'title',
    '내용': 'content',
    '작성자': 'nickname',
    '태그': 'tag',
  };

  @override
  void initState() {
    super.initState();
    _projectService = context.read<ProjectService>();
    _searchController = TextEditingController(text: widget.searchKeyword);
    _selectedSearchType = _searchTypes.contains(widget.searchType) ? widget.searchType : _searchTypes.first;

    if (widget.searchKeyword.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onSearch();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectService = context.watch<ProjectService>();
    final projectList = projectService.searchResults;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            if (_hasSearched) ...[
              _buildSearchTypeSelector(),
              _buildSortAndResultCount(projectList.length),
              _buildSearchResults(projectList),
            ],
          ],
        ),
      ),
    );
  }

  void _onSearch() {
    _projectService.clearSearchResults();
    _projectService.getSearchedProjectList(
      searchType: _searchTypeMap[_selectedSearchType]!,
      searchKeyword: _searchController.text,
      sortBy: _selectedSortBy,
    );
    setState(() {
      _hasSearched = true;
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '검색어를 입력해 주세요.',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onSearch,
            tooltip: '검색',
          ),
        ),
        onSubmitted: (_) => _onSearch(),
      ),
    );
  }

  Widget _buildSearchTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _searchTypes.map((type) {
            final isSelected = type == _selectedSearchType;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSearchType = type;
                });
                _onSearch();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortAndResultCount(int resultCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '총 $resultCount개 결과',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            value: _selectedSortBy,
            items: [
              const DropdownMenuItem(value: 'latest', child: Text('최신순')),
              const DropdownMenuItem(value: 'popularity', child: Text('인기순')),
              const DropdownMenuItem(value: 'views', child: Text('조회수순')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSortBy = value!;
              });
              _onSearch();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Project> projectList) {
    return Expanded(
      child: projectList.isEmpty
        ? const Center(child: Text('검색 결과가 없습니다.'))
        : ProjectList(
            projectList: projectList,
            searchType: _searchTypeMap[_selectedSearchType]!,
            searchKeyword: _searchController.text,
            sortBy: _selectedSortBy,
          ),
    );
  }
}
