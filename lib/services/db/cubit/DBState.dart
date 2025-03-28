part of 'DBCubit.dart';

@immutable
sealed class MediadbState {}

final class MediadbInitial extends MediadbState {}

class MediadbError extends MediadbState {
  final String errorMessage;

  MediadbError(this.errorMessage);
}
