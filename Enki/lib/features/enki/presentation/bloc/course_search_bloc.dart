import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'course_search_event.dart';
part 'course_search_state.dart';


class CourseSearchBloc extends Bloc<CourseSearchEvent, CourseSearchState>{
   CourseSeachBloc() : super(CourseSearchInitial()){
       on<CourseSearchGetTopTen>((event,emit)=> {

           });
   }

}
