import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vid_web/data/support_language_data.dart';

class LanguageManager {

  /// 初始语言设置
  static const defaultLanguageCode = "all";

  /// 资源的支持的语言类型
  static List<SupportLanguageData> supportLanguage = [
    SupportLanguageData(languageCode: defaultLanguageCode, languageName: tr('all'), currentLanguageCode: defaultLanguageCode),
    SupportLanguageData(languageCode: "en-US", languageName: tr('english'), currentLanguageCode: defaultLanguageCode),
    SupportLanguageData(languageCode: "ja-JP", languageName: tr('japanese'), currentLanguageCode: defaultLanguageCode),
    SupportLanguageData(languageCode: "th-TH", languageName: tr('thai'), currentLanguageCode: defaultLanguageCode),
    SupportLanguageData(languageCode: "ko-KR", languageName: tr('korean'), currentLanguageCode: defaultLanguageCode),
    SupportLanguageData(languageCode: "zh-CN", languageName: tr('chinese'), currentLanguageCode: defaultLanguageCode),
  ];

  static String getCountryFromCode(String localeCode) {
    switch (localeCode) {
      case "en-US":
        return tr('us');
      case "ar-AE":
        return tr('arab');
      case "de-DE":
        return tr('de');
      case "en-CA":
        return tr('ca');
      case "en-IN":
        return tr('in');
      case "en-PH":
        return tr('ph');
      case "es-ES":
        return tr('es');
      case "es-VE":
        return tr('ve');
      case "fi-FI":
        return tr('fi');
      case "fr-FR":
        return tr('fr');
      case "id-ID":
        return tr('id');
      case "it-IT":
        return tr('it');
      case "ja-JP":
        return tr('jp');
      case "kk-KZ":
        return tr('kz');
      case "ko-KR":
        return tr('kr');
      case "ms-MY":
        return tr('my');
      case "nb-NO":
        return tr('no');
      case "nl-NL":
        return tr('nl');
      case "pt-PT":
        return tr('pt');
      case "ru-RU":
        return tr('ru');
      case "ta-IN":
        return tr('in');
      case "th-TH":
        return tr('th');
      case "tr-TR":
        return tr('tr');
      case "uk-UA":
        return tr('ua');
      case "ur-PK":
        return tr('pk');
      case "vi-VN":
        return tr('vn');
      case "zh-CN":
        return tr('cn');
      case "zh-HK":
        return tr('hk');
      case "zh-TW":
        return tr('tw');
      default:
        return tr('us');
    }
  }

  /// 将语言代码映射成国家
  static String getCountryLanguageFromCode(String localeCode) {
    switch (localeCode) {
      case "en-US":
        return tr('english');
      case "ar-AE":
        return tr('arabic');
      case "de-DE":
        return tr('german');
      case "en-CA":
        return tr('canada');
      case "en-IN":
        return tr('indian');
      case "en-PH":
        return tr('philippines');
      case "es-ES":
        return tr('spanish');
      case "es-VE":
        return tr('venezuela');
      case "fi-FI":
        return tr('finnish');
      case "fr-FR":
        return tr('french');
      case "id-ID":
        return tr('indonesian');
      case "it-IT":
        return tr('italian');
      case "ja-JP":
        return tr('japanese');
      case "kk-KZ":
        return tr('kazakh');
      case "ko-KR":
        return tr('korean');
      case "ms-MY":
        return tr('malay');
      case "nb-NO":
        return tr('norwegian');
      case "nl-NL":
        return tr('dutch');
      case "pt-PT":
        return tr('portuguese');
      case "ru-RU":
        return tr('russian');
      case "ta-IN":
        return tr('tamil');
      case "th-TH":
        return tr('thai');
      case "tr-TR":
        return tr('turkish');
      case "uk-UA":
        return tr('ukrainian');
      case "ur-PK":
        return tr('pakistan');
      case "vi-VN":
        return tr('vietnamese');
      case "zh-CN":
        return tr('simplified chinese');
      case "zh-HK":
        return tr('chinese hong kong');
      case "zh-TW":
        return tr('chinese taiwan');
      default:
        return tr('english');
    }
  }

  static Locale codeToLocale(String localeCode) {
    switch (localeCode) {
      case "en_US":
        return const Locale('en', 'US');
      case "ar_AE":
        return const Locale('ar', 'AE');
      case "de_DE":
        return const Locale('de', 'DE');
      case "en_CA":
        return const Locale('en', 'CA');
      case "en_IN":
        return const Locale('en', 'IN');
      case "en_PH":
        return const Locale('en', 'PH');
      case "es_ES":
        return const Locale('es', 'ES');
      case "es_VE":
        return const Locale('es', 'VE');
      case "fi_FI":
        return const Locale('fi', 'FI');
      case "fr_FR":
        return const Locale('fr', 'FR');
      case "id_ID":
        return const Locale('id', 'ID');
      case "it_IT":
        return const Locale('it', 'IT');
      case "ja_JP":
        return const Locale('ja', 'JP');
      case "kk_KZ":
        return const Locale('kk', 'KZ');
      case "ko_KR":
        return const Locale('ko', 'KR');
      case "ms_MY":
        return const Locale('ms', 'MY');
      case "nb_NO":
        return const Locale('nb', 'NO');
      case "nl_NL":
        return const Locale('nl', 'NL');
      case "pt_PT":
        return const Locale('pt', 'PT');
      case "ru_RU":
        return const Locale('ru', 'RU');
      case "ta_IN":
        return const Locale('ta', 'IN');
      case "th_TH":
        return const Locale('th', 'TH');
      case "tr_TR":
        return const Locale('tr', 'TR');
      case "uk_UA":
        return const Locale('uk', 'UA');
      case "ur_PK":
        return const Locale('ur', 'PK');
      case "vi_VN":
        return const Locale('vi', 'VN');
      case "zh_CN":
        return const Locale('zh', 'CN');
      case "zh_HK":
        return const Locale('zh', 'HK');
      case "zh_TW":
        return const Locale('zh', 'TW');
      default:
        return const Locale('en', 'US');
    }
  }

  /// 获取当前系统语言
  static String getSystemLanguageCode(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    String languageCode = currentLocale.languageCode; // 语言代码
    String countryCode = currentLocale.countryCode ?? ''; // 国家代码（可选）
    if (countryCode.isNotEmpty) {
      return "${languageCode}_$countryCode";
    } else {
      return languageCode;
    }
  }

  // 获取当前系统语言
  static String getLocaleTag(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    String languageCode = currentLocale.languageCode; // 语言代码
    String countryCode = currentLocale.countryCode ?? ''; // 国家代码（可选）
    if (countryCode.isNotEmpty) {
      return "${languageCode}_$countryCode";
    } else {
      return languageCode;
    }
  }
}
