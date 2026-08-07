part of 'explore_bloc.dart';
 
@immutable
sealed class ExploreEvent {}
 
final class ExploreLoad extends ExploreEvent {
  final String userid;
  ExploreLoad({required this.userid});
}
 
 

