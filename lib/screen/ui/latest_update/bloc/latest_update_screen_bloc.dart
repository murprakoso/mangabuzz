import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mangabuzz/core/model/latest_update/latest_update_model.dart';
import 'package:mangabuzz/core/repository/remote/api_repository.dart';
import 'package:mangabuzz/core/util/connectivity_check.dart';
import 'package:moor_flutter/moor_flutter.dart';

part 'latest_update_screen_event.dart';
part 'latest_update_screen_state.dart';

class LatestUpdateScreenBloc
    extends Bloc<LatestUpdateScreenEvent, LatestUpdateScreenState> {
  LatestUpdateScreenBloc() : super(LatestUpdateScreenInitial());

  // Variables
  final apiRepo = APIRepository();
  final connectivity = ConnectivityCheck();

  @override
  Stream<LatestUpdateScreenState> mapEventToState(
    LatestUpdateScreenEvent event,
  ) async* {
    yield LatestUpdateScreenLoading();

    if (event is GetLatestUpdateScreenData)
      yield* getLatestUpdateScreenDataToState(event);
  }

  Stream<LatestUpdateScreenState> getLatestUpdateScreenDataToState(
      GetLatestUpdateScreenData event) async* {
    try {
      bool isConnected = await connectivity.checkConnectivity();
      if (isConnected == false) yield LatestUpdateScreenError();

      final data = await apiRepo.getLatestUpdate(event.pageNumber);

      yield LatestUpdateScreenLoaded(latestUpdate: data);
    } on Exception {
      yield LatestUpdateScreenError();
    }
  }
}
