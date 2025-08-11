import 'package:eClassify/data/repositories/item/item_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MakeAnOfferItemState {}

class MakeAnOfferItemInitial extends MakeAnOfferItemState {}

class MakeAnOfferItemInProgress extends MakeAnOfferItemState {}

class MakeAnOfferItemSuccess extends MakeAnOfferItemState {
  final String message;
  final String from;
  final dynamic data;


  MakeAnOfferItemSuccess(
    this.message,
    this.from,
    this.data,
  );
}

class MakeAnOfferItemFailure extends MakeAnOfferItemState {
  final String errorMessage;

  MakeAnOfferItemFailure(this.errorMessage);
}

class MakeAnOfferItemCubit extends Cubit<MakeAnOfferItemState> {
  final ItemRepository _itemRepository = ItemRepository();

  MakeAnOfferItemCubit() : super(MakeAnOfferItemInitial());

  Future<void> makeAnOfferItem(
      {required int id, required String from, double? amount}) async {
    emit(MakeAnOfferItemInProgress());

    await _itemRepository.makeAnOfferItem(id, amount).then((value) {
      emit(MakeAnOfferItemSuccess(value['message'], from, value['data']));
    }).catchError((e) {
      emit(MakeAnOfferItemFailure(e.toString()));
    });
  }
}
