import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:vid_web/data/video_file_data.dart';
import 'package:vid_web/enum/home_list_block.dart';
import 'package:vid_web/manager/manage_users.dart';

typedef DataFileCallback = void Function(drive.File file);

typedef VideoListFileCallback = void Function(List<drive.File> driveList);

typedef LoginFirebaseCallback = void Function(User? user);

typedef VideoFileItemClickCallback = void Function(VideoFileData? videoFileData);

typedef CurrentGoogleUserNameCallback = void Function(ManageUser manageUser);

typedef LogoutCallback = void Function();

typedef RemoveCallback = void Function(ManageUser manageUser);

typedef HomeTypeCallback = void Function(HomeListBlock homeListBlock);

typedef PageLoadCallback = void Function(DocumentSnapshot? lastDocument);

