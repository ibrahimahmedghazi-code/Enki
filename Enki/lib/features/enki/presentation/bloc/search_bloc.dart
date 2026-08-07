import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enki/features/enki/domain/entities/course.dart';
import 'package:enki/features/enki/domain/entities/user_info_entity.dart';
import 'package:enki/features/enki/domain/usecases/search_courses.dart';
import 'package:enki/features/enki/domain/usecases/search_users.dart';
import 'package:enki/features/enki/presentation/widgets/search_header_widget.dart';
import 'dart:async';
 
part 'search_event.dart';
part 'search_state.dart';
 
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchCourses _searchCourses;
  final SearchUsers _searchUsers;
 
  // Debounce timer so we don't fire on every keystroke
  Timer? _debounce;
 
  SearchBloc({
    required SearchCourses searchCourses,
    required SearchUsers searchUsers,
  })  : _searchCourses = searchCourses,
        _searchUsers = searchUsers,
        super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCleared>(_onCleared);
  }
 
  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    // Don't search if query is too short
    if (event.query.trim().length < 2) {
      emit(SearchInitial());
      return;
    }
 
    emit(SearchLoading());
 
    if (event.type == SearchType.course) {
      final result = await _searchCourses(
        SearchCoursesParams(
          query: event.query,
          category: event.category,
        ),
      );
      result.fold(
        (failure) => emit(SearchFailure(message: failure.message)),
        (courses) => emit(SearchCoursesLoaded(courses: courses)),
      );
    } else {
      final result = await _searchUsers(
        SearchUsersParams(query: event.query),
      );
      result.fold(
        (failure) => emit(SearchFailure(message: failure.message)),
        (users) => emit(SearchUsersLoaded(users: users)),
      );
    }
  }
 
  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
 
  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
