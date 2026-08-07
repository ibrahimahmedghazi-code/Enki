import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enki/core/themes/app_colors.dart';
import 'package:enki/features/enki/domain/entities/course.dart';
import 'package:enki/features/enki/domain/entities/user_info_entity.dart';
import 'package:enki/features/enki/presentation/bloc/search_bloc.dart';
import 'package:enki/features/enki/presentation/widgets/search_header_widget.dart';
import 'package:enki/features/enki/presentation/widgets/cards/course_card.dart';
import 'package:enki/features/enki/presentation/widgets/cards/user_card.dart';
import 'package:enki/features/enki/presentation/pages/details/course_detail_page.dart';
import 'package:enki/features/enki/presentation/pages/details/user_detail_page.dart';
 
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
 
  @override
  State<SearchPage> createState() => _SearchPageState();
}
 
class _SearchPageState extends State<SearchPage> {
  SearchType _selectedType = SearchType.course;
  String? _selectedCategory;
 
  void _onQueryChanged(String query) {
    context.read<SearchBloc>().add(
          SearchQueryChanged(
            query: query,
            type: _selectedType,
            category: _selectedCategory,
          ),
        );
  }
 
  void _onTypeChanged(SearchType type) {
    setState(() {
      _selectedType = type;
      _selectedCategory = null;
    });
    // Clear results when switching type
    context.read<SearchBloc>().add(SearchCleared());
  }
 
  void _onCategoryChanged(String? cat) {
    setState(() => _selectedCategory = cat);
    // Re-trigger search with new category if there's already a query
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(
            color: AppColors.enkiMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SearchHeaderWidget(
              selectedType: _selectedType,
              selectedCategory: _selectedCategory,
              onTypeChanged: _onTypeChanged,
              onCategoryChanged: _onCategoryChanged,
              onQueryChanged: _onQueryChanged,
            ),
            const Divider(height: 32),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Search for ${_selectedType == SearchType.course ? "courses" : "users"}',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    );
                  }
 
                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
 
                  if (state is SearchFailure) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
 
                  if (state is SearchCoursesLoaded) {
                    if (state.courses.isEmpty) {
                      return const Center(child: Text('No courses found.'));
                    }
                    return _CourseResults(courses: state.courses);
                  }
 
                  if (state is SearchUsersLoaded) {
                    if (state.users.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }
                    return _UserResults(users: state.users);
                  }
 
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _CourseResults extends StatelessWidget {
  final List<Course> courses;
  const _CourseResults({required this.courses});
 
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return CourseCard(
          course: course,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailPage(course: course),
            ),
          ),
        );
      },
    );
  }
}
 
class _UserResults extends StatelessWidget {
  final List<UserInfoEntity> users;
  const _UserResults({required this.users});
 
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];
        return UserCard(
          userInfo: user,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserDetailPage(user: user),
            ),
          ),
        );
      },
    );
  }
}
