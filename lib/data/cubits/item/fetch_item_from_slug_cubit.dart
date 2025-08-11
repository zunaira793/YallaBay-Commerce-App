import 'dart:developer';

import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/repositories/item/item_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchItemFromSlugState {}

class FetchItemFromSlugInitial extends FetchItemFromSlugState {}

class FetchItemFromSlugLoading extends FetchItemFromSlugState {}

class FetchItemFromSlugSuccess extends FetchItemFromSlugState {
  final ItemModel item;

  FetchItemFromSlugSuccess({required this.item});
}

class FetchItemFromSlugFailure extends FetchItemFromSlugState {
  final String errorMessage;

  FetchItemFromSlugFailure({required this.errorMessage});
}

class FetchItemFromSlugCubit extends Cubit<FetchItemFromSlugState> {
  FetchItemFromSlugCubit() : super(FetchItemFromSlugInitial());

  Future<void> fetchItemFromSlug({required String slug}) async {
    try {
      emit(FetchItemFromSlugLoading());

      final models = await ItemRepository().fetchItemFromItemSlug(slug);
      emit(FetchItemFromSlugSuccess(item: models.modelList.first));
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'fetchItemFromSlug');
      log('$stack', name: 'fetchItemFromSlug');
      emit(FetchItemFromSlugFailure(errorMessage: e.toString()));
    }
  }
}
