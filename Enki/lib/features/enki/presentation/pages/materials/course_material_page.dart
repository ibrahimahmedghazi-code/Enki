import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:enki/core/themes/app_colors.dart';
import 'package:enki/core/secrets/app_secrets.dart';
import 'package:enki/features/enki/domain/entities/course.dart';
import 'package:enki/features/enki/domain/entities/module.dart';
import 'package:enki/features/enki/domain/entities/lecture.dart';
import 'package:enki/features/enki/presentation/bloc/course_material_bloc.dart';
import 'package:enki/features/enki/presentation/pages/materials/video_player_page.dart';
import 'package:enki/features/enki/presentation/pages/materials/markdown_reader_page.dart';
import 'package:enki/init_dependencies.dart';

class CourseMaterialPage extends StatelessWidget {
  final Course course;
  const CourseMaterialPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final userid = Supabase.instance.client.auth.currentUser!.id;

    return BlocProvider(
      create: (_) => serviceLocator<CourseMaterialBloc>()
        ..add(CourseMaterialLoad(
          userid: userid,
          courseid: course.courseid,
          modules: course.modules,
        )),
      child: _CourseMaterialView(course: course, userid: userid),
    );
  }
}

// ── Changed to StatefulWidget to call enroll + lastwatchedat on open ──
class _CourseMaterialView extends StatefulWidget {
  final Course course;
  final String userid;

  const _CourseMaterialView({
    required this.course,
    required this.userid,
  });

  @override
  State<_CourseMaterialView> createState() => _CourseMaterialViewState();
}

class _CourseMaterialViewState extends State<_CourseMaterialView> {
  @override
  void initState() {
    super.initState();
    _enrollAndUpdateLastWatched();
  }

  Future<void> _enrollAndUpdateLastWatched() async {
    final base = AppSecrets.apiBaseUrl;
    final userid = widget.userid;
    final courseid = widget.course.courseid;

    try {
      // Enroll user — safe to call multiple times, backend handles duplicates
      await http.post(
        Uri.parse('$base/api/v1/users/$userid/enroll/$courseid'),
      );
    } catch (_) {}

    try {
      // Update lastwatchedat so LearnPage shows correct order
      await http.put(
        Uri.parse('$base/api/v1/users/$userid/watched/$courseid'),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (widget.course.modules.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            title: Text(widget.course.title), centerTitle: true),
        body: _buildEmptyState('This course has no modules yet.'),
      );
    }

    return DefaultTabController(
      length: widget.course.modules.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.course.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.enkiMain,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.grey,
            tabs: widget.course.modules
                .map((m) => Tab(text: 'Module ${m.numberOfModule}'))
                .toList(),
          ),
        ),
        body: BlocBuilder<CourseMaterialBloc, CourseMaterialState>(
          builder: (context, state) {
            if (state is CourseMaterialLoading ||
                state is CourseMaterialInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CourseMaterialFailure) {
              return Center(child: Text(state.message));
            }

            if (state is CourseMaterialLoaded) {
              return TabBarView(
                children: widget.course.modules
                    .map(
                      (module) => _LectureList(
                        module: module,
                        course: widget.course,
                        userid: widget.userid,
                        finishedMap: state.finishedMap,
                      ),
                    )
                    .toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _LectureList extends StatelessWidget {
  final Module module;
  final Course course;
  final String userid;
  final Map<String, bool> finishedMap;

  const _LectureList({
    required this.module,
    required this.course,
    required this.userid,
    required this.finishedMap,
  });

  void _openLecture(BuildContext context, Lecture lecture) {
    if (lecture.lectureUrl == null || lecture.lectureUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No content available yet.')),
      );
      return;
    }

    if (lecture.isItVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerPage(
            url: lecture.lectureUrl!,
            title: lecture.title ?? 'Lecture',
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MarkdownReaderPage(
            url: lecture.lectureUrl!,
            title: lecture.title ?? 'Article',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (module.lectures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No lectures in this module.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: module.lectures.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final lecture = module.lectures[index];
        final isFinished = finishedMap[lecture.lectureid] ?? false;

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isFinished
                  ? Colors.green.withOpacity(0.1)
                  : AppColors.enkiMain.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              lecture.isItVideo
                  ? Icons.play_arrow_rounded
                  : Icons.menu_book_rounded,
              color: isFinished ? Colors.green : AppColors.enkiMain,
            ),
          ),
          title: Text(
            'Lecture ${index + 1}: ${lecture.title ?? ""}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            lecture.isItVideo
                ? 'Video Lesson • ${lecture.durationMinutes ?? 0} min'
                : 'Reading Material • ${lecture.durationMinutes ?? 0} min',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          trailing: IconButton(
            tooltip:
                isFinished ? 'Mark as unfinished' : 'Mark as finished',
            icon: Icon(
              isFinished
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isFinished ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              context.read<CourseMaterialBloc>().add(
                    CourseMaterialToggleLecture(
                      userid: userid,
                      courseid: course.courseid,
                      moduleid: module.moduleid,
                      lectureid: lecture.lectureid,
                      isFinished: !isFinished,
                    ),
                  );
            },
          ),
          onTap: () => _openLecture(context, lecture),
        );
      },
    );
  }
}
