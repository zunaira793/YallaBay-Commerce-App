// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/chat/delete_message_cubit.dart';
import 'package:eClassify/data/cubits/chat/load_chat_messages.dart';
import 'package:eClassify/data/cubits/chat/send_message.dart';
import 'package:eClassify/data/cubits/item/fetch_my_item_cubit.dart';
import 'package:eClassify/data/cubits/item/job_application/fetch_job_application_cubit.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/repositories/item/item_repository.dart';
import 'package:eClassify/ui/screens/chat/chat_screen.dart';
import 'package:eClassify/ui/screens/item/job_application/job_application_list_screen.dart';
import 'package:eClassify/ui/screens/item/my_items_screen.dart';
import 'package:eClassify/ui/screens/main_activity.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/notification/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocalAwesomeNotification {
  AwesomeNotifications notification = AwesomeNotifications();

  void init(BuildContext context) {
    requestPermission();

    notification.initialize(
        'resource://mipmap/notification',
        [
          NotificationChannel(
              channelKey: Constant.notificationChannel,
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel',
              importance: NotificationImportance.Max,
              ledColor: Colors.grey),
          NotificationChannel(
              channelKey: "Chat Notification",
              channelName: 'Chat Notifications',
              channelDescription: 'Chat Notifications',
              importance: NotificationImportance.Max,
              ledColor: Colors.grey)
        ],
        channelGroups: [],
        debug: true);
    listenTap(context);
  }

  void listenTap(BuildContext context) {
    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    );
  }

  Future<void> createNotification({
    required RemoteMessage notificationData,
    required bool isLocked,
  }) async {
    try {
      bool isChat =
          notificationData.data["type"] == Constant.notificationTypeChat;
      bool hasImage = notificationData.data["image"] != null &&
          notificationData.data["image"].toString().isNotEmpty;

      if (isChat) {
        int chatId = int.parse(notificationData.data['sender_id']) +
            int.parse(notificationData.data['item_id']);
        if (Platform.isAndroid) {
        await notification.createNotification(
          content: NotificationContent(
            id: isChat ? chatId : Random().nextInt(5000),
            title: notificationData.data["title"] ??
                notificationData.notification?.title ??
                "New Message",
            hideLargeIconOnExpand: true,
            summary: "${notificationData.data['user_name']}",
            locked: isLocked,
            payload: Map.from(notificationData.data),
            autoDismissible: true,
            body: notificationData.data["body"] ??
                notificationData.notification?.body ??
                "",
            wakeUpScreen: true,
            notificationLayout: NotificationLayout.MessagingGroup,
            groupKey: notificationData.data["id"],
            channelKey: Constant.notificationChannel,
          ),
        );}
      } else {
        if (hasImage) {
          String? imageUrl = notificationData.data["image"];

          if (Platform.isAndroid) {
            await notification.createNotification(
              content: NotificationContent(
                id: Random().nextInt(5000),
                title: notificationData.data["title"] ??
                    notificationData.notification?.title ??
                    "New Notification",
                bigPicture: imageUrl,
                hideLargeIconOnExpand: true,
                summary: null,
                locked: isLocked,
                payload: Map.from(notificationData.data),
                autoDismissible: true,
                body: notificationData.data["body"] ??
                    notificationData.notification?.body ??
                    "",
                wakeUpScreen: true,
                notificationLayout: NotificationLayout.BigPicture,
                groupKey: notificationData.data["item_id"],
                channelKey: Constant.notificationChannel,
              ),
            );
          }
        } else {
          if (Platform.isAndroid) {
            await notification.createNotification(
              content: NotificationContent(
                id: Random().nextInt(5000),
                title: notificationData.data["title"] ??
                    notificationData.notification?.title ??
                    "New Notification",
                hideLargeIconOnExpand: true,
                summary: null,
                locked: isLocked,
                payload: Map.from(notificationData.data),
                autoDismissible: true,
                body: notificationData.data["body"] ??
                    notificationData.notification?.body ??
                    "",
                wakeUpScreen: true,
                notificationLayout: NotificationLayout.Default,
                groupKey: notificationData.data["item_id"],
                channelKey: Constant.notificationChannel,
              ),
            );
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestPermission() async {
    final notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      final newSettings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (newSettings.authorizationStatus == AuthorizationStatus.authorized ||
          newSettings.authorizationStatus == AuthorizationStatus.provisional) {
        // Permission granted, handle notification setup here.
      } else if (newSettings.authorizationStatus ==
          AuthorizationStatus.denied) {
        // Permission denied, do nothing.
        return;
      }
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      // Permission was already denied, do nothing.
      return;
    }

    // If the permission is already granted, you can proceed with setting up notifications here.
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    if (receivedNotification.payload?['type'] == "job-application") {
      int itemId =
          int.tryParse(receivedNotification.payload?['item_id'] ?? '') ?? 0;
      if (Routes.currentRoute == Routes.jobApplicationList &&
          currentJobItemId == itemId) {
        Constant.navigatorKey.currentContext!
            .read<FetchJobApplicationCubit>()
            .fetchApplications(itemId: itemId, isMyJobApplications: false);
      }
    }
    if (receivedNotification.payload?['type'] == "application-status") {
      if (Routes.currentRoute == Routes.jobApplicationList) {
        Constant.navigatorKey.currentContext!
            .read<FetchJobApplicationCubit>()
            .fetchApplications(itemId: 0, isMyJobApplications: true);
      }
    }
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    Map<String, String?>? payload = receivedAction.payload;
    if (payload?['type'] == Constant.notificationTypeChat) {
      var username = payload?['user_name'];
      var itemImage = payload?['item_image'];
      var itemName = payload?['item_name'];
      var userProfile = payload?['user_profile'];
      var senderId = payload?['user_id'];
      var itemId = payload?['item_id'];
      var date = payload?['created_at'];
      var itemOfferId = payload?['item_offer_id'];
      var itemPrice = payload?['item_price'];
      var itemOfferPrice = payload?['item_offer_amount'];
      Future.delayed(
        Duration.zero,
        () {
          Navigator.push(Constant.navigatorKey.currentContext!,
              MaterialPageRoute(
            builder: (context) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => LoadChatMessagesCubit(),
                  ),
                  BlocProvider(
                    create: (context) => SendMessageCubit(),
                  ),
                  BlocProvider(
                    create: (context) => DeleteMessageCubit(),
                  ),
                ],
                child: Builder(builder: (context) {
                  return ChatScreen(
                    profilePicture: userProfile ?? "",
                    userName: username ?? "",
                    itemImage: itemImage ?? "",
                    itemTitle: itemName ?? "",
                    userId: senderId ?? "",
                    itemId: itemId ?? "",
                    date: date ?? "",
                    itemOfferId: int.parse(itemOfferId!),
                    itemPrice: NotificationService.getPrice(itemPrice!),
                    itemOfferPrice:
                        NotificationService.getOfferPrice(itemOfferPrice),
                    buyerId: HiveUtils.getUserId(),
                    alreadyReview: false,
                    isPurchased: 0,
                  );
                }),
              );
            },
          ));
        },
      );
    } else if (payload?['type'] == Constant.notificationTypeOffer) {
      if (HiveUtils.isUserAuthenticated()) {
        var username = payload?['user_name'];
        var itemImage = payload?['item_image'];
        var itemName = payload?['item_name'];
        var userProfile = payload?['user_profile'];
        var senderId = payload?['user_id'];
        var itemId = payload?['item_id'];
        var date = payload?['created_at'];
        var itemOfferId = payload?['item_offer_id'];
        var itemPrice = payload?['item_price'];
        var itemOfferPrice = payload?['item_offer_amount'];

        Future.delayed(
          Duration.zero,
          () {
            Navigator.push(Constant.navigatorKey.currentContext!,
                MaterialPageRoute(
              builder: (context) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => LoadChatMessagesCubit(),
                    ),
                    BlocProvider(
                      create: (context) => SendMessageCubit(),
                    ),
                    BlocProvider(
                      create: (context) => DeleteMessageCubit(),
                    ),
                  ],
                  child: Builder(builder: (context) {
                    return ChatScreen(
                      profilePicture: userProfile ?? "",
                      userName: username ?? "",
                      itemImage: itemImage ?? "",
                      itemTitle: itemName ?? "",
                      userId: senderId ?? "",
                      itemId: itemId ?? "",
                      date: date ?? "",
                      itemOfferId: int.parse(itemOfferId!),
                      itemPrice: NotificationService.getPrice(itemPrice!),
                      itemOfferPrice:
                          NotificationService.getOfferPrice(itemOfferPrice),
                      buyerId: HiveUtils.getUserId(),
                      alreadyReview: false,
                      isPurchased: 0,
                    );
                  }),
                );
              },
            ));
          },
        );
      } else {
        Future.delayed(Duration.zero, () {
          HelperUtils.goToNextPage(Routes.notificationPage,
              Constant.navigatorKey.currentContext!, false);
        });
      }
    } else if (payload?['type'] == Constant.notificationTypeItemUpdate) {
      Future.delayed(Duration.zero, () {
        Navigator.popUntil(
            Constant.navigatorKey.currentContext!, (route) => route.isFirst);
        MainActivity.globalKey.currentState?.onItemTapped(2);
        Constant.navigatorKey.currentContext!
            .read<FetchMyItemsCubit>()
            .fetchMyItems(
              getItemsWithStatus: selectItemStatus,
            );
      });
    } else if (payload?['type'] == Constant.notificationTypeItemEdit) {
      String id = payload?["id"] ?? "";
      DataOutput<ItemModel> item =
      await ItemRepository().fetchItemFromItemId(int.parse(id));
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(
            Constant.navigatorKey.currentContext!, Routes.adDetailsScreen,
            arguments: {
              'model': item.modelList[0],
            });
        Constant.navigatorKey.currentContext!
            .read<FetchMyItemsCubit>()
            .fetchMyItems(
          getItemsWithStatus: selectItemStatus,
        );
      });
    }else if (payload?['type'] == Constant.notificationTypeJobApplication) {
      Navigator.pushNamed(
          Constant.navigatorKey.currentContext!, Routes.jobApplicationList,
          arguments: {
            'itemId': int.tryParse(payload?['item_id'] ?? '') ?? 0,
          });
    } else if (payload?['type'] == Constant.notificationTypeApplicationStatus) {
      Navigator.pushNamed(
          Constant.navigatorKey.currentContext!, Routes.jobApplicationList,
          arguments: {
            'itemId': 0,
            'isMyJobApplications': true,
          });
    } else if (receivedAction.payload?["item_id"] != null &&
        receivedAction.payload?["item_id"] != '') {
      String id = receivedAction.payload?["item_id"] ?? "";

      DataOutput<ItemModel> item =
          await ItemRepository().fetchItemFromItemId(int.parse(id));

      Future.delayed(
        Duration.zero,
        () {
          Navigator.pushNamed(
              Constant.navigatorKey.currentContext!, Routes.adDetailsScreen,
              arguments: {
                'model': item.modelList[0],
              });
        },
      );
    } else if (payload?['type'] == Constant.notificationTypePayment) {
      if (HiveUtils.isUserAuthenticated()) {
        Future.delayed(Duration.zero, () {
          Navigator.pushNamed(Constant.navigatorKey.currentContext!,
              Routes.subscriptionPackageListRoute);
        });
      } else {
        Future.delayed(Duration.zero, () {
          HelperUtils.goToNextPage(Routes.notificationPage,
              Constant.navigatorKey.currentContext!, false);
        });
      }
    } else {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(
            Constant.navigatorKey.currentContext!, Routes.notificationPage);
      });
    }
  }
}
