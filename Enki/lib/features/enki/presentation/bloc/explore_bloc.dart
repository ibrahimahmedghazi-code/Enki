import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enki/features/enki/domain/entities/course.dart';
import 'package:enki/features/enki/domain/usecases/get_top_courses.dart';
import 'package:enki/features/enki/domain/usecases/get_beginner_courses.dart';
import 'package:enki/features/enki/domain/usecases/get_user_watched_courses.dart';
import 'package:enki/core/usecase/usecase.dart';
 
part 'explore_event.dart';
part 'explore_state.dart';
 
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final GetTopCourses _getTopCourses;
  final GetBeginnerCourses _getBeginnerCourses;
  final GetUserWatchedCourses _getUserWatchedCourses;
 
  ExploreBloc({
    required GetTopCourses getTopCourses,
    required GetBeginnerCourses getBeginnerCourses,
    required GetUserWatchedCourses getUserWatchedCourses,
  })  : _getTopCourses = getTopCourses,
        _getBeginnerCourses = getBeginnerCourses,
        _getUserWatchedCourses = getUserWatchedCourses,
        super(ExploreInitial()) {
    on<ExploreLoad>(_onExploreLoad);
  }
 
  Future<void> _onExploreLoad(
    ExploreLoad event,
    Emitter<ExploreState> emit,
  ) async {
    emit(ExploreLoading());
 
    // Fire all 3 requests in parallel
    final results = await Future.wait([
      _getTopCourses(NoParams()),
      _getBeginnerCourses(NoParams()),
      _getUserWatchedCourses(
        GetUserWatchedCoursesParams(userid: event.userid),
      ),
    ]);
 
    final topResult = results[0];
    final beginnerResult = results[1];
    final watchedResult = results[2];
 
    // If any core list fails, emit failure
    if (topResult.isLeft() || beginnerResult.isLeft()) {
      final failure = topResult.isLeft()
          ? topResult.fold((f) => f.message, (_) => '')
          : beginnerResult.fold((f) => f.message, (_) => '');
      emit(ExploreFailure(message: failure));
      return;
    }
 
    final topCourses = topResult.fold((_) => <Course>[], (c) => c);
    final beginnerCourses = beginnerResult.fold((_) => <Course>[], (c) => c);
 
    // Watched courses failing is not critical — just show no current course
    final watchedCourses = watchedResult.fold((_) => <Course>[], (c) => c);
    final currentCourse = watchedCourses.isNotEmpty ? watchedCourses.first : null;
 
    emit(ExploreLoaded(
      currentCourse: currentCourse,
      topRated: topCourses,
      beginner: beginnerCourses,
      watchedCourses: watchedCourses,
    ));
  }
}
