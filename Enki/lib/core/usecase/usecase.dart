import 'package:enki/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';
// passing SuccessType because it will return block and passing paramtors
abstract interface class UseCase <SuccessType, Params> {
Future<Either<Failure, SuccessType>> call(Params params);

}

class NoParams {

}
