import 'dart:async';
import 'dart:developer';
import 'package:vibey/services/db/GlobalDB.dart';
import 'package:vibey/services/db/db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  StreamSubscription? _subscription;
  NotificationCubit() : super(NotificationInitial()) {
    getNotification();
  }
  void getNotification() async {
    List<NotificationDB> notifications = await DBService.getNotifications();
    emit(NotificationState(notifications: notifications));
  }

  void clearNotification() {
    DBService.clearNotifications();
    log("Notification Cleared");
    getNotification();
  }

  Future<void> watchNotification() async {
    _subscription = (await DBService.watchNotification()).listen((event) {
      getNotification();
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
