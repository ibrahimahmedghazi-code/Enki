import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enki/features/enki/domain/usecases/get_course_progress.dart';
import 'package:enki/features/enki/domain/usecases/mark_lecture_finished.dart';

part 'course_material_event.dart';
part 'course_material_state.dart';

class CourseMaterialBloc
    extends Bloc<CourseMaterialEvent, CourseMaterialState> {
  final GetCourseProgress _getProgress;
  final MarkLectureFinished _markFinished;

  CourseMaterialBloc({
    required GetCourseProgress getCourseProgress,
    required MarkLectureFinished markLectureFinished,
  })  : _getProgress = getCourseProgress,
        _markFinished = markLectureFinished,
        super(CourseMaterialInitial()) {
    on<CourseMaterialLoad>(_onLoad);
    on<CourseMaterialToggleLecture>(_onToggle);
  }

  Future<void> _onLoad(
    CourseMaterialLoad event,
    Emitter<CourseMaterialState> emit,
  ) async {
    emit(CourseMaterialLoading());
    final result = await _getProgress(
      GetCourseProgressParams(
        userid: event.userid,
        courseid: event.courseid,
      ),
    );
    result.fold(
      (failure) => emit(CourseMaterialFailure(message: failure.message)),
      (finishedIds) {
        // explicit Map<String, bool> to avoid type inference issue
        final map = <String, bool>{
          for (final String id in finishedIds) id: true,
        };
        emit(CourseMaterialLoaded(finishedMap: map));
      },
    );
  }

  Future<void> _onToggle(
    CourseMaterialToggleLecture event,
    Emitter<CourseMaterialState> emit,
  ) async {
    if (state is! CourseMaterialLoaded) return;
    final current = state as CourseMaterialLoaded;

    // Optimistic update
    emit(current.copyWith({event.lectureid: event.isFinished}));

    await _markFinished(
      MarkLectureFinishedParams(
        userid: event.userid,
        courseid: event.courseid,
        moduleid: event.moduleid,
        lectureid: event.lectureid,
        isFinished: event.isFinished,
      ),
    );
  }
}
