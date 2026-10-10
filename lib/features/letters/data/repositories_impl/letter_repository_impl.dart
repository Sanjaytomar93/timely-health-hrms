import 'dart:typed_data';

import 'package:timelay_health/features/letters/data/datasources/letter_remote_datasource.dart';
import 'package:timelay_health/features/letters/data/mappers/letter_mapper.dart';
import 'package:timelay_health/features/letters/domain/entities/letter.dart';
import 'package:timelay_health/features/letters/domain/repositories/letter_repository.dart';

class LetterRepositoryImpl implements LetterRepository {
  LetterRepositoryImpl({LetterRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? LetterRemoteDataSource();

  final LetterRemoteDataSource _remote;

  @override
  Future<List<Letter>> getEmployeeLetters(String employeeId) async {
    final models = await _remote.getEmployeeLetters(employeeId);
    return models.map(LetterMapper.toEntity).toList();
  }

  @override
  Future<Uint8List> downloadLetter(String fileUrl) =>
      _remote.downloadLetter(fileUrl);
}
