

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:eClassify/data/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_parser/http_parser.dart';

class SendMessageState {}

class SendMessageInitial extends SendMessageState {}

class SendMessageInProgress extends SendMessageState {}

class SendMessageSuccess extends SendMessageState {
  final int messageId;

  SendMessageSuccess({
    required this.messageId,
  });
}

class SendMessageFailed extends SendMessageState {
  final dynamic error;

  SendMessageFailed(
    this.error,
  );
}

class SendMessageCubit extends Cubit<SendMessageState> {
  SendMessageCubit() : super(SendMessageInitial());
  final ChatRepository _chatRepostiory = ChatRepository();

  void send(
      {required int itemOfferId,
      required String message,
      dynamic audio,
      dynamic attachment}) async {
    try {
      emit(SendMessageInProgress());
      MultipartFile? audioFile;
      MultipartFile? attachmentFile;

      if (audio != "") {
        audioFile = await MultipartFile.fromFile(
          audio,
          contentType: MediaType('audio', 'wav'),
          filename: 'audio.wav',
        );
      }
      if (attachment != "") {
        attachmentFile = await MultipartFile.fromFile(attachment!);
      }

      var message0 = message;

      var result = await _chatRepostiory.sendMessageApi(
          message: message0,
          itemOfferId: itemOfferId,
          attachment: attachmentFile,
          audio: audioFile);

      emit(SendMessageSuccess(messageId: result['data']['id']));
    } catch (e) {
      log(e.toString());
      emit(SendMessageFailed(e.toString()));
    }
  }

  bool isRemoteFile(dynamic file) {
    if (file is String) {
      return true;
    } else {
      return false;
    }
  }
}
