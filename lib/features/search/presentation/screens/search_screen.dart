import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/theme/index.dart';
import 'package:work_nest/features/search/data/repositories/search_repository.dart';
import 'package:work_nest/features/search/presentation/providers/search_providers.dart';
import 'package:work_nest/features/search/presentation/widgets/search_result_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final type = _getSearchTypeFromIndex(_tabController.index);
        ref.read(searchTypeFilterProvider.notifier).state = type;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.text = ref.read(searchQueryProvider);
    });
  }

  SearchResultType? _getSearchTypeFromIndex(int index) {
    if (index == 0) return null;
    if (index == 1) return SearchResultType.user;
    if (index == 2) return SearchResultType.project;
    return null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm người dùng, dự án...',
            hintStyle: TextStyle(
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.darkAccent,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.darkAccent,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'TẤT CẢ'),
            Tab(text: 'NGƯỜI DÙNG'),
            Tab(text: 'DỰ ÁN'),
          ],
        ),
      ),
      body: searchResults.when(
        data: (results) {
          if (results.isEmpty) {
            final query = ref.watch(searchQueryProvider);
            if (query.isEmpty) {
              return _buildEmptyState(
                'Nhập từ khóa để tìm kiếm',
                Icons.search_rounded,
              );
            }
            if (query.length < 2) {
              return _buildEmptyState(
                'Hãy nhập ít nhất 2 ký tự',
                Icons.text_fields_rounded,
              );
            }
            return _buildEmptyState(
              'Không tìm thấy kết quả nào cho "$query"',
              Icons.search_off_rounded,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: results.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              indent: 76,
              color: Colors.black.withOpacity(0.05),
            ),
            itemBuilder: (context, index) {
              final result = results[index];
              return SearchResultTile(result: result);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.darkAccent),
        ),
        error: (err, _) => Center(
          child: Text('Lỗi: $err', style: TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textTertiary.withOpacity(0.2)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
