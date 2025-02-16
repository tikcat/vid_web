import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:vid_web/util/my_logger.dart';

class GoogleDriveService {
  late drive.DriveApi _driveApi;

  Future<drive.DriveApi> getDriveApi(GoogleSignInAccount googleSignInAccount) async {
    // 使用 Google Sign-In 获取访问令牌
    final googleAuth = await googleSignInAccount.authentication;
    final credentials = auth.AccessCredentials(
      auth.AccessToken('Bearer', googleAuth.accessToken!, DateTime.now().add(const Duration(hours: 1)).toUtc()),
      null,
      ['https://www.googleapis.com/auth/drive.readonly'],
    );
    final baseClient = http.Client();
    final authClient = auth.authenticatedClient(baseClient, credentials);

    _driveApi = drive.DriveApi(authClient);
    return _driveApi;
  }

  Future<List<drive.File>> listFiles(GoogleSignInAccount googleSignInAccount) async {
    final driveApi = await getDriveApi(googleSignInAccount);
    final fileListResponse = await driveApi.files.list();
    final files = fileListResponse.files ?? [];
    return files;
  }

  /// 查找所有的文件夹
  Future<List<drive.File>> listFolders(GoogleSignInAccount googleSignInAccount) async {
    final driveApi = await getDriveApi(googleSignInAccount);
    final fileListResponse = await driveApi.files.list(
      q: "mimeType='application/vnd.google-apps.folder'",
      $fields: "files(id, name, mimeType)",
    );
    final folders = fileListResponse.files ?? [];
    return folders.where((file) => file.mimeType == 'application/vnd.google-apps.folder').toList();
  }

  /// 根据文件夹名称查找文件夹
  Future<List<drive.File>> findFolderByName(GoogleSignInAccount googleSignInAccount, String folderName) async {
    final driveApi = await getDriveApi(googleSignInAccount);
    final query = "mimeType='application/vnd.google-apps.folder' and name='$folderName'";
    final fileListResponse = await driveApi.files.list(
      q: query,
      $fields: "files(id, name, mimeType)",
    );
    final folders = fileListResponse.files ?? [];
    return folders.where((file) => file.mimeType == 'application/vnd.google-apps.folder' && file.name == folderName).toList();
  }

  /// 根据文件夹名称查找文件夹ID
  Future<String?> findFolderIdByName(GoogleSignInAccount googleSignInAccount, String folderName) async {
    final driveApi = await getDriveApi(googleSignInAccount);
    final query = "name = '$folderName' and mimeType = 'application/vnd.google-apps.folder'";
    final fileListResponse = await driveApi.files.list(q: query, spaces: 'drive');
    final folders = fileListResponse.files ?? [];

    if (folders.isNotEmpty) {
      return folders.first.id;
    }
    return null;
  }

  /// 按照指定的文件名称查询文件
  Future<drive.File?> findFileByNameInFolder(GoogleSignInAccount googleSignInAccount, {required String folderName, required String fileName}) async {
    final folderId = await findFolderIdByName(googleSignInAccount, folderName);
    if (folderId != null) {
      final List<drive.File> files = await getAllFilesInFolder(googleSignInAccount, folderId);
      if (files.isNotEmpty) {
        for (var file in files) {
          mLogger.d("文件的名称 fileName:${file.name} fileName:$fileName");
          if (file.name?.replaceAll(" ", "") == fileName.replaceAll(" ", "")) {
            return file;
          }
        }
      }
    }
    return null;
  }

  /// 获取文件夹下的所有文件，使用分页机制
  Future<List<drive.File>> getAllFilesInFolder(
    GoogleSignInAccount googleSignInAccount,
    String folderId,
  ) async {
    final driveApi = await getDriveApi(googleSignInAccount);
    List<drive.File> allFiles = [];
    String? pageToken;

    do {
      final fileList = await driveApi.files.list(
        q: "'$folderId' in parents",
        pageToken: pageToken,
        orderBy: 'name', // 按名称排序
        $fields: 'files(id, name, mimeType, webContentLink, webViewLink)', // 获取文件的 ID 和名称
      );

      // 添加当前页的文件到文件列表
      if (fileList.files != null) {
        allFiles.addAll(fileList.files!);
      }

      pageToken = fileList.nextPageToken; // 获取下一页的 token
    } while (pageToken != null); // 如果还有更多文件，则继续获取

    // 对文件列表按照文件名的数字部分进行排序
    allFiles.sort((a, b) {
      final numA = _extractNumberFromFileName(a.name);
      final numB = _extractNumberFromFileName(b.name);
      return numA.compareTo(numB); // 比较文件名中的数字部分
    });

    return allFiles; // 返回所有文件
  }

// 从文件名中提取数字部分
  int _extractNumberFromFileName(String? fileName) {
    final regex = RegExp(r'(\d+)'); // 正则匹配数字部分
    final match = regex.firstMatch(fileName ?? '')?.group(0);
    return int.tryParse(match ?? '0') ?? 0; // 提取数字并返回
  }

  Future<List<drive.File>> listFilesInFolder(GoogleSignInAccount googleSignInAccount, String folderId) async {
    final driveApi = await getDriveApi(googleSignInAccount);
    final query = "'$folderId' in parents";
    final fileListResponse = await driveApi.files.list(
      q: query,
      $fields: "files(id, name, mimeType, webContentLink, webViewLink)",
    );
    final files = fileListResponse.files ?? [];
    return files;
  }

  /// 根据文件名查找文件夹里边的文件
  Future<List<drive.File>> listFilesInNamedFolder(GoogleSignInAccount googleSignInAccount, String folderName) async {
    final folderId = await findFolderIdByName(googleSignInAccount, folderName);
    if (folderId != null) {
      return await listFilesInFolder(googleSignInAccount, folderId);
    }
    return [];
  }

  /// 根据文件名称查找获取文件夹下的所有文件
  Future<List<drive.File>> getAllFilesInNamedFolder(GoogleSignInAccount googleSignInAccount, String folderName) async {
    final folderId = await findFolderIdByName(googleSignInAccount, folderName);
    if (folderId != null) {
      return await getAllFilesInFolder(googleSignInAccount, folderId);
    }
    return [];
  }

  Future<drive.File> getFileDetails(GoogleSignInAccount googleSignInAccount, String fileId) async {
    final driveApi = await getDriveApi(googleSignInAccount);
    final file = await driveApi.files.get(fileId, $fields: "id,name,mimeType,webContentLink,webViewLink");
    return file as drive.File;
  }

  String? getPlayableLink(drive.File file) {
    if (file.webContentLink != null) {
      // return file.webContentLink!.replaceAll('&export=download', '');
      return file.webContentLink!;
    } else if (file.webViewLink != null) {
      final fileId = file.id;
      if (fileId != null) {
        return 'https://drive.google.com/uc?id=$fileId&export=download';
      }
    }
    if (file.mimeType?.isNotEmpty == true) {
      if (file.mimeType!.startsWith('video/')) {
        if (file.id?.isNotEmpty == true) {
          return 'https://drive.google.com/uc?id=${file.id}&export=download';
        }
      }
    }
    return null;
  }

  String? getDriveImageUrl(drive.File file) {
    if (file.mimeType?.isNotEmpty == true) {
      if (file.mimeType!.startsWith('image/')) {
        return "https://drive.google.com/uc?id=${file.id}&export=download";
      }
    }
    return null;
  }
}
