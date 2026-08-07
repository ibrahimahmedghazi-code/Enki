part of 'search_bloc.dart';
 
@immutable
sealed class SearchEvent {}
 
final class SearchQueryChanged extends SearchEvent {
  final String query;
  final SearchType type;
  final String? category;
  SearchQueryChanged({
    required this.query,
    required this.type,
    this.category,
  });
}
 
final class SearchCleared extends SearchEvent {}
