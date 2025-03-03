// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_file_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$VideoFileListStore on _VideoFileListStore, Store {
  late final _$videoFileDataListAtom =
      Atom(name: '_VideoFileListStore.videoFileDataList', context: context);

  @override
  List<VideoFileData> get videoFileDataList {
    _$videoFileDataListAtom.reportRead();
    return super.videoFileDataList;
  }

  @override
  set videoFileDataList(List<VideoFileData> value) {
    _$videoFileDataListAtom.reportWrite(value, super.videoFileDataList, () {
      super.videoFileDataList = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_VideoFileListStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$progressAtom =
      Atom(name: '_VideoFileListStore.progress', context: context);

  @override
  double get progress {
    _$progressAtom.reportRead();
    return super.progress;
  }

  @override
  set progress(double value) {
    _$progressAtom.reportWrite(value, super.progress, () {
      super.progress = value;
    });
  }

  late final _$isAvailableAtom =
      Atom(name: '_VideoFileListStore.isAvailable', context: context);

  @override
  bool get isAvailable {
    _$isAvailableAtom.reportRead();
    return super.isAvailable;
  }

  @override
  set isAvailable(bool value) {
    _$isAvailableAtom.reportWrite(value, super.isAvailable, () {
      super.isAvailable = value;
    });
  }

  late final _$isFreeAtom =
      Atom(name: '_VideoFileListStore.isFree', context: context);

  @override
  bool get isFree {
    _$isFreeAtom.reportRead();
    return super.isFree;
  }

  @override
  set isFree(bool value) {
    _$isFreeAtom.reportWrite(value, super.isFree, () {
      super.isFree = value;
    });
  }

  late final _$currentVideoFileLanguageAtom = Atom(
      name: '_VideoFileListStore.currentVideoFileLanguage', context: context);

  @override
  String get currentVideoFileLanguage {
    _$currentVideoFileLanguageAtom.reportRead();
    return super.currentVideoFileLanguage;
  }

  @override
  set currentVideoFileLanguage(String value) {
    _$currentVideoFileLanguageAtom
        .reportWrite(value, super.currentVideoFileLanguage, () {
      super.currentVideoFileLanguage = value;
    });
  }

  late final _$videoIntroAtom =
      Atom(name: '_VideoFileListStore.videoIntro', context: context);

  @override
  String get videoIntro {
    _$videoIntroAtom.reportRead();
    return super.videoIntro;
  }

  @override
  set videoIntro(String value) {
    _$videoIntroAtom.reportWrite(value, super.videoIntro, () {
      super.videoIntro = value;
    });
  }

  late final _$_VideoFileListStoreActionController =
      ActionController(name: '_VideoFileListStore', context: context);

  @override
  void updateVideoFileList(List<VideoFileData> newVideoFileList) {
    final _$actionInfo = _$_VideoFileListStoreActionController.startAction(
        name: '_VideoFileListStore.updateVideoFileList');
    try {
      return super.updateVideoFileList(newVideoFileList);
    } finally {
      _$_VideoFileListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateLoading(bool newLoading) {
    final _$actionInfo = _$_VideoFileListStoreActionController.startAction(
        name: '_VideoFileListStore.updateLoading');
    try {
      return super.updateLoading(newLoading);
    } finally {
      _$_VideoFileListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateProgress(double newProgress) {
    final _$actionInfo = _$_VideoFileListStoreActionController.startAction(
        name: '_VideoFileListStore.updateProgress');
    try {
      return super.updateProgress(newProgress);
    } finally {
      _$_VideoFileListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateIsAvailable(bool newAvailable) {
    final _$actionInfo = _$_VideoFileListStoreActionController.startAction(
        name: '_VideoFileListStore.updateIsAvailable');
    try {
      return super.updateIsAvailable(newAvailable);
    } finally {
      _$_VideoFileListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateIsFree(bool newFree) {
    final _$actionInfo = _$_VideoFileListStoreActionController.startAction(
        name: '_VideoFileListStore.updateIsFree');
    try {
      return super.updateIsFree(newFree);
    } finally {
      _$_VideoFileListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateCurrentVideoFileLanguage(String newLanguage) {
    final _$actionInfo = _$_VideoFileListStoreActionController.startAction(
        name: '_VideoFileListStore.updateCurrentVideoFileLanguage');
    try {
      return super.updateCurrentVideoFileLanguage(newLanguage);
    } finally {
      _$_VideoFileListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateVideoIntro(String newIntro) {
    final _$actionInfo = _$_VideoFileListStoreActionController.startAction(
        name: '_VideoFileListStore.updateVideoIntro');
    try {
      return super.updateVideoIntro(newIntro);
    } finally {
      _$_VideoFileListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
videoFileDataList: ${videoFileDataList},
isLoading: ${isLoading},
progress: ${progress},
isAvailable: ${isAvailable},
isFree: ${isFree},
currentVideoFileLanguage: ${currentVideoFileLanguage},
videoIntro: ${videoIntro}
    ''';
  }
}
