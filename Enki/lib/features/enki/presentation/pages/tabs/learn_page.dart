import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:enki/core/themes/app_colors.dart';
import 'package:enki/features/enki/domain/entities/course.dart';
import 'package:enki/features/enki/presentation/bloc/explore_bloc.dart';
import 'package:enki/features/enki/presentation/bloc/course_material_bloc.dart';
import 'package:enki/features/enki/presentation/pages/details/course_detail_page.dart';
import 'package:enki/init_dependencies.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Learning',
          style: TextStyle(
              color: AppColors.enkiMain, fontWeight: FontWeight.bold),
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
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
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
            final courses = state.watchedCourses;

            if (courses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined,
                        size: 72, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No courses yet.',
                      style: TextStyle(
                          fontSize: 18, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start exploring and enroll in a course.',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              );
            }

            final userid =
                Supabase.instance.client.auth.currentUser!.id;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _EnrolledCourseCard(
                  course: courses[index],
                  userid: userid,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}


// ── Enrolled course card with expandable lecture history ──────────────
class _EnrolledCourseCard extends StatefulWidget {
  final Course course;
  final String userid;

  const _EnrolledCourseCard({
    required this.course,
    required this.userid,
  });

  @override
  State<_EnrolledCourseCard> createState() => _EnrolledCourseCardState();
}

class _EnrolledCourseCardState extends State<_EnrolledCourseCard> {
  bool _expanded = false;

  int get _totalLectures => widget.course.modules
      .fold(0, (sum, m) => sum + m.lectures.length);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // One CourseMaterialBloc per card — loads progress for this course
      create: (_) => serviceLocator<CourseMaterialBloc>()
        ..add(CourseMaterialLoad(
          userid: widget.userid,
          courseid: widget.course.courseid,
          modules: widget.course.modules,
        )),
      child: Builder(
        builder: (context) => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade800),
          ),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: widget.course.imagePath != null &&
                                !widget.course.imagePath!
                                    .startsWith('assets')
                            ? Image.network(
                                widget.course.imagePath!,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _placeholder(),
                              )
                            : _placeholder(),
                      ),
                      const SizedBox(width: 14),

                      // Info + progress
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.course.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.course.author ?? '',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            // Progress bar
                            _ProgressBar(
                                totalLectures: _totalLectures),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Go to course + expand toggle
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios,
                                size: 16),
                            color: AppColors.enkiMain,
                            tooltip: 'Open course',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CourseDetailPage(
                                    course: widget.course),
                              ),
                            ),
                          ),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Expanded lecture list ────────────────────────
              if (_expanded) ...[
                const Divider(height: 1),
                _LectureHistoryList(course: widget.course),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10),
      ),
      child:
          Icon(Icons.book, color: Colors.grey.shade500, size: 28),
    );
  }
}


// ── Progress bar ──────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int totalLectures;
  const _ProgressBar({required this.totalLectures});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseMaterialBloc, CourseMaterialState>(
      builder: (context, state) {
        int finished = 0;
        if (state is CourseMaterialLoaded) {
          finished = state.finishedMap.values.where((v) => v).length;
        }
        final progress =
            totalLectures > 0 ? finished / totalLectures : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade800,
                color: AppColors.enkiMain,
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$finished / $totalLectures lectures completed'
              '${totalLectures > 0 ? '  (${(progress * 100).toInt()}%)' : ''}',
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        );
      },
    );
  }
}


// ── Lecture history list ──────────────────────────────────────────────
class _LectureHistoryList extends StatelessWidget {
  final Course course;
  const _LectureHistoryList({required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseMaterialBloc, CourseMaterialState>(
      builder: (context, state) {
        if (state is CourseMaterialLoading ||
            state is CourseMaterialInitial) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final finishedMap = state is CourseMaterialLoaded
            ? state.finishedMap
            : <String, bool>{};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...course.modules.map((module) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Module label
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        'Module ${module.numberOfModule}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.enkiMain,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // Lectures
                    ...module.lectures.map((lecture) {
                      final isDone =
                          finishedMap[lecture.lectureid] ?? false;
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        leading: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? Colors.green.withOpacity(0.15)
                                : Colors.grey.shade800,
                          ),
                          child: Icon(
                            isDone
                                ? Icons.check
                                : lecture.isItVideo
                                    ? Icons.play_arrow_rounded
                                    : Icons.article_outlined,
                            size: 16,
                            color: isDone
                                ? Colors.green
                                : Colors.grey.shade400,
                          ),
                        ),
                        title: Text(
                          lecture.title ?? 'Untitled',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDone
                                ? Colors.white
                                : Colors.grey.shade400,
                          ),
                        ),
                        subtitle: Text(
                          lecture.isItVideo
                              ? 'Video • ${lecture.durationMinutes ?? 0} min'
                              : 'Article • ${lecture.durationMinutes ?? 0} min',
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11),
                        ),
                        trailing: isDone
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.green.withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Done',
                                  style: TextStyle(
                                      color: Colors.green.shade400,
                                      fontSize: 11),
                                ),
                              )
                            : null,
                      );
                    }),
                  ],
                )),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
