import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/theme/index.dart';
import '../../domain/entities/search_result_entity.dart';
import '../providers/index.dart';
import '../widgets/index.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.text = ref.read(searchQueryProvider);
    });
  }


  @override
  void dispose() {
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
