import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vid_web/constant/data_callback.dart';
import 'package:vid_web/enum/home_list_block.dart';
import 'package:vid_web/manager/language_manager.dart';
import 'package:vid_web/util/my_logger.dart';

class FireStoreManager {
  static String getDocumentId({required String documentName}) {
    return "$documentName-123567";
  }

  /// 登录验证账户，获取数据库的操作权限
  static Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      mLogger.e('Error during sign-in: $e');
      return null;
    }
  }

  /// 判断集合是否存在
  static Future<bool> checkCollectionExists({required String rootCollectionName, required String childCollectionName}) async {
    try {
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      // 2. 创建第一个文档 'document1'，并在其下创建子集合 'subCollection1'
      final String documentId = getDocumentId(documentName: childCollectionName);
      final DocumentReference documentRef = rootCollectionRef.doc(documentId);
      final document = await documentRef.get();
      return document.exists;

      // final documentId = getDocumentId(documentName: collectionName);
      // final document = await FirebaseFirestore.instance.collection(collectionName).doc(documentId).get();
      // // 如果集合中有文档，则集合存在
      // return document.exists;
    } catch (e) {
      mLogger.e("发生错误: $e");
      return false; // 如果查询失败，认为集合不存在
    }
  }

  /// 根据指定文档的名称，从集合中查询文档存不存在
  static Future<bool> checkDocumentExistsByName({required String collectionName, required String childCollectionName}) async {
    try {
      // 获取父文档的引用
      final String documentId = getDocumentId(documentName: collectionName);
      var docRef = FirebaseFirestore.instance.collection(collectionName).doc(documentId);
      // 获取该文档的子集合
      var subCollectionSnapshot = await docRef.collection(childCollectionName).get();
      // 如果子集合中有文档，则认为子集合存在
      return subCollectionSnapshot.docs.isNotEmpty;
    } catch (e) {
      mLogger.e("检查文档失败: $e");
      return false;
    }
  }

  static Future<void> createCollectionAndAddDocument({
    required String rootCollectionName,
    required String childCollectionName,
    Map<String, dynamic>? childCollectionData,
    bool isAvailable = false,
  }) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    // 1. 创建根集合 'rootCollection'
    final CollectionReference rootCollectionRef = fireStore.collection(rootCollectionName);
    // 2. 创建第一个文档 'document1'，并在其下创建子集合 'subCollection1'
    final String documentId = getDocumentId(documentName: childCollectionName);
    final DocumentReference documentRef = rootCollectionRef.doc(documentId);
    await documentRef.set({
      'sub_collection_name': documentId,
      'created_at': FieldValue.serverTimestamp(),
      'isAvailable': isAvailable,
    });
    final CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
    await subCollectionRef.add(childCollectionData);
  }

  static Future<bool> registerUser({
    required String rootCollectionName,
    required String childCollectionName,
    Map<String, dynamic>? childCollectionData,
  }) async {
    try {
      final FirebaseFirestore fireStore = FirebaseFirestore.instance;
      final CollectionReference rootCollectionRef = fireStore.collection(rootCollectionName);
      final DocumentReference documentRef = rootCollectionRef.doc(childCollectionName);
      await documentRef.set({
        'sub_collection_name': childCollectionName,
        'created_at': FieldValue.serverTimestamp(),
      });
      final CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
      await subCollectionRef.add(childCollectionData);
      return true;
    } catch (e) {
      mLogger.e("注册用户出错：$e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> queryUserByGoogleId({required String rootCollectionName, required String googleId}) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final CollectionReference rootCollectionRef = fireStore.collection(rootCollectionName);
    final QuerySnapshot querySnapshot = await rootCollectionRef.get();
    for (var doc in querySnapshot.docs) {
      mLogger.d("数据 id:${doc.id} - data:${doc.data()}");
      final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
      CollectionReference subCollectionRef = documentRef.collection(doc.id);
      // 获取子集合的数据
      final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
      if (subCollectionSnapshot.docs.isNotEmpty) {
        for (var subDoc in subCollectionSnapshot.docs) {
          final data = subDoc.data() as Map<String, dynamic>;
          if (data['googleId'] == googleId) {
            mLogger.d("找到用户数据:${subDoc.id}  data:${subDoc.data()}");
            return data;
          }
        }
      }
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>?> queryHistory({
    required String rootCollectionName,
    required String userId,
    required int limit,
    DocumentSnapshot? lastDocument,
    PageLoadCallback? pageLoadCallback,
  }) async {
    // final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    // final CollectionReference rootCollectionRef = fireStore.collection(rootCollectionName);
    // final QuerySnapshot querySnapshot = await rootCollectionRef.get();
    // for (var doc in querySnapshot.docs) {
    //   mLogger.d("数据 id:${doc.id} - data:${doc.data()} - userId:$userId");
    //   if (doc.id == userId) {
    //     final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
    //     CollectionReference subCollectionRef = documentRef.collection(doc.id);
    //
    //     /// 修改
    //     QuerySnapshot subCollectionSnapshot;
    //     if (lastDocument == null) {
    //       subCollectionSnapshot = await subCollectionRef.orderBy('timestamp').limit(limit).get();
    //     } else {
    //       subCollectionSnapshot = await subCollectionRef.orderBy('timestamp').startAfterDocument(lastDocument).limit(limit).get();
    //     }
    //
    //     // 获取子集合的数据
    //     // final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
    //     if (subCollectionSnapshot.docs.isNotEmpty) {
    //       final List<Map<String, dynamic>> historyDataList = [];
    //       for (var subDoc in subCollectionSnapshot.docs) {
    //         final data = subDoc.data() as Map<String, dynamic>;
    //         historyDataList.add(data);
    //       }
    //       mLogger.d("查询的历史记录为:$historyDataList");
    //       return historyDataList;
    //     }
    //   }
    // }

    try {
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      QuerySnapshot querySnapshot;
      if (lastDocument == null) {
        querySnapshot = await rootCollectionRef.orderBy('created_at').limit(limit).get();
      } else {
        querySnapshot = await rootCollectionRef.orderBy('created_at').startAfterDocument(lastDocument).limit(limit).get();
      }
      final List<Map<String, dynamic>> historyDataList = [];
      for (var doc in querySnapshot.docs) {
        mLogger.d("数据 id:${doc.id} - data:${doc.data()} - userId:$userId");
        if (doc.id == userId) {
          final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
          CollectionReference subCollectionRef = documentRef.collection(doc.id);
          // 获取子集合的数据
          final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
          if (subCollectionSnapshot.docs.isNotEmpty) {
            for (var subDoc in subCollectionSnapshot.docs) {
              final data = subDoc.data() as Map<String, dynamic>;
              historyDataList.add(data);
            }
          }
        }
      }
      return historyDataList;
    } catch (e) {
      mLogger.e("获取历史记录出错：$e");
      return null;
    }

    // List<Map<String, dynamic>> targetDataList = [];
    // final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
    // QuerySnapshot querySnapshot;
    // if (lastDocument == null) {
    //   querySnapshot = await rootCollectionRef.orderBy('created_at').limit(limit).get();
    // } else {
    //   querySnapshot = await rootCollectionRef.orderBy('created_at').startAfterDocument(lastDocument).limit(limit).get();
    // }
    //   if (querySnapshot.docs.isNotEmpty) {
    //     pageLoadCallback?.call(querySnapshot.docs.last);
    //     for (var doc in querySnapshot.docs) {
    //       if (doc.id == userId) {
    //         final docData = doc.data() as Map<String, dynamic>;
    //         final isAvailable = docData['isAvailable'];
    //         mLogger.d('获取子集合 Document ID: ${doc.id}  数量:${querySnapshot.docs.length}  是否已上架:$isAvailable');
    //         if (isAvailable) {
    //           final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
    //           final childCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
    //           CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
    //
    //           final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
    //           if (subCollectionSnapshot.docs.isNotEmpty) {
    //             final Map<String, dynamic> documents = subCollectionSnapshot.docs.first.data() as Map<String, dynamic>;
    //             targetDataList.add(documents);
    //           }
    //         }
    //       }
    //     }
    //   }
  }

  static Future<Map<String, dynamic>?> queryVideoFileByVideoId({
    required String rootCollectionName,
    required String childCollectionName,
    required String videoId,
  }) async {
    try {
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      // 查询集合中的所有文档
      final QuerySnapshot querySnapshot = await rootCollectionRef.get();
      // 遍历所有文档并打印每个文档的数据
      for (var doc in querySnapshot.docs) {
        mLogger.d('Document ID: ${doc.id}');
        mLogger.d('Document Data: ${doc.data()}');
        final docData = doc.data() as Map<String, dynamic>;
        final isAvailable = docData['isAvailable'];
        if (isAvailable) {
          final currentCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
          if (currentCollectionName == childCollectionName) {
            final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
            final CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
            // 获取子集合的数据
            final QuerySnapshot subCollectionSnapshot = await subCollectionRef.where('videoId', isEqualTo: videoId).get();
            if (subCollectionSnapshot.docs.isNotEmpty) {
              final videoData = subCollectionSnapshot.docs.first.data() as Map<String, dynamic>;
              mLogger.d("指定查询的视频数据:$videoData");
              return videoData;
            }
          }
        }
      }
    } catch (e) {
      mLogger.e("查询视频出错：$e");
      return null;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> queryHistoryByVideoId({required String rootCollectionName, required String userId, required String videoId}) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final CollectionReference rootCollectionRef = fireStore.collection(rootCollectionName);
    final QuerySnapshot querySnapshot = await rootCollectionRef.get();
    for (var doc in querySnapshot.docs) {
      mLogger.d("数据 id:${doc.id} - data:${doc.data()} - userId:$userId");
      if (doc.id == userId) {
        final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
        CollectionReference subCollectionRef = documentRef.collection(doc.id);
        final QuerySnapshot subCollectionSnapshot = await subCollectionRef.where('videoId', isEqualTo: videoId).get();
        if (subCollectionSnapshot.docs.isNotEmpty) {
          final historyData = subCollectionSnapshot.docs.first.data() as Map<String, dynamic>;
          mLogger.d("指定查询的历史记录:$historyData");
          return historyData;
        } else {
          return null;
        }
      }
    }
    return null;
  }

  static Future<bool> createWatchHistory({
    required String rootCollectionName,
    required String userId,
    required String playName,
    required String videoUrl,
    Map<String, dynamic>? historyData,
  }) async {
    try {
      final FirebaseFirestore fireStore = FirebaseFirestore.instance;
      // 1. 创建根集合 'rootCollection'
      final CollectionReference rootCollectionRef = fireStore.collection(rootCollectionName);
      // 2. 创建第一个文档 'document1'，并在其下创建子集合 'subCollection1'
      final DocumentReference documentRef = rootCollectionRef.doc(userId);
      await documentRef.set({
        'sub_collection_name': userId,
        'created_at': FieldValue.serverTimestamp(),
        'isAvailable': true,
      });
      final CollectionReference subCollectionRef = documentRef.collection(userId);
      final QuerySnapshot subCollectionSnapshot = await subCollectionRef.where('playName', isEqualTo: playName).get();
      if (subCollectionSnapshot.docs.isNotEmpty) {
        // 更新
        for (var subDoc in subCollectionSnapshot.docs) {
          await subDoc.reference.update({'videoId': videoUrl});
        }
      } else {
        // 直接创建
        await subCollectionRef.add(historyData);
      }
      return true;
    } catch (e) {
      mLogger.e("新建观看历史记录视频错误：$e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> queryUserByAppleId({required String rootCollectionName, required String appleId}) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final CollectionReference rootCollectionRef = fireStore.collection(rootCollectionName);
    final QuerySnapshot querySnapshot = await rootCollectionRef.get();
    for (var doc in querySnapshot.docs) {
      mLogger.d("数据 id:${doc.id} - data:${doc.data()}");
      final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
      CollectionReference subCollectionRef = documentRef.collection(doc.id);
      // 获取子集合的数据
      final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
      if (subCollectionSnapshot.docs.isNotEmpty) {
        for (var subDoc in subCollectionSnapshot.docs) {
          final data = subDoc.data() as Map<String, dynamic>;
          if (data['appleId'] == appleId) {
            mLogger.d("找到用户数据:${subDoc.id}  data:${subDoc.data()}");
            return data;
          }
        }
      }
    }
    return null;
  }

  static Future<bool> uploadData({
    required String rootCollectionName,
    required String childCollectionName,
    Map<String, dynamic>? childCollectionData,
  }) async {
    try {
      final FirebaseFirestore fireStore = FirebaseFirestore.instance;
      // 1. 创建根集合 'rootCollection'
      final CollectionReference rootCollectionRef = fireStore.collection(rootCollectionName);
      // 2. 创建第一个文档 'document1'，并在其下创建子集合 'subCollection1'
      final String documentId = getDocumentId(documentName: childCollectionName);
      final DocumentReference documentRef = rootCollectionRef.doc(documentId);
      final CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
      await subCollectionRef.add(childCollectionData);
      return true;
    } catch (e) {
      mLogger.e("上传文件出错:e");
    }
    return false;
  }

  static Future<bool> deleteCollectionAndDocuments({required String rootCollectionName, required String childCollectionName}) async {
    try {
      // 获取 FireStore 实例
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      // 查询集合中的所有文档
      final QuerySnapshot querySnapshot = await rootCollectionRef.get();
      // 遍历所有文档并打印每个文档的数据
      for (var doc in querySnapshot.docs) {
        mLogger.d('Document ID: ${doc.id}');
        mLogger.d('Document Data: ${doc.data()}');
        final docData = doc.data() as Map<String, dynamic>;
        final isAvailable = docData['isAvailable'];
        if (isAvailable) {
          final currentCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
          if (currentCollectionName == childCollectionName) {
            final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
            CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
            // 获取子集合的数据
            final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
            if (subCollectionSnapshot.docs.isNotEmpty) {
              for (var subDoc in subCollectionSnapshot.docs) {
                mLogger.d("删除子集合元素:${subDoc.id}");
                subDoc.reference.delete();
              }
            }
            await documentRef.delete();
            doc.reference.delete();
            mLogger.d('删除父文档元素:${doc.id}');
            return true;
          }
        }
      }
    } catch (e) {
      mLogger.e("获取子集合出错:e");
    }
    return false;
  }

  /// 获取视频列表
  static Future<List<Map<String, dynamic>>?> getChildCollectionElement({required String rootCollectionName, required String childCollectionName}) async {
    try {
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      // 查询集合中的所有文档
      final QuerySnapshot querySnapshot = await rootCollectionRef.get();
      for (var doc in querySnapshot.docs) {
        final docData = doc.data() as Map<String, dynamic>;
        final isAvailable = docData['isAvailable'];
        if (isAvailable) {
          final docId = doc.id.substring(0, doc.id.lastIndexOf("-"));
          if (docId == childCollectionName) {
            final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
            final CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
            final QuerySnapshot childSnapshot = await subCollectionRef.orderBy('position').get();
            if (childSnapshot.docs.isNotEmpty) {
              List<Map<String, dynamic>> result = [];
              for (var doc in childSnapshot.docs) {
                result.add(doc.data() as Map<String, dynamic>);
              }
              return result;
            }
          }
        }
      }
      return null;
    } catch (e) {
      mLogger.e("获取视频列表的第一个文件失败:$e");
    }
    return null;
  }

  /// 随机获取集合中的10个元素
  static Future<List<Map<String, dynamic>>> getChildCollectionRandomElements({required String rootCollectionName}) async {
    final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
    // 查询集合中的所有文档
    final QuerySnapshot querySnapshot = await rootCollectionRef.get();
    if (querySnapshot.docs.isNotEmpty) {
      final List<Map<String, dynamic>> dataList = [];
      for (var doc in querySnapshot.docs) {
        mLogger.d('Document ID: ${doc.id}');
        mLogger.d('Document Data: ${doc.data()}');
        final docData = doc.data() as Map<String, dynamic>;
        final isAvailable = docData['isAvailable'];
        if (isAvailable) {
          final currentCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
          final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
          final CollectionReference subCollectionRef = documentRef.collection(currentCollectionName);
          // 获取子集合的数据
          final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
          if (subCollectionSnapshot.docs.isNotEmpty) {
            final Map<String, dynamic> firstElement = subCollectionSnapshot.docs.first.data() as Map<String, dynamic>;
            dataList.add(firstElement);
          }
        }
      }
      return dataList;
    }
    return [];
  }

  /// 获取视频列表的第一个视频
  static Future<Map<String, dynamic>?> getChildCollectionFirstElement({
    required String rootCollectionName,
    String languageCode = LanguageManager.defaultLanguageCode,
  }) async {
    // 获取 FireStore 实例
    try {
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      // 查询集合中的所有文档
      final QuerySnapshot querySnapshot = await rootCollectionRef.get();
      final DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      final docData = documentSnapshot.data() as Map<String, dynamic>;
      final isAvailable = docData['isAvailable'];
      if (isAvailable) {
        final DocumentReference documentRef = rootCollectionRef.doc(documentSnapshot.id);
        final childCollectionName = documentSnapshot.id.substring(0, documentSnapshot.id.lastIndexOf("-"));
        final CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
        final QuerySnapshot childSnapshot = await subCollectionRef.get();
        if (languageCode == LanguageManager.defaultLanguageCode) {
          return childSnapshot.docs.first.data() as Map<String, dynamic>;
        } else {
          for (var doc in childSnapshot.docs) {
            final subDocuments = doc.data() as Map<String, dynamic>;
            if (subDocuments['languageCode'] == languageCode) {
              return subDocuments;
            }
          }
        }
      } else {
        return null;
      }
    } catch (e) {
      mLogger.e("获取视频列表的第一个文件失败:$e");
    }
    return null;
  }

  /// 更新所有剧集自身的免费状态（剧集纬度）
  static Future<bool> updateEpisodeIsFreeStatus({
    required String rootCollectionName,
    required String childCollectionName,
    required bool isFree,
  }) async {
    try {
      // 1. 获取 parentDocumentName 文档的引用
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      // 查询集合中的所有文档
      final QuerySnapshot querySnapshot = await rootCollectionRef.get();
      // 遍历所有文档并打印每个文档的数据
      for (var doc in querySnapshot.docs) {
        mLogger.d('Document ID: ${doc.id}');
        mLogger.d('Document Data: ${doc.data()}');
        final currentCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
        if (currentCollectionName == childCollectionName) {
          final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
          final CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
          // 获取子集合的数据
          final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
          if (subCollectionSnapshot.docs.isNotEmpty) {
            for (var subDoc in subCollectionSnapshot.docs) {
              await subDoc.reference.update({
                'isFree': isFree,
              });
            }
            return true;
          } else {
            return false;
          }
        }
      }
      return false;
    } catch (e) {
      mLogger.e("获取上架状态失败:${e.toString()}");
      return false;
    }
  }

  /// 查询剧集是否免费
  static Future<bool> videoIsFree({
    required String rootCollectionName,
    required String childCollectionName,
  }) async {
    try {
      // 1. 获取 parentDocumentName 文档的引用
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      // 查询集合中的所有文档
      final QuerySnapshot querySnapshot = await rootCollectionRef.get();
      // 遍历所有文档并打印每个文档的数据
      for (var doc in querySnapshot.docs) {
        mLogger.d('Document ID: ${doc.id}');
        mLogger.d('Document Data: ${doc.data()}');
        final currentCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
        if (currentCollectionName == childCollectionName) {
          final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
          final CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
          // 获取子集合的数据
          final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
          if (subCollectionSnapshot.docs.isNotEmpty) {
            final subDocData = subCollectionSnapshot.docs.first as Map<String, dynamic>;
            return subDocData['isFree'];
          } else {
            return false;
          }
        }
      }
      return false;
    } catch (e) {
      mLogger.e("获取上架状态失败:${e.toString()}");
      return false;
    }
  }

  /// 资源是否已经上传
  static Future<bool> sourceIsUpload({
    required String rootCollectionName,
    required String childCollectionName,
  }) async {
    try {
      // 1. 获取 parentDocumentName 文档的引用
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      // 查询集合中的所有文档
      final QuerySnapshot querySnapshot = await rootCollectionRef.get();
      // 遍历所有文档并打印每个文档的数据
      for (var doc in querySnapshot.docs) {
        mLogger.d('Document ID: ${doc.id}');
        mLogger.d('Document Data: ${doc.data()}');
        final currentCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
        if (currentCollectionName == childCollectionName) {
          final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
          final CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
          // 获取子集合的数据
          final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
          if (subCollectionSnapshot.docs.isNotEmpty) {
            final subDocData = subCollectionSnapshot.docs.first;
            return subDocData['isUploaded'];
          } else {
            return false;
          }
        }
      }
      return false;
    } catch (e) {
      mLogger.e("获取上架状态失败:${e.toString()}");
      return false;
    }
  }

  /// 删除指定子文档文档
  static Future<bool> deleteChildDocument({
    required String rootCollectionName,
    required String childCollectionName,
    required String childDocumentId,
  }) async {
    try {
      // 1. 获取 parentDocumentName 文档的引用
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      // 查询集合中的所有文档
      final QuerySnapshot querySnapshot = await rootCollectionRef.get();
      // 遍历所有文档并打印每个文档的数据
      for (var doc in querySnapshot.docs) {
        mLogger.d('Document ID: ${doc.id}');
        mLogger.d('Document Data: ${doc.data()}');
        final currentCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
        if (currentCollectionName == childCollectionName) {
          final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
          final CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
          final DocumentReference subDocRef = subCollectionRef.doc(childDocumentId);
          subDocRef.delete();
          return true;
        }
      }
      return false;
    } catch (e) {
      mLogger.e("获取上架状态失败:${e.toString()}");
      return false;
    }
  }

  /// 更新所有剧集自身的上架状态（剧集纬度）
  static Future<bool> updateEpisodeAvailableStatus({
    required String rootCollectionName,
    required bool isAvailable,
  }) async {
    try {
      // 1. 获取 parentDocumentName 文档的引用
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      // 查询集合中的所有文档
      final QuerySnapshot querySnapshot = await rootCollectionRef.get();
      // 遍历所有文档并打印每个文档的数据
      for (var doc in querySnapshot.docs) {
        mLogger.d('Document ID: ${doc.id}');
        mLogger.d('Document Data: ${doc.data()}');
        await doc.reference.update({
          'isAvailable': isAvailable,
        });
        // final currentCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
        // if (currentCollectionName == childCollectionName) {
        //   final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
        //   final CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
        //   // 获取子集合的数据
        //   final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
        //   if (subCollectionSnapshot.docs.isNotEmpty) {
        //     for (var subDoc in subCollectionSnapshot.docs) {
        //       await subDoc.reference.update({
        //         'isAvailable': isAvailable,
        //       });
        //     }
        //     return true;
        //   } else {
        //     return false;
        //   }
        // }
      }
      return true;
    } catch (e) {
      mLogger.e("获取上架状态失败:${e.toString()}");
      return false;
    }
  }

  /// 资源是否已经上架
  static Future<bool> sourceIsAvailable({
    required String rootCollectionName,
    required String childCollectionName,
  }) async {
    try {
      // 1. 获取 parentDocumentName 文档的引用
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      // 查询集合中的所有文档
      final QuerySnapshot querySnapshot = await rootCollectionRef.get();
      // 遍历所有文档并打印每个文档的数据
      for (var doc in querySnapshot.docs) {
        mLogger.d('Document ID: ${doc.id}');
        mLogger.d('Document Data: ${doc.data()}');
        final currentCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
        if (currentCollectionName == childCollectionName) {
          final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
          final CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
          // 获取子集合的数据
          final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
          if (subCollectionSnapshot.docs.isNotEmpty) {
            final subDocData = subCollectionSnapshot.docs.first as Map<String, dynamic>;
            return subDocData['isAvailable'];
          } else {
            return false;
          }
        }
      }
      return false;
    } catch (e) {
      mLogger.e("获取上架状态失败:${e.toString()}");
      return false;
    }
  }

  /// 获取文档子集合的数据
  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getDocumentCollections({
    required String rootCollectionName,
    required String childCollectionName,
  }) async {
    try {
      // 1. 获取 parentDocumentName 文档的引用
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      // 查询集合中的所有文档
      final QuerySnapshot querySnapshot = await rootCollectionRef.get();
      // 遍历所有文档并打印每个文档的数据
      for (var doc in querySnapshot.docs) {
        mLogger.d('Document ID: ${doc.id}');
        mLogger.d('Document Data: ${doc.data()}');
        final currentCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
        if (currentCollectionName == childCollectionName) {
          final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
          CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
          // 获取子集合的数据
          final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
          return subCollectionSnapshot.docs as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
        }
      }
      return null;
    } catch (e) {
      mLogger.e('获取所有文档数据失败: $e');
      return null;
    }
  }

  static Future<Map<String, List<Map<String, dynamic>>>> getHomeAllBlockData({
    required List<HomeListBlock> rootCollectionNames,
    required int limit,
    required String languageCode,
  }) async {
    Map<String, List<Map<String, dynamic>>> targetDataMap = {};
    try {
      for (final value in rootCollectionNames) {
            final rootCollectionName = value.collectionName;
            final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
            final QuerySnapshot querySnapshot = await rootCollectionRef.limit(limit).get();
            if (querySnapshot.docs.isNotEmpty) {
              List<Map<String, dynamic>> targetDataList = [];
              for (var doc in querySnapshot.docs) {
                final docData = doc.data() as Map<String, dynamic>;
                if (docData['isAvailable']) {
                  final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
                  final childCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
                  CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
                  final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
                  if (subCollectionSnapshot.docs.isNotEmpty) {
                    if (languageCode == LanguageManager.defaultLanguageCode) {
                      final Map<String, dynamic> documents = subCollectionSnapshot.docs.first.data() as Map<String, dynamic>;
                      targetDataList.add(documents);
                    } else {
                      final Map<String, dynamic> subDocuments = subCollectionSnapshot.docs.first.data() as Map<String, dynamic>;
                      if (subDocuments['languageCode'] == languageCode) {
                        targetDataList.add(subDocuments);
                      }
                    }
                  }
                }
              }
              targetDataMap[value.sourceType] = targetDataList;
            }
          }
    } catch (e) {
      mLogger.e(e);
    }
    return targetDataMap;
  }

  static Future<Map<String, dynamic>?> searchTargetDocument({
    required List<HomeListBlock> rootCollectionNames,
    required String playName,
  }) async {
    try {
      for (final rootCollectionName in rootCollectionNames) {
        final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName.collectionName);
        final QuerySnapshot querySnapshot = await rootCollectionRef.get();
        for (var doc in querySnapshot.docs) {
          final playDocId = doc.id;
          final remotePlayName = playDocId.substring(0, playDocId.lastIndexOf("-"));
          if (remotePlayName == playName) {
            final docData = doc.data() as Map<String, dynamic>;
            final isAvailable = docData['isAvailable'];
            if (isAvailable) {
              final DocumentReference documentRef = rootCollectionRef.doc(playDocId);
              CollectionReference subCollectionRef = documentRef.collection(remotePlayName);
              final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
              if (subCollectionSnapshot.docs.isNotEmpty) {
                final Map<String, dynamic> targetDocument = subCollectionSnapshot.docs.first.data() as Map<String, dynamic>;
                return targetDocument;
              }
            }
          }
        }
      }
    } catch (e) {
      mLogger.e("搜索视频失败:${e.toString()}");
    }
    return null;
  }

  static Future<Map<String, List<Map<String, dynamic>>>> getHomeAllChildCollections({required List<HomeListBlock> allHomeBlocklist}) async {
    Map<String, List<Map<String, dynamic>>> targetDataMap = {};
    try {
      final List<int> numbers = [1, 2, 4, 6];
      final Random random = Random();
      for (var block in allHomeBlocklist) {
        final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(block.collectionName);
        final int randomNumber = numbers[random.nextInt(numbers.length)];
        final QuerySnapshot querySnapshot = await rootCollectionRef.limit(randomNumber).get();
        final List<Map<String, dynamic>> targetDataList = [];
        for (var doc in querySnapshot.docs) {
          final docData = doc.data() as Map<String, dynamic>;
          final isAvailable = docData['isAvailable'];
          if (isAvailable) {
            final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
            final childCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
            CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
            final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
            if (subCollectionSnapshot.docs.isNotEmpty) {
              final Map<String, dynamic> documents = subCollectionSnapshot.docs.first.data() as Map<String, dynamic>;
              targetDataList.add(documents);
            }
          }
        }
        targetDataMap[block.sourceType] = targetDataList;
      }
      return targetDataMap;
    } catch (e) {
      mLogger.e("getHomeAllChildCollections 查询数据出错:$e");
      return targetDataMap;
    }
  }

  static Future<List<Map<String, dynamic>>> getChildCollections({
    required String rootCollectionName,
    required int limit,
    required String languageCode,
  }) async {
    List<Map<String, dynamic>> targetDataList = [];
    try {
      // 获取 FireStore 实例
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      // 查询集合中的所有文档
      final QuerySnapshot querySnapshot = await rootCollectionRef.limit(limit).get();
      // 遍历所有文档并打印每个文档的数据
      for (var doc in querySnapshot.docs) {
        final docData = doc.data() as Map<String, dynamic>;
        final isAvailable = docData['isAvailable'];
        if (isAvailable) {
          final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
          final childCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
          CollectionReference subCollectionRef = documentRef.collection(childCollectionName);
          try {
            // 获取子集合的数据
            final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
            if (subCollectionSnapshot.docs.isNotEmpty) {
              if (languageCode == LanguageManager.defaultLanguageCode) {
                final Map<String, dynamic> documents = subCollectionSnapshot.docs.first.data() as Map<String, dynamic>;
                targetDataList.add(documents);
              } else {
                final Map<String, dynamic> subDocuments = subCollectionSnapshot.docs.first.data() as Map<String, dynamic>;
                if (subDocuments['languageCode'] == languageCode) {
                  targetDataList.add(subDocuments);
                }
              }
            }
          } catch (e) {
            mLogger.e('Error fetching subCollection data: $e');
          }
        }
      }
    } catch (e) {
      mLogger.e("获取子集合出错:$e");
    }
    mLogger.d("获取子集合数据:$targetDataList");
    return targetDataList;
  }

  static Future<List<Map<String, dynamic>>> getShortPageCollections({
    required String rootCollectionName,
    required int limit,
    DocumentSnapshot? lastDocument,
    PageLoadCallback? pageLoadCallback,
  }) async {
    List<Map<String, dynamic>> targetDataList = [];
    try {
      // 获取 FireStore 实例
      final CollectionReference rootCollectionRef = FirebaseFirestore.instance.collection(rootCollectionName);
      QuerySnapshot querySnapshot;
      if (lastDocument == null) {
        querySnapshot = await rootCollectionRef.orderBy('created_at').limit(limit).get();
      } else {
        querySnapshot = await rootCollectionRef.orderBy('created_at').startAfterDocument(lastDocument).limit(limit).get();
      }
      if (querySnapshot.docs.isNotEmpty) {
        pageLoadCallback?.call(querySnapshot.docs.last);
        for (var doc in querySnapshot.docs) {
          final docData = doc.data() as Map<String, dynamic>;
          final isAvailable = docData['isAvailable'];
          mLogger.d('获取子集合 Document ID: ${doc.id}  数量:${querySnapshot.docs.length}  是否已上架:$isAvailable');
          if (isAvailable) {
            final DocumentReference documentRef = rootCollectionRef.doc(doc.id);
            final childCollectionName = doc.id.substring(0, doc.id.lastIndexOf("-"));
            CollectionReference subCollectionRef = documentRef.collection(childCollectionName);

            final QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
            if (subCollectionSnapshot.docs.isNotEmpty) {
              final Map<String, dynamic> documents = subCollectionSnapshot.docs.first.data() as Map<String, dynamic>;
              targetDataList.add(documents);
            }
          }
        }
      }
    } catch (e) {
      mLogger.e("获取子集合出错:$e");
    }
    mLogger.d("获取子集合数据:$targetDataList");
    return targetDataList;
  }
}
