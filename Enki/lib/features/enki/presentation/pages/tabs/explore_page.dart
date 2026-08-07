import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:enki/core/themes/app_colors.dart';
import 'package:enki/features/enki/domain/entities/course.dart';
import 'package:enki/features/enki/presentation/bloc/explore_bloc.dart';
import 'package:enki/features/enki/presentation/widgets/cards/course_card.dart';
import 'package:enki/features/enki/presentation/widgets/cards/current_course_card.dart';
import 'package:enki/features/enki/presentation/pages/details/course_detail_page.dart'; 
import 'package:enki/features/enki/presentation/bloc/course_material_bloc.dart';
import 'package:enki/init_dependencies.dart';
 
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore',
          style: TextStyle(
            color: AppColors.enkiMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ExploreBloc, ExploreState>(
        builder: (context, state) {
          if (state is ExploreInitial || state is ExploreLoading) {
            return const Center(child: CircularProgressIndicator());
          }
 
          if (state is ExploreFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final userid =
                          Supabase.instance.client.auth.currentUser!.id;
                      context
                          .read<ExploreBloc>()
                          .add(ExploreLoad(userid: userid));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
 
          if (state is ExploreLoaded) {
            return _ExploreBody(state: state);
          }
 
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
 
class _ExploreBody extends StatelessWidget {
  final ExploreLoaded state;
  const _ExploreBody({required this.state});
 
  void _goToDetail(BuildContext context, Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Current / Last Watched Course ──────────────────────
          const Text(
            'My Course',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
 
          if (state.currentCourse != null)
              BlocProvider(
                create: (_) {
                  final userid = Supabase.instance.client.auth.currentUser!.id;
                  return serviceLocator<CourseMaterialBloc>()
                    ..add(CourseMaterialLoad(
                      userid: userid,
                      courseid: state.currentCourse!.courseid,
                      modules: state.currentCourse!.modules,
                    ));
                },
                child: _CurrentCourseWithProgress(
                  course: state.currentCourse!,
                  onGoToDetail: () => _goToDetail(context, state.currentCourse!),
                ),
              )

          else
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Text(
                  'No courses watched yet. Start exploring!',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
 
          const SizedBox(height: 24),
 
          // ── Top Rated Courses ──────────────────────────────────
          const Text(
            'Top rated courses',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
 
          if (state.topRated.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text('No courses yet.', style: TextStyle(color: Colors.grey)),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: state.topRated.length,
                itemBuilder: (context, index) {
                  final course = state.topRated[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 180,
                      child: CourseCard(
                        course: course,
                        onTap: () => _goToDetail(context, course),
                      ),
                    ),
                  );
                },
              ),
            ),
 
          const SizedBox(height: 24),
 
          // ── Beginner Courses ───────────────────────────────────
          const Text(
            'Courses for beginners',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
 
          if (state.beginner.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text('No beginner courses yet.', style: TextStyle(color: Colors.grey)),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: state.beginner.length,
                itemBuilder: (context, index) {
                  final course = state.beginner[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 180,
                      child: CourseCard(
                        course: course,
                        onTap: () => _goToDetail(context, course),
                      ),
                    ),
                  );
                },
              ),
            ),
 
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CurrentCourseWithProgress extends StatelessWidget {
  final Course course;
  final VoidCallback onGoToDetail;

  const _CurrentCourseWithProgress({
    required this.course,
    required this.onGoToDetail,
  });

  @override
  Widget build(BuildContext context) {
    final totalLectures =
        course.modules.fold(0, (sum, m) => sum + m.lectures.length);

    return BlocBuilder<CourseMaterialBloc, CourseMaterialState>(
      builder: (context, state) {
        int finished = 0;
        if (state is CourseMaterialLoaded) {
          finished = state.finishedMap.values.where((v) => v).length;
        }
        final progress =
            totalLectures > 0 ? finished / totalLectures : 0.0;

        return SizedBox(
          height: 125,
          width: double.infinity,
          child: CurrentCourseCard(
            course: course,
            progress: progress, // ← real progress
            onTap: onGoToDetail,
          ),
        );
      },
    );
  }
}
